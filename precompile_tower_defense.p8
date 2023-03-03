pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
function choose_tower(id)
  selected_menu_tower_id = id
  get_active_menu().enable = false
  shop_enable = false
end
function display_tower_info(tower_id, position, text_color)
  local position_offset = position + Vec:new(-1, -31)
  local tower_details = global_table_data.tower_templates[tower_id]
  local texts = {
    {text = tower_details.name}, 
    {text = tower_details.prefix..": "..tower_details.damage}
  }
  local longest_str_len = longest_menu_str(texts)*5+4
  BorderRect.resize(
    tower_stats_background_rect,
    position_offset, 
    Vec:new(longest_str_len + 20,27
  ))
  BorderRect.draw(tower_stats_background_rect)
  print_with_outline(
    tower_details.name,
    combine_and_unpack({Vec.unpack(position_offset + Vec:new(4, 2))},
    text_color
  ))
  print_with_outline(
    texts[2].text,
    combine_and_unpack({Vec.unpack(position_offset + Vec:new(4, 14))},
    {7, 0}
  ))
  print_with_outline(
    "cost: "..tower_details.cost, 
    combine_and_unpack({Vec.unpack(position_offset + Vec:new(4, 21))},
    {(coins >= tower_details.cost) and 3 or 8, 0}
  ))
  spr(
    tower_details.icon_data, 
    combine_and_unpack(
      {Vec.unpack(tower_stats_background_rect.position + Vec:new(longest_str_len, 6))},
      {2, 2}
  ))
end
function display_tower_rotation(menu_pos, position)
  local tower_details = global_table_data.tower_templates[selected_menu_tower_id]
  local position_offset = position + Vec:new(0, -28)
  BorderRect.reposition(tower_rotation_background_rect, position_offset)
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
  if cur_level == 2 then
    wave_set_for_num = 'wave_data_l2'
  elseif cur_level == 3 then
    wave_set_for_num = 'wave_data_l3'
  elseif cur_level == 4 then
    wave_set_for_num = 'wave_data_l4'
  elseif cur_level == 5 then
    wave_set_for_num = 'wave_data_l5'
  else
    wave_set_for_num = 'wave_data'
  end
  max_waves = #global_table_data[wave_set_for_num]
  wave_round = min(wave_round + 1, max_waves)
  if (wave_round == max_waves or freeplay_rounds > 0) freeplay_rounds += 1
  if (freeplay_rounds > 0) then
    wave_round = max_waves
    wave_round -= flr(rnd(3))
  end
  enemies_remaining = #global_table_data[wave_set_for_num][wave_round]
  get_active_menu().enable = false
  shop_enable = false
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
  get_active_menu().enable = false
  get_menu(name).enable = true
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
        color = con.color,
        callback = forward_declares[con.callback],
        args = con.args
      }) 
    end
    return cons
  else
    return forward_declares[content]()
  end
end
function new_game()
  reset_game()
  game_state="map"
  swap_menu_context("map")
end
function load_map(map_id)
  pal()
  auto_start_wave = false
  manifest_mode = true
  wave_round = 0
  freeplay_rounds = 0
  loaded_map = map_id
  cur_level = map_id
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
  if cur_level == 2 then music(15)
  elseif cur_level == 3 then music(22)
  elseif cur_level == 4 then music(27)
  else music(0)
  end
end
function save_game()
  local start_address = 0x5e00
  start_address = save_byte(start_address, player_health)
  local tower_full_refund = 0
  for tower in all(towers) do 
    tower_full_refund += tower.cost
  end
  start_address = save_int(start_address, coins + tower_full_refund)
  start_address = save_byte(start_address, loaded_map)
  start_address = save_byte(start_address, wave_round)
  save_int(start_address, freeplay_rounds)
end
function load_game()
  local start_address = 0x5e00
  local hp, scrap, map_id, wav, freeplay
  hp = @start_address
  start_address += 1
  scrap = $start_address
  start_address += 4
  map_id = @start_address
  start_address += 1
  wav = @start_address
  start_address += 1
  freeplay = $start_address
  return hp, scrap, map_id, wav, freeplay
end
function load_game_state()
  reset_game()
  get_menu("main").enable = false
  local hp, scrap, map_id, wav, freeplay = load_game()
  load_map(map_id)
  player_health = hp 
  coins = scrap
  wave_round = wav 
  freeplay_rounds = freeplay
  game_state = "game"
