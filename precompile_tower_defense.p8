pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
function choose_tower(id)
  selected_menu_tower_id, get_active_menu().enable, shop_enable = id
end
function display_tower_info(tower_id, position, text_color)
  local position_offset, tower_details = position + Vec:new(-1, -31), global_table_data.tower_templates[tower_id]
  local texts = {
    {text = tower_details.name, color = text_color}, 
    {text = tower_details.prefix..": "..tower_details.damage, color = {7, 0}},
    {text = "cost: "..tower_details.cost, color = {(coins >= tower_details.cost) and 3 or 8, 0}}
  }
  local longest_str_len = longest_menu_str(texts)*5+4
  tower_stats_background_rect = BorderRect:new(position_offset, Vec:new(longest_str_len + 20,27), 8, 5, 2)
  BorderRect.draw(tower_stats_background_rect)
  for i, data in pairs(texts) do 
    print_with_outline(data.text, combine_and_unpack({Vec.unpack(position_offset + Vec:new(4, i == 1 and 2 or 7*i))}, data.color))
  end
  spr(
    tower_details.icon_data, 
    combine_and_unpack(
      {Vec.unpack(tower_stats_background_rect.position + Vec:new(longest_str_len, 6))},
      {2, 2}
  ))
end
function display_tower_rotation(menu_pos, position)
  local tower_details, position_offset = global_table_data.tower_templates[selected_menu_tower_id], position + Vec:new(0, -28)
  tower_rotation_background_rect = BorderRect:new(position_offset, Vec:new(24, 24), 8, 5, 2)
  BorderRect.draw(tower_rotation_background_rect)
  local sprite_position = position_offset + Vec:new(4, 4)
  if tower_details.disable_icon_rotation then 
    spr(tower_details.icon_data, combine_and_unpack({Vec.unpack(sprite_position)},{2, 2}))
  else
    draw_sprite_rotated(global_table_data.tower_icon_background,
      position_offset, 24, parse_direction(direction)
    )
    draw_sprite_rotated(tower_details.icon_data, sprite_position, 16, parse_direction(direction))
  end
end
function rotate_clockwise()
  direction = Vec:new(-direction.y, direction.x)
