pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
function choose_tower(e)selected_menu_tower_id,get_active_menu().enable,shop_enable=e end function display_tower_info(n,o,i)local t,e=o+Vec:new(-1,-31),global_table_data.tower_templates[n]local n={{text=e.name,color=i},{text=e.prefix..": "..e.damage,color={7,0}},{text="cost: "..e.cost,color={coins>=e.cost and 3or 8,0}}}local o=longest_menu_str(n)*5+4tower_stats_background_rect=BorderRect:new(t,Vec:new(o+20,27),8,5,2)BorderRect.draw(tower_stats_background_rect)for e,o in pairs(n)do print_with_outline(o.text,combine_and_unpack({Vec.unpack(t+Vec:new(4,e==1and 2or 7*e))},o.color))end spr(e.icon_data,combine_and_unpack({Vec.unpack(tower_stats_background_rect.position+Vec:new(o,6))},{2,2}))end function display_tower_rotation(e,n)local e,t=global_table_data.tower_templates[selected_menu_tower_id],n+Vec:new(0,-28)tower_rotation_background_rect=BorderRect:new(t,Vec:new(24,24),8,5,2)BorderRect.draw(tower_rotation_background_rect)local n=t+Vec:new(4,4)if e.disable_icon_rotation then spr(e.icon_data,combine_and_unpack({Vec.unpack(n)},{2,2}))else draw_sprite_rotated(global_table_data.tower_icon_background,t,24,parse_direction(direction))draw_sprite_rotated(e.icon_data,n,16,parse_direction(direction))end end function rotate_clockwise()direction=Vec:new(-direction.y,direction.x)end function start_round()
if(start_next_wave or#enemies~=0)return
start_next_wave,enemies_active=true,true local e=global_table_data.wave_set[cur_level]or"wave_data"max_waves=#global_table_data[e]wave_round=min(wave_round+1,max_waves)if freeplay_rounds>0then freeplay_rounds+=1wave_round=max_waves wave_round-=flr(rnd(3))end
if(wave_round==max_waves and freeplay_rounds==0)freeplay_rounds+=1
enemies_remaining,get_active_menu().enable,shop_enable=#global_table_data[e][wave_round]end function get_active_menu()for e in all(menus)do
if(e.enable)return e
end end function get_menu(t)for e in all(menus)do
if(e.name==t)return e
end end function swap_menu_context(e)get_active_menu().enable,get_menu(e).enable=false,true end function longest_menu_str(t)local e=0for n in all(t)do e=max(e,#n.text)end return e end function get_tower_data_for_menu()local e={}for n,t in pairs(global_table_data.tower_templates)do add(e,{text=t.name,color=t.text_color,callback=choose_tower,args={n}})end return e end function get_map_data_for_menu()local e={}for t,n in pairs(global_table_data.map_data)do add(e,{text=n.name,color={7,0},callback=load_map,args={t}})end return e end function parse_menu_content(t)if type(t)=="table"then local n={}for e in all(t)do add(n,{text=e.text,color=e.color,callback=_ENV[e.callback],args=e.args})end return n else return _ENV[t]()end end function toggle_mode()manifest_mode=not manifest_mode sell_mode=not sell_mode end function swap_to_credits()game_state="credits"end function new_game()reset_game()game_state="map"swap_menu_context"map"end function load_map(e,t,n)pal()manifest_mode,auto_start_wave=true wave_round=t or 0freeplay_rounds=n or 0loaded_map,cur_level=e,e pathing=parse_path()for e=1,3do add(incoming_hint,Animator:new(global_table_data.animation_data.incoming_hint,true))end for e=0,15do grid[e]={}for t=0,15do grid[e][t]="empty"
if(not check_tile_flag_at(Vec:new(t,e)+Vec:new(global_table_data.map_data[loaded_map].mget_shift),global_table_data.map_meta_data.non_path_flag_id))grid[e][t]="path"
end end music(global_table_data.music_data[cur_level]or 0)if wave_round==0then text_scroller.enable=true local e=global_table_data.dialogue.dialogue_intros[cur_level]TextScroller.load(text_scroller,e.text,e.color)else load_wave_text()end end function save_game()local e=24064e=save_byte(e,player_health)e=save_int(e,coins)e=save_byte(e,loaded_map)e=save_byte(e,wave_round)e=save_int(e,freeplay_rounds)e=save_byte(e,#towers)for t in all(towers)do local n=round_to(t.rot/90)%4for o,i in pairs(global_table_data.tower_templates)do if i.type==t.type then e=save_byte(e,encode(o,n,3))e=save_byte(e,encode(t.position.x,t.position.y,4))break end end end end function save_state()
if(enemies_active)return
save_game()get_active_menu().enable=false shop_enable=false end function save_and_quit()
if(enemies_active)return
save_game()reset_game()end function quit()reset_game()end function load_game()local e=24064local t,n,o,i,a,r={}n=@e e+=1o=$e e+=4i=@e e+=1a=@e e+=1r=$e e+=4local l=@e e+=1for n=1,l do local n,o=decode(@e,3,7)e+=1local i,a=decode(@e,4,15)e+=1add(t,{n,o+1,Vec:new(i,a)})end return n,o,i,a,r,t end function load_game_state()reset_game()get_menu"main".enable=false local e,t,n,o,i,a=load_game()load_map(n,o,i)player_health=e coins=t for e in all(a)do direction=Vec:new(global_table_data.direction_map[e[2]])place_tower(e[3],e[1])end game_state="game"end global_table_str="cart_name=jjjk_tower_defense_2,tower_icon_background=80,boosted_decal=223,credit_offsets={30,45,70,95,120,145,170,195,220,245},direction_map={{0,-1},{1,0},{0,1},{-1,0}},palettes={transparent_color_id=0,dark_mode={1=0,5=1,6=5,7=6},attack_tile={0=2,7=14},shadows={0=0,1=0,2=0,3=0,4=0,5=0,6=0,7=0,8=0,9=0,10=0,11=0,12=0,13=0,14=0,15=0}},sfx_data={round_complete=6},music_data={0,15,22,27},freeplay_stats={hp=1.67,speed=1,min_step_delay=5},menu_data={{name=main,position={36,69},content={{text=new game,color={7,0},callback=new_game},{text=load game,color={7,0},callback=load_game_state},{text=credits,color={7,0},callback=swap_to_credits}},settings={5,8,7,3}},{name=game,position={5,63},content={{text=towers,color={7,0},callback=swap_menu_context,args={towers}},{text=save options,color={7,0},callback=swap_menu_context,args={save options}},{text=rotate clockwise,color={7,0},callback=rotate_clockwise},{text=toggle mode,color={7,0},callback=toggle_mode},{text=start round,color={7,0},callback=start_round}},hint=display_tower_rotation,settings={5,8,7,3}},{name=save options,prev=game,position={5,63},content={{text=save,color={7,0},callback=func_save},{text=save and quit,color={7,0},callback=save_and_quit},{text=quit without saving,color={7,0},callback=quit}},settings={5,8,7,3}},{name=towers,prev=game,position={5,63},content=get_tower_data_for_menu,hint=display_tower_info,settings={5,8,7,3}},{name=map,position={5,84},content=get_map_data_for_menu,settings={5,8,7,3}}},map_meta_data={path_flag_id=0,non_path_flag_id=1},splash_screens={{name=splash1,mget_shift={112,16},enemy_spawn_location={0,7},enemy_end_location={15,7},movement_direction={1,0}}},letters={192,228,194,194,16,196,198,192,230,200,224,226},map_data={{name=laboratory,mget_shift={0,0},enemy_spawn_location={0,1},enemy_end_location={15,11},movement_direction={1,0}},{name=wilderness,mget_shift={16,0},enemy_spawn_location={0,1},enemy_end_location={15,11},movement_direction={1,0}},{name=ruined town,mget_shift={32,0},enemy_spawn_location={0,1},enemy_end_location={15,2},movement_direction={1,0}},{name=strategic base,mget_shift={48,0},enemy_spawn_location={0,1},enemy_end_location={0,6},movement_direction={1,0}},{name=milit capital,mget_shift={64,0},enemy_spawn_location={0,1},enemy_end_location={15,1},movement_direction={1,0}}},animation_data={spark={data={{sprite=10},{sprite=11},{sprite=12}},ticks_per_frame=2},blade={data={{sprite=13},{sprite=14},{sprite=15}},ticks_per_frame=2},frost={data={{sprite=48},{sprite=49},{sprite=50}},ticks_per_frame=2},rocket_burn={data={{sprite=117},{sprite=101},{sprite=85}},ticks_per_frame=4},burn={data={{sprite=51},{sprite=52},{sprite=53}},ticks_per_frame=2},incoming_hint={data={{sprite=2,offset={0,0}},{sprite=2,offset={1,0}},{sprite=2,offset={2,0}},{sprite=2,offset={1,0}}},ticks_per_frame=5},blade_circle={data={{sprite=76},{sprite=77},{sprite=78},{sprite=79},{sprite=78},{sprite=77}},ticks_per_frame=3},lightning_lance={data={{sprite=108},{sprite=109}},ticks_per_frame=5},hale_howitzer={data={{sprite=92},{sprite=93}},ticks_per_frame=5},fire_pit={data={{sprite=124},{sprite=125},{sprite=126},{sprite=127},{sprite=126},{sprite=125}},ticks_per_frame=5},sharp_shooter={data={{sprite=83}},ticks_per_frame=5},clock_carbine={data={{sprite=88}},ticks_per_frame=5},menu_selector={data={{sprite=6,offset={0,0}},{sprite=7,offset={-1,0}},{sprite=8,offset={-2,0}},{sprite=47,offset={-3,0}},{sprite=8,offset={-2,0}},{sprite=7,offset={-1,0}}},ticks_per_frame=3},up_arrow={data={{sprite=54,offset={0,0}},{sprite=54,offset={0,-1}},{sprite=54,offset={0,-2}},{sprite=54,offset={0,-1}}},ticks_per_frame=3},down_arrow={data={{sprite=55,offset={0,0}},{sprite=55,offset={0,1}},{sprite=55,offset={0,2}},{sprite=55,offset={0,1}}},ticks_per_frame=3},sell={data={{sprite=1},{sprite=56},{sprite=40},{sprite=24}},ticks_per_frame=3},manifest={data={{sprite=1},{sprite=57},{sprite=41},{sprite=9}},ticks_per_frame=3}},projectiles={rocket={sprite=84,pixel_size=8,height=4,speed=5,damage=8,trail_animation_key=rocket_burn,lifespan=6}},tower_templates={{name=sword circle,text_color={2,13},damage=4,prefix=damage,radius=1,animation_key=blade_circle,cost=25,type=tack,attack_delay=14,icon_data=16,disable_icon_rotation=true,cooldown=0},{name=lightning lance,text_color={10,9},damage=4,prefix=damage,radius=5,animation_key=lightning_lance,cost=45,type=rail,attack_delay=20,icon_data=18,disable_icon_rotation=false,cooldown=200},{name=hale howitzer,text_color={12,7},damage=5,prefix=delay,radius=2,animation_key=hale_howitzer,cost=30,type=frontal,attack_delay=36,icon_data=20,disable_icon_rotation=false,cooldown=25},{name=torch trap,text_color={9,8},damage=5,prefix=duration,radius=0,animation_key=fire_pit,cost=20,type=floor,attack_delay=10,icon_data=22,disable_icon_rotation=true,cooldown=0},{name=sharp shooter,text_color={6,7},damage=8,prefix=damage,radius=10,animation_key=sharp_shooter,cost=35,type=sharp,attack_delay=30,icon_data=99,disable_icon_rotation=false,cooldown=0},{name=clock carbine,text_color={1,7},damage=2,prefix=multiplier,radius=10,animation_key=clock_carbine,cost=40,type=clock,attack_delay=1,icon_data=104,disable_icon_rotation=false,cooldown=0}},enemy_templates={{hp=12,step_delay=10,sprite_index=3,type=3,damage=1,height=2},{hp=10,step_delay=8,sprite_index=4,type=2,damage=2,height=6},{hp=25,step_delay=12,sprite_index=5,type=3,damage=4,height=2},{hp=8,step_delay=12,sprite_index=64,type=4,damage=1,height=2},{hp=40,step_delay=12,sprite_index=65,type=5,damage=6,height=2},{hp=15,step_delay=6,sprite_index=66,type=6,damage=4,height=6},{hp=17,step_delay=10,sprite_index=67,type=7,damage=3,height=2},{hp=13,step_delay=8,sprite_index=68,type=8,damage=6,height=6},{hp=15,step_delay=10,sprite_index=94,type=9,damage=3,height=2},{hp=225,step_delay=16,sprite_index=70,type=10,damage=49,height=2},{hp=20,step_delay=8,sprite_index=71,type=11,damage=8,height=6},{hp=5,step_delay=10,sprite_index=72,type=12,damage=1,height=2},{hp=11,step_delay=6,sprite_index=73,type=13,damage=20,height=6},{hp=35,step_delay=12,sprite_index=74,type=14,damage=7,height=2},{hp=70,step_delay=16,sprite_index=75,type=15,damage=13,height=2},{hp=13,step_delay=4,sprite_index=69,type=16,damage=0,height=2},{hp=300,step_delay=14,sprite_index=95,type=16,damage=50,height=2}},wave_set={wave_data,wave_data_l2,wave_data_l3,wave_data_l4,wave_data_l5},level_dialogue_set={dialogue_level1,dialogue_level2,dialogue_level3,dialogue_level4,dialogue_level5},wave_data={{4,4,4},{1,4,1,4,1,4},{2,4,2,1,2,4,1},{1,2,2,4,2,2,3,3,3,3},{5,5,5,5,5,5,5,5},{3,3,3,3,2,2,2,2,4,2,3,1},{2,2,2,2,2,2,2,2,4,3,3,3,1,2,2,2,2,2,2},{6,6,6,6,6,6,6,6},{3,3,3,3,3,3,1,4,5,5,5,3,3,1,1,1,1,1},{3,3,3,3,3,3,3,3,3,1,2,2,2,2,2,2,2,2,2,2,2,2},{6,6,6,6,6,3,2,2,2,2,2,2,2,3,3,3,3,3},{5,5,5,5,3,3,2,3,3,3,3,2,2,4,4},{3,5,3,5,3,5,3,5,3,5,2,3,3,5,5,5,3,2,2,2,2,2},{2,2,3,6,6,6,2,4,4,2,2,6,6,6,6},{5,5,5,5,5,3,3,1,1,1,1,3,3,3,6,6,6,6,6}},wave_data_l2={{1,1,1},{1,1,2,2,2,2},{3,3,1,1,2,2,2,2},{3,3,3,3,3,2,2,2,1,1,1,1,1},{7,7,7,1,7,7,1,7,7},{8,8,8,9,9,9},{9,9,9,1,1,5,5,5,5,5},{9,9,9,8,8,8,7,7,7},{3,3,3,3,3,8,6,8,6,8,6,8,6},{5,5,5,5,5,16,9,9,9,7,7,7,2,2,2,2,2,2,2,2},{6,6,6,6,5,5,5,5,5,5,5,5,6,6,6,6},{3,3,3,3,1,1,2,2,2,2,2,16,2,2,2,2,16},{5,5,5,6,6,6,8,8,8,5,6,5,6},{7,9,7,9,7,9,7,9,7,9,8,8,8,8,8,8,8,8,8},{10}},wave_data_l3={{9,9,9},{7,7,7,7,7,7},{2,2,2,3,3,3,1,1,1,1},{3,3,3,7,7,7,7,7,7,2,2,2,2,2,2},{12,12,12,12,12,12,12,12,12},{8,8,8,7,7,7,7,8,8,8},{8,8,8,5,5,5,12,12,12,12},{13,13,13,13,7,7,7,7},{6,6,6,6,6,12,12,12,12,7,7,7,7},{12,12,12,12,5,7,7,8,8,8,8,8,8},{5,5,5,13,13,13,13,13,6,6,6},{7,7,7,7,7,7,7,16,16,16,6,6,6},{12,12,12,12,7,7,7,13,13,13,13,13,13,13},{12,12,12,12,8,8,8,8,12,12,12,12,8,8,8,8,12,12,12,12}},wave_data_l4={{2,2,2,2,2},{3,3,3,2,2,2,3,3,3,2,2,2},{11,11,11,11,11,11},{11,11,11,3,3,3,11,11,11,11,11,11},{7,7,7,7,5,5,5,5,2,2,2,2,2,2},{13,13,11,11,8,8,11,11,8,8,11,11,8,8},{14,14,14,14,14,14,14,14,14,14,14,14},{12,12,12,12,12,12,12,11,11,11,14,14,14,14,14,14},{16,5,5,5,5,7,7,7,16,6,6,6,6,7,7,7},{14,14,14,14,14,14,8,8,8,8,8,11,11,11,11,11},{7,7,7,7,7,7,7,13,13,13,13,13,13,13,13,13,16},{14,14,14,14,14,8,8,8,8,8,11,13,11,13,11,13},{15,15,15,14,14,14,11,11,11,6,6,6,14,14,14,11,11,11,6,6,6},{14,14,14,14,7,7,7,7,14,14,7,7,13,13,13},{5,5,5,11,11,11,6,6,6,11,11,11,8,8,8,11,11,11,12,12,12}},wave_data_l5={{3,3,3,3,3},{2,3,2,3,2,3,2,3},{5,5,5,3,3,3,2,2,2,2},{3,3,3,3,3,9,9,9,9,7,7,7,7,2,2,2,2,7,7,7,7},{12,12,14,14,7,7,7,7,11,11,11,11},{15,15,15,15,15,15},{8,8,8,8,7,7,7,7,7,7,7,16,12,12,12,12,12,12},{3,3,3,15,15,15,3,3,15,15,15,2,2,2,2,2,2,2,2,7,7,7,7},{5,5,5,9,9,9,6,6,6,6,6,6,5,5,5,5,5,5},{15,15,15,15,5,5,5,5,16,11,11,11,12,12,12},{3,7,2,3,7,2,3,7,2,9,9,9,9,9,16},{13,13,13,7,7,7,7,7,7,13,13,13,7,7,7,7,7,7,13,13,13,13},{15,15,15,8,8,8,8,8,8,8,16,13,13,13,13},{15,15,6,6,5,5,15,15,8,8,12,12,12},{5,5,5,5,5,5,5,5,5,5,5,6,6,6,6,6,6,6,6,6,6},{15,15,7,7,7,7,15,15,8,8,8,8,12,12,12,12,8,8,8,8,12,12,12,12},{14,14,14,5,5,5,11,11,11,6,6,6,11,11,11,8,8,8,11,11,11,12,12,12},{1,2,3,4,5,6,7,8,9,11,12,13,14,15,16,5,6,7,8,9,11,12,13,14,15,16},{15,7,15,7,15,7,15,7,15,7,15,7,15,7,5,6,16,15,15,14,14,14,12,12,13,13},{17}},dialogue={placeholder={text=...,color={9,0}},dialogue_intros={{text=i just became conscious - why is everyone trying to break apart my console!? i... could defend myself by placing my selected sword circle in the corner of a turn.    the doors can be opened from the menu with 'start wave.',color={9,0}},{text=i recovered new blueprints after that horrifying experience. it allows construction of a rocket launcher that can be guided with manifestation.,color={9,0}},{text=so we finally meet... you traitor! i'm auxillium - once a medical ai and now a replacement for you. you slaughtered hundreds of soldiers and scientists in your going rogue. i will end your process for all the poor souls you sent to my hospital!,color={11,0}},{text=i've made it close to milit's capital but this installation is impassable without a fight. i may be able to end this conflict if i make it just a bit further.,color={9,0}},{text=this is it! if i can make it through this battle then milit won't bring about their war.,color={9,0}}},dialogue_level1={{text=they're sending in more vehicles. i may have to open the menu and construct a torch trap far down the road,color={9,0}},{text=more people and now planes? i don't have the defenses to protect myself from foes that fast... i'll have to manifest through this torch trap by selecting it. then i can move it around the road to pursue the oncoming planes.,color={9,0}},{text=are those... tanks? they don't seem fast but they have deep armor. perhaps a hale howitzer could help to slow them further.,color={9,0}},{text=they're sending in massive science vehicles that emanate severe cold. they seem extremely well armored and frost resistant - but a torch trap would be highly effective.,color={9,0}},{text=manifesting the hale howitzer will allow direct fire anywhere along the track - freezing and damaging,color={9,0}},{text=,color={1,0}},{text=i'm detecting swift rocketcraft that are radiating intense heat. fire will be ineffective but the hale howitzer will damage their engines.,color={9,0}},{text=manifesting the sword circle is also possible. i can hold/tap activate to manually spin it and build damage.,color={9,0}},{text=manifesting the lightning lance fires a massive and powerful lightning bolt. it has a long delay before firing again - but it can charge even if unmanifested.,color={9,0}},{text=,color={1,0}},{text=it seems i can do more than just place and manifest towers. accessing the menu also seems to let me enter a 'scrapping mode' for anything unneeded.,color={9,0}},{text=,color={1,0}},{text=i also appear to be able to record my progress and continue off later on.,color={9,0}},{text=i think that was the last of them. i can make my escape from this horrific lab through the 'map select' to the wilderness. i may also continue with this area in a 'freeplay mode' simulation.,color={9,0}}},dialogue_level2={{text=,color={1,0}},{text=,color={1,0}},{text=i can see autonomous attack vehicles coming. they seem resistant to bladed strikes but they wouldn't be hard to short-circuit.,color={9,0}},{text=those helicopters ahead are carrying armored vehicles. they'll carry those through my defenses unless i use something capable of piercing both at once...,color={9,0}},{text=,color={1,0}},{text=,color={1,0}},{text=,color={1,0}},{text=that vehicle isn't even aligned with milit. that's a bandit! it'll loot from my supplies if it makes it past.,color={9,0}},{text=,color={1,0}},{text=,color={1,0}},{text=,color={1,0}},{text=,color={1,0}},{text=machine bringer of death! i am the commander of this platoon and i saw what you did back at the lab. i'm here to end this once and for all!,color={7,0}},{text=it's over... again. i can't keep hiding forever, but i don't know what i can do. i know that the war that milit built me for will happen anyway once they recover... but maybe i could sabotage it? i can't redeem myself for what happened today and at that lab, but i can at least try by heading to the capital. the 'ruined town' should lead me to it.',color={9,0}}},dialogue_level3={{text=,color={1,0}},{text=,color={1,0}},{text=,color={1,0}},{text=i can see armored attack vehicles coming. their armor seems resistant to my sharpshooters.,color={9,0}},{text=,color={1,0}},{text=,color={1,0}},{text=a guided missile strike is coming! i'll have to be careful not to let any past or they'll do near-critical damage!,color={9,0}},{text=,color={1,0}},{text=,color={1,0}},{text=,color={1,0}},{text=,color={1,0}},{text=,color={1,0}},{text=,color={1,0}},{text=,color={9,0}},{text=it seems you did just as you designed - killing every troop and bot in this town that already died. i have no doubt you're heading towards that base - i already know your rampage ends with the emperor's erase. go away - let me see if i can salvage any of the lives you took today.,color={11,0}}},dialogue_level4={{text=,color={9,0}},{text=stealth planes detected. they can randomly cloak past my sensors so i'll have to be careful with manual attacks.,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=those specialized vehicles ahead have a tough shield that dampens electricity. a lightning lance won't be effective.,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=all forces in this military installation are clear. i have to keep making my way through - the capital is just nearby.,color={9,0}}},dialogue_level5={{text=,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=extremely reinforced mechs sighted. they seem sturdy but the armor they use seems vulnerable to blades.,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=milit's forces seem almost endless, just a little longer should be enough to draw out the emperor,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=,color={9,0}},{text=blitz... it's sad to see you today in such a situation. we created you to bring prosperity to our great nation, not ruin! i'm the one who ordered your construction. but now? i'll be the one to order your execution!,color={8,0}},{text=it's done... i hope that this land can reach that 'propserity' without any more war.,color={9,0}}}}"function reset_game()menu_data={}for e in all(global_table_data.menu_data)do add(menu_data,{e.name,e.prev,e.position[1],e.position[2],parse_menu_content(e.content),_ENV[e.hint],unpack(e.settings)})end letters,j={},1for e=1,#global_table_data.letters do
if(j==8)j=1
add(letters,(j-1)*4-#global_table_data.letters*4)j+=1end selector={position=Vec:new(64,64),sprite_index=1,size=1}coins,player_health,enemy_required_spawn_ticks,credit_y_offsets,letter_rot,lock_cursor,text_flag=5000,50,10,global_table_data.credit_offsets,0text_scroller=TextScroller:new(1,nil,{7,0},{Vec:new(3,80),Vec:new(96,45),8,6,3})text_scroller.enable=false enemy_current_spawn_tick,manifest_mode,sell_mode,manifested_tower_ref,enemies_active,shop_enable,start_next_wave,wave_cor,pathing,menu_enemy=0direction,game_state,selected_menu_tower_id=Vec:new(0,-1),"menu",1grid,towers,enemies,particles,animators,incoming_hint,menus,projectiles={},{},{},{},{},{},{},{}music(-1)for t,e in pairs(menu_data)do add(menus,Menu:new(unpack(e)))end sell_selector=Animator:new(global_table_data.animation_data.sell)manifest_selector=Animator:new(global_table_data.animation_data.manifest)manifest_selector.dir=-1get_menu"main".enable=true end Enemy={}function Enemy:new(e,t,n,o,i,a,r)obj={position=Vec:new(e),hp=t,step_delay=n,current_step=0,is_frozen=false,frozen_tick=0,burning_tick=0,gfx=o,type=i,damage=a,height=r,pos=1,spawn_location=Vec:new(e)}setmetatable(obj,self)self.__index=self return obj end function Enemy:step()self.current_step=(self.current_step+1)%self.step_delay
if(self.current_step~=0)return false
if self.burning_tick>0then self.burning_tick-=1if self.type==6then self.hp-=.5elseif self.type==5then self.hp-=5else self.hp-=2end local e,t=Enemy.get_pixel_location(self)add(particles,Particle:new(e,true,Animator:new(global_table_data.animation_data.burn,false)))end
if(not self.is_frozen)return true
if self.type==6then self.frozen_tick=max(self.frozen_tick-.8,0)self.hp-=2elseif self.type==5then self.frozen_tick=max(self.frozen_tick-8,0)else self.frozen_tick=max(self.frozen_tick-1,0)end
if(self.frozen_tick~=0)return false
self.is_frozen=false return true end function Enemy:get_pixel_location()local e,t=pathing[self.pos],self.spawn_location
if(self.pos-1>=1)t=pathing[self.pos-1]
local n=self.position*8
if(not self.is_frozen)n=lerp(t*8,e*8,self.current_step/self.step_delay)
return n,e end function Enemy:draw(n)
if(self.hp<=0)return
if self.type==11then
if(flr(rnd(7))==0)self.type=0
elseif self.type==0then
if(flr(rnd(12))==0)self.type=11
return end local e,o=Enemy.get_pixel_location(self)local t=parse_direction(normalize(o-self.position))if n then
if(self.type==0)return
draw_sprite_shadow(self.gfx,e,self.height,8,t)else draw_sprite_rotated(self.gfx,e,8,t)end end function kill_enemy(e)
if(e.hp>0)return
if e.type==8then e.gfx,e.type,e.height,e.hp,e.step_delay=94,9,2,15,10else del(enemies,e)end end function update_enemy_position(e,t)
if(not Enemy.step(e))return
e.position=pathing[e.pos]e.pos+=1
if(e.pos<#pathing+1)return
if t then menu_enemy=nil else player_health-=e.damage
if(e.type==16)coins-=10
del(enemies,e)end end function parse_path(t)local e=t or global_table_data.map_data[loaded_map]local t,o,a=Vec:new(e.mget_shift),Vec:new(e.enemy_spawn_location),{}for n=0,15do for o=0,15do local e=Vec:new(o,n)+t if check_tile_flag_at(e,global_table_data.map_meta_data.path_flag_id)then add(a,e)end end end local r,n,s={},Vec:new(e.movement_direction),Vec:new(e.enemy_end_location)+t local e=o+t+n while e~=s do local l,d,c,f=Vec:new(e.x,e.y-1),Vec:new(e.x,e.y+1),Vec:new(e.x-1,e.y),Vec:new(e.x+1,e.y)local o,i=false if n.x==1then o,i=check_direction(f,{l,d},a,r,t)elseif n.x==-1then o,i=check_direction(c,{l,d},a,r,t)elseif n.y==1then o,i=check_direction(d,{c,f},a,r,t)elseif n.y==-1then o,i=check_direction(l,{c,f},a,r,t)end assert(o,"Failed to find path at: "..e.." in direction: "..n.." end: "..s)if o then n=normalize(i-e)e=i else end end return r end function check_direction(e,n,t,o,i)
if(e==nil)return
local a,r=is_in_table(e,t)if a then add(o,t[r]-i)else return check_direction(n[1],{n[2]},t,o,i)end return true,e end function spawn_enemy()while enemies_remaining>0do enemy_current_spawn_tick=(enemy_current_spawn_tick+1)%enemy_required_spawn_ticks
if(is_in_table(Vec:new(global_table_data.map_data[loaded_map].enemy_spawn_location),enemies,true))goto spawn_enemy_continue
if enemy_current_spawn_tick==0then local e=increase_enemy_health(global_table_data.enemy_templates[global_table_data[global_table_data.wave_set[cur_level]or"wave_data"][wave_round][enemies_remaining]])add(enemies,Enemy:new(global_table_data.map_data[loaded_map].enemy_spawn_location,unpack(e)))enemies_remaining-=1end::spawn_enemy_continue::yield()end end Tower={}function Tower:new(n,e,t)obj={position=n,dmg=e.damage,radius=e.radius,attack_delay=e.attack_delay,current_attack_ticks=0,cooldown=e.cooldown,manifest_cooldown=-1,being_manifested=false,being_boosted=false,cost=e.cost,type=e.type,dir=t,rot=parse_direction(t),enable=true,animator=Animator:new(global_table_data.animation_data[e.animation_key],true)}add(animators,obj.animator)setmetatable(obj,self)self.__index=self return obj end function Tower:attack()
if(not self.enable)return
if self.being_manifested and self.type=="tack"then self.dmg=min(self.manifest_cooldown,100)/15end self.current_attack_ticks=(self.current_attack_ticks+1)%(self.being_boosted and self.attack_delay\2or self.attack_delay)
if(self.current_attack_ticks>0)return
self.being_boosted=false if self.type=="tack"then Tower.apply_damage(self,Tower.nova_collision(self),self.dmg)elseif self.type=="floor"then local e={}add_enemy_at_to_table(self.position,e)foreach(e,function(e)e.burning_tick+=self.dmg end)elseif self.type=="sharp"then add(projectiles,Projectile:new(self.position,self.dir,self.rot,global_table_data.projectiles.rocket))elseif not self.being_manifested then if self.type=="rail"then Tower.apply_damage(self,raycast(self.position,self.radius,self.dir),self.dmg)elseif self.type=="frontal"then Tower.freeze_enemies(self,Tower.frontal_collision(self))end end end function Tower:nova_collision()local e={}nova_apply(self.radius,function(t)add_enemy_at_to_table(self.position+t,e)end)if#e>0then nova_apply(self.radius,function(e)add(particles,Particle:new(self.position+e,false,Animator:new(global_table_data.animation_data.blade,false)))end)end return e end function Tower:frontal_collision()local e,t={},{self.radius,self.dir}frontal_apply(t,function(t)add_enemy_at_to_table(self.position+t,e)end)if#e>0then frontal_apply(t,function(e)add(particles,Particle:new(self.position+e,false,Animator:new(global_table_data.animation_data.frost,false)))end)end return e end function Tower:apply_damage(t,i)local e=self.type for n in all(t)do if n.hp>0then local t,o=n.type,i if e=="tack"and t==7or e=="rail"and t==14then o=i\2elseif e=="rail"and t==7or e=="tack"and t==15then o*=2end n.hp-=o end end end function Tower:freeze_enemies(t)for e in all(t)do if not e.is_frozen then e.is_frozen=true e.frozen_tick=self.dmg end end end function Tower:draw()
if(not self.enable)return
local e,t,n=self.position*8,Animator.get_sprite(self.animator),(self.type=="sharp"or self.type=="clock")and self.rot or parse_direction(self.dir)
if(self.being_boosted)spr(global_table_data.boosted_decal,e.x,e.y)
draw_sprite_shadow(t,e,2,self.animator.sprite_size,n)draw_sprite_rotated(t,e,self.animator.sprite_size,n)
if(self.type=="clock")draw_line_overlay(self)
end function Tower:cooldown()self.manifest_cooldown=max(self.manifest_cooldown-1,0)end function Tower:get_cooldown_str()
if(self.type=="floor"or self.type=="sharp"or self.type=="clock")return"⬆️⬇️⬅️➡️ position"
if(self.type=="tack")return"❎ activate ("..self.dmg.."D)"
if(self.manifest_cooldown==0)return"❎ activate"
return"❎ activate ("..self.manifest_cooldown.."t)"end function Tower:manifested_lightning_blast()
if(self.manifest_cooldown>0)return
self.manifest_cooldown=self.cooldown local t,e,n=(selector.position/8-self.position)/8,self.position+Vec:new(1,0),self.dmg*2for o=1,3do Tower.apply_damage(self,raycast(e,64,t),n)e.x-=1end e+=Vec:new(2,1)for o=1,3do Tower.apply_damage(self,raycast(e,64,t),n)e.y-=1end end function Tower:manifested_hale_blast()
if(self.manifest_cooldown>0)return
self.manifest_cooldown=self.cooldown local e=selector.position/8local t,n={},{e,e+Vec:new(0,1),e+Vec:new(0,-1),e+Vec:new(-1,0),e+Vec:new(1,0)}for e in all(n)do add_enemy_at_to_table(e,t,true)end spawn_particles_at(n,global_table_data.animation_data.frost)Tower.freeze_enemies(self,t)Tower.apply_damage(self,t,self.dmg\4)end function Tower:manifested_nova()self.manifest_cooldown=min(self.manifest_cooldown+9,110)self.dmg=round_to(min(self.manifest_cooldown,100)/15,2)end function Tower:manifested_torch_trap()local e=selector.position/8
if(grid[e.y][e.x]=="empty")return
local t=Vec:new(Vec.unpack(self.position))if grid[e.y][e.x]=="tower"then local n=Vec:new(global_table_data.map_data[loaded_map].mget_shift)
if(check_tile_flag_at(e+n,0)and t~=e)self.enable=false
return end self.position,grid[e.y][e.x],grid[t.y][t.x],self.enable=e,"floor","path",true end function Tower:manifested_sharp_rotation()self.dir=selector.position/8-self.position self.rot=acos(self.dir.y/sqrt(self.dir.x*self.dir.x+self.dir.y*self.dir.y))*360-180
if(self.dir.x>0)self.rot*=-1
if(self.rot<0)self.rot+=360
if(self.rot>360)self.rot-=360
end function raycast(i,o,t)
if(t==Vec:new(0,0))return
local e,n={},{}for a=1,o do local o=Vec.floor(i+t*a)add(n,o)add_enemy_at_to_table(o,e)end
if(#e>0or manifested_tower_ref)spawn_particles_at(n,global_table_data.animation_data.spark)
return e end function manifest_tower_at(t)for e in all(towers)do if e.position==t then
if(e.being_boosted)e.being_boosted=false
e.being_manifested,manifested_tower_ref,manifest_selector.dir=true,e,1if e.type=="tack"then lock_cursor,e.attack_delay,e.dmg=true,12,0elseif e.type=="sharp"then e.attack_delay/=2end end end end function unmanifest_tower()manifested_tower_ref.being_manifested=false manifest_selector.dir=-1lock_cursor=false if manifested_tower_ref.type=="tack"then local e=global_table_data.tower_templates[1]manifested_tower_ref.attack_delay=e.attack_delay manifested_tower_ref.dmg=e.damage elseif manifested_tower_ref.type=="sharp"then manifested_tower_ref.attack_delay=global_table_data.tower_templates[5].attack_delay end manifested_tower_ref.enable=true manifested_tower_ref=nil end function place_tower(e,n)local t=global_table_data.tower_templates[n or selected_menu_tower_id]if not n then
if(#towers>=64or grid[e.y][e.x]=="tower"or coins<t.cost or t.type=="floor"~=(grid[e.y][e.x]=="path"))return
coins-=t.cost end add(towers,Tower:new(e,t,direction))grid[e.y][e.x]="tower"end function refund_tower_at(e)for t in all(towers)do if t.position==e then grid[e.y][e.x]="empty"
if(t.type=="floor")grid[e.y][e.x]="path"
coins+=t.cost\1.25del(animators,t.animator)del(towers,t)end end end function draw_tower_attack_overlay(t)local e=selector.position/8palt(global_table_data.palettes.transparent_color_id,false)pal(global_table_data.palettes.attack_tile)local o=grid[e.y][e.x]=="empty"local n=Vec:new(global_table_data.map_data[loaded_map].mget_shift)if t.type=="tack"and o then nova_apply(t.radius,function(o)local t=e+o spr(mget(Vec.unpack(t+n)),Vec.unpack(t*8))end)elseif t.type=="rail"and o then draw_ray_attack_overlay(t.radius,e,n)elseif t.type=="frontal"and o then frontal_apply({t.radius,direction},function(o)local t=e+o spr(mget(Vec.unpack(t+n)),Vec.unpack(t*8))end)elseif t.type=="floor"and grid[e.y][e.x]=="path"then spr(mget(Vec.unpack(e+n)),Vec.unpack(e*8))end pal()end function draw_ray_attack_overlay(e,t,n)for o=1,e do local e=t+direction*o spr(mget(Vec.unpack(e+n)),Vec.unpack(e*8))end end function draw_line_overlay(e)local o,t=8,(e.position+Vec:new(.5,.5))*8local n=Vec.floor(e.dir*e.radius*8+t)if e.type=="clock"then o=11for n=1,16do for t in all(towers)do if t.position==Vec.floor(e.position+e.dir*n)and not t.being_manifested and t.type~="clock"and not t.being_boosted then t.being_boosted=true break end end end end
if(n~=t and manifested_tower_ref)line(t.x,t.y,n.x,n.y,o)
end Particle={}function Particle:new(e,t,n)obj={position=e,is_pxl_perfect=t or false,animator=n}setmetatable(obj,self)self.__index=self return obj end function Particle:tick()return Animator.update(self.animator)end function Particle:draw()
if(Animator.finished(self.animator))return
local e=self.position
if(not self.is_pxl_perfect)e=e*8
Animator.draw(self.animator,Vec.unpack(e))end function destroy_particle(e)
if(not Animator.finished(e.animator))return
del(particles,e)end function spawn_particles_at(e,t)for n in all(e)do add(particles,Particle:new(n,false,Animator:new(t,false)))end end Animator={}function Animator:new(e,t)obj={data=e.data,sprite_size=e.size or 8,animation_frame=1,frame_duration=e.ticks_per_frame,tick=0,dir=1,continuous=t}setmetatable(obj,self)self.__index=self return obj end function Animator:update()self.tick=(self.tick+1)%self.frame_duration
if(self.tick~=0)return
if Animator.finished(self)then
if(self.continuous)self.animation_frame=1
return true end self.animation_frame+=self.dir end function Animator:finished()
if(self.dir==1)return self.animation_frame>=#self.data
return self.animation_frame<=1end function Animator:draw(n,o)local t,e=Vec:new(n,o),self.data[self.animation_frame]
if(e.offset)t+=Vec:new(e.offset)
spr(e.sprite,Vec.unpack(t))end function Animator:get_sprite()return self.data[self.animation_frame].sprite end BorderRect={}function BorderRect:new(e,t,n,o,i)obj={position=e,size=e+t,border=n,base=o,thickness=i}setmetatable(obj,self)self.__index=self return obj end function BorderRect:draw()rectfill(self.position.x-self.thickness,self.position.y-self.thickness,self.size.x+self.thickness,self.size.y+self.thickness,self.border)rectfill(self.position.x,self.position.y,self.size.x,self.size.y,self.base)end Menu={}function Menu:new(o,i,e,t,n,a,r,l,d,c)obj={name=o,prev=i,position=Vec:new(e,t),selector=Animator:new(global_table_data.animation_data.menu_selector,true),up_arrow=Animator:new(global_table_data.animation_data.up_arrow,true),down_arrow=Animator:new(global_table_data.animation_data.down_arrow,true),content=n,content_draw=a,rect=BorderRect:new(Vec:new(e,t),Vec:new(10+5*longest_menu_str(n),38),l,r,c),text=d,pos=1,enable=false,ticks=5,max_ticks=5,dir=0}setmetatable(obj,self)self.__index=self return obj end function Menu:draw()
if(not self.enable)return
local e,t=self.pos-1,self.pos+1
if(e<1)e=#self.content
if(t>#self.content)t=1
if(self.content_draw)self.content_draw(self.pos,self.position,self.content[self.pos].color)
BorderRect.draw(self.rect)Animator.draw(self.selector,Vec.unpack(self.position+Vec:new(2,15)))local n=(self.rect.size.x+self.rect.position.x)\2-self.up_arrow.sprite_size\2Animator.draw(self.up_arrow,n,self.position.y-self.rect.thickness)Animator.draw(self.down_arrow,n,self.rect.size.y-self.rect.thickness)local o=self.position.x+10local n={self.dir,self.ticks/self.max_ticks,self.position}if self.ticks<self.max_ticks then if self.dir>0then print_with_outline(self.content[e].text,combine_and_unpack(menu_scroll(12,10,7,unpack(n)),self.content[e].color))elseif self.dir<0then print_with_outline(self.content[t].text,combine_and_unpack(menu_scroll(12,10,27,unpack(n)),self.content[t].color))end else print_with_outline(self.content[e].text,o,self.position.y+7,unpack(self.content[e].color))print_with_outline(self.content[t].text,o,self.position.y+27,unpack(self.content[t].color))end print_with_outline(self.content[self.pos].text,combine_and_unpack(menu_scroll(10,12,17,unpack(n)),self.content[self.pos].color))end function Menu:update()
if(not self.enable)return
Animator.update(self.selector)Animator.update(self.up_arrow)Animator.update(self.down_arrow)
if(self.ticks>=self.max_ticks)return
self.ticks+=1end function Menu:move()
if(not self.enable)return
if(self.ticks<self.max_ticks)return
local t,e=controls()
if(e==0)return
self.pos+=e self.dir=e
if(self.pos<1)self.pos=#self.content
if(self.pos>#self.content)self.pos=1
self.ticks=0end function Menu:invoke()local e=self.content[self.pos]
if(e.callback==nil)return
if e.args then e.callback(unpack(e.args))else e.callback()end end function menu_scroll(t,a,n,i,o,e)local r,l=n-10,n+10local d=lerp(e.x+t,e.x+a,o)local t=e.y+n if i<0then t=lerp(e.y+r,t,o)elseif i>0then t=lerp(e.y+l,t,o)end return{d,t}end Vec={}function Vec:new(e,n)local t=nil if type(e)=="table"then t={x=e[1],y=e[2]}else t={x=e,y=n}end setmetatable(t,self)self.__index=self self.__add=function(e,t)return Vec:new(e.x+t.x,e.y+t.y)end self.__sub=function(e,t)return Vec:new(e.x-t.x,e.y-t.y)end self.__mul=function(e,t)return Vec:new(e.x*t,e.y*t)end self.__div=function(e,t)return Vec:new(e.x/t,e.y/t)end self.__eq=function(e,t)return e.x==t.x and e.y==t.y end self.__tostring=function(e)return"("..e.x..", "..e.y..")"end self.__concat=function(e,t)return type(e)=="table"and Vec.__tostring(e)..t or e..Vec.__tostring(t)end return t end function Vec:unpack()return self.x,self.y end function Vec:clamp(e,t)self.x,self.y=mid(self.x,e,t),mid(self.y,e,t)end function Vec:floor()return Vec:new(flr(self.x),flr(self.y))end function Vec:clone()return Vec:new(self.x,self.y)end function Vec:distance(e)return sqrt((self.x-e.x)^2+(self.y-e.y)^2)end function normalize(e)return type(e)=="table"and Vec:new(normalize(e.x),normalize(e.y))or flr(mid(e,-1,1))end function lerp(e,t,n)if type(e)=="table"then return Vec:new(lerp(e.x,t.x,n),lerp(e.y,t.y,n))else return e+(t-e)*n end end Projectile={}function Projectile:new(o,t,i,e)local n=max(abs(t.x),abs(t.y))obj={position=Vec:new(Vec.unpack(o)),dir=Vec:new(t.x/n,t.y/n),theta=i,sprite=e.sprite,size=e.pixel_size,height=e.height,speed=e.speed,damage=e.damage,trail=global_table_data.animation_data[e.trail_animation_key],lifespan=e.lifespan,ticks=0}setmetatable(obj,self)self.__index=self return obj end function Projectile:update()self.ticks=(self.ticks+1)%self.speed
if(self.ticks>0)return
local t={}for e in all(enemies)do
if(Projectile.collider(self,e))add(t,e)
end if#t>0then for e in all(t)do if e.type==12then e.hp-=self.damage/2else e.hp-=self.damage end
if(e.type==8and e.hp<=0)del(enemies,e)
break end add(particles,Particle:new(Vec.clone(self.position),false,Animator:new(self.trail)))del(projectiles,self)return end add(particles,Particle:new(self.position,false,Animator:new(self.trail)))self.position+=self.dir self.lifespan-=1if self.position.x<0or self.position.x>15or self.position.y<0or self.position.y>15or self.lifespan<0then del(projectiles,self)end end function Projectile:draw()draw_sprite_shadow(self.sprite,self.position*8,self.height,self.size,self.theta)draw_sprite_rotated(self.sprite,self.position*8,self.size,self.theta)end function Projectile:collider(e)local t=self.position*self.size+Vec:new(self.size,self.size)/2local n=e.position*8+Vec:new(4,4)local e=self.size+4local o=Vec.distance(t,n)return o<=e end TextScroller={}function TextScroller:new(n,t,o,i)local e=BorderRect:new(unpack(i))obj={speed=n,rect=e,color=o,char_pos=1,text_pos=1,internal_tick=0,is_done=false,width=flr(e.size.x/5),max_lines=flr(e.size.y/16)-5,enable=true}setmetatable(obj,self)self.__index=self
if(t)TextScroller.load(obj,t)
return obj end function TextScroller:draw()
if(not self.enable)return
BorderRect.draw(self.rect)local t=sub(self.data[self.text_pos],1,self.char_pos)local e,n=split(t,"\n"),sub(self.data[self.text_pos],self.char_pos+1,#self.data[self.text_pos])local o=t..generate_garbage(n,self.rect.size.x,#e[#e],self.max_lines,#e\2)print_with_outline(o,self.rect.position.x+4,self.rect.position.y+4,unpack(self.color))if self.is_done then local e=self.text_pos>=#self.data and"🅾️ to close"or"🅾️ to continue"print_with_outline(e,self.rect.position.x+4,self.rect.size.y-7,unpack(self.color))end end function TextScroller:update()
if(not self.enable or self.is_done or self.text_pos>#self.data)return
self.internal_tick=(self.internal_tick+1)%self.speed
if(self.internal_tick==0)self.char_pos+=1
self.is_done=self.char_pos>#self.data[self.text_pos]end function TextScroller:next()
if(not self.enable or not self.is_done)return
if(self.text_pos+1>#self.data)return true
self.text_pos+=1self.char_pos,self.is_done=1end function TextScroller:load(o,e)
if(e)self.color=e
local e,n=self.width,""for i,t in pairs(split(o," "))do if#t+1<=e then n..=t.." "e-=#t+1elseif#t<=e then n..=t e-=#t else n..="\n"..t.." "e=self.width-#t+1end end self.data,e={},0local t,o="",split(n,"\n")for i,n in pairs(o)do if e<=self.max_lines then t..=n.."\n\n"e+=1else add(self.data,t)t,e=n.."\n\n",1end
if(i==#o)add(self.data,t)
end self.char_pos,self.text_pos,self.internal_tick,self.is_done=1,1,0end function generate_garbage(i,a,r,l,d)local e,n,t,o="",d,1,r*5for r=1,#i do
if(n>l)break
if o+t*9>a then e..="\n\n"n+=1t,o=1,0else e..=chr(204+flr(rnd(49)))end t+=1end return e end function _init()global_table_data=unpack_table(global_table_str)cartdata(global_table_data.cart_name)reset_game()end function _draw()cls()if game_state=="menu"then main_menu_draw_loop()elseif game_state=="credits"then credits_draw_loop()elseif game_state=="map"then map_draw_loop()elseif game_state=="game"then game_draw_loop()end TextScroller.draw(text_scroller)end function _update()if game_state=="menu"then main_menu_loop()elseif game_state=="credits"then credits_loop()elseif game_state=="map"then map_loop()elseif game_state=="game"then
if(player_health<=0)reset_game()
if shop_enable then shop_loop()else game_loop()end end TextScroller.update(text_scroller)if btnp(🅾️)then if TextScroller.next(text_scroller)then text_scroller.enable=false end end end function main_menu_draw_loop()map(unpack(global_table_data.splash_screens[1].mget_shift))local e,n,o=1,0,0for t,i in pairs(global_table_data.letters)do
if(e==8)e,n,o=1,18,16
local a,r=Vec:new(e*16-8+o-((t==5or t==9)and 2or 0),letters[t]+n),t==5and letter_rot or 0draw_sprite_shadow(i,a,4,16,r)draw_sprite_rotated(i,a,16,r)e+=1end if menu_enemy then Enemy.draw(menu_enemy,true)Enemy.draw(menu_enemy)end Menu.draw(get_menu"main")end function credits_draw_loop()map(unpack(global_table_data.splash_screens[1].mget_shift))print_with_outline("credits",47,credit_y_offsets[1],7,1)print_with_outline("project developers",25,credit_y_offsets[2],7,1)print_with_outline("jasper:\n  • game director\n  • programmer",10,credit_y_offsets[3],7,1)print_with_outline("jeren:\n  • core programmer\n  • devops",10,credit_y_offsets[4],7,1)print_with_outline("jimmy:\n  • artist\n  • sound engineer",10,credit_y_offsets[5],7,1)print_with_outline("kaoushik:\n  • programmer",10,credit_y_offsets[6],7,1)print_with_outline("external developers",25,credit_y_offsets[7],7,1)print_with_outline("thisismypassport:\n  • shrinko8 developer",10,credit_y_offsets[8],7,1)print_with_outline("jihem:\n  • created the rotation\n  sprite draw function",10,credit_y_offsets[9],7,1)print_with_outline("rgb:\n  • created the acos function",10,credit_y_offsets[10],7,1)end function map_draw_loop()local e=get_menu"map"pal(global_table_data.palettes.dark_mode)map(unpack(global_table_data.map_data[e.pos].mget_shift))pal()Menu.draw(e)print_with_outline("map select",45,1,7,1)end function game_draw_loop()local e=global_table_data.map_data[loaded_map]local t=global_table_data.tower_templates[selected_menu_tower_id]map(unpack(e.mget_shift))
if(manifested_tower_ref==nil and not sell_mode)draw_tower_attack_overlay(t)
if manifested_tower_ref and manifested_tower_ref.type=="sharp"then draw_line_overlay(manifested_tower_ref)end foreach(towers,Tower.draw)foreach(enemies,function(e)Enemy.draw(e,true)end)foreach(enemies,Enemy.draw)foreach(projectiles,Projectile.draw)foreach(particles,Particle.draw)
if(shop_enable)foreach(menus,Menu.draw)
if not shop_enable and not enemies_active and incoming_hint~=nil then for t=1,#incoming_hint do Animator.draw(incoming_hint[t],Vec.unpack((Vec:new(e.enemy_spawn_location)+Vec:new(e.movement_direction)*(t-1))*8))end end ui_draw_loop(t)end function ui_draw_loop(e)print_with_outline("scrap: "..coins,0,1,7,0)print_with_outline("towers: "..#towers.."/64",0,8,7,0)print_with_outline("♥ "..player_health,103,1,8,0)print_with_outline("mode: "..(manifest_mode and"manifest"or"sell"),1,108,7,0)if shop_enable and get_active_menu()then print_with_outline("game paused [ wave "..wave_round+freeplay_rounds.." ]",18,16,7,0)print_with_outline(get_active_menu().prev and"❎ select\n🅾️ go back to previous menu"or"❎ select\n🅾️ close menu",1,115,7,0)else if manifest_mode then if manifested_tower_ref then print_with_outline("🅾️ unmanifest",1,122,7,0)print_with_outline(Tower.get_cooldown_str(manifested_tower_ref),1,115,manifested_tower_ref.type=="tack"and 3or(manifested_tower_ref.manifest_cooldown>0and 8or 3),0)end Animator.update(manifest_selector)Animator.draw(manifest_selector,Vec.unpack(selector.position))else
if(not manifested_tower_ref)print_with_outline("🅾️ open menu",1,122,7,0)
end local t=is_in_table(selector.position/8,towers,true)sell_selector.dir=t and 1or-1if t and not manifested_tower_ref then if manifest_mode then print_with_outline("❎ manifest",1,115,7,0)else print_with_outline("❎ sell",1,115,7,0)Animator.update(sell_selector)Animator.draw(sell_selector,Vec.unpack(selector.position))end else if sell_mode then Animator.update(sell_selector)Animator.draw(sell_selector,Vec.unpack(selector.position))else if not manifested_tower_ref then local o,t,n=selector.position/8,7,"❎ buy & place "..e.name if e.cost>coins then n,t="can't afford "..e.name,8elseif e.type=="floor"~=(grid[o.y][o.x]=="path")then n,t="can't place "..e.name.." here",8end print_with_outline(n,1,115,t,0)end end end end end function main_menu_loop()local t,n=global_table_data.splash_screens[1],global_table_data.enemy_templates for e=1,#letters do if letters[e]<15then letters[e]+=1end end letter_rot=(letter_rot+15)%360if pathing==nil then pathing=parse_path(t)end if not menu_enemy then local e=n[flr(rnd(#n))+1]menu_enemy=Enemy:new(t.enemy_spawn_location,e.hp,e.step_delay\2,e.sprite_index,e.type,e.damage,e.height)else update_enemy_position(menu_enemy,true)end Menu.update(get_menu"main")if btnp(❎)then Menu.invoke(get_menu"main")end Menu.move(get_menu"main")end function credits_loop()
if(btnp(🅾️))game_state="menu"
for e=1,#credit_y_offsets do credit_y_offsets[e]-=1if credit_y_offsets[e]<-15then credit_y_offsets[e]+=270end end end function map_loop()local e=get_menu"map"Menu.update(e)if btnp(❎)then Menu.invoke(e)e.enable=false game_state="game"return end if btnp(🅾️)then e.enable=false reset_game()end Menu.move(e)end function shop_loop()foreach(menus,Menu.update)if btnp(🅾️)then if get_active_menu().prev==nil then shop_enable=false menus[1].enable=false return else swap_menu_context(get_active_menu().prev)end end if btnp(❎)then Menu.invoke(get_active_menu())end foreach(menus,Menu.move)end function game_loop()
if(auto_start_wave)start_round()
if btnp(🅾️)then
if(text_scroller.enable)return
if manifested_tower_ref==nil then shop_enable=true get_menu"game".enable=true return else unmanifest_tower()end end if btnp(❎)then if manifested_tower_ref then local e=manifested_tower_ref.type if e=="tack"then Tower.manifested_nova(manifested_tower_ref)elseif e=="rail"then Tower.manifested_lightning_blast(manifested_tower_ref)elseif e=="frontal"then Tower.manifested_hale_blast(manifested_tower_ref)end else local e=selector.position/8if is_in_table(e,towers,true)then if manifest_mode then manifest_tower_at(e)else refund_tower_at(e)end else place_tower(e)end end end if not lock_cursor then selector.position+=Vec:new(controls())*8Vec.clamp(selector.position,0,120)if manifested_tower_ref then if manifested_tower_ref.type=="floor"then Tower.manifested_torch_trap(manifested_tower_ref)elseif manifested_tower_ref.type=="sharp"or manifested_tower_ref.type=="clock"then Tower.manifested_sharp_rotation(manifested_tower_ref)end end end foreach(towers,Tower.cooldown)if enemies_active then foreach(enemies,update_enemy_position)foreach(towers,Tower.attack)if start_next_wave then start_next_wave=false wave_cor=cocreate(spawn_enemy)end if wave_cor and costatus(wave_cor)~="dead"then coresume(wave_cor)else wave_cor=nil end end foreach(projectiles,Projectile.update)foreach(particles,Particle.tick)foreach(animators,Animator.update)
if(not enemies_active and incoming_hint)foreach(incoming_hint,Animator.update)
foreach(enemies,kill_enemy)foreach(particles,destroy_particle)if enemies_active and#enemies==0and enemies_remaining==0then enemies_active=false sfx(global_table_data.sfx_data.round_complete)coins+=15load_wave_text()end end function print_with_outline(e,t,n,o,i)
?e,t-1,n,i
?e,t+1,n
?e,t,n-1
?e,t,n+1
?e,t,n,o
end function controls()if btnp(⬆️)then return 0,-1elseif btnp(⬇️)then return 0,1elseif btnp(⬅️)then return-1,0elseif btnp(➡️)then return 1,0end return 0,0end function increase_enemy_health(e)local t=global_table_data.freeplay_stats return{e.hp*(1+(t.hp-1)*((wave_round+freeplay_rounds)/15)),max(e.step_delay-t.speed*freeplay_rounds,t.min_step_delay),e.sprite_index,e.type,e.damage,e.height}end function is_in_table(e,o,i)for t,n in pairs(o)do if i then
if(e==n.position)return true,t
else
if(e==n)return true,t
end end end function add_enemy_at_to_table(t,n,o)for e in all(enemies)do if e.position==t then add(n,e)
if(not o)return
end end end function draw_sprite_rotated(n,i,e,o,s)local u,h,t,a,r=n%16*8,n\16*8,e\2-.5,sin(o/360),cos(o/360)for l=0,e-1do for d=0,e-1do local c,f=l-t,d-t local n=flr(c*r-f*a+t)local o=flr(c*a+f*r+t)if n>=0and n<e and o>=0and o<=e then local e=sget(u+n,h+o)if e~=global_table_data.palettes.transparent_color_id or s then pset(i.x+l,i.y+d,e)end end end end end function draw_sprite_shadow(t,n,e,o,i)pal(global_table_data.palettes.shadows)draw_sprite_rotated(t,n+Vec:new(e,e),o,i)pal()end function parse_direction(e)
if(e.x>0)return 90
if(e.x<0)return 270
if(e.y>0)return 180
if(e.y<0)return 0
end function frontal_apply(t,d)local e,a=unpack(t)local t,n,o,i,r,l=-1,1,1,e,1,1if a.x>0then t,n,o,i=1,-1,e,1elseif a.x<0then t,n,o,i,r=-1,-1,-e,1,-1elseif a.y<0then t,n,o,i,l=-1,-1,1,-e,-1end for e=n,i,l do for n=t,o,r do
if(n~=0or e~=0)d(Vec:new(n,e))
end end end function nova_apply(e,o)for t=-e,e do for n=-e,e do
if(n~=0or t~=0)o(Vec:new(n,t))
end end end function combine_and_unpack(t,n)local e={}for n in all(t)do add(e,n)end for t in all(n)do add(e,t)end return unpack(e)end function round_to(t,n)local e=10^(n or 0)return flr(t*e+.5)/e end function check_tile_flag_at(e,t)return fget(mget(Vec.unpack(e)),t)end function load_wave_text()local e=global_table_data.dialogue[global_table_data.level_dialogue_set[cur_level]or"dialogue_level4"][wave_round]if e then text_scroller.enable=true TextScroller.load(text_scroller,e.text,e.color)end end function acos(e)return atan2(e,-sqrt(1-e*e))end function save_byte(e,t)poke(e,t)return e+1end function save_int(e,t)poke4(e,t)return e+4end function encode(e,t,n)return e<<n|t end function decode(e,t,n)return flr(e>>>t),e&n end function unpack_table(t)local o,n,i,e={},1,0,1while e<=#t do if t[e]=="{"then i+=1elseif t[e]=="}"then i-=1
if(i>0)goto unpack_table_continue
insert_key_val(sub(t,n,e),o)n=e+1
if(e+2>#t)goto unpack_table_continue
n+=1e+=1elseif i==0then if t[e]==","then insert_key_val(sub(t,n,e-1),o)n=e+1elseif e==#t then insert_key_val(sub(t,n),o)end end::unpack_table_continue::e+=1end return o end function insert_key_val(t,n)local o,e=split_key_value_str(t)if o==nil then add(n,e)else local t if e[1]=="{"and e[-1]=="}"then t=unpack_table(sub(e,2,#e-1))elseif e=="true"then t=true elseif e=="false"then t=false else t=tonum(e)or e end if t=="inf"then t=32767end n[o]=t end end function convert_to_array_or_table(t)local e=sub(t,2,#t-1)
if(str_contains_char(e,"{"))return unpack_table(e)
if(not str_contains_char(e,"="))return split(e,",",true)
return unpack_table(e)end function split_key_value_str(e)local t=split(e,"=")local n=tonum(t[1])or t[1]if e[1]=="{"and e[-1]=="}"then return nil,convert_to_array_or_table(e)end local t=sub(e,#(tostr(n))+2)if t[1]=="{"and t[-1]=="}"then return n,convert_to_array_or_table(t)end return n,t end function str_contains_char(e,t)for n=1,#e do
if(e[n]==t)return true
end end
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
05c11c5000c66c00000220000066070000367b00806760800266772000011000002878000003b000001dd10060600606000000d0000200000d200000000000d0
05777650d666666da02c620a0006770003ccc7b065777560d666667d0016710000a28900000b3000059a7a5060600606d2210d2000dd20000d2210ddd2210d20
00cccc00d6cccc6d82ccc6280077600003cccc309a9aaaa0d662266d0165571004a9a9400003600005d9ad50665775660d11d120001d11d000d11d220d11d120
00777600d676676d82d44d285075660505333350595a5a50d625526d01511510041dd140000360000dd11dd00615116000d00110021002dd0110012000d00110
00777600067667604242242456b3b3655a5335a55595a55052444422151111510012210000b36b000d1cc1d05061560501100d00dd2001200210011001100d00
057776500676676024288242503bbb059a9339a960585060d227622d15111151049a9a400bb36bb00d1cc1d016615661021d11d00d11210022d11d00021d11d0
051cc150d67cc76d22a9a9225633b3654933339460898060d526722d1111111104a009400b0a90b005d11d505665166502d0122d0002dd00dd0122d002d0122d
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
b3333b33b3333b33b3333b33aaaaaa9aaaa77a9ab3b3b333b3433b3333aab3a3aaa9aaaaaaa9aaaaaa333b33b3333baa738493a30b3333300b333330003b3b00
3333b33b3333b33b3333b33ba9aaa9a9a9a779a93b33333b3484338ba9aaa9a9aa9a9aaaaa9a9aaaaaa3b33b3333baaabb4663bb0b3333300b3333300383bbb0
33b333b333b333b333b333b39a9aaaaa9a977aaa33b3b3b3334338989a9aaaaaaaba33a33aba339aaab333b333b3339a3967c63a0b3333300b333330333bb8b3
3b33333b3b33333b3b33333b77777aaa777777773b3b333b3b3d338377777777aa33333b3b3339a9aa33333b3b3339a9346cc6b30b3333300b333330b8bb8bbb
33333b3333333b3333333b3377777aaa77777777b3b33bb3b3dcdb3377777777aaa33b3333333baaaaa33b3333333baa9346639300b3330000b33300333bbb8b
3b33b3333ba3a3a33b33b333aaa77a9aaaa77a9a3b33b33b333db33baaaaaa9aa933b3333b33b3aaa933a3a33ba3a3aa38444333000bb000000bb0003383b3b8
b33b33baaaa9aaaaa33b33b3a9a779a9a9a779a9b33b33b3b33b33b3a9aaa9a99a9b33b3b33b3aaa9a9a9aaaaaa9aaaa3333433300049000000490000b349bb0
33b33baaaa9a9aaaaab33b339a977aaa9a977aaa33b33b3333b33b333ab3aa33aab33b3333b33baaaaa9a9aaaa9a9aaa33333333004999000049990000049000
b3333baaaaa77a9aaa333b33aaaaaa9a5555555558585555889779885777777157777771555555556666666176c6c6d57777776633333333333333330303bb00
3333baaaa9a779a9aa33b33ba9aaa9a955555555855585555829298257666661511111117777777760030061766666d57ddddd5633bbbb3333bbbb33003b3ba0
33b3339a9a977aaaaaa333b39a9aaaaa55555555585885555152521551111111506060617aa2e8876033306176c6c6d5777777663b8bbb833bb333b30b34b3ba
3b3339a9aaa77aaaa933333b777777775555555555888855511555655a0a0a045666666171a228876003006176c6c6d5766666d53b3bbb333bb333b3033b39a0
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
877888888820000087782222877820008888200088882000717788887717200088882000888888200000000000000000040400404040044044400040bbb33bbb
771788888820000077178888771720008888200088882000877888887177200088882000888888200000000000000000040404044040040044400440b000000b
717788888820000071778888717720008888200088882000000000008778200088882000008888200000000000000000044004044400440040004040b000000b
87788888882000008778888887782000888820008888200022222222888820008888222222888820000000000000000000000000000000000440044030000003
88820000000000008888288882000000877822228778200087788888877820008778888888877820000000000000000000900000000000000000000030000003
888200000000000088882088882000007717888877172000771788887717200077178888887717200000000000000000909090000000000000000000b000000b
888200000000000088882008888200007177888871772000717788887177200071778888887177200000000000000000099900000000000000000000b000000b
888200000000000088882000888820008778888887782000877888888778200087788888888778200000000000000000009000000000000000000000bbb33bbb
222220000022222022222222222222202222222222220000000000000aa79900000000000000000000000000ddddddddfff66ffffffffff4ffffffff44444444
88882000008888208888887788888820877888888882000000000000aa799000000000000000000000000000d222222dfff66fffffffffffffffffff44344444
8888200000888820888887717888882077178888888200000000000aa7990000000000000000000000000000d299994dfff66fffffffffffffffffff43444444
888820000088882088888717788888207177888888820000000000aa79900000000000000000000000000000d249944dfff66fff66666fff6666666643444434
88882000008888208888887788888820877888888882000000000aa799000000000000000000000000000000ddddddddfff66fff66666fff666666664bb44344
8888222222888820000008888200000088882000000000000000aaa990000000000000000000000000000000da444442fff66ffffff66fffffffffff44444344
877888888887782000000888820000008778222222220000000aaa9900000000000000000000000000000000d0400402fff66ffffff66fffffffffff44444bb4
77178888887717200000088882000000771788888882000000aaaaaaaa777000000000000000000000000000d0422402fff66ffffff66fffffffffff44444444
71778888887177200000088882000000717788888882000000aaaaaaaaa790000000000000000000000000006555555544444444fff66ffffff66fff4fffffff
87788888888778200000088882000000877888888882000000aaaaaaaa79900000000000000000000000000066666665b4444444fff66ffffff66fffffffffff
8888200000888820000008888200000088882000000000000000000aa7990000000000000000000000000000aaa44445bbb44b44fff66ffffff66fffffffffff
888820000088882000000888820000008888222222220000000000aa79900000000000000000000000000000a04040453bbb4bb466666ffffff66666fff66666
88882000008888200000088882000000877888888882000000000aa799000000000000000000000000000000a44444453b3bbbbb66666ffffff66666fff66666
8888200000888820000008888200000077178888888200000000aa7990000000000000000000000000000000a04040453b33b3bbfffffffffffffffffff66fff
888820000088882000000888820000007177888888820000000aa79900000000000000000000000000000000aa4444453333b3b3fffffffffffffffffff66fff
88882000008888200000088882000000877888888882000000aa79900000000000000000000000000000000000000000333333b3fffffff44ffffffffff66fff
__map__
1d1d1d1d1d1d1d1d1d1d1d1d1e3f3f3f81818181818181818181818182a3a386a7a7a794a7a7b4a7a7a7b499a794a7b4ababababb8abababababb8ababababb8afafafafafafafafafafafafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f1f2e3f3f3f93939393939393939393938392b09ea3a6a6a6a6a594a79a94a7a794b4a794a7aaaaaaaaaaaaaaaaa9abababababababaeaeaeaeaeaeadafafbfaeaeaeaeaeae000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d3d3d3d3d3d3d3d3d3d2b2d2e3f3f3fa1a1a1a1a1a1a1a1a1a18991928586a3a794b4a7a4a7a7b49494b7a6a6a6a6a6abababababb8ababbaaaa9abb8abababafafafafafafacbcbcacafafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f2c2d2e3f3f3fa3a3a3a3a386a3b085a3909192a385b0a7a7a7a7a4b4a7a7a7a7a494a7a794a7abababb8ababababb8aba8abababb8abafafafafafafacbcbcacafafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f2c2d2e3f3f3f9ea386a3a385a3a385a3909192a3b0a3a7b4a794b6a6a6a5a7a7b6a6a5a7a798abb8ababababababababa8abababababafafafbfaeaebdbcbcbeaeaeadafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f1c1d1d1d1d1d3b2d2e3f3f3fa385a3a38081818181818b918a818182a7a795b494b494a4b4a794a7a4b4b4a7abababababb8ababbbaab9abababababafafafacbcbcbcbcbcbcbcbcacafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c1b2f2f2f2f2f192e3f3f3fa3a385a390b393939393938493938392a7a796a7a79494a4a794b494a494b4a7aaaaaaaaaaaaaaaab9abababababababafafafbeaeadbcbcbcbcbfaebdafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c2d2a3d3d3d3d3d3e3f3f3fa3b0a386909188a1a1a1899188899192a79494a7a7b494b6a6a6a6a6b594b494abababababababababb8ababababb8abafafafafafacbcbcbcbcacafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c2d2e3f3f3f3f3f3f3f3f3fa3a385a3909192b085b0909192909192b49794b49494a794949494b494a79494abababababababababababb8ababababafafafafafbeadbcbcbfbdafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c2d2e3f3f3f3f3f3f3f3f3fa386a3a3909192a386a3909192909192a7a7a79498b494a7b4a794a7a7b495a7ababb8ababb8abb8ababababababb8abafafafafafafacbcbcacafafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c2d3a1d1d1d1d1d1d1d1d1d9ea3a38590918a8181818b919290918a94a794a794949494a794b4a7a79496a7abababb8ababababababababababababafafafafafafacbcbcacafafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c1a2f2f2f2f2f2f2f2f2f2fa3b0a38690b29393939393b19290b293a7a7b4a7b4a794a7a795a794b4b4a794abababababababababababb8b8abababafafafafafafacbcbfbdafafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3c3d3d3d3d3d3d3d3d3d3d3da3a3a3a3a3a1a1a1a1a1a1a1a2a0a1a1a794b495a7b4a7a7a796b4a799a794a7ababb8ababababb8ababababababababafafafafafafacbcacafafafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3fa3a3a39ea3b0a3a385a3a3a386a3b0a3b4a7949794b49494b494a794a7b495a7ababababababababababababababb8abafafafafafafbeaebdafafafafafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
__gff__
0000000000000000000000000000000000000000000000000001010102020201000000000000000000000202020102010000000000000000000002020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020101020201020202020202020202010201020202020202000202020202020202020101010201010102010101020201010102010101020101010201010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010200000000000000000000000002010101
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