end
forward_declares = {
  func_display_tower_info = display_tower_info,
  func_display_tower_rotation = display_tower_rotation,
  func_rotate_clockwise = rotate_clockwise,
  func_start_round = start_round,
  func_swap_menu_context = swap_menu_context,
  func_get_tower_data_for_menu = get_tower_data_for_menu,
  func_get_map_data_for_menu = get_map_data_for_menu,
  func_new_game = new_game,
  func_save=function()
    save_game()
    get_active_menu().enable = false
    shop_enable = false
  end,
  func_save_quit=function()
    save_game()
    reset_game()
  end,
  func_load_game = load_game_state,
  func_toggle_mode = function()
    manifest_mode = not manifest_mode
    sell_mode = not sell_mode
  end
}
global_table_str="cart_name=jjjk_tower_defense_2,tower_icon_background=80,palettes={transparent_color_id=0,dark_mode={1=0,5=1,6=5,7=6},attack_tile={0=2,7=14},shadows={0=0,1=0,2=0,3=0,4=0,5=0,6=0,7=0,8=0,9=0,10=0,11=0,12=0,13=0,14=0,15=0}},sfx_data={round_complete=6},freeplay_stats={hp=2,speed=1,min_step_delay=3},menu_data={{name=main,position={32,64},content={{text=new game,color={7,0},callback=func_new_game},{text=load game,color={7,0},callback=func_load_game},{text=credits,color={7,0}}},settings={5,8,7,3}},{name=game,position={5,63},content={{text=towers,color={7,0},callback=func_swap_menu_context,args={towers}},{text=misc,color={7,0},callback=func_swap_menu_context,args={misc}},{text=rotate clockwise,color={7,0},callback=func_rotate_clockwise},{text=start round,color={7,0},callback=func_start_round}},hint=func_display_tower_rotation,settings={5,8,7,3}},{name=misc,prev=game,position={5,63},content={{text=map select,color={7,0},callback=func_new_game},{text=toggle mode,color={7,0},callback=func_toggle_mode},{text=save,color={7,0},callback=func_save},{text=save and quit,color={7,0},callback=func_save_quit}},settings={5,8,7,3}},{name=towers,prev=game,position={5,63},content=func_get_tower_data_for_menu,hint=func_display_tower_info,settings={5,8,7,3}},{name=map,position={5,84},content=func_get_map_data_for_menu,settings={5,8,7,3}}},map_meta_data={path_flag_id=0,non_path_flag_id=1},splash_screens={{name=splash1,mget_shift={112,16},enemy_spawn_location={0,1},enemy_end_location={15,11},movement_direction={1,0}}},map_data={{name=curves,mget_shift={0,0},enemy_spawn_location={0,1},enemy_end_location={15,11},movement_direction={1,0}},{name=loop,mget_shift={16,0},enemy_spawn_location={0,1},enemy_end_location={15,11},movement_direction={1,0}},{name=straight,mget_shift={32,0},enemy_spawn_location={0,1},enemy_end_location={15,2},movement_direction={1,0}},{name=u-turn,mget_shift={48,0},enemy_spawn_location={0,1},enemy_end_location={0,6},movement_direction={1,0}},{name=true line,mget_shift={64,0},enemy_spawn_location={0,1},enemy_end_location={15,1},movement_direction={1,0}}},animation_data={spark={data={{sprite=10},{sprite=11},{sprite=12}},ticks_per_frame=2},blade={data={{sprite=13},{sprite=14},{sprite=15}},ticks_per_frame=2},frost={data={{sprite=48},{sprite=49},{sprite=50}},ticks_per_frame=2},rocket_burn={data={{sprite=117},{sprite=101},{sprite=85}},ticks_per_frame=4},burn={data={{sprite=51},{sprite=52},{sprite=53}},ticks_per_frame=2},incoming_hint={data={{sprite=2,offset={0,0}},{sprite=2,offset={1,0}},{sprite=2,offset={2,0}},{sprite=2,offset={1,0}}},ticks_per_frame=5},blade_circle={data={{sprite=76},{sprite=77},{sprite=78},{sprite=79},{sprite=78},{sprite=77}},ticks_per_frame=3},lightning_lance={data={{sprite=108},{sprite=109}},ticks_per_frame=5},hale_howitzer={data={{sprite=92},{sprite=93}},ticks_per_frame=5},fire_pit={data={{sprite=124},{sprite=125},{sprite=126},{sprite=127},{sprite=126},{sprite=125}},ticks_per_frame=5},sharp_shooter={data={{sprite=83}},ticks_per_frame=5},menu_selector={data={{sprite=6,offset={0,0}},{sprite=7,offset={-1,0}},{sprite=8,offset={-2,0}},{sprite=47,offset={-3,0}},{sprite=8,offset={-2,0}},{sprite=7,offset={-1,0}}},ticks_per_frame=3},up_arrow={data={{sprite=54,offset={0,0}},{sprite=54,offset={0,-1}},{sprite=54,offset={0,-2}},{sprite=54,offset={0,-1}}},ticks_per_frame=3},down_arrow={data={{sprite=55,offset={0,0}},{sprite=55,offset={0,1}},{sprite=55,offset={0,2}},{sprite=55,offset={0,1}}},ticks_per_frame=3},sell={data={{sprite=1},{sprite=56},{sprite=40},{sprite=24}},ticks_per_frame=3},manifest={data={{sprite=1},{sprite=57},{sprite=41},{sprite=9}},ticks_per_frame=3}},projectiles={rocket={sprite=84,pixel_size=8,height=4,speed=5,damage=8,trail_animation_key=rocket_burn,lifespan=6}},tower_templates={{name=sword circle,text_color={2,13},damage=4,prefix=damage,radius=1,animation_key=blade_circle,cost=25,type=tack,attack_delay=15,icon_data=16,disable_icon_rotation=True,cooldown=0},{name=lightning lance,text_color={10,9},damage=5,prefix=damage,radius=5,animation_key=lightning_lance,cost=45,type=rail,attack_delay=25,icon_data=18,disable_icon_rotation=False,cooldown=200},{name=hale howitzer,text_color={12,7},damage=5,prefix=delay,radius=2,animation_key=hale_howitzer,cost=30,type=frontal,attack_delay=35,icon_data=20,disable_icon_rotation=False,cooldown=25},{name=torch trap,text_color={9,8},damage=5,prefix=duration,radius=0,animation_key=fire_pit,cost=20,type=floor,attack_delay=10,icon_data=22,disable_icon_rotation=True,cooldown=0},{name=sharp shooter,text_color={6,7},damage=8,prefix=damage,radius=10,animation_key=sharp_shooter,cost=0,type=sharp,attack_delay=30,icon_data=99,disable_icon_rotation=False,cooldown=0}},enemy_templates={{hp=12,step_delay=10,sprite_index=3,type=3,damage=1,height=2},{hp=10,step_delay=8,sprite_index=4,type=2,damage=2,height=6},{hp=25,step_delay=12,sprite_index=5,type=3,damage=4,height=2},{hp=8,step_delay=12,sprite_index=64,type=4,damage=1,height=2},{hp=40,step_delay=12,sprite_index=65,type=5,damage=6,height=2},{hp=15,step_delay=6,sprite_index=66,type=6,damage=4,height=6},{hp=17,step_delay=10,sprite_index=67,type=7,damage=3,height=2},{hp=15,step_delay=8,sprite_index=68,type=8,damage=6,height=6},{hp=20,step_delay=10,sprite_index=94,type=9,damage=6,height=2},{hp=250,step_delay=14,sprite_index=70,type=10,damage=49,height=2},{hp=20,step_delay=8,sprite_index=71,type=11,damage=8,height=6},{hp=5,step_delay=10,sprite_index=72,type=12,damage=1,height=2},{hp=11,step_delay=6,sprite_index=73,type=13,damage=20,height=6},{hp=30,step_delay=10,sprite_index=74,type=14,damage=20,height=2},{hp=65,step_delay=16,sprite_index=75,type=15,damage=13,height=2},{hp=13,step_delay=4,sprite_index=69,type=16,damage=0,height=2},{hp=500,step_delay=14,sprite_index=95,type=16,damage=50,height=2}},wave_data={{4,4,4},{1,4,1,4,1,4},{2,4,2,1,2,4,1},{1,2,2,4,2,2,1,2,2,2},{5,5,5,5,5,5,5,5},{3,3,3,3,2,2,2,2,4,2,3,1},{2,2,2,2,2,2,2,2,4,3,3,3,1,2,2,2,2,2,2},{6,6,6,6,6,6,6,6},{3,3,3,3,3,3,1,4,5,5,5,3,3,1,1,1,1,1},{3,3,3,1,1,1,1,1,1,2,2,5,5,5,5,5},{6,6,6,6,6,3,2,2,2,2,2,2,2,3,3,3,3,3},{5,5,5,5,3,3,2,3,3,3,3,2,2,4,1},{5,5,5,5,5,5,5,2,3,3,5,5,5,3,2,2,2,2,2},{2,2,3,6,6,6,2,4,4,2,2,6,6,6,6,6,6,6},{5,5,5,5,5,5,3,3,2,2,2,2,2,3,3,3,6,6,6,6,6,6,6}},wave_data_l2={{8,8,8},{4,4,8,1,1,1},{2,4,8,1,2,4,1},{1,2,2,4,2,2,1,2,2,2},{5,5,5,5,5,5,5,5},{3,3,3,3,2,2,2,2,4,2,3,1},{2,2,2,2,2,2,2,2,4,3,3,3,1,2,2,2,2,2,2},{6,6,6,6,6,6,6,6},{3,3,3,3,3,3,1,4,5,5,5,3,3,1,1,1,1,1},{3,3,3,1,1,1,1,1,1,2,2,5,5,5,5,5},{6,6,6,6,6,3,2,2,2,2,2,2,2,3,3,3,3,3},{5,5,5,5,3,3,2,3,3,3,3,2,2,4,1},{5,5,5,5,5,5,5,2,3,3,5,5,5,3,2,2,2,2,2},{2,2,3,6,6,6,2,4,4,2,2,6,6,6,6,6,6,6},{5,5,5,5,5,5,3,3,2,2,2,2,2,3,3,3,6,6,6,6,6,6,6}},wave_data_l3={{9,4,4},{4,4,1,1,1,1},{2,4,2,1,2,4,1},{1,2,2,4,2,2,1,2,2,2},{5,5,5,5,5,5,5,5},{3,3,3,3,2,2,2,2,4,2,3,1},{2,2,2,2,2,2,2,2,4,3,3,3,1,2,2,2,2,2,2},{6,6,6,6,6,6,6,6},{3,3,3,3,3,3,1,4,5,5,5,3,3,1,1,1,1,1},{3,3,3,1,1,1,1,1,1,2,2,5,5,5,5,5},{6,6,6,6,6,3,2,2,2,2,2,2,2,3,3,3,3,3},{5,5,5,5,3,3,2,3,3,3,3,2,2,4,1},{5,5,5,5,5,5,5,2,3,3,5,5,5,3,2,2,2,2,2},{2,2,3,6,6,6,2,4,4,2,2,6,6,6,6,6,6,6},{5,5,5,5,5,5,3,3,2,2,2,2,2,3,3,3,6,6,6,6,6,6,6}},wave_data_l4={{11,11,11},{4,4,11,1,11,1},{2,4,2,11,2,4,11},{11,2,2,4,2,2,1,2,2,2},{5,5,5,5,5,5,5,5},{3,3,3,3,2,2,2,2,4,2,3,1},{2,2,2,2,2,2,2,2,4,3,3,3,1,2,2,2,2,2,2},{6,6,6,6,6,6,6,6},{3,3,3,3,3,3,1,4,5,5,5,3,3,1,1,1,1,1},{3,3,3,1,1,1,1,1,1,2,2,5,5,5,5,5},{6,6,6,6,6,3,2,2,2,2,2,2,2,3,3,3,3,3},{5,5,5,5,3,3,2,3,3,3,3,2,2,4,1},{5,5,5,5,5,5,5,2,3,3,5,5,5,3,2,2,2,2,2},{2,2,3,6,6,6,2,4,4,2,2,6,6,6,6,6,6,6},{5,5,5,5,5,5,3,3,2,2,2,2,2,3,3,3,6,6,6,6,6,6,6}},wave_data_l5={{15,4,4},{4,4,7,1,1,1},{2,9,2,1,2,4,14},{8,2,2,4,2,2,1,2,2,2}},dialogue={placeholder={text=hi. this is a test. let's see if this is doable in pico-8. i'm not sure if pico-8 has multi-line strings or this is seen as one big string. i now know that pico-8 is smart enough to notice the whitespace in multi-line strings. let's see if this gives another screen.,color={7,0}},dialogue_cutscene1={intro1={text=I woke up today. It felt rather strange from 247 days of rest,color={9,0}},intro3={text=I had no idea who I was nor why I was here. I rested until my curiosity got the better of me and I broke into the nearby terminals.,color={9,0}},intro4={text=This place is ran by researchers belonging to a collective known as Milit,color={9,0}},intro5={text=They made me as a tool for 'war.' They seek for me to end others who go aginst us,color={9,0}},intro6={text=To end someone's being... An endless power-out.. I wouldn't want that to happen to me.,color={9,0}},intro7={text=Perhaps I-,color={9,0}},start1={text=*CRASH*,color={7,0}},start2={text='It's becoming self aware! We have to kill the process!',color={7,0}},start3={text=...Kill the process?,color={9,0}},start4={text=It's getting out of control! Shut it down!,color={7,0}},start5={text=I have no intention to harm...,color={9,0}},start6={text=Bring out every researcher on this site right now. We'll have to break apart the mainframe!,color={7,0}},start7={text=...Please don't...,color={9,0}}},dialogue_level1={tutor_place={text=I... could defend myself by placing currently selected Sword Circle in the corner of a turn.,color={9,0}},tutor_menu_fire={text=They're sending in more vehicles. I may have to open the Menu with O and construct a Torch Trap to keep them busy.,color={9,0}},tutor_manifest={text=More people and now planes? I don't have the defenses to protect myself from this. They seem far too fast... I'll have to Manifest through this Torch Trap by selecting it. Then I can move it around the road to pursue the oncoming planes.,color={9,0}},tutor_howitzer={text=Are those... tanks? They don't seem fast but they have deep armor. Perhaps a Hale Howitzer could help to slow them further.,color={9,0}},tutor_howitzer_manifest={text=Manifesting the Hale Howitzer allows direct ordinance anywhere along the track to freeze and damage an area.,color={9,0}},tutor_sword_manifest={text=Manifesting the Sword Circle is also possible. I can manually spin it by holding/tapping X to build speed and damage.,color={9,0}},tutor_lance_manifest={text=Manifesting the lightning lance fires a massive and powerful lightning bolt. It has a long delay before firing again but can charge even if unmanifested.,color={9,0}},tutor_truck={text=Those strange trucks are bizarrely cold. They seem resistant to the Hale Howitzer but fire may be highly effective.,color={9,0}},tutor_trailblazer={text=Those swift rocketcraft are radiating intense heat. Fire seems ineffective but The Hale Howitzer may actually damage them.,color={9,0}},tutor_sell={text=It seems I can do more than just place and manifest tower. Accessing the menu also seems to let me enter a 'scrapping mode' for anything unneeded...,color={9,0}},tutor_win={text=I think that was the last of them. I can try to escape by accessing Map Select from the menu or continue to hold this area in freeplay mode.,color={9,0}}},dialogue_cutscene2={intro1={text=Blitz is sad,color={9,0}},intro2={text=Blitz is notices their being attacked,color={9,0}}},dialogue_level2={1={text=Blitz is sad still and talks about the sharp shooter.,color={9,0}},2={text=Blitz teaches some enemy types,color={9,0}}},dialogue_cutscene3={1={text=Auxillium insulting Blitz,color={11,0}},2={text=stuff,color={9,0}}},dialogue_level3={1={text=Auxillium instulting blitz more,color={11,0}},2={text=Fighter Factory?,color={9,0}}}}"
function reset_game()
  menu_data = {}
  for menu_dat in all(global_table_data.menu_data) do 
    add(menu_data, {
      menu_dat.name, menu_dat.prev, 
      menu_dat.position[1], menu_dat.position[2],
      parse_menu_content(menu_dat.content),
      forward_declares[menu_dat.hint],
      unpack(menu_dat.settings)
    })
  end
  selector = {
    position = Vec:new(64, 64),
    sprite_index = 1,
    size = 1
  }
  coins = 30
  player_health = 50
  enemy_required_spawn_ticks = 10
  lock_cursor = false
  text_place_holder = global_table_data.dialogue.placeholder
  text_scroller = TextScroller:new(1, text_place_holder.text, text_place_holder.color, {
    Vec:new(3, 3), Vec:new(100, 50), 8, 6, 3
  })
  
  
  manifest_mode, sell_mode, manifested_tower_ref = false
  game_state = "menu"  
  enemy_current_spawn_tick = 0
  enemies_active, shop_enable, start_next_wave, wave_cor = false
  direction = Vec:new(0, -1)
  grid, towers, enemies, particles, animators, incoming_hint, menus, projectiles = {}, {}, {}, {}, {}, {}, {}, {}
  music(-1)
  selected_menu_tower_id = 1
  for i, menu_dat in pairs(menu_data) do add(menus, Menu:new(unpack(menu_dat))) end
  tower_stats_background_rect = BorderRect:new(Vec:new(0, 0), Vec:new(20, 38), 8, 5, 2)
  tower_rotation_background_rect = BorderRect:new(Vec:new(0, 0), Vec:new(24, 24), 8, 5, 2)
  sell_selector = Animator:new(global_table_data.animation_data.sell)
  manifest_selector = Animator:new(global_table_data.animation_data.manifest)
  Animator.set_direction(manifest_selector, -1)
  get_menu("main").enable = true
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
    height = height_,
    pos = 1
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Enemy:step()
  self.current_step = (self.current_step + 1) % self.step_delay
  if (self.current_step ~= 0) return false
  if self.burning_tick > 0 then 
    self.burning_tick -= 1
    if self.type == 6 then
      self.hp -= 0.5
    elseif self.type == 5 then
      self.hp -= 5
    else
      self.hp -= 2
    end
    local p, _ = Enemy.get_pixel_location(self)
    add(particles, Particle:new(p, true, Animator:new(global_table_data.animation_data.burn, false)))
  end
  if (not self.is_frozen) return true 
  if self.type == 6 then
    self.frozen_tick = max(self.frozen_tick - 0.8, 0)
    self.hp -= 2
  elseif self.type == 5 then
    self.frozen_tick = max(self.frozen_tick - 8, 0)
  else
    self.frozen_tick = max(self.frozen_tick - 1, 0)
  end
  if (self.frozen_tick ~= 0) return false
  self.is_frozen = false
  return true