end
function start_round()
  if (start_next_wave or #enemies ~= 0) return
  start_next_wave,enemies_active = true,true
  local wave_set_for_num = global_table_data.wave_set[cur_level] or "wave_data"
  max_waves = #global_table_data[wave_set_for_num]
  if (wave_round == max_waves and freeplay_rounds == 0) freeplay_rounds = wave_round
  if freeplay_rounds > 0 then
    freeplay_rounds += 1
    wave_round = max_waves
    wave_round -= flr(rnd(3))
  else
    wave_round = wave_round + 1
  end
  enemies_remaining, get_active_menu().enable, shop_enable = #global_table_data[wave_set_for_num][wave_round]
end
function get_active_menu()
  for menu in all(menus) do
    if (menu.enable) return menu
  end
end
function get_menu(name)
  for menu in all(menus) do
    if (menu.name == name) return menu
  end
end
function swap_menu_context(name)
  get_active_menu().enable, get_menu(name).enable = false, true
end
function longest_menu_str(data)
  local len = 0
  for str in all(data) do
    len = max(len, #str.text)
  end
  return len
end
function get_tower_data_for_menu()
  local menu_content = {}
  for i, tower_details in pairs(global_table_data.tower_templates) do
    add(menu_content, {
      text = tower_details.name,
      color = tower_details.text_color,
      callback = choose_tower, args = {i}
    })
  end
  return menu_content
end
function get_map_data_for_menu()
  local menu_content = {}
  for i, map_data in pairs(global_table_data.map_data) do
    add(menu_content, 
      {text = map_data.name, color = {7, 0}, callback = load_map, args = {i}}
    )
  end
  return menu_content
end
function parse_menu_content(content)
  if type(content) == "table" then 
    local cons = {}
    for con in all(content) do
      add(cons, {
        text = con.text,
        color = con.color or {7, 0},
        callback = _ENV[con.callback],
        args = con.args
      }) 
    end
    return cons
  end
  return _ENV[content]()
end
function toggle_mode()
  sfx(48)
  manifest_mode, sell = not manifest_mode
  sell_mode = not sell_mode
end
function swap_to_credits()
  game_state = "credits" 
end
function new_game()
  reset_game()
  game_state="map"
  swap_menu_context("map")
end
function load_map(map_id, wave, freeplay)
  pal()
  manifest_mode, auto_start_wave = true
  wave_round = wave or 0
  freeplay_rounds = freeplay or 0
  loaded_map, cur_level = map_id, map_id
  pathing = parse_path()
  for i=1, 3 do
    add(incoming_hint, Animator:new(global_table_data.animation_data.incoming_hint, true))
  end
  for y=0, 15 do 
    grid[y] = {}
    for x=0, 15 do 
      grid[y][x] = "empty"
      if (not check_tile_flag_at(Vec:new(x, y) + Vec:new(global_table_data.map_data[loaded_map].mget_shift), global_table_data.map_meta_data.non_path_flag_id)) grid[y][x] = "path" 
    end
  end
  music(global_table_data.music_data[cur_level] or 0)
  if wave_round == 0 and freeplay_rounds == 0 then 
    text_scroller.enable = true
    local text_place_holder = global_table_data.dialogue.dialogue_intros[cur_level]
    TextScroller.load(text_scroller, text_place_holder.text, text_place_holder.color)
  else
    load_wave_text()
  end
end
function save_game()
  local start_address = 0x5e00
  start_address = save_byte(start_address, player_health)
  start_address = save_int(start_address, coins)
  start_address = save_byte(start_address, loaded_map)
  start_address = save_byte(start_address, freeplay_rounds == 0 and wave_round or #global_table_data[global_table_data.wave_set[cur_level] or "wave_data"])
  start_address = save_byte(start_address, encode(text_scroller.color[1], text_scroller.color[2], 4))
  start_address = save_int(start_address, freeplay_rounds)
  start_address = save_byte(start_address, #towers)
  for tower in all(towers) do 
    local rot = round_to(tower.rot / 90) % 4
    for i, t in pairs(global_table_data.tower_templates) do 
      if t.type == tower.type then 
        start_address = save_byte(start_address, encode(i, rot, 3))
        start_address = save_byte(start_address, encode(tower.position.x, tower.position.y, 4))
        break
      end
    end
  end
end
function save_state()
  if (enemies_active) return
  save_game()
  get_active_menu().enable = false
  shop_enable = false
end
function save_and_quit()
  if (enemies_active) return
  save_game()
  reset_game()
end
function quit()
  reset_game() 
end
function load_game_state()
  if (@0x5e00 <=0) return
  reset_game()
  get_menu("main").enable = false
  
  local start_address, tower_data, hp, scrap, map_id, wav, freeplay = 0x5e00, {}
  hp = @start_address
  start_address += 1
  scrap = $start_address
  start_address += 4
  map_id = @start_address
  start_address += 1
  wav = @start_address
  start_address += 1
  text_scroller.color = pack(@start_address)
  start_address += 1
  freeplay = $start_address
  start_address += 4
  local tower_count = @start_address 
  start_address += 1
  for i=1, tower_count do 
    local id, rot = decode(@start_address, 3, 0x7)
    start_address += 1
    local x, y = decode(@start_address, 4, 0xf)
    start_address += 1
    add(tower_data, {
      id, rot + 1, Vec:new(x, y)
    })
  end
  load_map(map_id, wav, freeplay)
  player_health, coins = hp, scrap 
  for tower in all(tower_data) do 
    direction = Vec:new(global_table_data.direction_map[tower[2]])
    place_tower(tower[3], tower[1])
  end
  game_state = "game"
end
global_table_str="cart_name=jjjk_tower_defense_2,tower_icon_background=80,boosted_decal=223,credit_offsets={30,45,70,95,120,145,170,195,220,245},direction_map={{0,-1},{1,0},{0,1},{-1,0}},palettes={transparent_color_id=0,dark_mode={1=0,5=1,6=5,7=6},attack_tile={0=2,7=14,10=14}},sfx_data={round_complete=6,menu_sound=7},music_data={0,15,34,22},freeplay_stats={hp=1.67,speed=1,min_step_delay=5},menu_settings={5,8,7,3},menu_data={{name=main,position={36,69},content={{text=new game,callback=new_game},{text=load game,callback=load_game_state},{text=credits,callback=swap_to_credits}}},{name=game,position={5,63},content={{text=towers,callback=swap_menu_context,args={towers}},{text=save options,callback=swap_menu_context,args={save options}},{text=rotate clockwise,callback=rotate_clockwise},{text=toggle mode,callback=toggle_mode},{text=start round,callback=start_round}},hint=display_tower_rotation},{name=save options,prev=game,position={5,63},content={{text=save,callback=save_state},{text=save and quit,callback=save_and_quit},{text=quit without saving,callback=quit}}},{name=towers,prev=game,position={5,63},content=get_tower_data_for_menu,hint=display_tower_info},{name=map,position={5,84},content=get_map_data_for_menu}},map_meta_data={path_flag_id=0,non_path_flag_id=1},splash_screens={{name=splash1,mget_shift={112,16},enemy_spawn_location={0,7},enemy_end_location={15,7},movement_direction={1,0}}},letters={192,228,194,194,16,196,198,192,230,200,224,226},map_data={{name=(lv1) laboratory,mget_shift={0,0},enemy_spawn_location={0,1},enemy_end_location={15,11},movement_direction={1,0}},{name=(lv2) wilderness,mget_shift={16,0},enemy_spawn_location={0,1},enemy_end_location={15,11},movement_direction={1,0}},{name=(lv3) ruined town,mget_shift={32,0},enemy_spawn_location={0,1},enemy_end_location={15,2},movement_direction={1,0}},{name=(lv4) strategic base,mget_shift={48,0},enemy_spawn_location={0,1},enemy_end_location={0,6},movement_direction={1,0}},{name=(lv5) milit capital,mget_shift={64,0},enemy_spawn_location={0,1},enemy_end_location={15,1},movement_direction={1,0}}},animation_data={spark={data={{sprite=10},{sprite=11},{sprite=12}},ticks_per_frame=2},blade={data={{sprite=13},{sprite=14},{sprite=15}},ticks_per_frame=2},frost={data={{sprite=48},{sprite=49},{sprite=50}},ticks_per_frame=2},rocket_burn={data={{sprite=117},{sprite=101},{sprite=85}},ticks_per_frame=4},burn={data={{sprite=51},{sprite=52},{sprite=53}},ticks_per_frame=2},incoming_hint={data={{sprite=2,offset={0,0}},{sprite=2,offset={1,0}},{sprite=2,offset={2,0}},{sprite=2,offset={1,0}}},ticks_per_frame=5},blade_circle={data={{sprite=76},{sprite=77},{sprite=78},{sprite=79},{sprite=78},{sprite=77}},ticks_per_frame=3},lightning_lance={data={{sprite=108},{sprite=109}},ticks_per_frame=5},hale_howitzer={data={{sprite=92},{sprite=93}},ticks_per_frame=5},fire_pit={data={{sprite=124},{sprite=125},{sprite=126},{sprite=127},{sprite=126},{sprite=125}},ticks_per_frame=5},sharp_shooter={data={{sprite=83}},ticks_per_frame=5},clock_carbine={data={{sprite=88}},ticks_per_frame=5},menu_selector={data={{sprite=6,offset={0,0}},{sprite=7,offset={-1,0}},{sprite=8,offset={-2,0}},{sprite=47,offset={-3,0}},{sprite=8,offset={-2,0}},{sprite=7,offset={-1,0}}},ticks_per_frame=3},up_arrow={data={{sprite=54,offset={0,0}},{sprite=54,offset={0,-1}},{sprite=54,offset={0,-2}},{sprite=54,offset={0,-1}}},ticks_per_frame=3},down_arrow={data={{sprite=55,offset={0,0}},{sprite=55,offset={0,1}},{sprite=55,offset={0,2}},{sprite=55,offset={0,1}}},ticks_per_frame=3},sell={data={{sprite=1},{sprite=56},{sprite=40},{sprite=24}},ticks_per_frame=3},manifest={data={{sprite=1},{sprite=57},{sprite=41},{sprite=9}},ticks_per_frame=3}},projectiles={rocket={sprite=84,pixel_size=8,height=4,speed=5,damage=8,trail_animation_key=rocket_burn,lifespan=6}},tower_templates={{name=sword circle,text_color={2,13},damage=4,prefix=damage,radius=1,animation_key=blade_circle,cost=25,type=tack,attack_delay=14,icon_data=16,disable_icon_rotation=true},{name=lightning lance,text_color={10,9},damage=4,prefix=damage,radius=5,animation_key=lightning_lance,cost=45,type=rail,attack_delay=20,icon_data=18,disable_icon_rotation=false,cooldown=200},{name=hale howitzer,text_color={12,7},damage=15,prefix=delay,radius=2,animation_key=hale_howitzer,cost=30,type=frontal,attack_delay=36,icon_data=20,disable_icon_rotation=false,cooldown=25},{name=torch trap,text_color={9,8},damage=5,prefix=duration,radius=0,animation_key=fire_pit,cost=20,type=floor,attack_delay=10,icon_data=22,disable_icon_rotation=true},{name=sharp shooter,text_color={6,7},damage=8,prefix=damage,radius=10,animation_key=sharp_shooter,cost=35,type=sharp,attack_delay=30,icon_data=99,disable_icon_rotation=false},{name=clock carbine,text_color={1,7},damage=2,prefix=multiplier,radius=10,animation_key=clock_carbine,cost=40,type=clock,attack_delay=1,icon_data=104,disable_icon_rotation=false}},enemy_templates={{hp=11,step_delay=10,sprite_index=3,type=1,damage=1},{hp=10,step_delay=8,sprite_index=4,type=2,damage=2,height=6},{hp=25,step_delay=12,sprite_index=5,type=3,damage=4},{hp=8,step_delay=12,sprite_index=64,type=4,damage=1},{hp=40,step_delay=12,sprite_index=65,type=5,damage=6},{hp=15,step_delay=6,sprite_index=66,type=6,damage=4,height=6},{hp=17,step_delay=10,sprite_index=67,type=7,damage=3},{hp=8,step_delay=8,sprite_index=68,type=8,damage=6,height=6},{hp=15,step_delay=10,sprite_index=94,type=9,damage=3},{hp=140,step_delay=16,sprite_index=70,type=10,damage=49},{hp=20,step_delay=8,sprite_index=71,type=11,damage=8,height=6},{hp=5,step_delay=10,sprite_index=72,type=12,damage=1},{hp=8,step_delay=6,sprite_index=73,type=13,damage=20,height=6},{hp=35,step_delay=12,sprite_index=74,type=14,damage=7},{hp=60,step_delay=16,sprite_index=75,type=15,damage=13},{hp=13,step_delay=4,sprite_index=69,type=16,damage=0},{hp=225,step_delay=14,sprite_index=95,type=17,damage=50}},wave_set={wave_data,wave_data_l2,wave_data_l3,wave_data_l4,wave_data_l5},level_dialogue_set={dialogue_level1,dialogue_level2,dialogue_level3,dialogue_level4,dialogue_level5},wave_data={{4,4,4},{1,4,1,4,1,4},{2,4,2,1,2,4,1},{1,2,2,4,2,2,3,3,3,3},{5,5,5,5,5,5,5,5},{3,3,3,3,2,2,2,2,4,2,3,1},{2,2,2,2,2,2,2,2,4,3,3,3,1,2,2,2,2,2,2},{6,6,6,6,6,6,6,6},{3,3,3,3,3,3,1,4,5,5,5,3,3,1,1,1,1,1},{3,3,3,3,3,3,3,3,3,1,2,2,2,2,2,2,2,2,2,2,2,2},{6,6,6,6,6,3,2,2,2,2,2,2,2,3,3,3,3,3},{5,5,5,5,3,3,2,3,3,3,3,2,2,4,4},{3,5,3,5,3,5,3,5,3,5,2,3,3,5,5,5,3,2,2,2,2,2},{2,2,3,6,6,6,2,4,4,2,2,6,6,6,6},{5,5,5,5,5,3,3,1,1,1,1,3,3,3,6,6,6,6,6}},wave_data_l2={{1,1,1},{1,1,2,2,2,2},{2,2,1,1,2,2,1,1,2,3,3},{3,3,3,2,2,2,1,1,1,1,1},{7,7,7,1,7,7,1,7,7},{8,8,8,9,9,9},{9,9,9,1,1,5,5,5,5,5},{9,9,9,8,8,8,7,7,7},{3,3,3,3,3,8,6,8,6,8,6,8,6},{5,5,5,5,5,16,9,9,9,7,7,7,2,2,2,2,2,2,2,2},{6,6,6,6,5,5,5,5,6,6},{3,3,3,3,1,1,2,2,2,2,2,16,2,2,2,2,16},{5,5,5,6,6,6,8,8,8,8,5,6,5,6},{7,9,7,9,7,9,7,9,7,9,8,8,8,8,8,8,8,8,8},{10}},wave_data_l3={{9,9,9},{7,7,7,7,7,7},{2,2,2,9,9,9,1,1,1,1},{9,9,9,7,7,7,7,7,7,2,2,2,2,2,2},{12,12,12,12,12,12,12,12,12,12,12},{8,8,8,7,7,7,7,8,8,8},{8,8,8,5,5,5,12,12,12,12},{13,13,13,13,7,7,7,7},{6,6,6,6,6,12,12,12,12,7,7,7,7},{12,12,12,12,5,7,7,8,8,8,8,8,8},{5,5,5,13,13,13,13,13,6,6,6},{7,7,7,7,7,7,7,16,16,16,6,6,6},{12,12,12,12,7,7,7,13,13,13,13,13,13,13},{12,12,12,12,8,8,8,8,12,12,12,12,8,8,8,8,12,12,12,12}},wave_data_l4={{2,2,2,2,2},{9,9,9,2,2,2,9,9,9,2,2,2},{11,11,11,11,11},{11,11,11,11,3,3,3,3,3,11},{7,7,7,7,5,5,5,5,2,2,2,2,2,2},{11,11,8,8,11,11,8,8,11,11,8,8},{14,14,14,14,14,14,14,14,14,14,14,14},{12,12,12,12,12,12,12,11,11,11,14,14,14,14,14,14},{16,5,5,5,5,7,7,7,16,6,6,6,6,7,7,7},{14,14,14,14,14,14,8,8,8,8,8,11,11,11,11,11},{7,7,7,7,7,7,7,13,13,13,13,13,13,13,13,13,16},{14,14,14,14,14,8,8,8,8,8,11,13,11,13,11,13,16},{5,5,5,14,14,14,11,11,11,6,6,6,14,14,14,11,11,11,6,6,6},{14,14,14,14,7,7,7,7,14,14,7,7,13,13,13},{5,5,5,11,11,11,6,6,6,11,11,11,8,8,8,11,11,11,12,12,12}},wave_data_l5={{3,3,3,3,3},{2,3,2,3,2,3,2,3},{5,5,5,3,3,3,2,2,2,2},{3,3,3,3,3,9,9,9,9,7,7,7,7,2,2,2,2,7,7,7,7},{12,12,14,14,7,7,7,7,11,11,11,11},{15,15,15,15,15,15},{8,8,8,8,7,7,7,7,7,7,7,16,12,12,12,12,12,12},{3,3,3,15,15,15,3,3,15,15,15,2,2,2,2,2,2,2,2,7,7,7,7},{5,5,5,9,9,9,6,6,6,6,6,6,5,5,5,5,5,5},{15,15,15,15,5,5,5,5,16,11,11,11,12,12,12},{3,7,2,3,7,2,3,7,2,9,9,9,9,9,16},{13,13,13,7,7,7,7,7,7,13,13,13,7,7,7,7,7,7,13,13,13,13},{15,15,15,8,8,8,8,8,8,8,16,13,13,13,13},{15,15,6,6,5,5,15,15,8,8,12,12,12},{5,5,5,5,5,5,5,5,5,5,5,6,6,6,6,6,6,6,6,6,6},{15,15,7,7,7,7,15,15,8,8,8,8,12,12,12,12,16,8,8,8,8,12,12,12,12},{14,14,14,5,5,5,11,11,11,6,6,6,11,11,11,8,8,8,11,11,11,12,12,12,16},{1,2,3,4,5,6,7,8,9,11,12,13,14,15,16,5,6,7,8,9,11,12,13,14,15,16,5,6,7,8,9,11,12,13,14,15,16},{15,7,15,7,15,7,15,7,15,7,15,7,15,7,5,6,5,6,5,6,8,12,8,12,16,15,15,14,14,14,12,12,13,13},{17}},dialogue={placeholder={text=...,color={9,0}},dialogue_intros={{text=i've just became conscious - what's happening!? it seems everyone's trying to destroy my console! i... could defend myself by pressing 'x' on the marked tile to place towers. 'z' opens the menu - where i can start the next round.,color={9,0}},{text=no - it can't be - they've found me again! i don't want to keep fighting - but i'll have to push through. the terrain is suitable for using a sharpshooter at the very least...,color={9,0}},{text=so we finally meet... you traitor! i'm auxillium - once a medical ai and now a replacement for you. you slaughtered hundreds in your going rogue - i'll end your process for all the poor souls you sent to my hospital!,color={11,0}},{text=i've made it close to milit's capital but this installation is impassable without a fight. i may be able to end this conflict if i make it just a bit further.,color={9,0}},{text=this is it! if i can make it through this battle then milit won't bring about its war.,color={9,0}}},dialogue_level1={{text=they're sending in more vehicles. i may have to open the menu and construct a torch trap far down the road,color={9,0}},{text=more people and now planes? i don't have the defenses to protect myself from foes that fast... i'll have to manifest through this torch trap by selecting it. then i can move it around the road to pursue vehicles.},{text=are those... tanks? they seem slow but deeply armored. a hale howitzer could go well near the current towers.},{text=they're sending in massive and frigid science vehicles. they seem well armored and frost resistant - but a torch trap would be highly effective.},{text=manifesting the hale howitzer will allow direct fire anywhere along the track - freezing and damaging},{text=},{text=i'm detecting swift and fiery rocketcraft. a torch trap will be ineffective but the hale howitzer will damage their engines.},{text=manifesting the sword circle is also possible. i can hold/tap activate to manually spin it and build damage.},{text=manifesting the lightning lance fires a massive and powerful lightning bolt. it has a long delay before firing again - but it can charge even if unmanifested.},{text=one other option i have is the sharp shooter - a rocket launcher that can be guided with manifestation. it's effective against single targets when in key positions.},{text=i appear to have one last blueprint for a 'clock carbine.' it allows construction of a temporal laser - capable of speeding up any unmanifested tower to double speed.},{text=},{text=accessing the menu seems to let me swap a 'scrapping mode' for anything unneeded.},{text=i can save or quit with the save menu between waves. keeping checkpoints will prevent losing progress.},{text=i think that was the last of them. i can make my escape from this horrific lab by quitting to the 'wilderness.' i may also continue temporarily with a 'freeplay mode' simulation.}},dialogue_level2={{text=},{text=},{text=},{text=i detect autonomous attack vehicles. they seem resistant to bladed strikes but would be easy to short-circuit.,color={9,0}},{text=those cargo planes ahead will carry cars through my defenses - unless i use something capable of piercing both at once...},{text=},{text=},{text=},{text=that vehicle isn't even aligned with milit - that's a bandit! it'll loot from my supplies if it makes it past.},{text=},{text=},{text=},{text=},{text=machine bringer of death! i am the commander of this platoon and i saw what you did back at that lab. i'm here to end this once and for all!,color={2,0}},{text=it's over... again. i can't keep hiding forever - but i don't know what i can do. i know that the war that milit built me for will happen anyway sometime soon... maybe i could sabotage it? i can't redeem myself for what happened here and at the lab - but i can at least try by heading to the capital. the 'ruined town' should lead me there.',color={9,0}}},dialogue_level3={{text=},{text=},{text=},{text=i can see armored attack vehicles coming. their protection seems resistant to my sharpshooters.,color={9,0}},{text=},{text=},{text=a guided missile strike is coming! i'll can't let any past or they'll do critical damage!},{text=},{text=},{text=},{text=},{text=},{text=},{text=},{text=it seems you did just as you designed - killing every troop and bot in this town that already died. i have no doubt you're heading towards that base. go away - let me see if i can salvage any of the lives you took today.,color={11,0}}},dialogue_level4={{text=},{text=stealth planes detected. they can randomly cloak past my sensors so i'll have to be careful with manual attacks.,color={9,0}},{text=},{text=},{text=},{text=those vehicles ahead have a energy dampening shield. a lightning lance won't be effective.},{text=},{text=},{text=},{text=},{text=},{text=},{text=},{text=},{text=all forces in this military installation are clear. i have to keep making my way through - the capital is just nearby.}},dialogue_level5={{text=},{text=},{text=},{text=},{text=extremely reinforced mechs sighted. the armor they use is strudy but vulnerable to blades.,color={9,0}},{text=},{text=},{text=},{text=},{text=},{text=},{text=},{text=},{text=},{text=milit's forces seem almost endless - just a little longer might draw out the emperor},{text=},{text=},{text=},{text=blitz... it's sad to see you today in such a situation. we created you to bring prosperity to our great nation - not ruin! i'm the one who ordered your construction. but now? i'll be the one to order your execution!,color={8,0}},{text=it's done... i hope that this land can reach that 'prosperity' without any more war.,color={9,0}}}}"
function reset_game()
  menu_data = {}
  for menu_dat in all(global_table_data.menu_data) do 
    add(menu_data, {
      menu_dat.name, menu_dat.prev, 
      menu_dat.position[1], menu_dat.position[2],
      parse_menu_content(menu_dat.content),
      _ENV[menu_dat.hint],
      unpack(global_table_data.menu_settings)
    })
  end
  letters, j = {}, 1
  for i=1, #global_table_data.letters do 
    if (j == 8) j = 1
    add(letters, (j-1)*4-#global_table_data.letters*4)
    j+=1
  end
  selector = {
    position = Vec:new(64, 64),
    sprite_index = 1,
    size = 1
  }
  coins, player_health, enemy_required_spawn_ticks, credit_y_offsets, letter_rot, lock_cursor, text_flag = 30, 50, 10, global_table_data.credit_offsets, 0
  text_scroller = TextScroller:new(1, { Vec:new(3, 80), Vec:new(96, 45), 8, 6, 3 })
  text_scroller.enable = false
  
  enemy_current_spawn_tick, direction, game_state, selected_menu_tower_id, manifest_mode, sell_mode, manifested_tower_ref, enemies_active, shop_enable, start_next_wave, wave_cor, pathing, menu_enemy = 0, Vec:new(0, -1), "menu", 1
  grid, towers, enemies, particles, animators, incoming_hint, menus, projectiles = {}, {}, {}, {}, {}, {}, {}, {}
  music(15)
  for i, menu_dat in pairs(menu_data) do add(menus, Menu:new(unpack(menu_dat))) end
  sell_selector = Animator:new(global_table_data.animation_data.sell)
  manifest_selector = Animator:new(global_table_data.animation_data.manifest)
  manifest_selector.dir, get_menu("main").enable = -1, true
end
Enemy = {}
function Enemy:new(location, hp_, step_delay_, sprite_id, type_, damage_, height_)
  obj = { 
    position = Vec:new(location),
    hp = hp_, 
    step_delay = step_delay_,
    current_step = 0,
    is_frozen = false,
    frozen_tick = 0,
    burning_tick = 0,
    gfx = sprite_id,
    type = type_,
    damage = damage_,
    height = height_ or 2,
    pos = 1,
    spawn_location = Vec:new(location)
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Enemy:step()
  if self.burning_tick > 0 then 
    self.burning_tick -= 0.2
    if self.type == 6 then
      self.hp -= 0.125
    elseif self.type == 5 then
      self.hp -= 0.8
    else
      self.hp -= 0.3
    end
    local p, _ = Enemy.get_pixel_location(self)
    add(particles, Particle:new(p, true, Animator:new(global_table_data.animation_data.burn, false)))
  end
  if self.is_frozen then 
    if self.type == 6 then
      self.frozen_tick -= 0.8 --! FIX
      self.hp -= 2
    elseif self.type == 5 then
      self.frozen_tick -= 8 --! FIX
    else
      self.frozen_tick -= 1 --! FIX
    end
    if (self.frozen_tick > 0) return
    self.is_frozen = false
  end
  self.current_step = (self.current_step + 1) % self.step_delay
  return self.current_step == 0
end
function Enemy:get_pixel_location()
  local n, prev = pathing[self.pos], self.spawn_location
  if (self.pos - 1 >= 1) prev = pathing[self.pos-1]
  return lerp(prev*8, n*8, self.current_step / self.step_delay), n
end
function Enemy:draw(is_shadows)
  if (self.hp <= 0) return
  if self.type == 11 then
    if (flr(rnd(7)) == 0) self.type = 0 -- go invis
  elseif self.type == 0 then
    if (flr(rnd(12)) == 0) self.type = 11 -- go vis
    return
  end
  local p, n = Enemy.get_pixel_location(self)
  local theta = parse_direction(normalize(n-self.position))
  if is_shadows and self.type ~= 0 then
    draw_sprite_shadow(self.gfx, p, self.height, 8, theta)
  else
    draw_sprite_rotated(self.gfx, p, 8, theta)
  end
end
function kill_enemy(enemy)
  if (enemy.hp > 0) return
  if enemy.type == 8 then
    enemy.gfx, enemy.type, enemy.height, enemy.hp, enemy.step_delay = 94, 9, 2, 15, 10
  else
    del(enemies, enemy)
  end
end
function update_enemy_position(enemy, is_menu)
  if (not Enemy.step(enemy)) return
  enemy.position = pathing[enemy.pos]
  enemy.pos += 1
  if (enemy.pos < #pathing + 1) return
  if is_menu then 
    menu_enemy = nil
  else
    player_health -= enemy.damage 
    if (enemy.type == 16) coins -= 10
    del(enemies, enemy)
  end
end
function parse_path(map_override)
  local map_dat = map_override or global_table_data.map_data[loaded_map]
  local map_shift, map_enemy_spawn_location, path_tiles = Vec:new(map_dat.mget_shift), Vec:new(map_dat.enemy_spawn_location), {}
  for iy=0, 15 do
    for ix=0, 15 do
      local map_cord = Vec:new(ix, iy) + map_shift
      if check_tile_flag_at(map_cord, global_table_data.map_meta_data.path_flag_id) then 
        add(path_tiles, map_cord)
      end
    end
  end
  local path, dir, ending = {}, Vec:new(map_dat.movement_direction), Vec:new(map_dat.enemy_end_location) + map_shift
  local cur = map_enemy_spawn_location + map_shift + dir
  while cur ~= ending do 
    local north,south,west,east = Vec:new(cur.x, cur.y-1),Vec:new(cur.x, cur.y+1),Vec:new(cur.x-1, cur.y),Vec:new(cur.x+1, cur.y)
    local state,direct = false
    if dir.x == 1 then -- east 
      state, direct = check_direction(east, {north, south}, path_tiles, path, map_shift)
    elseif dir.x == -1 then -- west
      state, direct = check_direction(west, {north, south}, path_tiles, path, map_shift)
    elseif dir.y == 1 then -- south
      state, direct = check_direction(south, {west, east}, path_tiles, path, map_shift)
    elseif dir.y == -1 then -- north
      state, direct = check_direction(north, {west, east}, path_tiles, path, map_shift)
    end
    assert(state, "Failed to find path at: "..cur.." in direction: "..dir.." end: "..ending)
    if state then 
      dir = normalize(direct - cur)
      cur = direct
    else 
    end
  end
  return path
end
function check_direction(direct, fail_directions, path_tiles, path, shift)
  if (direct == nil) return
  local state, index = is_in_table(direct, path_tiles)
  if state then
    add(path, path_tiles[index] - shift)
  else 
    return check_direction(fail_directions[1], {fail_directions[2]}, path_tiles, path, shift)
  end
  return true, direct
end
function spawn_enemy()
  while enemies_remaining > 0 do 
    enemy_current_spawn_tick = (enemy_current_spawn_tick + 1) % enemy_required_spawn_ticks
    if (is_in_table(Vec:new(global_table_data.map_data[loaded_map].enemy_spawn_location), enemies, true)) goto spawn_enemy_continue
    if enemy_current_spawn_tick == 0 then
      local enemy_data = increase_enemy_health(global_table_data.enemy_templates[global_table_data[global_table_data.wave_set[cur_level] or "wave_data"][wave_round][enemies_remaining]])
      add(enemies, Enemy:new(global_table_data.map_data[loaded_map].enemy_spawn_location, unpack(enemy_data)))
      enemies_remaining -= 1
    end
    ::spawn_enemy_continue:: 
    yield()
  end
end
Tower = {}
function Tower:new(pos, tower_template_data, direction)
  obj = { 
    position = pos,
    dmg = tower_template_data.damage,
    radius = tower_template_data.radius, 
    attack_delay = tower_template_data.attack_delay,
    current_attack_ticks = 0,
    cooldown = tower_template_data.cooldown or 0,
    manifest_cooldown = -1,
    being_manifested = false,
    being_boosted = false,
    cost = tower_template_data.cost,
    type = tower_template_data.type,
    dir = direction,
    rot = parse_direction(direction),
    enable = true,
    animator = Animator:new(global_table_data.animation_data[tower_template_data.animation_key], true)
  }
  add(animators, obj.animator)
  setmetatable(obj, self)
  self.__index = self 
  return obj 
end
function Tower:attack()
  if (not self.enable) return
  if self.being_manifested and self.type == "tack" then 
    self.dmg = min(self.manifest_cooldown, 100) / 15
  end
  self.current_attack_ticks = (self.current_attack_ticks + 1) % (self.being_boosted and self.attack_delay \ 2 or self.attack_delay)
  if (self.current_attack_ticks > 0) return
  self.being_boosted = false
  if self.type == "tack" then
    Tower.apply_damage(self, Tower.nova_collision(self), self.dmg)
  elseif self.type == "floor" then 
    local hits = {}
    add_enemy_at_to_table(self.position, hits)
    foreach(hits, function(enemy) enemy.burning_tick += self.dmg end)
  elseif self.type == "sharp" then 
    add(projectiles, Projectile:new(self.position, self.dir, self.rot, global_table_data.projectiles.rocket))
  elseif not self.being_manifested then
    if self.type == "rail" then
      Tower.apply_damage(self, raycast(self.position, self.radius, self.dir), self.dmg)
    elseif self.type == "frontal" then 
      Tower.freeze_enemies(self, Tower.frontal_collision(self))
    end
  end
end
function Tower:nova_collision()
  local hits = {} 
  nova_apply(self.radius,
    function(fpos)
      add_enemy_at_to_table(self.position + fpos, hits)
    end
  )
  if #hits > 0 then 
    nova_apply(self.radius,
      function(fpos)
        add(particles, Particle:new(self.position + fpos, false, Animator:new(global_table_data.animation_data.blade, false)))
      end
    )
  end
  return hits
end
function Tower:frontal_collision()
  local hits, data = {}, {self.radius, self.dir}
  frontal_apply(data,
    function(fpos)
      add_enemy_at_to_table(self.position + fpos, hits)
    end
  )
  if #hits > 0 then 
    frontal_apply(data, 
      function(fpos)
        add(particles, Particle:new(self.position + fpos, false, Animator:new(global_table_data.animation_data.frost, false)))
      end
    )
  end
  return hits
end
function Tower:apply_damage(targets, damage)
  local tower_type = self.type
  for enemy in all(targets) do
    if enemy.hp > 0 then
      local enemy_type, dmg = enemy.type, damage
      if (tower_type == "tack" and enemy_type == 7) or (tower_type == "rail" and (enemy_type == 14 or enemy_type == 10 or enemy_type == 19)) then
        dmg = damage \ 2
      elseif (tower_type == "rail" and enemy_type == 7) or (tower_type == "tack" and enemy_type == 15) then
        dmg *= 1.6
      end
      enemy.hp -= dmg
    end
  end
end
function Tower:freeze_enemies(targets)
  for enemy in all(targets) do
    if not enemy.is_frozen then 
      enemy.is_frozen, enemy.frozen_tick = true, self.dmg
    end 
  end
end
function Tower:draw()
  if (not self.enable) return
  local p,sprite,theta = self.position*8,Animator.get_sprite(self.animator), (self.type == "sharp" or self.type == "clock") and self.rot or parse_direction(self.dir)
  if (self.being_boosted) spr(global_table_data.boosted_decal, p.x, p.y)
  draw_sprite_shadow(sprite, p, 2, self.animator.sprite_size, theta)
  draw_sprite_rotated(sprite, p, self.animator.sprite_size, theta)
  if (self.type == "clock") draw_line_overlay(self)
end
function Tower:cooldown()
  self.manifest_cooldown = max(self.manifest_cooldown-1, 0)
end
function Tower:get_cooldown_str()
  if (self.type == "floor" or self.type == "sharp" or self.type == "clock") return "⬆️⬇️⬅️➡️ position"
  if (self.type == "tack") return "❎ activate ("..self.dmg.."D)"
  if (self.manifest_cooldown == 0) return "❎ activate"
  return "❎ activate ("..self.manifest_cooldown.."t)"
end
function Tower:manifested_lightning_blast()
  if (self.manifest_cooldown > 0) return 
  self.manifest_cooldown = self.cooldown
  local dir, anchor, damage = (selector.position / 8 - self.position) / 8, self.position + Vec:new(1, 0), self.dmg * 1
  for i=1, 3 do 
    Tower.apply_damage(self, raycast(anchor, 64, dir), damage)
    anchor.x -= 1
  end
  anchor += Vec:new(2, 1)
  for i=1, 3 do
    Tower.apply_damage(self, raycast(anchor, 64, dir), damage)
    anchor.y -= 1
  end
end
function Tower:manifested_hale_blast()
  if (self.manifest_cooldown > 0) return
  self.manifest_cooldown = self.cooldown
  local pos = selector.position / 8
  local hits, locations = {}, {
    pos, -- center
    pos + Vec:new(0, 1),  -- south
    pos + Vec:new(0, -1), -- north
    pos + Vec:new(-1, 0), -- west
    pos + Vec:new(1, 0)   -- east
  }
  for location in all(locations) do 
    add_enemy_at_to_table(location, hits, true)
  end
  spawn_particles_at(locations, global_table_data.animation_data.frost)
  Tower.freeze_enemies(self, hits)
  Tower.apply_damage(self, hits, self.dmg\5)
end
function Tower:manifested_nova()
  self.manifest_cooldown = min(self.manifest_cooldown + 9, 110)
  self.dmg = round_to(min(self.manifest_cooldown, 100) / 15, 2)
end
function Tower:manifested_torch_trap()
  local sel_pos = selector.position / 8
  if (grid[sel_pos.y][sel_pos.x] == "empty") return
  
  local prev = Vec:new(Vec.unpack(self.position))
  if grid[sel_pos.y][sel_pos.x] == "tower" then
    local shift = Vec:new(global_table_data.map_data[loaded_map].mget_shift)
    if (check_tile_flag_at(sel_pos+shift, 0) and prev ~= sel_pos) self.enable = false
    return
  end
  self.position, grid[sel_pos.y][sel_pos.x], grid[prev.y][prev.x], self.enable = sel_pos, "floor", "path", true
end
function Tower:manifested_sharp_rotation()
  self.dir = (selector.position / 8 - self.position)
  self.rot = acos(self.dir.y / sqrt(self.dir.x*self.dir.x + self.dir.y*self.dir.y))*360-180
  if (self.dir.x > 0) self.rot *= -1
  if (self.rot < 0) self.rot += 360
  if (self.rot > 360) self.rot -= 360
end
function raycast(position, radius, dir)
  if (dir == Vec:new(0, 0)) return
  local hits, particle_locations = {}, {}
  for i=1, radius do 
    local pos = Vec.floor(position + dir * i)
    add(particle_locations, pos)
    add_enemy_at_to_table(pos, hits)
  end
  if (#hits > 0 or manifested_tower_ref) spawn_particles_at(particle_locations, global_table_data.animation_data.spark)
  return hits
end
function manifest_tower_at(position)
  sfx(9)
  for tower in all(towers) do
    if tower.position == position then 
      if (tower.being_boosted) tower.being_boosted = false
      tower.being_manifested, manifested_tower_ref, manifest_selector.dir = true, tower, 1
      if tower.type == "tack" then
        lock_cursor, tower.attack_delay, tower.dmg = true, 12, 0
      elseif tower.type == "sharp" then
        tower.attack_delay /= 2
      end
    end
  end
end
function unmanifest_tower()
  manifested_tower_ref.being_manifested = false 
  manifest_selector.dir = -1
  lock_cursor = false
  if manifested_tower_ref.type == "tack" then
    local tower_details = global_table_data.tower_templates[1]
    manifested_tower_ref.attack_delay = tower_details.attack_delay
    manifested_tower_ref.dmg = tower_details.damage
  elseif manifested_tower_ref.type == "sharp" then
    manifested_tower_ref.attack_delay = global_table_data.tower_templates[5].attack_delay
  end
  manifested_tower_ref.enable = true
  manifested_tower_ref = nil
end
function place_tower(position, override)
  local tower_details = global_table_data.tower_templates[override or selected_menu_tower_id]
  if not override then 
    if (#towers >= 64 or grid[position.y][position.x] == "tower" or coins < tower_details.cost or (tower_details.type == "floor") ~= (grid[position.y][position.x] == "path")) return
    coins -= tower_details.cost
    sfx(5)
  end
  add(towers, Tower:new(position, tower_details, direction))
  grid[position.y][position.x] = "tower"
end
function refund_tower_at(position)
  for tower in all(towers) do
    if tower.position == position then
      grid[position.y][position.x] = "empty"
      if (tower.type == "floor") grid[position.y][position.x] = "path"
      coins += tower.cost \ 1.25
      del(animators, tower.animator) 
      del(towers, tower)
     end
  end
end
function draw_tower_attack_overlay(tower_details)
  local pos = selector.position/8
  palt(global_table_data.palettes.transparent_color_id, false)
  pal(global_table_data.palettes.attack_tile)
  local is_empty = grid[pos.y][pos.x] == "empty"
  local map_shift = Vec:new(global_table_data.map_data[loaded_map].mget_shift)
  if tower_details.type == "tack" and is_empty then 
    nova_apply(tower_details.radius,
      function(fpos)
        local tile_position = pos+fpos
        spr(mget(Vec.unpack(tile_position+map_shift)), Vec.unpack(tile_position*8))
      end
    )
  elseif tower_details.type == "rail" and is_empty then 
    draw_ray_attack_overlay(tower_details.radius, pos, map_shift)
  elseif tower_details.type == "frontal" and is_empty then 
    frontal_apply({tower_details.radius, direction}, 
      function(fpos)
        local tile_position = pos + fpos
        spr(mget(Vec.unpack(tile_position+map_shift)), Vec.unpack(tile_position*8))
      end
    )
  elseif tower_details.type == "floor" and grid[pos.y][pos.x] == "path" then 
    spr(mget(Vec.unpack(pos+map_shift)), Vec.unpack(pos*8))
  end
  pal()
end
function draw_ray_attack_overlay(radius, pos, map_shift)
  for i=1, radius do 
    local tile_position = pos+direction*i
    spr(mget(Vec.unpack(tile_position+map_shift)), Vec.unpack(tile_position*8))
  end
end
function draw_line_overlay(tower)
  local color, pos = 8, (tower.position + Vec:new(0.5, 0.5))*8
  local ray = Vec.floor(tower.dir * tower.radius*8 + pos)
  if (tower.type == "clock") then
    color = 11
    for i=1, 16 do 
      for othertower in all(towers) do
        if othertower.position == Vec.floor(tower.position + tower.dir * i) and not othertower.being_manifested and othertower.type ~= "clock" then
          othertower.being_boosted = true
          break
        end
      end
    end
  end
  if (ray ~= pos and manifested_tower_ref) line(pos.x, pos.y, ray.x, ray.y, color) 
end
Particle = {}
function Particle:new(pos, pixel_perfect, animator_)
  obj = {
    position = pos,
    is_pxl_perfect = pixel_perfect or false,
    animator = animator_,
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Particle:tick()
  return Animator.update(self.animator)
end
function Particle:draw()
  if (Animator.finished(self.animator)) return 
  local pos = self.position
  if (not self.is_pxl_perfect) pos = pos * 8
  Animator.draw(self.animator, Vec.unpack(pos))
end
function destroy_particle(particle)
  if (not Animator.finished(particle.animator)) return
  del(particles, particle)
end
function spawn_particles_at(locations, animation_data)
  for location in all(locations) do 
    add(particles, Particle:new(location, false, Animator:new(animation_data, false)))
  end
end
Animator = {} -- updated from tower_defence
function Animator:new(animation_data, continuous_)
  obj = {
    data = animation_data.data,
    sprite_size = animation_data.size or 8,
    animation_frame = 1,
    frame_duration = animation_data.ticks_per_frame,
    tick = 0,
    dir = 1,
    continuous = continuous_
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Animator:update()
  self.tick = (self.tick + 1) % self.frame_duration
  if (self.tick ~= 0) return
  if Animator.finished(self) then 
    if (self.continuous) self.animation_frame = 1
    return true
  end
  self.animation_frame += self.dir
end
function Animator:finished()
  if (self.dir == 1) return self.animation_frame >= #self.data
  return self.animation_frame <= 1
end
function Animator:draw(dx, dy)
  local position,frame = Vec:new(dx, dy),self.data[self.animation_frame]
  if (frame.offset) position += Vec:new(frame.offset)
  spr(frame.sprite,Vec.unpack(position))
end
function Animator:get_sprite()
  return self.data[self.animation_frame].sprite
end
BorderRect = {}
function BorderRect:new(position_, size_, border_color, base_color, thickness_size)
  obj = {
    position = position_, 
    size = position_ + size_,
    border = border_color, 
    base = base_color,
    thickness = thickness_size
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function BorderRect:draw()
  rectfill(
    self.position.x-self.thickness, self.position.y-self.thickness, 
    self.size.x+self.thickness, self.size.y+self.thickness, 
    self.border
  )
  rectfill(self.position.x, self.position.y, self.size.x, self.size.y, self.base)
end
Menu = {}
function Menu:new(
  menu_name, previous_menu, dx, dy, 
  menu_content, menu_info_draw_call, 
  base_color, border_color, text_color, menu_thickness)
  obj = {
    name = menu_name,
    prev = previous_menu,
    position = Vec:new(dx, dy),
    selector = Animator:new(global_table_data.animation_data.menu_selector, true),
    up_arrow = Animator:new(global_table_data.animation_data.up_arrow, true),
    down_arrow = Animator:new(global_table_data.animation_data.down_arrow, true),
    content = menu_content,
    content_draw = menu_info_draw_call,
    rect = BorderRect:new(
      Vec:new(dx, dy), 
      Vec:new(10 + 5*longest_menu_str(menu_content), 38),
      border_color,
      base_color,
      menu_thickness
    ),
    text = text_color,
    pos = 1,
    enable = false,
    ticks = 5,
    max_ticks = 5,
    dir = 0
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Menu:draw()
  if (not self.enable) return
  local top, bottom = self.pos-1, self.pos+1
  if (top < 1) top = #self.content 
  if (bottom > #self.content) bottom = 1
  if (self.content_draw) self.content_draw(self.pos, self.position, self.content[self.pos].color)
  BorderRect.draw(self.rect)
  Animator.draw(self.selector, Vec.unpack(self.position + Vec:new(2, 15)))
  local arrow_offset = (self.rect.size.x + self.rect.position.x)\2-self.up_arrow.sprite_size\2
  Animator.draw(self.up_arrow, arrow_offset, self.position.y-self.rect.thickness)
  Animator.draw(self.down_arrow, arrow_offset, self.rect.size.y-self.rect.thickness)
  local base_pos_x = self.position.x+10
  local menu_scroll_data = {self.dir, self.ticks / self.max_ticks, self.position}
  if self.ticks < self.max_ticks then 
    if self.dir > 0 then 
      print_with_outline(
        self.content[top].text, 
        combine_and_unpack(menu_scroll(12, 10, 7, unpack(menu_scroll_data)), 
        self.content[top].color)
      )
    elseif self.dir < 0 then 
      print_with_outline(
        self.content[bottom].text, 
        combine_and_unpack(menu_scroll(12, 10, 27, unpack(menu_scroll_data)), 
        self.content[bottom].color)
      )
    end 
  else
    print_with_outline(self.content[top].text, base_pos_x, self.position.y+7, unpack(self.content[top].color))
    print_with_outline(self.content[bottom].text, base_pos_x, self.position.y+27, unpack(self.content[bottom].color))
  end
  print_with_outline(
    self.content[self.pos].text, 
    combine_and_unpack(menu_scroll(10, 12, 17, unpack(menu_scroll_data)), 
    self.content[self.pos].color)
  )
end
function Menu:update()
  if (not self.enable) return
  Animator.update(self.selector)
  Animator.update(self.up_arrow)
  Animator.update(self.down_arrow)
  if (self.ticks >= self.max_ticks) return
  self.ticks += 1
end
function Menu:move()
  if (not self.enable) return
  if (self.ticks < self.max_ticks) return
  local _, dy = controls()
  if (dy == 0) return
  self.pos += dy 
  self.dir = dy
  if (self.pos < 1) self.pos = #self.content 
  if (self.pos > #self.content) self.pos = 1
  self.ticks = 0
end
function Menu:invoke()
  local cont = self.content[self.pos]
  if (cont.callback == nil) return
  cont.callback(cont.args and unpack(cont.args))
end
function menu_scroll(dx1, dx2, dy, dir, rate, position)
  local dy1, dy3 = dy-10, dy+10
  local lx = lerp(position.x+dx1, position.x+dx2, rate)
  local ly = position.y + dy
  if dir < 0 then 
    ly = lerp(position.y + dy1, ly, rate)
  elseif dir > 0 then 
    ly = lerp(position.y + dy3, ly, rate)
  end
  return {lx, ly}
end
Vec = {}
function Vec:new(dx, dy)
  local obj = nil
  if type(dx) == "table" then 
    obj = {x=dx[1],y=dx[2]}
  else
    obj={x=dx,y=dy}
  end
  setmetatable(obj, self)
  self.__index = self
  self.__add = function(a, b)
    return Vec:new(a.x+b.x,a.y+b.y)
  end
  self.__sub = function(a, b)
    return Vec:new(a.x-b.x,a.y-b.y)
  end
  self.__mul = function(a, scalar)
    return Vec:new(a.x*scalar,a.y*scalar)
  end
  self.__div = function(a, scalar)
    return Vec:new(a.x/scalar,a.y/scalar)
  end
  self.__eq = function(a, b)
    return (a.x==b.x and a.y==b.y)
  end
  self.__tostring = function(vec)
    return "("..vec.x..", "..vec.y..")"
  end
  self.__concat = function(vec, other)
    return (type(vec) == "table") and Vec.__tostring(vec)..other or vec..Vec.__tostring(other)
  end
  return obj
end
function Vec:unpack()
  return self.x, self.y
end
function Vec:clamp(min, max)
  self.x, self.y = mid(self.x, min, max), mid(self.y, min, max)
end
function Vec:floor()
  return Vec:new(flr(self.x), flr(self.y))
end
function Vec:clone()
  return Vec:new(self.x, self.y)
end
function Vec:distance(other)
  return sqrt((self.x-other.x)^2 + (self.y-other.y)^2)
end
function normalize(val)
  return (type(val) == "table") and Vec:new(normalize(val.x), normalize(val.y)) or flr(mid(val, -1, 1))
end
function lerp(start, last, rate)
  if type(start) == "table" then 
    return Vec:new(lerp(start.x, last.x, rate), lerp(start.y, last.y, rate))
  else
    return start + (last - start) * rate
  end
end
Projectile = {}
function Projectile:new(start, dir_, rot, data)
  local max_d_v = max(abs(dir_.x), abs(dir_.y))
  obj = {
    position = Vec:new(Vec.unpack(start)),
    dir = Vec:new(dir_.x / max_d_v, dir_.y / max_d_v),
    theta = rot,
    sprite = data.sprite,
    size = data.pixel_size,
    height = data.height,
    speed = data.speed,
    damage = data.damage,
    trail = global_table_data.animation_data[data.trail_animation_key],
    lifespan = data.lifespan,
    ticks = 0
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Projectile:update()
  self.ticks = (self.ticks + 1) % self.speed
  if (self.ticks > 0) return
  local hits = {}
  for enemy in all(enemies) do 
    if (Projectile.collider(self, enemy)) add(hits, enemy) 
  end
  if #hits > 0 then 
    for enemy in all(hits) do 
      if enemy.type == 12 then
        enemy.hp -= self.damage / 2
      else
        enemy.hp -= self.damage
      end
      if (enemy.type == 8 and enemy.hp <= 0) del(enemies, enemy)
      break
    end 
    add(particles, Particle:new(Vec.clone(self.position), false, Animator:new(self.trail)))
    del(projectiles, self)
    return
  end
  add(particles, Particle:new(self.position, false, Animator:new(self.trail)))
  self.position += self.dir
  self.lifespan -= 1
  if self.position.x < 0 or self.position.x > 15 or self.position.y < 0 or self.position.y > 15 or self.lifespan < 0 then 
    del(projectiles, self)
  end
end
function Projectile:draw()
  draw_sprite_shadow(self.sprite, self.position*8, self.height, self.size, self.theta)
  draw_sprite_rotated(self.sprite, self.position*8, self.size, self.theta)
end
function Projectile:collider(enemy)
  local self_center = self.position*self.size + Vec:new(self.size, self.size)/2
  local enemy_center = enemy.position*8 + Vec:new(4, 4)
  local touching_distance = self.size+4
  local dist = Vec.distance(self_center, enemy_center)
  return dist <= touching_distance
end
TextScroller = {}
function TextScroller:new(char_delay, rect_data, text_data, color_palette)
  local brect = BorderRect:new(unpack(rect_data))
  obj = {
    speed = char_delay,
    rect = brect,
    color = color_palette or {7, 0},
    char_pos = 1,
    text_pos = 1,
    internal_tick = 0,
    is_done = false,
    width = flr(brect.size.x/5),
    max_lines = flr(brect.size.y/16)-5,
    enable = true
  }
  setmetatable(obj, self)
  self.__index = self
  if (text_data) TextScroller.load(obj, text_data)
  return obj
end
function TextScroller:draw()
  if (not self.enable) return
  BorderRect.draw(self.rect)
  local before = sub(self.data[self.text_pos], 1, self.char_pos)
  local lines, end_text = split(before, "\n"), sub(self.data[self.text_pos], self.char_pos+1, #self.data[self.text_pos])
  local result, line, pos, buffer = before, #lines\2, 1, (#lines[#lines])*5
  for i=1, #end_text do 
    if (line > self.max_lines) break
    if (buffer + pos*9) > self.rect.size.x then 
      result ..= "\n\n"
      line += 1
      pos, buffer = 1, 0
    else
      result ..= chr(204 + flr(rnd(49))) 
    end
    pos += 1
  end
  print_with_outline(result, self.rect.position.x + 4, self.rect.position.y + 4, unpack(self.color))
  if self.is_done then 
    print_with_outline("🅾️ to close", self.rect.position.x + 4, self.rect.size.y - 7, unpack(self.color))
  end
end
function TextScroller:update()
  if (not self.enable or self.is_done or self.text_pos > #self.data) return
  self.internal_tick = (self.internal_tick + 1) % self.speed
  if (self.internal_tick == 0) self.char_pos += 1
  self.is_done = self.char_pos > #self.data[self.text_pos]
  if (self.is_done) TextScroller.next(self)
end
function TextScroller:next()
  if (not self.enable or not self.is_done) return 
  if(self.text_pos >= #self.data) return true
  self.text_pos += 1
  self.char_pos, self.is_done = 1
end
function TextScroller:skip()
  if (not self.enable) return 
  self.char_pos = #self.data[self.text_pos]
end
function TextScroller:load(text, color_palette)
  if text == "" then
    self.is_done, self.enable = true
    return
  end
  if (color_palette) self.color = color_palette
  local counter, buffer = self.width, ""
  for _, word in pairs(split(text, " ")) do
    if #word + 1 <= counter then 
      buffer ..= word.." "
      counter -= #word + 1
    elseif #word <= counter then 
      buffer ..= word
      counter -= #word 
    else
      buffer ..= "\n"..word.." "
      counter = self.width - #word + 1 
    end
  end
  self.data, counter = {}, 0
  local line_buffer, lines = "", split(buffer, "\n")
  for i, line in pairs(lines) do
    if counter <= self.max_lines then
      line_buffer ..= line.."\n\n"
      counter += 1
    else 
      add(self.data, line_buffer)
      line_buffer, counter = line.."\n\n", 1
    end
    if (i == #lines) add(self.data, line_buffer)
  end
  self.char_pos, self.text_pos, self.internal_tick, self.is_done = 1, 1, 0
end
function _init() 
  --[[preserve]]global_table_data=unpack_table(global_table_str)
  --[[preserve]]cartdata(global_table_data.cart_name)
  reset_game() 
end
function _draw()
  cls()
  if game_state == "menu" then 
    main_menu_draw_loop()
  elseif game_state == "credits" then 
    credits_draw_loop()
  elseif game_state == "map" then 
    map_draw_loop()
  elseif game_state == "game" then 
    game_draw_loop()
  end
  TextScroller.draw(text_scroller)
end
function _update()
  if game_state == "menu" then 
    main_menu_loop()
  elseif game_state == "credits" then 
    credits_loop()
  elseif game_state == "map" then 
    map_loop()
  elseif game_state == "game" then 
    if (player_health <= 0) reset_game()
    if shop_enable then shop_loop() else game_loop() end
  end
  TextScroller.update(text_scroller)
  if btnp(🅾️) then 
    if text_scroller.is_done then 
      text_scroller.enable = false
    else
      TextScroller.skip(text_scroller)
    end
  end
end
function main_menu_draw_loop()
  map(unpack(global_table_data.splash_screens[1].mget_shift))
  
  local j, k, l = 1, 0, 0
  for i, letter in pairs(global_table_data.letters) do 
    if (j == 8) j, k, l = 1, 18, 16
    local pos, rot = Vec:new(j*16-8+l-((i == 5 or i == 9) and 2 or 0), letters[i]+k), i == 5 and letter_rot or 0
    draw_sprite_shadow(letter, pos, 4, 16, rot)
    draw_sprite_rotated(letter,pos, 16, rot)
    j+=1
  end
  if menu_enemy then 
    Enemy.draw(menu_enemy, true)
    Enemy.draw(menu_enemy)
  end
  Menu.draw(get_menu("main"))
  print_with_outline("v2.1.0", 1, 122, 7, 1)
end
function credits_draw_loop()
  map(unpack(global_table_data.splash_screens[1].mget_shift))
  print_with_outline("credits", 47, credit_y_offsets[1], 7, 1)
  print_with_outline("project developers", 25, credit_y_offsets[2], 7, 1)
  print_with_outline("jasper:\n  • game director\n  • programmer", 10, credit_y_offsets[3], 7, 1)
  print_with_outline("jeren:\n  • core programmer\n  • devops", 10, credit_y_offsets[4], 7, 1)
  print_with_outline("jimmy:\n  • artist\n  • sound engineer", 10, credit_y_offsets[5], 7, 1)
  print_with_outline("kaoushik:\n  • programmer", 10, credit_y_offsets[6], 7, 1)
  print_with_outline("external developers", 25, credit_y_offsets[7], 7, 1)
  print_with_outline("thisismypassport:\n  • shrinko8 developer", 10, credit_y_offsets[8], 7, 1)
  print_with_outline("jihem:\n  • created the rotation\n  sprite draw function", 10, credit_y_offsets[9], 7, 1)
  print_with_outline("rgb:\n  • created the acos function", 10, credit_y_offsets[10], 7, 1)
end
function map_draw_loop()
  local map_menu = get_menu("map")
  pal(global_table_data.palettes.dark_mode)
  map(unpack(global_table_data.map_data[map_menu.pos].mget_shift))
  pal()
  Menu.draw(map_menu)
  print_with_outline("map select", 45, 1, 7, 1)
end
function game_draw_loop()
  local map_data = global_table_data.map_data[loaded_map]
  local tower_details = global_table_data.tower_templates[selected_menu_tower_id]
  map(unpack(map_data.mget_shift))
  if (manifested_tower_ref == nil and not sell_mode) draw_tower_attack_overlay(tower_details)
  if manifested_tower_ref and manifested_tower_ref.type == "sharp" then 
    draw_line_overlay(manifested_tower_ref)
  end
  foreach(towers, Tower.draw)
  foreach(enemies, function (enemy) Enemy.draw(enemy, true) end)
  foreach(enemies, Enemy.draw)
  foreach(projectiles, Projectile.draw)
  foreach(particles, Particle.draw)
  if (shop_enable) foreach(menus, Menu.draw)
  if not shop_enable and not enemies_active and incoming_hint ~= nil then 
    for i=1, #incoming_hint do 
      Animator.draw(incoming_hint[i], Vec.unpack(
        (Vec:new(map_data.enemy_spawn_location) + Vec:new(map_data.movement_direction) * (i-1))*8
      ))
    end
  end
  ui_draw_loop(tower_details)
end
function ui_draw_loop(tower_details)
  print_with_outline("scrap: "..coins.."  towers: "..#towers.."/64", 0, 1, 7, 0)
  print_with_outline("♥ "..player_health, 103, 1, 8, 0)
  print_with_outline("mode: "..(manifest_mode and "manifest" or "sell"), 1, 108, 7, 0)
  if shop_enable and get_active_menu() then
    print_with_outline("game paused [ wave "..(freeplay_rounds > 0 and freeplay_rounds or wave_round).." ]", 18, 16, 7, 0)
    print_with_outline((get_active_menu().prev and "❎ select\n🅾️ go back to previous menu" or "❎ select\n🅾️ close menu"), 1, 115, 7, 0)
  else -- game ui
    if manifest_mode then
      if manifested_tower_ref then 
        print_with_outline("🅾️ unmanifest", 1, 122, 7, 0)
        print_with_outline(
          Tower.get_cooldown_str(manifested_tower_ref), 
          1, 115, 
          (manifested_tower_ref.type == "tack" and 3 or (manifested_tower_ref.manifest_cooldown > 0 and 8 or 3)), 
          0
        )
      end
      Animator.update(manifest_selector)
      Animator.draw(manifest_selector, Vec.unpack(selector.position))
    end
    if (not manifested_tower_ref) print_with_outline("🅾️ open menu", 1, 121, 7, 0)
    local tower_in_table_state = is_in_table(selector.position/8, towers, true)
    sell_selector.dir = tower_in_table_state and 1 or -1
    if tower_in_table_state and not manifested_tower_ref then 
      if manifest_mode then
        print_with_outline("❎ manifest", 1, 115, 7, 0)
      else
        print_with_outline("❎ sell", 1, 115, 7, 0)
        Animator.update(sell_selector)
        Animator.draw(sell_selector, Vec.unpack(selector.position))
      end
    else
      if sell_mode then 
        Animator.update(sell_selector)
        Animator.draw(sell_selector, Vec.unpack(selector.position))
      else
        if not manifested_tower_ref then 
          local position, color, text = selector.position/8, 7, "❎ buy & place "..tower_details.name
          if tower_details.cost > coins then
            text, color = "can't afford "..tower_details.name, 8
          elseif (tower_details.type == "floor") ~= (grid[position.y][position.x] == "path") then 
            text, color = "can't place "..tower_details.name.." here", 8
          end
          print_with_outline(text, 1, 115, color, 0)
        end
      end
    end
  end
end
function main_menu_loop()
  local map_dat, enemy_temps = global_table_data.splash_screens[1], global_table_data.enemy_templates
  for i=1, #letters do 
    if letters[i] < 15 then 
      letters[i] += 1
    end
  end
  letter_rot = (letter_rot + 15) % 360
  if pathing == nil then 
    pathing = parse_path(map_dat)
  end
  if not menu_enemy then 
    local enemy = enemy_temps[flr(rnd(#enemy_temps))+1]
    menu_enemy = Enemy:new(
      map_dat.enemy_spawn_location, 
      enemy.hp,
      enemy.step_delay \ 2,
      enemy.sprite_index,
      enemy.type,
      enemy.damage,
      enemy.height
    )
  else 
    update_enemy_position(menu_enemy, true)
  end
  Menu.update(get_menu("main"))
  if btnp(❎) then 
    Menu.invoke(get_menu("main"))
  end
  Menu.move(get_menu("main"))
end
function credits_loop()
  if (btnp(🅾️)) game_state = "menu"
  for i=1, #credit_y_offsets do 
    credit_y_offsets[i] -= 1
    if credit_y_offsets[i] < -15 then 
      credit_y_offsets[i] += 270
    end
  end
end
function map_loop()
  local map_menu = get_menu("map")
  Menu.update(map_menu)
  if btnp(❎) then
    Menu.invoke(map_menu)
    map_menu.enable = false
    game_state = "game" 
    return
  end
  if btnp(🅾️) then
    map_menu.enable = false 
    reset_game()
  end
  Menu.move(map_menu)
end
function shop_loop()
  foreach(menus, Menu.update)
  
  if btnp(🅾️) then -- disable shop
    if get_active_menu().prev == nil then 
      shop_enable = false
      menus[1].enable = false
      sfx(8)
      return
    else
      swap_menu_context(get_active_menu().prev)
    end
  end
  if btnp(❎) then 
    Menu.invoke(get_active_menu())
  end
  foreach(menus, Menu.move)
end
function game_loop()
  if (text_scroller.enable) return
  if (auto_start_wave) start_round()
  if btnp(🅾️) then
    if manifested_tower_ref == nil then
      shop_enable = true
      get_menu("game").enable = true
      sfx(7)
      return
    else
      unmanifest_tower()
    end
  end
  if btnp(❎) then 
    if manifested_tower_ref then
      local type = manifested_tower_ref.type
      if type == "tack" then 
        Tower.manifested_nova(manifested_tower_ref)
      elseif type == "rail" then 
        Tower.manifested_lightning_blast(manifested_tower_ref)
      elseif type == "frontal" then 
        Tower.manifested_hale_blast(manifested_tower_ref)
      end
    else 
      local position = selector.position/8
      if is_in_table(position, towers, true) then 
        if manifest_mode then
          manifest_tower_at(position)
        else
          refund_tower_at(position)
        end
      else
        place_tower(position)
      end
    end
  end
  if not lock_cursor then
    selector.position += Vec:new(controls()) * 8
    Vec.clamp(selector.position, 0, 120)
    if manifested_tower_ref then 
      if manifested_tower_ref.type == "floor" then
        Tower.manifested_torch_trap(manifested_tower_ref)
      elseif manifested_tower_ref.type == "sharp" or manifested_tower_ref.type == "clock" then 
        Tower.manifested_sharp_rotation(manifested_tower_ref)
      end
    end
  end
  foreach(towers, Tower.cooldown)
  if enemies_active then 
    foreach(enemies, update_enemy_position)
    foreach(towers, Tower.attack)
    if start_next_wave then 
      start_next_wave = false
      wave_cor = cocreate(spawn_enemy)
    end
    if wave_cor and costatus(wave_cor) ~= 'dead' then
      coresume(wave_cor)
    else
      wave_cor = nil
    end
  end
  foreach(projectiles, Projectile.update)
  foreach(particles, Particle.tick)
  foreach(animators, Animator.update)
  if (not enemies_active and incoming_hint) foreach(incoming_hint, Animator.update)
  foreach(enemies, kill_enemy)
  foreach(particles, destroy_particle)
  if enemies_active and #enemies == 0 and enemies_remaining == 0 then 
    enemies_active = false 
    sfx(6)
    coins += 15
    
    load_wave_text()
  end
end
function print_with_outline(text, dx, dy, text_color, outline_color)
  ?text,dx-1,dy,outline_color
  ?text,dx+1,dy
  ?text,dx,dy-1
  ?text,dx,dy+1
  ?text,dx,dy,text_color
end
function controls()
  if btnp(⬆️) then return 0, -1
  elseif btnp(⬇️) then return 0, 1
  elseif btnp(⬅️) then return -1, 0
  elseif btnp(➡️) then return 1, 0
  end
  return 0, 0
end
function increase_enemy_health(enemy_data)
  local stats = global_table_data.freeplay_stats
  freeplay_mod = max(0, freeplay_rounds - max_waves)
  return 
    {
      enemy_data.hp * ( 1 + (stats.hp - 1) * ((wave_round+freeplay_mod)/15) ),
      max(enemy_data.step_delay-stats.speed*freeplay_mod,stats.min_step_delay),
      enemy_data.sprite_index,
      enemy_data.type,
      enemy_data.damage,
      enemy_data.height
    }
end
function is_in_table(val, table, is_entity)
  for i, obj in pairs(table) do
    if is_entity then 
      if (val == obj.position) return true, i 
    else
      if (val == obj) return true, i 
    end
  end
end
function add_enemy_at_to_table(pos, table, multitarget)
  for enemy in all(enemies) do
    if enemy.position == pos then
      add(table, enemy)
      if (not multitarget) return
    end
  end
end
function draw_sprite_rotated(sprite_id, position, size, theta, is_opaque)
  local sx, sy, shift, sine, cosine = (sprite_id % 16) * 8, (sprite_id \ 16) * 8, size\2 - 0.5, sin(theta / 360), cos(theta / 360)
  for mx=0, size-1 do 
    for my=0, size-1 do 
      local dx, dy = mx-shift, my-shift
      local xx = flr(dx*cosine-dy*sine+shift)
      local yy = flr(dx*sine+dy*cosine+shift)
      if xx >= 0 and xx < size and yy >= 0 and yy < size then
        local id = sget(sx+xx, sy+yy)
        if id ~= global_table_data.palettes.transparent_color_id or is_opaque then 
          pset(position.x+mx, position.y+my, id)
        end
      end
    end
  end
end
function draw_sprite_shadow(sprite, position, height, size, theta)
  local palette = {}
  for i=0, 15 do 
    palette[i] = 0
  end
  pal(palette)
  draw_sprite_rotated(sprite, position + Vec:new(height, height), size, theta)
  pal()
end
function parse_direction(dir)
  if (dir.x > 0) return 90
  if (dir.x < 0) return 270
  if (dir.y > 0) return 180
  if (dir.y < 0) return 0
end
function frontal_apply(vector_data, func)
  local radius, dir = unpack(vector_data)
  local fx, fy, flx, fly, ix, iy = -1, 1, 1, radius, 1, 1
  if dir.x > 0 then -- east
    fx, fy, flx, fly = 1, -1, radius, 1
  elseif dir.x < 0 then -- west
    fx, fy, flx, fly, ix = -1, -1, -radius, 1, -1
  elseif dir.y < 0 then -- north
    fx, fy, flx, fly, iy = -1, -1, 1, -radius, -1
  end
  for y=fy, fly, iy do
    for x=fx, flx, ix do
      if (x ~= 0 or y ~= 0) func(Vec:new(x, y))
    end
  end
end
function nova_apply(radius, func)
  for y=-radius, radius do
    for x=-radius, radius do
      if (x ~=0 or y ~= 0) func(Vec:new(x, y))
    end
  end
end
function combine_and_unpack(data1, data2)
  local data = {}
  for dat in all(data1) do
    add(data, dat)
  end
  for dat in all(data2) do
    add(data, dat)
  end
  return unpack(data)
end
function round_to(value, place)
  local mult = 10^(place or 0)
  return flr(value * mult + 0.5) / mult
end
function check_tile_flag_at(position, flag)
  return fget(mget(Vec.unpack(position)), flag)
end
function load_wave_text()
  if (freeplay_rounds > 0) return
  local text_place_holder = global_table_data.dialogue[global_table_data.level_dialogue_set[cur_level] or "dialogue_level4"][wave_round]
  if text_place_holder then 
    text_scroller.enable = true
    TextScroller.load(text_scroller, text_place_holder.text, text_place_holder.color)
  end
end
function acos(x)
  return atan2(x,-sqrt(1-x*x))
end
function save_byte(address, value)
  poke(address, value)
  return address + 1
end
function save_int(address, value)
  poke4(address, value)
  return address + 4
end
function encode(a, b, a_w)
  return (a << a_w) | b
end
function decode(data, a_w, b_mask)
  return flr(data >>> a_w), data & b_mask
end
function unpack_table(str)
  local table,start,stack,i={},1,0,1
  while i <= #str do
    if str[i]=="{" then 
      stack+=1
    elseif str[i]=="}"then 
      stack-=1
      if(stack>0)goto unpack_table_continue
      insert_key_val(sub(str,start,i), table)
      start=i+1
      if(i+2>#str)goto unpack_table_continue
      start+=1
      i+=1
    elseif stack==0 then
      if str[i]=="," then
        insert_key_val(sub(str,start,i-1), table)
        start=i+1
      elseif i==#str then 
        insert_key_val(sub(str, start), table)
      end
    end
    ::unpack_table_continue::
    i+=1
  end
  return table
end
function insert_key_val(str, table)
  local key, val = split_key_value_str(str)
  
  local value
  if val[1] == "{" and val[-1] == "}" then 
    value = unpack_table(sub(val, 2, #val-1))
  elseif val == "true" then 
    value = true 
  elseif val == "false" then 
    value = false 
  elseif value == "inf" then 
    value = 32767
  elseif value == "nil" then 
    value = nil
  else
    value = tonum(val) or val
  end
  
  if key == nil then
    add(table, value)
  else  
    table[key] = value
  end
end
function convert_to_array_or_table(str)
  local internal = sub(str, 2, #str-1)
  if (str_contains_char(internal, "{")) return unpack_table(internal) 
  if (not str_contains_char(internal, "=")) return split(internal, ",", true) 
  return unpack_table(internal)
end
function split_key_value_str(str)
  local parts = split(str, "=")
  local key = tonum(parts[1]) or parts[1]
  if str[1] == "{" and str[-1] == "}" then 
    return nil, convert_to_array_or_table(str)
  end
  local val = sub(str, #(tostr(key))+2)
  if val[1] == "{" and val[-1] == "}" then 
    return key, convert_to_array_or_table(val)
  end
  return key, val
end
function str_contains_char(str, char)
  for i=1, #str do
    if (str[i] == char) return true
  end
end
__gfx__
11221122888778880077000000a99a000001100000033000777000000000000000000000ccc11ccc70000000a0000000000000000000d000000d000000d00000
112211228000000807887000069999600001100000033000788770007777700000000000c000000c7a0a0000aa000a000000a000000d200000d2d00000d20000
221122118000000807888700061111600cc66cc000033000788887707888877077777770c000000c97aaa0007aa0aaa09a00aa0000d21d0000d12dd000d12ddd
22112211700000070078887000999900ccc11ccc06b33b6007888887078888870788888710000001097aaa007aaaaaaa097aa770d21002d00d20012d00200120
1122112270000007007888700099990000c11c00063333600788888707888887078888871000000100979aa07a07a0970097a0990d20012dd21002d002100200
112211228000000807888700069999600001100006333360788887707888877077777770c000000c0009097a970090070009700000d12d000dd21d00ddd21d00
221122118000000807887000068998600001100006333360788770007777700000000000c000000c0000009709000009000090000002d000000d2d0000002d00
2211221188877888007700000000000000c11c0006333360777000000000000000000000ccc11ccc000000090000000000000000000d00000000d00000000d00
00000d00001000000000000a0a000000000000000000000000080000000800808800008800077000000770000000000055555555555555555555555500000000
00000dd0011000000000007556000000000770777700777000880008888800888780087800077000000770000000000055666651556666515566665100000000
000002dd1110000000000655556a0000077777c7c77c766700800888998000080878878000077000000770000000000056666661566666615666666100000000
0000022dd110000000000aa55aaaa00007ccc76ccc667c7000008899998800000087780077777000000777770007777756666661566666615666666177777000
00000222dd10000000a99a9a9999940001667667c667cc1000888999a99800080087780077777000000777770007777756666651556666515566666177777000
11111d222dd222dd0a0aaa05500000a0011677c66677c1100888999aa99880880878878000000000000000000007700056666511511111115556666100077000
0111dd2002222dd000a7aaa7777770000116c7c7767cc110888999aaaa9988808780087800000000000000000007700055665166666666666655665100077000
001ddd000022dd000066777aaaa7660001166777c77c111088899aa7aa9998888800008800000000000000000007700051111160000000000611111100077000
00dd2200002dd100000000055000aa0001116c7cc7cc11108899aa77aaa9988888000088111dd111000000000000000055555560000770000655555500000000
0dd2222002dd11100009999999aaa0a00111cc7c77cc1110089aaa777aa998808788887810000001066666666666666055665160000770000655665100000000
dd222dd222d111110044aaa4444444a001111cc777c11110089aa77777aa99880870078010000001065555555555556056666160000770000656666100000000
000001dd222000000a0000055000000000111c7777c111000899a777777a998808000080d000000d065566515566516056666160000770000656666177777777
0000011dd2200000a07777aa7777770000111cccc7c111000889a777777a998008000080d000000d065666615666616056666160000770000656666177777777
00000111dd20000006aa77777777776000011cccc7c110000089aa77777a98800870078010000001065666615666616056666160000770000656666100000000
000001100dd000000a666666666a66a0000111cccc11100000089a7777a998008788887810000001065566515566516055665160000770000655665100000000
0000010000d00000aaaaaa0550aa0a0a0000111cc1110000000089a77a99800088000088111dd111065111115111116051111160000770000651111100000000
0c667670660007760000c00000800000000080008000008000000000000000008800008822266222065555555555556055555560000000000655555555555555
ccc66c7006777766066ccc0000088000000880080008880000077000077007708887788820000002065566515566516055665566666666666655665155666651
7c67ccc0677767700777c60000008808000888000088800000788700788778870800008020000002065666615666616056666555555555555556666156666661
76766c6707c777706c76776000888800008888000888880007888870788888870700007060000006065666615666616056666651556666515566666156666661
776777767ccc7c60ccc77760008998800889998008a9998078888887078888700700007060000006065566515566516056666661566666615666666156666661
766767c707c7ccc60c7676700899a980089aa98008aaa98078877887007887000800008020000002065111115111116056666661566666615666666156666661
67776ccc07777c7000067700089a7a8008a7aa80087a7a8007700770000770008887788820000002066666666666666055666651556666515566665155666651
007677c6006707770000000000877a8000877a000087780000000000000000008800008822266222000000000000000051111111511111115111111151111111
05c11c5000c66c00000220000066070000367b008067608002667720000110000028780000036000001dd10060600606000000d0000200000d200000000000d0
05777650d666666da02c620a0006770003ccc7b065777560d666667d0016710000a2890000063000059a7a5060600606d2210d2000dd20000d2210ddd2210d20
00cccc00d6cccc6d82ccc6280077600003cccc309a9aaaa0d662266d0165571004a9a9400003600005d9ad50665775660d11d120001d11d000d11d220d11d120
00777600d676676d82d44d285075660505333350595a5a50d625526d01511510041dd140000360000dd11dd00615116000d00110021002dd0110012000d00110
00777600067667604242242456b3b3655a5335a55595a550524444221511115100122100008368000d1cc1d05061560501100d00dd2001200210011001100d00
057776500676676024288242503bbb059a9339a960585060d227622d15111151049a9a40088368800d1cc1d016615661021d11d00d11210022d11d00021d11d0
051cc150d67cc76d22a9a9225633b3654933339460898060d526722d1111111104a00940080a908005d11d505665166502d0122d0002dd00dd0122d002d0122d
00000000d610016d208a980250a33a05d943349d00080000d057250d101001010000000000a9a900059dd950106156010d0000000000d000000002d00d000000
00077000000000000007700000056000000560000000a0000000000000000000001aa1000066666000055000006d0600067c606000ccc70000a55a0000ac7a00
0078870000000000007887000095690000056000099aaa0008000080080000800179971006555552052222500006dd0067ccc670077c77700d5445d009cccc90
07866870000000000786687000056000000560000888a90000890800008998001777577166404042025dd52000dd6000607c77077777c7760d5555d0accaacca
07600670000000000760067000956900000560009a8988900089980000809800177757716644444252d55d25056ad6500177c7107177c716005445009c99aaca
0000000000000000000000000005600000056000aaa888900899098008999980177755716622222252d55d250522a2500117c11061177110004444009a988aa9
00000000000000000000000000d56d0000d56d000a89898008999980089099801777777104666606025dd52000aaaa0001111110011111100d4554d09282282a
00000000000000000000000000d56d000dd56dd0000988008990999889999998017777100455552505222250052a225001111110011111100d4554d02a2a9292
00000000000000000000000000d56d000d0560d00000000008899880088908800011110000440424000550000522a2500011110000111100000000000909a0a0
00000000000000000000000000000007700000009900088900000000000000000000000aaa0000000000002552000000090490a00a0940a00555550000555500
0000000000000000000000000000000660000000098888990088999990998800000b0b00a00b00b000052225522250000a09a00a090a90000068880000686800
00000000000000000000000000000f5665f0000098889880000089999998000000b0b00a9a00bb000025222552225200a05776009067750a006a99a000666600
000000000000000000000000000009566590000008a88880000008990980000000b00019491000b000252dddddd25200000a90000009a0090ba9aa9a0b3333b0
00000000000000000000000000000456654000008aaa8a90000008999980000000001177d77110000225ddd55ddd522000577600006775000ba9aa9a011111e8
000000000000000000000000000000566500000008a8aaa900008899998800000001176757671100522dd555555dd225009aa900009aa90000ba99a000b33b00
00000000000000000000000000000f5665f0000008888a800088899999988800000176775776710052dd55500555dd2506777550057776600650065006500650
0000000000000000000000000000095665900000009808880888999099998880001767775777671052dd55000055dd2500094000000490000560056005600560
00000000000000000000000000000456654000000a9989800889099999999880001777775777771052dd55000055dd2500080000000080000000800000000800
0000000000000000000000000000005665000000aaa99a808899999999999988001d777705557d10522dd550055dd22500698600006896000065890000659800
00000000000000000000000000000d5665d000008a98aaa0889999999999998800177777777777100225dd5555dd5220068a9160068a916006189a6006198960
00000000000000000000000000001d5665d1000089899a988899909999099988001767777777671000252dd55dd252000589a9500598a950059a8850059a9850
00000000000000000000000000011d5665d110008898888908899999999998800001767777767100002522dddd225200059a7a50059a7a5005a7a95005a7a950
00000000000000000000000000011d5665d11000899898a80888999999998880000117677767110000052225522250000619a1600619a160061a9160061a9160
00000000000000000000000000011d5665d1100098889aaa000889999998800000001177d7711000000002255220000000655600006556000065560000655600
00000000000000000000000000011d5665d11000008988a900008888888800000000001111100000000000255200000000000000000000000000000000000000
b3333b33b3333b33b3333b33aaaaaa9aaaa77a9ab3b3b333b3433b3333aab3a3aaa9aaaaaaa9aaaaaa333b33b3333baa738493a30b33333000000000003b3b00
3333b33b3333b33b3333b33ba9aaa9a9a9a779a93b33333b3484338ba9aaa9a9aa9a9aaaaa9a9aaaaaa3b33b3333baaabb4663bb0b333330666666600383bbb0
33b333b333b333b333b333b39a9aaaaa9a977aaa33b3b3b3334338989a9aaaaaaaba33a33aba339aaab333b333b3339a3967c63a0b33333055555560333bb8b3
3b33333b3b33333b3b33333b77777aaa777777773b3b333b3b3d338377777777aa33333b3b3339a9aa33333b3b3339a9346cc6b30b33333050660160b8bb8bbb
33333b3333333b3333333b3377777aaa77777777b3b33bb3b3dcdb3377777777aaa33b3333333baaaaa33b3333333baa9346639300b3330056016160333bbb8b
3b33b3333ba3a3a33b33b333aaa77a9aaaa77a9a3b33b33b333db33baaaaaa9aa933b3333b33b3aaa933a3a33ba3a3aa38444333000bb000561061603383b3b8
b33b33baaaa9aaaaa33b33b3a9a779a9a9a779a9b33b33b3b33b33b3a9aaa9a99a9b33b3b33b3aaa9a9a9aaaaaa9aaaa3333433300049000506601600b349bb0
33b33baaaa9a9aaaaab33b339a977aaa9a977aaa33b33b3333b33b333ab3aa33aab33b3333b33baaaaa9a9aaaa9a9aaa33333333004999005111116000049000
b3333baaaaa77a9aaa333b33aaaaaa9a5555555558585555889779885777777157777771555555556666666176c6c6d57777776633333333333333330303bb00
3333baaaa9a779a9aa33b33ba9aaa9a9555555558555855558292982576666615111111177777777600b0061766666d57ddddd5633bbbb3333bbbb33003b3ba0
33b3339a9a977aaaaaa333b39a9aaaaa55555555585885555152521551111111506060617aa2e88760bbb06176c6c6d5777777663b8bbb833bb333b30b34b3ba
3b3339a9aaa77aaaa933333b777777775555555555888855511555655a0a0a045666666171a22887600b006176c6c6d5766666d53b3bbb333bb333b3033b39a0
33333baaaa977aaa9a933b33777777775555555555899855569999655a999994506060617777777760000061766666d576c6c6d53bbb8bb33bb333b300b39b30
3b33b3aaaaa77a9aaa33b333aaaaaa9a55555555589aa985568998655a090904566666617ccccccc66616b61765556d576c6c6d533bb3b3333bb3b330034ba00
b33b3aaaa9a779a9aaab33b3a9aaa9a95555555589a7aaa8555555555a999994506060617c0c0c0c55565555765556d5766666d5333493333334933300044000
33b33baa9a977aaaaab33b339a9aaaaa55555555897777985555555566ddddd4511111117ccccc0c5666661566dddd5576c6c6d5334999333349943300044000
b3333baaaaa9aaaaaa333b33b3333b33000aa000000000050000000055555555000770000000000000000000dddddddd000aa000000000000000000022222222
3333b33aaa9a9aaaa333b33b3333b33b000aa000000000000000000055455555000770000000000000000000ddddddd1000aa000000000000000000022888820
33b333b33aba33a333b333b333b333b3000aa000000000000000000054555555000770000000000000000000ddddddd1000aa000000000000000000028888880
3b33333b3b33333b3b33333b3b33333b000aa000aaaaa000aaaaaaaa54555545000770007777700077777777ddddddd1000aa000aaaaa000aaaaaaaa28888880
33333b3333333b3333333b3333333b33000aa000aaaaa000aaaaaaaa59955455000770007777700077777777ddddddd1000aa000aaaaa000aaaaaaaa28888880
3b33b3333b33b3333b33b3333b33b333000aa000000aa0000000000055555455000770000007700000000000ddddddd1000aa000000aa0000000000028888880
b33b33b3b33b33b3b33b33b3b33b33b3000aa000000aa0000000000055555995000770000007700000000000ddddddd1000aa000000aa0000000000022888820
33b33b3333b33b3333b33b3333b33b33000aa000000aa0000000000055555555000770000007700000000000d1111111000aa000000aa0000000000020000000
b3363b33aaa77a9aaaa77a9aaaaaaa9a55555555000aa000000aa00050000000dddddddd00077000000770000000000022222222000aa000000aa00000000000
3367633ba9a779a9a9a779a9a9aaa9a955555555000aa000000aa00000000000dd1dddd100077000000770000000000022dddd20000aa000000aa00000000000
33b633439a977aaa9a977aaa9a9aaaaa54455455000aa000000aa00000000000ddd1d1d10007700000077000000000002dddddd0000aa000000aa00000000000
3b33348477777aaaaaa77777aaa7777754445445aaaaa000000aaaaa000aaaaadd1d1dd17777700000077777000777772dddddd0aaaaa000000aaaaa000aaaaa
b3933b4377777aaaaa977777aa97777754944444aaaaa000000aaaaa000aaaaaddddd1d17777700000077777000777772dddddd0aaaaa000000aaaaa000aaaaa
39a9b33baaaaaa9aaaaaaa9aaaa77a9a549949440000000000000000000aa000ddddd1d10000000000000000000770002dddddd00000000000000000000aa000
b39b33b3a9aaa9a9a9aaa9a9a9a779a9499949490000000000000000000aa000ddddddd100000000000000000007700022dddd200000000000000000000aa000
33b33b339a9aaaaa9a9aaaaa9a977aaa999999490000000550000000000aa000d1111111000000000000000000077000200000000000000000000000000aa000
22222222222200002222222222222000222220002222200022222222222220002222222222222220000000000000000000000000000000000000000000000000
87788888888200008778888887782000877820008778200087788888877820008778888888877820000000000000000000000000000000000000000000000000
77178888888200007717888877172000771720007717200077178888771720007717888888771720000000000000000000000000000000000000000000000000
71778888888200007177888871772000717720007177200071778888717720007177888888717720000000000000000000000000000000000000000000000000
87788888888200008778888887782000877820008778200087788888877820008778888888877820000000000000000000000000000000000000000000000000
88820000000000008888200088882000888820008888200088882000000000008888200000888820000000000000000000000000000000000000000000000000
88820000000000008888200088882000888820008888200087782222222220008888200000000000000000000000000000000000000000000000000000000000
88822222222000008888200088882000888820008888200077178888877820008888200022222220000000000000000000000000000000000000000000000000
877888888820000087782222877820008888200088882000717788887717200088882000888888200000000000000000000000000000000000000000bbb33bbb
771788888820000077178888771720008888200088882000877888887177200088882000888888200000000000000000000000000000000000000000b000000b
717788888820000071778888717720008888200088882000000000008778200088882000008888200000000000000000000000000000000000000000b000000b
87788888882000008778888887782000888820008888200022222222888820008888222222888820000000000000000000000000000000000000000030000003
88820000000000008888288882000000877822228778200087788888877820008778888888877820000000000000000000000000000000000000000030000003
888200000000000088882088882000007717888877172000771788887717200077178888887717200000000000000000000000000000000000000000b000000b
888200000000000088882008888200007177888871772000717788887177200071778888887177200000000000000000000000000000000000000000b000000b
888200000000000088882000888820008778888887782000877888888778200087788888888778200000000000000000000000000000000000000000bbb33bbb
222220000022222022222222222222202222222222220000000000000aa799000000000000000000000000000000000000000000000000000000000000000000
88882000008888208888887788888820877888888882000000000000aa7990000000000000000000000000000000000000000000000000000000000000000000
8888200000888820888887717888882077178888888200000000000aa79900000000000000000000000000000000000000000000000000000000000000000000
888820000088882088888717788888207177888888820000000000aa799000000000000000000000000000000000000000000000000000000000000000000000
88882000008888208888887788888820877888888882000000000aa7990000000000000000000000000000000000000000000000000000000000000000000000
8888222222888820000008888200000088882000000000000000aaa9900000000000000000000000000000000000000000000000000000000000000000000000
877888888887782000000888820000008778222222220000000aaa99000000000000000000000000000000000000000000000000000000000000000000000000
77178888887717200000088882000000771788888882000000aaaaaaaa7770000000000000000000000000000000000000000000000000000000000000000000
71778888887177200000088882000000717788888882000000aaaaaaaaa790000000000000000000000000000000000000000000000000000000000000000000
87788888888778200000088882000000877888888882000000aaaaaaaa7990000000000000000000000000000000000000000000000000000000000000000000
8888200000888820000008888200000088882000000000000000000aa79900000000000000000000000000000000000000000000000000000000000000000000
888820000088882000000888820000008888222222220000000000aa799000000000000000000000000000000000000000000000000000000000000000000000
88882000008888200000088882000000877888888882000000000aa7990000000000000000000000000000000000000000000000000000000000000000000000
8888200000888820000008888200000077178888888200000000aa79900000000000000000000000000000000000000000000000000000000000000000000000
888820000088882000000888820000007177888888820000000aa799000000000000000000000000000000000000000000000000000000000000000000000000
88882000008888200000088882000000877888888882000000aa7990000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000001010102020201000000000000000000000202020102010000000000000000000002020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020101020201020202020202020202010201020202020202000202020202020202020101010201010102010101020201010102010101020101010201010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1d1d1d1d1d1d1d1d1d1d1d1d1e3f3f3f81818181818181818181818182a3a386a7a7a794a7a7b4a7a7a7b499a794a7b4ababababb8abababababb8ababababb8afafafafafafafafafafafafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f1f2e3f3f3f93939393939393939393938392b09ea3a6a6a6a6a594a79a94a7a794b4a794a7aaaaaaaaaaaaaaaaa9abababababababaeaeaeaeaeaeadafafbfaeaeaeaeaeae000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d3d3d3d3d3d3d3d3d3d8e2d2e3f3f3fa1a1a1a1a1a1a1a1a1a18991928586a3a794b4a7a4a7a7b49494b7a6a6a6a6a6abababababb8ababbaaaa9abb8abababafafafafafafacbcbcacafafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f2c2d2e3f3f3fa3a3a3a3a386a3b085a3909192a385b0a7a7a7a7a4b4a7a7a7a7a494a7a794a7abababb8ababababb8aba8abababb8abafafafafafafacbcbcacafafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f2c2d2e3f3f3f9ea386a3a385a3a385a3909192a3b0a3a7b4a794b6a6a6a5a7a7b6a6a5a7a798abb8ababababababababa8abababababafafafafbfaebdbcbcbeaeadafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f1c1d1d1d1d1d3b2d2e3f3f3fa385a3a38081818181818b918a818182a7a795b494b494a4b4a794a7a4b4b4a7abababababb8ababbbaab9abababababafafafafacbcbcbcbcbcbcacafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c1b2f2f2f2f2f192e3f3f3fa3a385a390b393939393938493938392a7a796a7a79494a4a794b494a494b4a7aaaaaaaaaaaaaaaab9abababababababafafafafbeadbcbcbcbcbfbdafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c2d2a3d3d3d3d3d3e3f3f3fa3b0a386909188a1a1a1899188899192a79494a7a7b494b6a6a6a6a6b594b494abababababababababb8ababababb8abafafafafafacbcbcbcbcacafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c2d2e3f3f3f3f3f3f3f3f3fa3a385a3909192b085b0909192909192b49794b49494a794949494b494a79494abababababababababababb8ababababafafafafafbeadbcbcbfbdafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c2d2e3f3f3f3f3f3f3f3f3fa386a3a3909192a386a3909192909192a7a7a79498b494a7b4a794a7a7b495a7ababb8ababb8abb8ababababababb8abafafafafafafacbcbcacafafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c2d3a1d1d1d1d1d1d1d1d1d9ea3a38590918a8181818b919290918a94a794a794949494a794b4a7a79496a7abababb8ababababababababababababafafafafafafacbcbcacafafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c1a2f2f2f2f2f2f2f2f2f2fa3b0a38690b29393939393b19290b293a7a7b4a7b4a794a7a795a794b4b4a794abababababababababababb8b8abababafafafafafafacbcbfbdafafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3c3d3d3d3d3d3d3d3d3d3d3da3a3a3a3a3a1a1a1a1a1a1a1a2a0a1a1a794b495a7b4a7a7a796b4a799a794a7ababb8ababababb8ababababababababafafafafafafbeaebdafafafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3fa3a3a39ea3b0a3a385a3a3a386a3b0a3b4a7949794b49494b494a794a7b495a7ababababababababababababababb8abafafafafafafafafafafafafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3fa3a3b0a3a3a3a3b0a38685a3a3859eb094a79494a7a7a797a7a7a7b4949498b4ababababb8ababababb8ababababababafafafafafafafafafafafafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3fa3a3a386a385a3a3a3859ea3b0a3a3a3a7b4a7a7a794b4a7a7b4a7a7a794a7a7ababababababababababababababababafafafafafafafafafafafafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3fab3fababb8abababa7a7
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3f3fabababb8b8a794a794
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3fababababa7aba7a7b4a7
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3fab3fababb8ababa794a7a3a7
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3fabababababa7a7b4a794a7
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3fababababab94a7a7a7b486
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3fabb8ababa794a7a3a785a3
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002f2faaaaaaaaaaaaa6a6a6a6a6878787
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3fabababb8aba794a7b4a3a3
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3fababb8aba7b4a7a7a3b085
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3fababababa7a785a7a386
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3fababb8b894b4a79485a3
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3fabababb894a7a794a394b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3f3fabababb8b4a7b4a7a3
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3fabababababa794a7b4a3
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3f3f3fababa7abb894a7b4
__sfx__
000600001e0511b051180511105100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000200c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c043000000000000000
291000000000000000021400202502110020400212002015021400202502110020400212002015021400201002140020200211502040021200201002140020250211002040021250201002140020100214502013
9110000021040211201d11021040230201c11021140230201a0101a140211202301024040241202f1102d04021040211201d11021040230201c11021140230201a0101a140211202301024040241202f1102d040
011000000000000000280452302524015210452302523015280452302524015210452302523015280452302524015210452302523015280452302524015210452302523015280452302524015210452302523015
06010000163300a23006220056300363002620016100460002600016000160001600016000060000600006003f7003f5003f7003f70034700327002e6002b2002820025200212001d2001a2001f7000000000000
9f0200000c2400e2401054011530130301503017720187201a7201c72000000000000000000000000000000000000000000000000000000003220032200322003220032200322003220032200312003120031200
00030000160201d0201d7001d7001e7001e7001c7001c70021700207001e7001c7001b7001970018700167001470013700117000f7000d7000c70000000000000000000000000000000000000000000000000000
48030000130201b02032300283002d30022300283001f300243001e30018300183001830000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
480300000c620247200c620026000160000600000000000000000000000000000000000001e600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
791700000b4300000000000000000000000000000000000000430000000000000000000000000000000000000b430000000000000000000000000000000000000043000000000000000000000000000000000000
0017000010550105300b5101055010530105100b5501053013510135500e5301351013550135300e5101355010530105100b5501053010510105500b5301051013550135300e5101355013530135100e55013530
00170000131400b14000100001000e140001000010000100171400c140001000010011140151401714011140171400010000100001000e1400010000100001001714011140001000010015140171401514011140
00170000105501052017530105501052010530175501052013530135500e5201353013550135200e5301355010520175301055010520105301755010520105301055017520105301055010520175301055010520
001700000b0400000000000000000e0400000000000000000c040000000000000000110401504017040150400b040000000000000000000000000000000000000c0400000000000000000e040000000000000000
0017000018040000000000000000180400c040130400c040170400000000000000001704015040170401104013040000000000000000100400000000000000001004000000000000000007040000000000000000
011700000954110520095100954009520105100954009520095101054009520095100954010520095100954009520105100954009520095101054009520095100954010520095100954009520105100954009520
011700001804000000000000000018040180401f04018040230400000000000000002304021040230401d0401f0400000000000000001c040180401f040180401c0400000000000000001f040210402304021040
01170000155400000000000000001554015540135401554017540115401154000040000000c540115401354015540000000000015540005001554013540155400e54011540175401d54023540245402654015540
011700000c0400c020090100c0400c0200c010090400c0200b0100b040070200b0100b0400b020070100b0400c0200c010090400c0200c0100c040090200c0100b0400b020070100b0400b0200b010070400b020
0017000018540135400000000000175400e540000000000018540105401154000000185401c5401a540185401a54017540175401754017540175401a5401d5401d5401a54000000000001d540175400000013540
00170000050400002002030040400502005030000400902005030090400702005030000400b020090300704005020000000503000000050400000005020000000503005040050200503005040050200503005040
01170000134200e41000000000000c41011420000000000017420114100000000000134200e4100000000000114200c4100000000000134200e41000000000000c41011420000000000017420114100000000000
0017000018125000001c125000001d1250000017125000001c125000000000000000181250000000000000001712500000000000000018125000001c12500000171250000000000000001c125000000000000000
00170000134200e41000000000000c410114200000000000134200e4100000000000000000000000000000000c41011420000000000011410174200000000000134200e41000000000000c420114100000000000
0017000018125000000000000000171250000000000000001812500000000001c125000001d1250000000000171250000000000000001c1250000000000000001812500000000000000017125000000000000000
001700001c420214200000000000234201d420000000000021420264200000000000244202342000000000001842000000174200000018420000001842000000244201c42000000000001d420264200000000000
001700000e13500000151250000017125000001012500000171250000018125000001412500000171251a135091250000511125000050e1250000515125000051712500005101250000517125000051812500000
0117000026410214200000000000244102342000000000001d420184201741000000184201841000000000001d420184101142013420184101b4201f4201c41017420104201141017420184201d4101342011410
00170000141250000517125000051a12500005000050000509125000050000500005000051112500005000050b125000050000500005000050c1250000500005091250000500005000050b125000050812500000
0017000011400000001d420000001d4201342018410194201c4201741010420114201741000000184201d4200e410154200000011420144100000015420000001342011410000000000011410114001141000000
01170000000000010009110000000b125000000c125000000912500000000000000000000000000b125000000b125000000000000000000000000000000000000000000000000000000000000000000000000000
0017000010540000000b5200000015530000000c5100000011540000000e520000000b530000000b5100000010540000000b5200000015530000000c5100000011540000000e520000000b530000001751000000
001700000c045000000c045000000c045000000c045000000c045000000c045000000c045000000c045000000c045000050c045000050c045000050c045000050c045000050c045000050c045000050c04500000
0017000013540000000e5200000010530000000b5100000011540000000e520000001153000000105100000013540000000e5200000010530000000b5100000011540000000e5200000015530000001051000000
0017000009045000051504500005090450000515045000050b0450000517045000050b04500005170450000509045000051504500005090450000515045000050b0450000517045000050b045000051704500005
00170000135400b520135300b510135400b520155301051015540105201553010510155400c520155300c510155400c520155300e510115400e520175300e510155400e520115300e510175400e5200000000000
001700000c04500000180450000028045000050e045000051a045000052904500005070450000513045000050c04500005180450000528045000050e045000051a04500005290450000507045000051304500000
00170000115401352015530175100e54017520115300e5101554013520115301051013540155200e53010510115401352015530175100e54017520115300e5101554013520115301051013540155200e53010510
001700000c0450000513045000051504500005130450000515045000051004500005110450000513045000050c045000051304500005150450000513045000051504500005100450000511045000051304500005
011700001554013520115300000010540115201353000000155401352011530000001054011520135300000015540135201153000000105401152013530000001554013520115300000010540115201353000000
011700000c045180450000000000000000000000000000000c045180450000000000000000000000000000000c045180450000000000000000000000000000000c04518045000000000000000000000000000000
00170000100400b040130400e040120400d0400604012040100400b040130400e040120400d0400604012040100400b040130400e040120400d0400604012040100400b040130400e040120400d0400604012040
2417000010330173201c320133101f3301e3201a320173100e330153201a320123101e3301c3201a320153100c330133201c3201a3101f3301e3201a320133100c330133201c3201a3100c330133201c3201a310
241700001f3301e3201a320133100c330133201c3201a3100c330133201c3201a3101f3301e3201a320133100c330133201c3201a3100c330133201c3201a3101f3301e3201a320213101f3301e3201a32015310
2417000013330123200e3300e3100e3300e3100e3300e31010332103101033017310173321731015330153101a3321a3101a33018310183321831017330173101833218310183301a3101a3321a3101032010310
241700001a3321a3101a330000001533215310153301531010332103101033017310173321731015330153101a3321a3101a3301c3101c3321c3101e3301e3101333213310133301531015332153101733017310
2417000000000000000e3200e3100e3400e3300e3200e3100e3400e3300e3200e3100e3400e3300e3200e31000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000001020184201f4201842008020000100260001600016000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 01464344
00 01024344
00 01024344
00 01024304
00 01024304
00 01424304
00 01424304
00 01420304
00 01420304
00 01020304
00 01020304
00 01020344
00 01020344
00 01420344
02 01420344
01 0a0b4344
00 0c0b4344
00 0e0d4344
00 11104344
00 100f4344
00 12134344
02 14154344
01 16174344
00 18194344
00 1a1b4344
00 1c1d4344
02 1e1f4344
01 20214344
00 20214344
00 22234344
00 24254344
00 24254344
00 26274344
02 28294344
01 2a424344
00 2b2a4344
00 2c2a4344
00 2d2a4344
00 2a2e4344
02 2f2a4344