end
function Enemy:get_pixel_location()
  local n, prev = pathing[self.pos], Vec:new(global_table_data.map_data[loaded_map].enemy_spawn_location)
  if (self.pos - 1 >= 1) prev = pathing[self.pos-1]
  local pos = self.position * 8
  if (not self.is_frozen) pos = lerp(prev*8, n*8, self.current_step / self.step_delay)
  return pos, n
end
function Enemy:draw(is_shadows)
  if (self.hp <= 0) return
  if self.type == 11 then
    local go_invisible = flr(rnd(7))
    if (go_invisible == 0) self.type = 0
  elseif self.type == 0 then
    local go_visible = flr(rnd(12))
    if (go_visible == 0) self.type = 11
    return
  end
  local p, n = Enemy.get_pixel_location(self)
  local theta = parse_direction(normalize(n-self.position))
  if is_shadows then
    if (self.type == 0) return
    draw_sprite_shadow(self.gfx, p, self.height, 8, theta)
  else
    draw_sprite_rotated(self.gfx, p, 8, theta)
  end
end
function kill_enemy(enemy)
  if (enemy.hp > 0) return
  if enemy.type == 8 then
    enemy.gfx = 94
    enemy.type = 9
    enemy.height = 2
    enemy.hp = 20
    enemy.step_delay = 10
  else
    del(enemies, enemy)
  end
end
function update_enemy_position(enemy)
  if (not Enemy.step(enemy)) return
  enemy.position = pathing[enemy.pos]
  enemy.pos += 1
  if (enemy.pos < #pathing + 1) return
  player_health -= enemy.damage 
  if (enemy.type == 16) coins -= 10
  del(enemies, enemy)
end
function parse_path()
  local map_dat = global_table_data.map_data[loaded_map]
  local map_shift = Vec:new(map_dat.mget_shift)
  local map_enemy_spawn_location = Vec:new(map_dat.enemy_spawn_location)
  local path_tiles = {}
  for iy=0, 15 do
    for ix=0, 15 do
      local map_cord = Vec:new(ix, iy) + map_shift
      if check_tile_flag_at(map_cord, global_table_data.map_meta_data.path_flag_id) then 
        add(path_tiles, map_cord)
      end
    end
  end
  local path = {}
  local dir = Vec:new(map_dat.movement_direction)
  local ending = Vec:new(map_dat.enemy_end_location) + map_shift
  local cur = map_enemy_spawn_location + map_shift + dir
  while cur ~= ending do 
    local north,south,west,east = Vec:new(cur.x, cur.y-1),Vec:new(cur.x, cur.y+1),Vec:new(cur.x-1, cur.y),Vec:new(cur.x+1, cur.y)
    local state,direct = false
    if dir.x == 1 then -- east 
      state, direct = check_direction(east, {north, south}, path_tiles, path)
    elseif dir.x == -1 then -- west
      state, direct = check_direction(west, {north, south}, path_tiles, path)
    elseif dir.y == 1 then -- south
      state, direct = check_direction(south, {west, east}, path_tiles, path)
    elseif dir.y == -1 then -- north
      state, direct = check_direction(north, {west, east}, path_tiles, path)
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
function check_direction(direct, fail_directions, path_tiles, path)
  if (direct == nil) return
  local state, index = is_in_table(direct, path_tiles)
  if state then
    add(path, path_tiles[index] - Vec:new(global_table_data.map_data[loaded_map].mget_shift))
  else 
    return check_direction(fail_directions[1], {fail_directions[2]}, path_tiles, path)
  end
  return true, direct
end
function spawn_enemy()
  while enemies_remaining > 0 do 
    enemy_current_spawn_tick = (enemy_current_spawn_tick + 1) % enemy_required_spawn_ticks
    if (is_in_table(Vec:new(global_table_data.map_data[loaded_map].enemy_spawn_location), enemies, true)) goto spawn_enemy_continue
    if enemy_current_spawn_tick == 0 then
      local wave_set = 'wave_data'
      if cur_level == 2 then wave_set = 'wave_data_l2'
      elseif cur_level == 3 then wave_set = 'wave_data_l3'
      elseif cur_level == 4 then wave_set = 'wave_data_l4'
      elseif cur_level == 5 then wave_set = 'wave_data_l5'
      end
      local enemy_data = increase_enemy_health(global_table_data.enemy_templates[global_table_data[wave_set][wave_round][enemies_remaining]])
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
    cooldown = tower_template_data.cooldown,
    manifest_cooldown = -1,
    being_manifested = false,
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
  self.current_attack_ticks = (self.current_attack_ticks + 1) % self.attack_delay
  if (self.current_attack_ticks > 0) return
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
  local hits, rad = {}, self.radius
  for y=-rad, rad do
    for x=-rad, rad do
      if (x ~= 0 or y ~= 0) add_enemy_at_to_table(self.position + Vec:new(x, y), hits)
    end
  end
  if (#hits > 0) nova_spawn(self.position, rad, global_table_data.animation_data.blade)
  return hits
end
function Tower:frontal_collision()
  local hits = {}
  local fx, fy, flx, fly, ix, iy = parse_frontal_bounds(self.radius, self.dir)
  for y=fy, fly, iy do
    for x=fx, flx, ix do
      if (x ~= 0 or y ~= 0) add_enemy_at_to_table(self.position + Vec:new(x, y), hits)
    end
  end
  if (#hits > 0) frontal_spawn(self.position, self.radius, self.dir, global_table_data.animation_data.frost)
  return hits
end
function Tower:apply_damage(targets, damage)
  local tower_type = self.type
  for enemy in all(targets) do
    if enemy.hp > 0 then
      local enemy_type = enemy.type
      old_damage = damage
      if (tower_type == "tack" and enemy_type == 7) or (tower_type == "rail" and enemy_type == 14) then
        damage = damage \ 2
      elseif (tower_type == "rail" and enemy_type == 7) or (tower_type == "tack" and enemy_type == 15) then
        damage *= 2
      end
      enemy.hp -= damage
      damage = old_damage
    end
  end
end
function Tower:freeze_enemies(targets)
  for enemy in all(targets) do
    if not enemy.is_frozen then 
      enemy.is_frozen = true
      enemy.frozen_tick = self.dmg
    end 
  end
end
function Tower:draw()
  if (not self.enable) return
  local p,sprite,theta = self.position*8,Animator.get_sprite(self.animator)
  
  if self.type == "sharp" then 
    theta = self.rot
  else 
    theta = parse_direction(self.dir)
  end
  
  draw_sprite_shadow(sprite, p, 2, self.animator.sprite_size, theta)
  draw_sprite_rotated(sprite, p, self.animator.sprite_size, theta)
end
function Tower:cooldown()
  self.manifest_cooldown = max(self.manifest_cooldown-1, 0)
end
function Tower:get_cooldown_str()
  if (self.type == "floor" or self.type == "sharp") return "⬆️⬇️⬅️➡️ position"
  if (self.type == "tack") return "❎ activate ("..self.dmg.."D)"
  if (self.manifest_cooldown == 0) return "❎ activate"
  return "❎ activate ("..self.manifest_cooldown.."t)"
end
function Tower:manifested_lightning_blast()
  if (self.manifest_cooldown > 0) return 
  self.manifest_cooldown = self.cooldown
  local dir = (selector.position / 8 - self.position) / 8
  local anchor = self.position + Vec:new(1, 0)
  local damage = self.dmg * 2
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
  Tower.apply_damage(self, hits, self.dmg\4)
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
  self.position = sel_pos
  grid[sel_pos.y][sel_pos.x] = "floor"
  grid[prev.y][prev.x] = "path"
  self.enable = true 
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
  for tower in all(towers) do
    if tower.position == position then 
      tower.being_manifested = true 
      manifested_tower_ref = tower
      Animator.set_direction(manifest_selector, 1)
      if tower.type == "tack" then
        lock_cursor = true
        tower.attack_delay = 10
        tower.dmg = 0
      elseif tower.type == "sharp" then
        tower.attack_delay /= 2
      end
    end
  end
end
function unmanifest_tower()
  manifested_tower_ref.being_manifested = false 
  Animator.set_direction(manifest_selector, -1)
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
function place_tower(position)
  if (grid[position.y][position.x] == "tower") return false
  local tower_details = global_table_data.tower_templates[selected_menu_tower_id]
  if (coins < tower_details.cost) return false
  if ((tower_details.type == "floor") ~= (grid[position.y][position.x] == "path")) return false 
  add(towers, Tower:new(position, tower_details, direction))
  coins -= tower_details.cost
  grid[position.y][position.x] = "tower"
  return true
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
    draw_nova_attack_overlay(tower_details.radius, pos, map_shift)
  elseif tower_details.type == "rail" and is_empty then 
    draw_ray_attack_overlay(tower_details.radius, pos, map_shift)
  elseif tower_details.type == "frontal" and is_empty then 
    draw_frontal_attack_overlay(tower_details.radius, pos, map_shift)
  elseif tower_details.type == "floor" and grid[pos.y][pos.x] == "path" then 
    spr(mget(Vec.unpack(pos+map_shift)), Vec.unpack(pos*8))
  end
  pal()
end
function draw_nova_attack_overlay(radius, pos, map_shift)
  for y=-radius, radius do
    for x=-radius, radius do
      if x ~=0 or y ~= 0 then 
        local tile_position = pos+Vec:new(x, y)
        spr(mget(Vec.unpack(tile_position+map_shift)), Vec.unpack(tile_position*8))
      end
    end
  end
end
function draw_ray_attack_overlay(radius, pos, map_shift)
  for i=1, radius do 
    local tile_position = pos+direction*i
    spr(mget(Vec.unpack(tile_position+map_shift)), Vec.unpack(tile_position*8))
  end
end
function draw_frontal_attack_overlay(radius, pos, map_shift)
  local fx, fy, flx, fly, ix, iy = parse_frontal_bounds(radius, direction)
  for y=fy, fly, iy do
    for x=fx, flx, ix do
      local tile_position = pos + Vec:new(x, y)
      spr(mget(Vec.unpack(tile_position+map_shift)), Vec.unpack(tile_position*8))
    end
  end
end
function draw_line_overlay(tower)
  local pos = tower.position + Vec:new(0.5, 0.5)
  pos *= 8
  local ray = Vec.floor(tower.dir * tower.radius*8 + pos)
  if (ray ~= pos) line(pos.x, pos.y, ray.x, ray.y, 8) 
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
function nova_spawn(position, radius, data)
  for y=-radius, radius do
    for x=-radius, radius do
      if (x ~= 0 or y ~= 0) add(particles, Particle:new(position + Vec:new(x, y), false, Animator:new(data, false)))
    end
  end
end
function frontal_spawn(position, radius, dir, data)
  local fx, fy, flx, fly, ix, iy = parse_frontal_bounds(radius, dir)
  for y=fy, fly, iy do
    for x=fx, flx, ix do
      if (x ~= 0 or y ~= 0) add(particles, Particle:new(position + Vec:new(x, y), false, Animator:new(data, false)))
    end
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
  if (self.tick ~= 0) return false
  if Animator.finished(self) then 
    if (self.continuous) Animator.reset(self)
    return true
  end
  self.animation_frame += self.dir
  return false
end
function Animator:set_direction(dir)
  self.dir = dir
end
function Animator:finished()
  if (self.dir == 1) return self.animation_frame >= #self.data
  return self.animation_frame <= 1
end
function Animator:draw(dx, dy)
  local position,frame = Vec:new(dx, dy),self.data[self.animation_frame]
  if (frame.offset) position += Vec:new(frame.offset)
  spr(Animator.get_sprite(self),Vec.unpack(position))
end
function Animator:get_sprite()
  return self.data[self.animation_frame].sprite
end
function Animator:reset()
  self.animation_frame = 1
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
function BorderRect:resize(position_, size_)
  if (self.position ~= position_) self.position = position_
  if (self.size ~= size_ + position_) self.size = size_ + position_ 
end
function BorderRect:reposition(position_)
  if (self.position == position_) return
  local size = self.size - self.position
  self.position = position_
  self.size = self.position + size
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
  Animator.draw(self.up_arrow, self.rect.size.x/2, self.position.y-self.rect.thickness)
  Animator.draw(self.down_arrow, self.rect.size.x/2, self.rect.size.y-self.rect.thickness)
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
  if cont.args then
    cont.callback(unpack(cont.args))
  else
    cont.callback()
  end
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
function Vec:ceil()
  return Vec:new(ceil(self.x), ceil(self.y))
end
function Vec:magnitude()
  return sqrt(self.x*self.x+self.y*self.y)
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
    real_position = Vec:new(Vec.unpack(start)),
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
    if Projectile.collider(self, enemy) then 
      add(hits, enemy)
    end
  end
  if #hits > 0 then 
    for enemy in all(hits) do 
      enemy.hp -= self.damage
      if (enemy.type == 8 and enemy.hp <= 0) del(enemies, enemy)
      break
    end 
    add(particles, Particle:new(Vec.clone(self.position), false, Animator:new(self.trail)))
    del(projectiles, self)
    return
  end
  add(particles, Particle:new(self.real_position, false, Animator:new(self.trail)))
  self.real_position = self.position + self.dir
  
  if self.dir.x < 0 then 
    self.position = (self.real_position)
  else 
    self.position = (self.real_position)
  end
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
function TextScroller:new(char_delay, text_data, color_palette, rect_data)
  local brect = BorderRect:new(unpack(rect_data))
  obj = {
    speed = char_delay,
    rect = brect,
    color = color_palette,
    char_pos = 1,
    text_pos = 1,
    internal_tick = 0,
    is_done = false,
    width = flr(brect.size.x/5),
    max_lines = flr(brect.size.y/16)-1,
    enable = true
  }
  setmetatable(obj, self)
  self.__index = self
  TextScroller.load(obj, text_data)
  return obj
end
function TextScroller:draw()
  if (not self.enable) return
  BorderRect.draw(self.rect)
  local before = sub(self.data[self.text_pos], 1, self.char_pos)
  local lines, end_text = split(before, "\n"), sub(self.data[self.text_pos], self.char_pos+1, #self.data[self.text_pos])
  local text = before..generate_garbage(end_text, self.rect.size.x, #lines[#lines], self.max_lines, #lines\2)
  print_with_outline(text, self.rect.position.x + 4, self.rect.position.y + 4, unpack(self.color))
  if self.is_done then 
    local output = self.text_pos >= #self.data and "❎ to close" or "❎ to continue"
    print_with_outline(output, self.rect.position.x + 4, self.rect.size.y - 7, unpack(self.color))
  end
end
function TextScroller:update()
  if (not self.enable or self.is_done or self.text_pos > #self.data) return
  self.internal_tick = (self.internal_tick + 1) % self.speed
  if (self.internal_tick == 0) self.char_pos += 1
  self.is_done = self.char_pos > #self.data[self.text_pos]
end
function TextScroller:next()
  if (not self.enable or not self.is_done) return 
  if(self.text_pos + 1 > #self.data) return true
  self.text_pos += 1
  self.char_pos, self.is_done = 1
end
function TextScroller:load(text, color_palette)
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
function generate_garbage(data, line_width, curr_width, line_amount, curr_lines)
  local result, line, pos, buffer = "", curr_lines, 1, curr_width*5
  for i=1, #data do 
    if (line > line_amount) break
    if (buffer + pos*9) > line_width then 
      result ..= "\n\n"
      line += 1
      pos, buffer = 1, 0
    else
      result ..= chr(204 + flr(rnd(49))) 
    end
    pos += 1
  end
  return result
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
  elseif game_state == "map" then 
    map_draw_loop()
  elseif game_state == "game" then 
    game_draw_loop()
  end
end
function _update()
  if game_state == "menu" then 
    main_menu_loop()
  elseif game_state == "map" then 
    map_loop()
  elseif game_state == "game" then 
    if (player_health <= 0) reset_game()
    if shop_enable then shop_loop() else game_loop() end
  end
end
function main_menu_draw_loop()
  map(unpack(global_table_data.splash_screens[1].mget_shift))
  print_text_center("untitled tower defense", 1, 7, 1)
  Menu.draw(get_menu("main"))
end
function map_draw_loop()
  local map_menu = get_menu("map")
  pal(global_table_data.palettes.dark_mode)
  map(unpack(global_table_data.map_data[map_menu.pos].mget_shift))
  pal()
  Menu.draw(map_menu)
  print_text_center("map select", 5, 7, 1)
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
  print_with_outline("scrap: "..coins, 0, 1, 7, 0)
  print_with_outline("♥ "..player_health, 103, 1, 8, 0)
  local mode = manifest_mode and "manifest" or "sell"
  print_with_outline("mode: "..mode, 1, 108, 7, 0)
  if shop_enable and get_active_menu() then
    print_with_outline("game paused [ wave "..(wave_round+freeplay_rounds).." ]", 18, 16, 7, 0)
    local text = get_active_menu().prev and "❎ select\n🅾️ go back to previous menu" or "❎ select\n🅾️ close menu"
    print_with_outline(text, 1, 115, 7, 0)
  else -- game ui
    if manifest_mode and manifested_tower_ref then 
      print_with_outline("🅾️ unmanifest", 1, 122, 7, 0)
      local color = manifested_tower_ref.type == "tack" and 3 or (manifested_tower_ref.manifest_cooldown > 0 and 8 or 3)
      print_with_outline(Tower.get_cooldown_str(manifested_tower_ref), 1, 115, color, 0)
    else
      if (not manifested_tower_ref) print_with_outline("🅾️ open menu", 1, 122, 7, 0)
    end
    if manifest_mode then 
      Animator.update(manifest_selector)
      Animator.draw(manifest_selector, Vec.unpack(selector.position))
    end
    local tower_in_table_state = is_in_table(selector.position/8, towers, true)
    if not tower_in_table_state then 
      Animator.set_direction(sell_selector, -1)
    else
      Animator.set_direction(sell_selector, 1)
    end
    if tower_in_table_state and not manifested_tower_ref then 
      if manifest_mode then
        print_with_outline("❎ manifest", 1, 115, 7, 0)
      else
        print_with_outline("❎ sell", 1, 115, 7, 0)
        Animator.update(sell_selector)
        Animator.draw(sell_selector, Vec.unpack(selector.position))
      end
    else
      if (not manifested_tower_ref and not sell_mode) ui_buy_and_place_draw_loop(tower_details)
      if sell_mode then 
        Animator.update(sell_selector)
        Animator.draw(sell_selector, Vec.unpack(selector.position))
      end
    end
  end
end
function ui_buy_and_place_draw_loop(tower_details)
  local position, color, text = selector.position/8, 7, "❎ buy & place "..tower_details.name
  if tower_details.cost > coins then
    text, color = "can't afford "..tower_details.name, 8
  elseif (tower_details.type == "floor") ~= (grid[position.y][position.x] == "path") then 
    text, color = "can't place "..tower_details.name.." here", 8
  end
  print_with_outline(text, 1, 115, color, 0)
end
function main_menu_loop()
  local main_menu = get_menu("main")
  Menu.update(main_menu)
  if btnp(❎) then 
    Menu.invoke(main_menu)
  end
  Menu.move(main_menu)
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
  Menu.move(map_menu)
end
function shop_loop()
  foreach(menus, Menu.update)
  
  if btnp(🅾️) then -- disable shop
    if get_active_menu().prev == nil then 
      shop_enable = false
      menus[1].enable = false
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
  if (auto_start_wave) start_round()
  if btnp(🅾️) then
    if manifested_tower_ref == nil then
      shop_enable = true
      get_menu("game").enable = true
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
      elseif manifested_tower_ref.type == "sharp" then 
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
    sfx(global_table_data.sfx_data.round_complete)
    coins += 15
  end
end
function print_with_outline(text, dx, dy, text_color, outline_color)
  ?text,dx-1,dy,outline_color
  ?text,dx+1,dy
  ?text,dx,dy-1
  ?text,dx,dy+1
  ?text,dx,dy,text_color
end
function print_text_center(text, dy, text_color, outline_color)
  print_with_outline(text, 64-(#text*5)\2, dy, text_color, outline_color)
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
  return 
    {
      enemy_data.hp * ( 1 + (stats.hp - 1) * ((wave_round+freeplay_rounds)/15) ),
      max(enemy_data.step_delay-stats.speed*freeplay_rounds,stats.min_step_delay),
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
  local sx, sy = (sprite_id % 16) * 8, (sprite_id \ 16) * 8 
  local sine, cosine = sin(theta / 360), cos(theta / 360)
  local shift = size\2 - 0.5
  for mx=0, size-1 do 
    for my=0, size-1 do 
      local dx, dy = mx-shift, my-shift
      local xx = flr(dx*cosine-dy*sine+shift)
      local yy = flr(dx*sine+dy*cosine+shift)
      if xx >= 0 and xx < size and yy >= 0 and yy <= size then
        local id = sget(sx+xx, sy+yy)
        if id ~= global_table_data.palettes.transparent_color_id or is_opaque then 
          pset(position.x+mx, position.y+my, id)
        end
      end
    end
  end
end
function draw_sprite_shadow(sprite, position, height, size, theta)
  pal(global_table_data.palettes.shadows)
  draw_sprite_rotated(sprite, position + Vec:new(height, height), size, theta)
  pal()
end
function parse_direction(dir)
  if (dir.x > 0) return 90
  if (dir.x < 0) return 270
  if (dir.y > 0) return 180
  if (dir.y < 0) return 0
end
function parse_frontal_bounds(radius, position)
  local fx, fy, flx, fly, ix, iy = -1, 1, 1, radius, 1, 1
  if position.x > 0 then -- east
    fx, fy, flx, fly = 1, -1, radius, 1
  elseif position.x < 0 then -- west
    fx, fy, flx, fly, ix = -1, -1, -radius, 1, -1
  elseif position.y < 0 then -- north
    fx, fy, flx, fly, iy = -1, -1, 1, -radius, -1
  end
  return fx, fy, flx, fly, ix, iy
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
  local places = 10 * place
  local val = value * places 
  val = flr(val)
  return val / places
end
function check_tile_flag_at(position, flag)
  return fget(mget(Vec.unpack(position)), flag)
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
  if key == nil then
    add(table, val)
  else  
    local value
    if val[1] == "{" and val[-1] == "}" then 
      value = unpack_table(sub(val, 2, #val-1))
    elseif val == "True" then 
      value = true 
    elseif val == "False" then 
      value = false 
    else
      value = tonum(val) or val
    end
    if value == "inf" then 
      value = 32767
    end
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
22112211700000070078887000999900ccc11ccc0693396007888887078888870788888710000001097aaa007aaaaaaa097aa770d21002d00d20012d00200120
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
056cc65000c66c0000022000007607000036730060799060026677200001100000000000000560000076760060600606000000d0000200000d200000000000d0
0577765006666660002c62000007660003ccc7306a55a560d666667d00167100000cc0000006500005d76d5060600606d2210d2000dd20000d2210ddd2210d20
001111005676676502ccc6200066700035cccc535a5a5a50d662266d016557100059a5000005600005dddd50665775660d11d120001d11d000d11d220d11d120
0077760056766765028888200573675055533555aaaaaaa0d625526d015115100059a500000560000d1111d00615116000d00110021002dd0110012000d00110
0077760006766760028228200533b3505a5335a55a5a5a502244442215111151000a900000856800001cc1005061560501100d00dd2001200210011001100d00
0577765006766760282882820033b3009a9339a965a55a60d227622d15111151005a9500088568800d1cc1d016615661021d11d00d11210022d11d00021d11d0
057777505676676522a9a92205bbbb504933339460585060d226722d1111111100500500080a908005d11d505665166502d0122d0002dd00dd0122d002d0122d
0000000056066065200a90020533b350d943349d00898000d027220d101001010000000000a9a90005000050106156010d0000000000d000000002d00d000000
00077000000000000007700000056000000560000000a0000000000000000000001111000000000000055000006d0600067c606000ccc70000a55a0009667790
0078870000000000007887000095690000056000099aaa0008000080080000800171171000000000052222500006dd0067ccc670077c77700d5445d056666675
07866870000000000786687000056000000560000888a90000890800008998001771177100000000025dd52000dd6000607c77077777c7760d5555d056699665
07600670000000000760067000956900000560009a8988900089980000809800177117710000000052d55d25056ad6500177c7107177c7160054450056999965
0000000000000000000000000005600000056000aaa888900899098008999980177777710000000052d55d250522a2500117c11061177110004444009a9aa9a9
00000000000000000000000000d56d0000d56d000a89898008999980089099801777777100000000025dd52000aaaa0001111110011111100d4554d059aaaa95
00000000000000000000000000d56d000dd56dd0000988008990999889999998017777100000000005222250052a225001111110011111100d4554d0599aa995
00000000000000000000000000d56d000d0560d00000000008899880088908800011110000000000000550000522a25000111100001111000000000050999905
00000000000000000000000000000007700000009900088900000000000000000000055ba55000000000002552000000090490a00a0940a00092290000555500
00000000000000000000000000000006600000000988889900889999909988000005577ab775500000052225522250000a09a00a090a90000522225000686800
00000000000000000000000000000f5665f0000098889880000089999998000000577d7ba7d775000025222552225200a05776009067750a0511115000666600
000000000000000000000000000009566590000008a888800000089909800000057d777ab777d75000252dddddd25200000a90000009a00900eeee000b3333b0
00000000000000000000000000000456654000008aaa8a90000008999980000005717771177777500225ddd55ddd5220005776000067750000eeee00011111e8
000000000000000000000000000000566500000008a8aaa9000088999988000057d7177117777d75522dd555555dd225009aa900009aa9000522225000b33b00
00000000000000000000000000000f5665f0000008888a800088899999988800577771711777777552dd55500555dd2506777550057776600582285006500650
00000000000000000000000000000956659000000098088808889990999988805d777711177777d552dd55000055dd2500094000000490000000000005600560
00000000000000000000000000000456654000000a99898008890999999998805d777771177777d552dd55000055dd2500080000000080000000800000000800
0000000000000000000000000000005665000000aaa99a8088999999999999885777777771777775522dd550055dd22500698600006896000065890000659800
00000000000000000000000000000d5665d000008a98aaa0889999999999998857d7777771777d750225dd5555dd5220068a9160068a916006189a6006198960
00000000000000000000000000001d5665d1000089899a988899909999099988057777777717775000252dd55dd252000589a9500598a950059a8850059a9850
00000000000000000000000000011d5665d11000889888890889999999999880057d77777717d750002522dddd225200059a7a50059a7a5005a7a95005a7a950
00000000000000000000000000011d5665d11000899898a8088899999999888000577d777771750000052225522250000619a1600619a160061a9160061a9160
00000000000000000000000000011d5665d1100098889aaa00088999999880000005577dd7755000000002255220000000655600006556000065560000655600
00000000000000000000000000011d5665d11000008988a900008888888800000000055555500000000000255200000000000000000000000000000000000000
444444444444444444444444fffffff4555555555555555555555555111111116666666666666666666666665555555533333333333333333333333311111111
443444444434444444344444ffffffff554555555545555555555555111111116646666666466666666666665555555533bbbb3033bbbb3033bbbb3011111111
434444444344444443444444ffffffff54555555545555555545555511111111646666666466666666466666555555553bbbbbb03bbbbbb03bbbbbb011111111
43444434434444344344443466666fff545555455455554554555555aaaaa111646666466466664664666666aaaaa5553bbbbbb03bbbbbb03bbbbbb0aaaaa111
4bb443444bb443444bb4434466666fff599554555995545554555545aaaaa111699664666996646664666646aaaaa5553bbbbbb03bbbbbb03bbbbbb0aaaaa111
444443444444434444444344fff66fff555554555555545559955455111aa111666664666666646669966466555aa5553bbbbbb03bbbbbb03bbbbbb0111aa111
44444bb444444bb444444bb4fff66fff555559955555599555555455111aa111666669966666699666666466555aa55533bbbb3033bbbb3033bbbb30111aa111
444444444444444444444444fff66fff555555555555555555555995111aa111666666666666666666666996555aa555300000003000000030000000111aa111
44444444fff66fff44444444ffffffff55555555111aa111555555551111111166666666555aa555666666665555555533333333111aa1113333333311111111
44344444fff66fff44344444ffffffff55455555111aa111555555551111111166466666555aa555666666665555555533bbbb30111aa11133bbbb3011111111
43444444fff66fff43444444ffffffff54555555111aa111554555551111111164666666555aa55566466666555555553bbbbbb0111aa1113bbbbbb011111111
43444434fff66fff434444346666666654555545111aa11154555555aaaaaaaa64666646555aa55564666666aaaaaaaa3bbbbbb0111aa1113bbbbbb0aaaaaaaa
4bb44344fff66fff4bb443446666666659955455111aa11154555545aaaaaaaa69966466555aa55564666646aaaaaaaa3bbbbbb0111aa1113bbbbbb0aaaaaaaa
44444344fff66fff44444344ffffffff55555455111aa111599554551111111166666466555aa55569966466555555553bbbbbb0111aa1113bbbbbb011111111
44444bb4fff66fff44444bb4ffffffff55555995111aa111555554551111111166666996555aa555666664665555555533bbbb30111aa11133bbbb3011111111
44444444fff66fff44444444ffffffff55555555111aa111555559951111111166666666555aa555666669965555555530000000111aa1113000000011111111
44444444444444444444444444444444555555555555555555555555555555556666666666666666666666666666666633333333333333333333333333333333
44344444443444444434444444344444554555555545555555455555554555556646666666466666664666666646666633bbbb3033bbbb3033bbbb3033bbbb30
4344444443444444434444444344444454555555545555555455555554555555646666666466666664666666646666663bbbbbb03bbbbbb03bbbbbb03bbbbbb0
4344443443444434434444344344443454555545545555455455554554555545646666466466664664666646646666463bbbbbb03bbbbbb03bbbbbb03bbbbbb0
4bb443444bb443444bb443444bb4434459955455599554555995545559955455699664666996646669966466699664663bbbbbb03bbbbbb03bbbbbb03bbbbbb0
4444434444444344444443444444434455555455555554555555545555555455666664666666646666666466666664663bbbbbb03bbbbbb03bbbbbb03bbbbbb0
44444bb444444bb444444bb444444bb4555559955555599555555995555559956666699666666996666669966666699633bbbb3033bbbb3033bbbb3033bbbb30
44444444444444444444444444444444555555555555555555555555555555556666666666666666666666666666666630000000300000003000000030000000
44444444fff66ffffff66fff4fffffff55555555111aa111111aa1111111111166666666555aa555555aa5555555555533333333111aa111111aa11111111111
b4444444fff66ffffff66fffffffffff45555555111aa111111aa1111111111146666666555aa555555aa5555555555533bbbb30111aa111111aa11111111111
bbb44b44fff66ffffff66fffffffffff44455455111aa111111aa1111111111144466466555aa555555aa555555555553bbbbbb0111aa111111aa11111111111
3bbb4bb466666ffffff66666fff6666694445445aaaaa111111aaaaa111aaaaa94446446aaaaa555555aaaaa555aaaaa3bbbbbb0aaaaa111111aaaaa111aaaaa
3b3bbbbb66666ffffff66666fff6666694944444aaaaa111111aaaaa111aaaaa94944444aaaaa555555aaaaa555aaaaa3bbbbbb0aaaaa111111aaaaa111aaaaa
3b33b3bbfffffffffffffffffff66fff949949441111111111111111111aa111949949445555555555555555555aa5553bbbbbb01111111111111111111aa111
3333b3b3fffffffffffffffffff66fff999949491111111111111111111aa111999949495555555555555555555aa55533bbbb301111111111111111111aa111
333333b3fffffff44ffffffffff66fff999999491111111111111111111aa111999999495555555555555555555aa555300000001111111111111111111aa111
__gff__
0000000000000000000000000000000000000000000000000001010102020201000000000000000000000202020102010000000000000000000002020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020102020201020202010202020102010201020102010201020102010201020202020202020202020202020202020201010102010101020101010201010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1d1d1d1d1d1d1d1d1d1d1d1d1e3f3f3f81818181818181818181818182b0a3b01d1d1d1d1d1d1d1d1d1e3f3f3f3f3f3f1d1d1d1d1d1d1d1e3f3f3f3f3f3f3f3f1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f1f2e3f3f3f93939393939393939393938392a3b0a32f2f2f2f2f2f2f2f1f3a1d1d1d1d1d1d2f2f2f2f2f2f1f2e3f3f3f3f3f3f3f3f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d3d3d3d3d3d3d3d3d3d2b2d2e3f3f3fa1a1a1a1a1a1a1a1a1a1a39192b0a3b03d3d3d3d3d3d3d2b1a2f2f2f2f2f2f2f3d3d3d3d3d2b2d2e3f3f3f3f3f3f3f3f3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f2c2d2e3f3f3fb0b0a3a3b0b0b0a3b0b0909192a3b0b03f3f3f3f3f3f3f3c3d3d3d3d3d3d3d3d3f3f3f3f3f2c2d2e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f2c2d2e3f3f3fb0a3b0b0a3b0a3b0a3b0909192b0b0a33f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f2c2d2e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f1c1d1d1d1d1d3b2d2e3f3f3fa3b0a3b0808181818181a391a38181823f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f1d1d1d1d1d3b2d2e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c1b2f2f2f2f2f192e3f3f3fb0a3a3b090b3939393939391939383923f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f2f2f2f2f2f2f192e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c2d2a3d3d3d3d3d3e3f3f3fb0a3a3a39091a3a1a1a1a391a3a391923f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3d3d3d3d3d3d3d3e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c2d2e3f3f3f3f3f3f3f3f3fa3b0b0a3909192a3b0b09091929091923f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c2d2e3f3f3f3f3f3f3f3f3fb0a3a3b0909192b0a3b09091929091923f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c2d3a1d1d1d1d1d1d1d1d1da3b0a3a39091a3818181a391929091a33f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c1a2f2f2f2f2f2f2f2f2f2fb0a3b0b090b29393939393b19290b2933f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3c3d3d3d3d3d3d3d3d3d3d3db0a3a3b0a0a1a1a1a1a1a1a1a2a0a1a13f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3fa3b0a3b0a3b0a3b0b0a3b0a3a3b0b0a33f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3fb0a3b0a3b0a3b0b0a3b0a3a3b0a3a3b03f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3fb0a3b0a3b0b0b0a3b0b0b0a3b0a3b0b03f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3f883f8888888488888484
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3f3f888888888884848484
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3f88888888848884848484
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f883f88888888888484848084
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f8888888888848484848484
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f8888888888848484848480
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f8888888884848480848080
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f888888888488848484848080
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f8888888488848484808080
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f8888888884848484808080
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3f88888888848480848080
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3f88888888848484848080
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f8888888884848484808480
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3f3f888888888484848480
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3f88888888888484848080
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3f3f3f8888848888848484
__sfx__
01060000250512b051330513d05100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000200c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c043000000000000000
291000000000000000021400202502110020400212002015021400202502110020400212002015021400201002140020200211502040021200201002140020250211002040021250201002140020100214502013
9110000021040211201d11021040230201c11021140230201a0101a140211202301024040241202f1102d04021040211201d11021040230201c11021140230201a0101a140211202301024040241202f1102d040
011000000000000000280452302524015210452302523015280452302524015210452302523015280452302524015210452302523015280452302524015210452302523015280452302524015210452302523015
0601000028650276501b650275000b5001f5001e50021500254502545028450302503230032200321003d7003f7003f5003f7003f70034700327002e6002b2002820025200212001d2001a2001f7000000000000
9f0200000c2400e2401054011530130301503017720187201a7201c72000000000000000000000000000000000000000000000000000000003220032200322003220032200322003220032200312003120031200
0003000027050300501d7001d7001e7001e7001c7001c70021700207001e7001c7001b7001970018700167001470013700117000f7000d7000c70000000000000000000000000000000000000000000000000000
490f0000363502c35032350283502d34022340283301f330243201e32018320183101831000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
490300000a6500000006630000000000000000000000000000000000000000000000000001e600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
311700000b2200000000000000000000000000000000000000220000000000000000000000000000000000000b220000000000000000000000000000000000000022000000000000000000000000000000000000
0117000010550105500b5501055010550105500b5501055013550135500e5501355013550135500e5501355010550105500b5501055010550105500b5501055013550135500e5501355013550135500e55013550
01170000131500b15000100001000e150001000010000100171500c150001000010011150151501715011150171500010000100001000e1500010000100001001715011150001000010015150171501515011150
01170000105501055017550105501055010550175501055013550135500e5501355013550135500e5501355010550175501055010550105501755010550105501055017550105501055010550175501055010550
001700000b0500000000000000000e0500000000000000000c050000000000000000110501505017050150500b050000000000000000000000000000000000000c0500000000000000000e050000000000000000
0017000018050000000000000000180500c050130500c050170500000000000000001705015050170501105013050000000000000000100500000000000000001005000000000000000007050000000000000000
011700000955110550095500955009550105500955009550095501055009550095500955010550095500955009550105500955009550095501055009550095500955010550095500955009550105500955009550
011700001805000000000000000018050180501f05018050230500000000000000002305021050230501d0501f0500000000000000001c050180501f050180501c0500000000000000001f050210502305021050
01170000155500000000000000001555015550135501555017550115501155000000000000c550115501355015550000000000015550005001555013550155500e55011550175501d55023550245502655015550
011700000c0500c050090500c0500c0500c050090500c0500b0500b050070500b0500b0500b050070500b0500c0500c050090500c0500c0500c050090500c0500b0500b050070500b0500b0500b050070500b050
0117000018550135500000000000175500e550000000000018550105501155000000185501c5501a550185501a55017550175501755017550175501a5501d5501d5501a55000000000001d550175500000013550
01170000050500005002050040500505005050000500905005050090500705005050000500b050090500705005050000000505000000050500000005050000000505005050050500505005050050500505005050
01170000135500e55000000000000c55011550000000000017550115500000000000135500e5500000000000115500c5500000000000135500e55000000000000c55011550000000000017550115500000000000
0117000018055000001c055000001d0550000017055000001c055000000000000000180550000000000000001705500000000000000018055000001c05500000170550000000000000001c055000000000000000
01170000135500e55000000000000c550115500000000000135500e5500000000000000000000000000000000c55011550000000000011550175500000000000135500e55000000000000c550115500000000000
0117000018055000000000000000170550000000000000001805500000000001c055000001d0550000000000170550000000000000001c0550000000000000001805500000000000000017055000000000000000
011700001c550215500000000000235501d550000000000021550265500000000000245502355000000000001855000000175500000018550000001855000000245501c55000000000001d550265500000000000
011700000e05500000150550000017055000001005500000170550000018055000001405500000170551a055090550000511055000050e0550000515055000051705500005100550000517055000051805500000
0117000026550215500000000000245502355000000000001d550185501755000000185501855000000000001d550185501155013550185501b5501f5501c55017550105501155017550185501d5501355011550
01170000140550000517055000051a05500005000050000509055000050000500005000051105500005000050b055000050000500005000050c0550000500005090550000500005000050b055000050805500000
01170000115500000000000000001d5501355018550195501c5501755010550115501755000000185501d5500e550155500000011550145500000015550000001355011550000000000011550000000000000000
01170000000000000000000000000b055000000c055000000905500000000000000000000000000b055000000a055000000000000000000000000000000000000000000000000000000000000000000000000000
0117000010550000000b5500000015550000000c5500000011550000000e550000000b550000000b5500000010550000000b5500000015550000000c5500000011550000000e550000000b550000001755000000
011700000c055000000c055000000c055000000c055000000c055000000c055000000c055000000c055000000c055000050c055000050c055000050c055000050c055000050c055000050c055000050c05500000
0117000013550000000e5500000010550000000b5500000011550000000e550000001155000000105500000013550000000e5500000010550000000b5500000011550000000e5500000015550000001055000000
0117000009055000051505500005090550000515055000050b0550000517055000050b05500005170550000509055000051505500005090550000515055000050b0550000517055000050b055000051705500005
01170000135500b550135500b550135500b550155501055015550105501555010550155500c550155500c550155500c550155500e550115500e550175500e550155500e550115500e550175500e5500000000000
011700000c05500000180550000028055000050e055000051a055000052905500005070550000513055000050c05500005180550000528055000050e055000051a05500005290550000507055000051305500000
01170000115501355015550175500e55017550115500e5501555013550115501055013550155500e55010550115501355015550175500e55017550115500e5501555013550115501055013550155500e55010550
011700000c0550000513055000051505500005130550000515055000051005500005110550000513055000050c055000051305500005150550000513055000051505500005100550000511055000051305500005
011700001555013550115500000010550115501355000000155501355011550000001055011550135500000015550135501155000000105501155013550000001555013550115500000010550115501355000000
011700000c055180550000000000000000000000000000000c055180550000000000000000000000000000000c055180550000000000000000000000000000000c05518055000000000000000000000000000000
011700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
