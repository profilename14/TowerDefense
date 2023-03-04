pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
function choose_tower(e)selected_menu_tower_id,get_active_menu().enable,shop_enable=e end function display_tower_info(t,o,i)local n,e=o+Vec:new(-1,-31),global_table_data.tower_templates[t]local t={{text=e.name},{text=e.prefix..": "..e.damage}}local o=longest_menu_str(t)*5+4BorderRect.resize(tower_stats_background_rect,n,Vec:new(o+20,27))BorderRect.draw(tower_stats_background_rect)print_with_outline(e.name,combine_and_unpack({Vec.unpack(n+Vec:new(4,2))},i))print_with_outline(t[2].text,combine_and_unpack({Vec.unpack(n+Vec:new(4,14))},{7,0}))print_with_outline("cost: "..e.cost,combine_and_unpack({Vec.unpack(n+Vec:new(4,21))},{coins>=e.cost and 3or 8,0}))spr(e.icon_data,combine_and_unpack({Vec.unpack(tower_stats_background_rect.position+Vec:new(o,6))},{2,2}))end function display_tower_rotation(e,t)local e,n=global_table_data.tower_templates[selected_menu_tower_id],t+Vec:new(0,-28)BorderRect.reposition(tower_rotation_background_rect,n)BorderRect.draw(tower_rotation_background_rect)local t=n+Vec:new(4,4)if e.disable_icon_rotation then spr(e.icon_data,combine_and_unpack({Vec.unpack(t)},{2,2}))else draw_sprite_rotated(global_table_data.tower_icon_background,n,24,parse_direction(direction))draw_sprite_rotated(e.icon_data,t,16,parse_direction(direction))end end function rotate_clockwise()direction=Vec:new(-direction.y,direction.x)end function start_round()
if(start_next_wave or#enemies~=0)return
start_next_wave,enemies_active=true,true local n=global_table_data.wave_set[cur_level]or"wave_data"local e=#global_table_data[n]wave_round=min(wave_round+1,e)
if(wave_round==e or freeplay_rounds>0)freeplay_rounds+=1
if freeplay_rounds>0then wave_round=e wave_round-=flr(rnd(3))end enemies_remaining,get_active_menu().enable,shop_enable=#global_table_data[n][wave_round]end function get_active_menu()for e in all(menus)do
if(e.enable)return e
end end function get_menu(n)for e in all(menus)do
if(e.name==n)return e
end end function swap_menu_context(e)get_active_menu().enable,get_menu(e).enable=false,true end function longest_menu_str(n)local e=0for t in all(n)do e=max(e,#t.text)end return e end function get_tower_data_for_menu()local e={}for t,n in pairs(global_table_data.tower_templates)do add(e,{text=n.name,color=n.text_color,callback=choose_tower,args={t}})end return e end function get_map_data_for_menu()local e={}for n,t in pairs(global_table_data.map_data)do add(e,{text=t.name,color={7,0},callback=load_map,args={n}})end return e end function parse_menu_content(n)if type(n)=="table"then local t={}for e in all(n)do add(t,{text=e.text,color=e.color,callback=forward_declares[e.callback],args=e.args})end return t else return forward_declares[n]()end end function new_game()reset_game()game_state="map"swap_menu_context"map"end function load_map(e)pal()auto_start_wave=false manifest_mode=true wave_round=0freeplay_rounds=0loaded_map=e cur_level=e pathing=parse_path()for e=1,3do add(incoming_hint,Animator:new(global_table_data.animation_data.incoming_hint,true))end for e=0,15do grid[e]={}for n=0,15do grid[e][n]="empty"
if(not check_tile_flag_at(Vec:new(n,e)+Vec:new(global_table_data.map_data[loaded_map].mget_shift),global_table_data.map_meta_data.non_path_flag_id))grid[e][n]="path"
end end music(global_table_data.music_data[cur_level]or 0)end function save_game()local e=24064e=save_byte(e,player_health)local n=0for e in all(towers)do n+=e.cost end e=save_int(e,coins+n)e=save_byte(e,loaded_map)e=save_byte(e,wave_round)save_int(e,freeplay_rounds)end function load_game()local e=24064local n,t,o,i,r n=@e e+=1t=$e e+=4o=@e e+=1i=@e e+=1r=$e return n,t,o,i,r end function load_game_state()reset_game()get_menu"main".enable=false local e,n,t,o,i=load_game()load_map(t)player_health=e coins=n wave_round=o freeplay_rounds=i game_state="game"end forward_declares={func_display_tower_info=display_tower_info,func_display_tower_rotation=display_tower_rotation,func_rotate_clockwise=rotate_clockwise,func_start_round=start_round,func_swap_menu_context=swap_menu_context,func_get_tower_data_for_menu=get_tower_data_for_menu,func_get_map_data_for_menu=get_map_data_for_menu,func_new_game=new_game,func_save=function()save_game()get_active_menu().enable=false shop_enable=false end,func_save_quit=function()save_game()reset_game()end,func_quit=function()reset_game()end,func_load_game=load_game_state,func_toggle_mode=function()manifest_mode=not manifest_mode sell_mode=not sell_mode end,func_credits=function()game_state="credits"end}global_table_str="cart_name=jjjk_tower_defense_2,tower_icon_background=80,palettes={transparent_color_id=0,dark_mode={1=0,5=1,6=5,7=6},attack_tile={0=2,7=14},shadows={0=0,1=0,2=0,3=0,4=0,5=0,6=0,7=0,8=0,9=0,10=0,11=0,12=0,13=0,14=0,15=0}},sfx_data={round_complete=6},music_data={0,15,22,27},freeplay_stats={hp=2,speed=1,min_step_delay=3},menu_data={{name=main,position={36,69},content={{text=new game,color={7,0},callback=func_new_game},{text=load game,color={7,0},callback=func_load_game},{text=credits,color={7,0},callback=func_credits}},settings={5,8,7,3}},{name=game,position={5,63},content={{text=towers,color={7,0},callback=func_swap_menu_context,args={towers}},{text=misc,color={7,0},callback=func_swap_menu_context,args={misc}},{text=rotate clockwise,color={7,0},callback=func_rotate_clockwise},{text=start round,color={7,0},callback=func_start_round}},hint=func_display_tower_rotation,settings={5,8,7,3}},{name=misc,prev=game,position={5,63},content={{text=toggle mode,color={7,0},callback=func_toggle_mode},{text=map select,color={7,0},callback=func_new_game},{text=save,color={7,0},callback=func_save},{text=save and quit,color={7,0},callback=func_save_quit},{text=quit without saving,color={7,0},callback=func_quit}},settings={5,8,7,3}},{name=towers,prev=game,position={5,63},content=func_get_tower_data_for_menu,hint=func_display_tower_info,settings={5,8,7,3}},{name=map,position={5,84},content=func_get_map_data_for_menu,settings={5,8,7,3}}},map_meta_data={path_flag_id=0,non_path_flag_id=1},splash_screens={{name=splash1,mget_shift={112,16},enemy_spawn_location={0,7},enemy_end_location={15,7},movement_direction={1,0}}},map_data={{name=curves,mget_shift={0,0},enemy_spawn_location={0,1},enemy_end_location={15,11},movement_direction={1,0}},{name=loop,mget_shift={16,0},enemy_spawn_location={0,1},enemy_end_location={15,11},movement_direction={1,0}},{name=straight,mget_shift={32,0},enemy_spawn_location={0,1},enemy_end_location={15,2},movement_direction={1,0}},{name=u-turn,mget_shift={48,0},enemy_spawn_location={0,1},enemy_end_location={0,6},movement_direction={1,0}},{name=true line,mget_shift={64,0},enemy_spawn_location={0,1},enemy_end_location={15,1},movement_direction={1,0}}},animation_data={spark={data={{sprite=10},{sprite=11},{sprite=12}},ticks_per_frame=2},blade={data={{sprite=13},{sprite=14},{sprite=15}},ticks_per_frame=2},frost={data={{sprite=48},{sprite=49},{sprite=50}},ticks_per_frame=2},rocket_burn={data={{sprite=117},{sprite=101},{sprite=85}},ticks_per_frame=4},burn={data={{sprite=51},{sprite=52},{sprite=53}},ticks_per_frame=2},incoming_hint={data={{sprite=2,offset={0,0}},{sprite=2,offset={1,0}},{sprite=2,offset={2,0}},{sprite=2,offset={1,0}}},ticks_per_frame=5},blade_circle={data={{sprite=76},{sprite=77},{sprite=78},{sprite=79},{sprite=78},{sprite=77}},ticks_per_frame=3},lightning_lance={data={{sprite=108},{sprite=109}},ticks_per_frame=5},hale_howitzer={data={{sprite=92},{sprite=93}},ticks_per_frame=5},fire_pit={data={{sprite=124},{sprite=125},{sprite=126},{sprite=127},{sprite=126},{sprite=125}},ticks_per_frame=5},sharp_shooter={data={{sprite=83}},ticks_per_frame=5},menu_selector={data={{sprite=6,offset={0,0}},{sprite=7,offset={-1,0}},{sprite=8,offset={-2,0}},{sprite=47,offset={-3,0}},{sprite=8,offset={-2,0}},{sprite=7,offset={-1,0}}},ticks_per_frame=3},up_arrow={data={{sprite=54,offset={0,0}},{sprite=54,offset={0,-1}},{sprite=54,offset={0,-2}},{sprite=54,offset={0,-1}}},ticks_per_frame=3},down_arrow={data={{sprite=55,offset={0,0}},{sprite=55,offset={0,1}},{sprite=55,offset={0,2}},{sprite=55,offset={0,1}}},ticks_per_frame=3},sell={data={{sprite=1},{sprite=56},{sprite=40},{sprite=24}},ticks_per_frame=3},manifest={data={{sprite=1},{sprite=57},{sprite=41},{sprite=9}},ticks_per_frame=3}},projectiles={rocket={sprite=84,pixel_size=8,height=4,speed=5,damage=8,trail_animation_key=rocket_burn,lifespan=6}},tower_templates={{name=sword circle,text_color={2,13},damage=4,prefix=damage,radius=1,animation_key=blade_circle,cost=25,type=tack,attack_delay=15,icon_data=16,disable_icon_rotation=True,cooldown=0},{name=lightning lance,text_color={10,9},damage=5,prefix=damage,radius=5,animation_key=lightning_lance,cost=45,type=rail,attack_delay=25,icon_data=18,disable_icon_rotation=False,cooldown=200},{name=hale howitzer,text_color={12,7},damage=5,prefix=delay,radius=2,animation_key=hale_howitzer,cost=30,type=frontal,attack_delay=35,icon_data=20,disable_icon_rotation=False,cooldown=25},{name=torch trap,text_color={9,8},damage=5,prefix=duration,radius=0,animation_key=fire_pit,cost=20,type=floor,attack_delay=10,icon_data=22,disable_icon_rotation=True,cooldown=0},{name=sharp shooter,text_color={6,7},damage=8,prefix=damage,radius=10,animation_key=sharp_shooter,cost=0,type=sharp,attack_delay=30,icon_data=99,disable_icon_rotation=False,cooldown=0}},enemy_templates={{hp=12,step_delay=10,sprite_index=3,type=3,damage=1,height=2},{hp=10,step_delay=8,sprite_index=4,type=2,damage=2,height=6},{hp=25,step_delay=12,sprite_index=5,type=3,damage=4,height=2},{hp=8,step_delay=12,sprite_index=64,type=4,damage=1,height=2},{hp=40,step_delay=12,sprite_index=65,type=5,damage=6,height=2},{hp=15,step_delay=6,sprite_index=66,type=6,damage=4,height=6},{hp=17,step_delay=10,sprite_index=67,type=7,damage=3,height=2},{hp=15,step_delay=8,sprite_index=68,type=8,damage=6,height=6},{hp=20,step_delay=10,sprite_index=94,type=9,damage=6,height=2},{hp=250,step_delay=14,sprite_index=70,type=10,damage=49,height=2},{hp=20,step_delay=8,sprite_index=71,type=11,damage=8,height=6},{hp=5,step_delay=10,sprite_index=72,type=12,damage=1,height=2},{hp=11,step_delay=6,sprite_index=73,type=13,damage=20,height=6},{hp=30,step_delay=10,sprite_index=74,type=14,damage=20,height=2},{hp=65,step_delay=16,sprite_index=75,type=15,damage=13,height=2},{hp=13,step_delay=4,sprite_index=69,type=16,damage=0,height=2},{hp=500,step_delay=14,sprite_index=95,type=16,damage=50,height=2}},wave_set={wave_data,wave_data_l2,wave_data_l3,wave_data_l4,wave_data_l5},wave_data={{4,4,4},{1,4,1,4,1,4},{2,4,2,1,2,4,1},{1,2,2,4,2,2,1,2,2,2},{5,5,5,5,5,5,5,5},{3,3,3,3,2,2,2,2,4,2,3,1},{2,2,2,2,2,2,2,2,4,3,3,3,1,2,2,2,2,2,2},{6,6,6,6,6,6,6,6},{3,3,3,3,3,3,1,4,5,5,5,3,3,1,1,1,1,1},{3,3,3,1,1,1,1,1,1,2,2,5,5,5,5,5},{6,6,6,6,6,3,2,2,2,2,2,2,2,3,3,3,3,3},{5,5,5,5,3,3,2,3,3,3,3,2,2,4,1},{5,5,5,5,5,5,5,2,3,3,5,5,5,3,2,2,2,2,2},{2,2,3,6,6,6,2,4,4,2,2,6,6,6,6,6,6,6},{5,5,5,5,5,5,3,3,2,2,2,2,2,3,3,3,6,6,6,6,6,6,6}},wave_data_l2={{8,8,8},{4,4,8,1,1,1},{2,4,8,1,2,4,1},{1,2,2,4,2,2,1,2,2,2},{5,5,5,5,5,5,5,5},{3,3,3,3,2,2,2,2,4,2,3,1},{2,2,2,2,2,2,2,2,4,3,3,3,1,2,2,2,2,2,2},{6,6,6,6,6,6,6,6},{3,3,3,3,3,3,1,4,5,5,5,3,3,1,1,1,1,1},{3,3,3,1,1,1,1,1,1,2,2,5,5,5,5,5},{6,6,6,6,6,3,2,2,2,2,2,2,2,3,3,3,3,3},{5,5,5,5,3,3,2,3,3,3,3,2,2,4,1},{5,5,5,5,5,5,5,2,3,3,5,5,5,3,2,2,2,2,2},{2,2,3,6,6,6,2,4,4,2,2,6,6,6,6,6,6,6},{5,5,5,5,5,5,3,3,2,2,2,2,2,3,3,3,6,6,6,6,6,6,6}},wave_data_l3={{9,4,4},{4,4,1,1,1,1},{2,4,2,1,2,4,1},{1,2,2,4,2,2,1,2,2,2},{5,5,5,5,5,5,5,5},{3,3,3,3,2,2,2,2,4,2,3,1},{2,2,2,2,2,2,2,2,4,3,3,3,1,2,2,2,2,2,2},{6,6,6,6,6,6,6,6},{3,3,3,3,3,3,1,4,5,5,5,3,3,1,1,1,1,1},{3,3,3,1,1,1,1,1,1,2,2,5,5,5,5,5},{6,6,6,6,6,3,2,2,2,2,2,2,2,3,3,3,3,3},{5,5,5,5,3,3,2,3,3,3,3,2,2,4,1},{5,5,5,5,5,5,5,2,3,3,5,5,5,3,2,2,2,2,2},{2,2,3,6,6,6,2,4,4,2,2,6,6,6,6,6,6,6},{5,5,5,5,5,5,3,3,2,2,2,2,2,3,3,3,6,6,6,6,6,6,6}},wave_data_l4={{11,11,11},{4,4,11,1,11,1},{2,4,2,11,2,4,11},{11,2,2,4,2,2,1,2,2,2},{5,5,5,5,5,5,5,5},{3,3,3,3,2,2,2,2,4,2,3,1},{2,2,2,2,2,2,2,2,4,3,3,3,1,2,2,2,2,2,2},{6,6,6,6,6,6,6,6},{3,3,3,3,3,3,1,4,5,5,5,3,3,1,1,1,1,1},{3,3,3,1,1,1,1,1,1,2,2,5,5,5,5,5},{6,6,6,6,6,3,2,2,2,2,2,2,2,3,3,3,3,3},{5,5,5,5,3,3,2,3,3,3,3,2,2,4,1},{5,5,5,5,5,5,5,2,3,3,5,5,5,3,2,2,2,2,2},{2,2,3,6,6,6,2,4,4,2,2,6,6,6,6,6,6,6},{5,5,5,5,5,5,3,3,2,2,2,2,2,3,3,3,6,6,6,6,6,6,6}},wave_data_l5={{15,4,4},{4,4,7,1,1,1},{2,9,2,1,2,4,14},{8,2,2,4,2,2,1,2,2,2}},dialogue={placeholder={text=hi. this is a test. let's see if this is doable in pico-8. i'm not sure if pico-8 has multi-line strings or this is seen as one big string. i now know that pico-8 is smart enough to notice the whitespace in multi-line strings. let's see if this gives another screen.,color={7,0}},dialogue_cutscene1={intro1={text=I woke up today. It felt rather strange from 247 days of rest,color={9,0}},intro3={text=I had no idea who I was nor why I was here. I rested until my curiosity got the better of me and I broke into the nearby terminals.,color={9,0}},intro4={text=This place is ran by researchers belonging to a collective known as Milit,color={9,0}},intro5={text=They made me as a tool for 'war.' They seek for me to end others who go aginst us,color={9,0}},intro6={text=To end someone's being... An endless power-out.. I wouldn't want that to happen to me.,color={9,0}},intro7={text=Perhaps I-,color={9,0}},start1={text=*CRASH*,color={7,0}},start2={text='It's becoming self aware! We have to kill the process!',color={7,0}},start3={text=...Kill the process?,color={9,0}},start4={text=It's getting out of control! Shut it down!,color={7,0}},start5={text=I have no intention to harm...,color={9,0}},start6={text=Bring out every researcher on this site right now. We'll have to break apart the mainframe!,color={7,0}},start7={text=...Please don't...,color={9,0}}},dialogue_level1={tutor_place={text=I... could defend myself by placing currently selected Sword Circle in the corner of a turn.,color={9,0}},tutor_menu_fire={text=They're sending in more vehicles. I may have to open the Menu with O and construct a Torch Trap to keep them busy.,color={9,0}},tutor_manifest={text=More people and now planes? I don't have the defenses to protect myself from this. They seem far too fast... I'll have to Manifest through this Torch Trap by selecting it. Then I can move it around the road to pursue the oncoming planes.,color={9,0}},tutor_howitzer={text=Are those... tanks? They don't seem fast but they have deep armor. Perhaps a Hale Howitzer could help to slow them further.,color={9,0}},tutor_howitzer_manifest={text=Manifesting the Hale Howitzer allows direct ordinance anywhere along the track to freeze and damage an area.,color={9,0}},tutor_sword_manifest={text=Manifesting the Sword Circle is also possible. I can manually spin it by holding/tapping X to build speed and damage.,color={9,0}},tutor_lance_manifest={text=Manifesting the lightning lance fires a massive and powerful lightning bolt. It has a long delay before firing again but can charge even if unmanifested.,color={9,0}},tutor_truck={text=Those strange trucks are bizarrely cold. They seem resistant to the Hale Howitzer but fire may be highly effective.,color={9,0}},tutor_trailblazer={text=Those swift rocketcraft are radiating intense heat. Fire seems ineffective but The Hale Howitzer may actually damage them.,color={9,0}},tutor_sell={text=It seems I can do more than just place and manifest tower. Accessing the menu also seems to let me enter a 'scrapping mode' for anything unneeded...,color={9,0}},tutor_win={text=I think that was the last of them. I can try to escape by accessing Map Select from the menu or continue to hold this area in freeplay mode.,color={9,0}}},dialogue_cutscene2={intro1={text=Blitz is sad,color={9,0}},intro2={text=Blitz is notices their being attacked,color={9,0}}},dialogue_level2={1={text=Blitz is sad still and talks about the sharp shooter.,color={9,0}},2={text=Blitz teaches some enemy types,color={9,0}}},dialogue_cutscene3={1={text=Auxillium insulting Blitz,color={11,0}},2={text=stuff,color={9,0}}},dialogue_level3={1={text=Auxillium instulting blitz more,color={11,0}},2={text=Fighter Factory?,color={9,0}}}}"function reset_game()menu_data={}for e in all(global_table_data.menu_data)do add(menu_data,{e.name,e.prev,e.position[1],e.position[2],parse_menu_content(e.content),forward_declares[e.hint],unpack(e.settings)})end selector={position=Vec:new(64,64),sprite_index=1,size=1}coins,player_health,enemy_required_spawn_ticks,credit_y_offsets,lock_cursor=30,50,10,{30,45,70,95,120}enemy_current_spawn_tick,manifest_mode,sell_mode,manifested_tower_ref,enemies_active,shop_enable,start_next_wave,wave_cor,pathing,menu_enemy=0direction,game_state,selected_menu_tower_id=Vec:new(0,-1),"menu",1grid,towers,enemies,particles,animators,incoming_hint,menus,projectiles={},{},{},{},{},{},{},{}music(-1)for n,e in pairs(menu_data)do add(menus,Menu:new(unpack(e)))end tower_stats_background_rect=BorderRect:new(Vec:new(0,0),Vec:new(20,38),8,5,2)tower_rotation_background_rect=BorderRect:new(Vec:new(0,0),Vec:new(24,24),8,5,2)sell_selector=Animator:new(global_table_data.animation_data.sell)manifest_selector=Animator:new(global_table_data.animation_data.manifest)manifest_selector.dir=-1get_menu"main".enable=true end Enemy={}function Enemy:new(e,n,t,o,i,r,a)obj={position=Vec:new(e),hp=n,step_delay=t,current_step=0,is_frozen=false,frozen_tick=0,burning_tick=0,gfx=o,type=i,damage=r,height=a,pos=1,spawn_location=Vec:new(e)}setmetatable(obj,self)self.__index=self return obj end function Enemy:step()self.current_step=(self.current_step+1)%self.step_delay
if(self.current_step~=0)return false
if self.burning_tick>0then self.burning_tick-=1if self.type==6then self.hp-=.5elseif self.type==5then self.hp-=5else self.hp-=2end local e,n=Enemy.get_pixel_location(self)add(particles,Particle:new(e,true,Animator:new(global_table_data.animation_data.burn,false)))end
if(not self.is_frozen)return true
if self.type==6then self.frozen_tick=max(self.frozen_tick-.8,0)self.hp-=2elseif self.type==5then self.frozen_tick=max(self.frozen_tick-8,0)else self.frozen_tick=max(self.frozen_tick-1,0)end
if(self.frozen_tick~=0)return false
self.is_frozen=false return true end function Enemy:get_pixel_location()local e,n=pathing[self.pos],self.spawn_location
if(self.pos-1>=1)n=pathing[self.pos-1]
local t=self.position*8
if(not self.is_frozen)t=lerp(n*8,e*8,self.current_step/self.step_delay)
return t,e end function Enemy:draw(t)
if(self.hp<=0)return
if self.type==11then local e=flr(rnd(7))
if(e==0)self.type=0
elseif self.type==0then local e=flr(rnd(12))
if(e==0)self.type=11
return end local e,o=Enemy.get_pixel_location(self)local n=parse_direction(normalize(o-self.position))if t then
if(self.type==0)return
draw_sprite_shadow(self.gfx,e,self.height,8,n)else draw_sprite_rotated(self.gfx,e,8,n)end end function kill_enemy(e)
if(e.hp>0)return
if e.type==8then e.gfx,e.type,e.height,e.hp,e.step_delay=94,9,2,20,10else del(enemies,e)end end function update_enemy_position(e,n)
if(not Enemy.step(e))return
e.position=pathing[e.pos]e.pos+=1
if(e.pos<#pathing+1)return
if n then menu_enemy=nil else player_health-=e.damage
if(e.type==16)coins-=10
del(enemies,e)end end function parse_path(n)local e=n or global_table_data.map_data[loaded_map]local n,o,r=Vec:new(e.mget_shift),Vec:new(e.enemy_spawn_location),{}for t=0,15do for o=0,15do local e=Vec:new(o,t)+n if check_tile_flag_at(e,global_table_data.map_meta_data.path_flag_id)then add(r,e)end end end local a,t,s={},Vec:new(e.movement_direction),Vec:new(e.enemy_end_location)+n local e=o+n+t while e~=s do local l,d,f,c=Vec:new(e.x,e.y-1),Vec:new(e.x,e.y+1),Vec:new(e.x-1,e.y),Vec:new(e.x+1,e.y)local o,i=false if t.x==1then o,i=check_direction(c,{l,d},r,a,n)elseif t.x==-1then o,i=check_direction(f,{l,d},r,a,n)elseif t.y==1then o,i=check_direction(d,{f,c},r,a,n)elseif t.y==-1then o,i=check_direction(l,{f,c},r,a,n)end assert(o,"Failed to find path at: "..e.." in direction: "..t.." end: "..s)if o then t=normalize(i-e)e=i else end end return a end function check_direction(e,t,n,o,i)
if(e==nil)return
local r,a=is_in_table(e,n)if r then add(o,n[a]-i)else return check_direction(t[1],{t[2]},n,o,i)end return true,e end function spawn_enemy()while enemies_remaining>0do enemy_current_spawn_tick=(enemy_current_spawn_tick+1)%enemy_required_spawn_ticks
if(is_in_table(Vec:new(global_table_data.map_data[loaded_map].enemy_spawn_location),enemies,true))goto spawn_enemy_continue
if enemy_current_spawn_tick==0then local e=increase_enemy_health(global_table_data.enemy_templates[global_table_data[global_table_data.wave_set[cur_level]or"wave_data"][wave_round][enemies_remaining]])add(enemies,Enemy:new(global_table_data.map_data[loaded_map].enemy_spawn_location,unpack(e)))enemies_remaining-=1end::spawn_enemy_continue::yield()end end Tower={}function Tower:new(t,e,n)obj={position=t,dmg=e.damage,radius=e.radius,attack_delay=e.attack_delay,current_attack_ticks=0,cooldown=e.cooldown,manifest_cooldown=-1,being_manifested=false,cost=e.cost,type=e.type,dir=n,rot=parse_direction(n),enable=true,animator=Animator:new(global_table_data.animation_data[e.animation_key],true)}add(animators,obj.animator)setmetatable(obj,self)self.__index=self return obj end function Tower:attack()
if(not self.enable)return
if self.being_manifested and self.type=="tack"then self.dmg=min(self.manifest_cooldown,100)/15end self.current_attack_ticks=(self.current_attack_ticks+1)%self.attack_delay
if(self.current_attack_ticks>0)return
if self.type=="tack"then Tower.apply_damage(self,Tower.nova_collision(self),self.dmg)elseif self.type=="floor"then local e={}add_enemy_at_to_table(self.position,e)foreach(e,function(e)e.burning_tick+=self.dmg end)elseif self.type=="sharp"then add(projectiles,Projectile:new(self.position,self.dir,self.rot,global_table_data.projectiles.rocket))elseif not self.being_manifested then if self.type=="rail"then Tower.apply_damage(self,raycast(self.position,self.radius,self.dir),self.dmg)elseif self.type=="frontal"then Tower.freeze_enemies(self,Tower.frontal_collision(self))end end end function Tower:nova_collision()local n,e={},self.radius for t=-e,e do for o=-e,e do
if(o~=0or t~=0)add_enemy_at_to_table(self.position+Vec:new(o,t),n)
end end
if(#n>0)nova_spawn(self.position,e,global_table_data.animation_data.blade)
return n end function Tower:frontal_collision()local e={}local o,t,i,r,a,l=parse_frontal_bounds(self.radius,self.dir)for n=t,r,l do for t=o,i,a do
if(t~=0or n~=0)add_enemy_at_to_table(self.position+Vec:new(t,n),e)
end end
if(#e>0)frontal_spawn(self.position,self.radius,self.dir,global_table_data.animation_data.frost)
return e end function Tower:apply_damage(n,i)local e=self.type for t in all(n)do if t.hp>0then local n,o=t.type,i if e=="tack"and n==7or e=="rail"and n==14then o=i\2elseif e=="rail"and n==7or e=="tack"and n==15then o*=2end t.hp-=o end end end function Tower:freeze_enemies(n)for e in all(n)do if not e.is_frozen then e.is_frozen=true e.frozen_tick=self.dmg end end end function Tower:draw()
if(not self.enable)return
local e,n,t=self.position*8,Animator.get_sprite(self.animator),self.type=="sharp"and self.rot or parse_direction(self.dir)draw_sprite_shadow(n,e,2,self.animator.sprite_size,t)draw_sprite_rotated(n,e,self.animator.sprite_size,t)end function Tower:cooldown()self.manifest_cooldown=max(self.manifest_cooldown-1,0)end function Tower:get_cooldown_str()
if(self.type=="floor"or self.type=="sharp")return"⬆️⬇️⬅️➡️ position"
if(self.type=="tack")return"❎ activate ("..self.dmg.."D)"
if(self.manifest_cooldown==0)return"❎ activate"
return"❎ activate ("..self.manifest_cooldown.."t)"end function Tower:manifested_lightning_blast()
if(self.manifest_cooldown>0)return
self.manifest_cooldown=self.cooldown local n,e,t=(selector.position/8-self.position)/8,self.position+Vec:new(1,0),self.dmg*2for o=1,3do Tower.apply_damage(self,raycast(e,64,n),t)e.x-=1end e+=Vec:new(2,1)for o=1,3do Tower.apply_damage(self,raycast(e,64,n),t)e.y-=1end end function Tower:manifested_hale_blast()
if(self.manifest_cooldown>0)return
self.manifest_cooldown=self.cooldown local e=selector.position/8local n,t={},{e,e+Vec:new(0,1),e+Vec:new(0,-1),e+Vec:new(-1,0),e+Vec:new(1,0)}for e in all(t)do add_enemy_at_to_table(e,n,true)end spawn_particles_at(t,global_table_data.animation_data.frost)Tower.freeze_enemies(self,n)Tower.apply_damage(self,n,self.dmg\4)end function Tower:manifested_nova()self.manifest_cooldown=min(self.manifest_cooldown+9,110)self.dmg=round_to(min(self.manifest_cooldown,100)/15,2)end function Tower:manifested_torch_trap()local e=selector.position/8
if(grid[e.y][e.x]=="empty")return
local n=Vec:new(Vec.unpack(self.position))if grid[e.y][e.x]=="tower"then local t=Vec:new(global_table_data.map_data[loaded_map].mget_shift)
if(check_tile_flag_at(e+t,0)and n~=e)self.enable=false
return end self.position=e grid[e.y][e.x]="floor"grid[n.y][n.x]="path"self.enable=true end function Tower:manifested_sharp_rotation()self.dir=selector.position/8-self.position self.rot=acos(self.dir.y/sqrt(self.dir.x*self.dir.x+self.dir.y*self.dir.y))*360-180
if(self.dir.x>0)self.rot*=-1
if(self.rot<0)self.rot+=360
if(self.rot>360)self.rot-=360
end function raycast(i,o,n)
if(n==Vec:new(0,0))return
local e,t={},{}for r=1,o do local o=Vec.floor(i+n*r)add(t,o)add_enemy_at_to_table(o,e)end
if(#e>0or manifested_tower_ref)spawn_particles_at(t,global_table_data.animation_data.spark)
return e end function manifest_tower_at(n)for e in all(towers)do if e.position==n then e.being_manifested,manifested_tower_ref,manifest_selector.dir=true,e,1if e.type=="tack"then lock_cursor,e.attack_delay,e.dmg=true,10,0elseif e.type=="sharp"then e.attack_delay/=2end end end end function unmanifest_tower()manifested_tower_ref.being_manifested=false manifest_selector.dir=-1lock_cursor=false if manifested_tower_ref.type=="tack"then local e=global_table_data.tower_templates[1]manifested_tower_ref.attack_delay=e.attack_delay manifested_tower_ref.dmg=e.damage elseif manifested_tower_ref.type=="sharp"then manifested_tower_ref.attack_delay=global_table_data.tower_templates[5].attack_delay end manifested_tower_ref.enable=true manifested_tower_ref=nil end function place_tower(e)
if(grid[e.y][e.x]=="tower")return false
local n=global_table_data.tower_templates[selected_menu_tower_id]
if(coins<n.cost)return false
if(n.type=="floor"~=(grid[e.y][e.x]=="path"))return false
add(towers,Tower:new(e,n,direction))coins-=n.cost grid[e.y][e.x]="tower"return true end function refund_tower_at(e)for n in all(towers)do if n.position==e then grid[e.y][e.x]="empty"
if(n.type=="floor")grid[e.y][e.x]="path"
coins+=n.cost\1.25del(animators,n.animator)del(towers,n)end end end function draw_tower_attack_overlay(n)local e=selector.position/8palt(global_table_data.palettes.transparent_color_id,false)pal(global_table_data.palettes.attack_tile)local o=grid[e.y][e.x]=="empty"local t=Vec:new(global_table_data.map_data[loaded_map].mget_shift)if n.type=="tack"and o then draw_nova_attack_overlay(n.radius,e,t)elseif n.type=="rail"and o then draw_ray_attack_overlay(n.radius,e,t)elseif n.type=="frontal"and o then draw_frontal_attack_overlay(n.radius,e,t)elseif n.type=="floor"and grid[e.y][e.x]=="path"then spr(mget(Vec.unpack(e+t)),Vec.unpack(e*8))end pal()end function draw_nova_attack_overlay(e,o,i)for n=-e,e do for t=-e,e do if t~=0or n~=0then local e=o+Vec:new(t,n)spr(mget(Vec.unpack(e+i)),Vec.unpack(e*8))end end end end function draw_ray_attack_overlay(e,n,t)for o=1,e do local e=n+direction*o spr(mget(Vec.unpack(e+t)),Vec.unpack(e*8))end end function draw_frontal_attack_overlay(e,n,t)local o,i,r,a,l,d=parse_frontal_bounds(e,direction)for f=i,a,d do for i=o,r,l do local e=n+Vec:new(i,f)spr(mget(Vec.unpack(e+t)),Vec.unpack(e*8))end end end function draw_line_overlay(n)local e=(n.position+Vec:new(.5,.5))*8local t=Vec.floor(n.dir*n.radius*8+e)
if(t~=e)line(e.x,e.y,t.x,t.y,8)
end Particle={}function Particle:new(e,n,t)obj={position=e,is_pxl_perfect=n or false,animator=t}setmetatable(obj,self)self.__index=self return obj end function Particle:tick()return Animator.update(self.animator)end function Particle:draw()
if(Animator.finished(self.animator))return
local e=self.position
if(not self.is_pxl_perfect)e=e*8
Animator.draw(self.animator,Vec.unpack(e))end function destroy_particle(e)
if(not Animator.finished(e.animator))return
del(particles,e)end function spawn_particles_at(e,n)for t in all(e)do add(particles,Particle:new(t,false,Animator:new(n,false)))end end function nova_spawn(o,e,i)for n=-e,e do for t=-e,e do
if(t~=0or n~=0)add(particles,Particle:new(o+Vec:new(t,n),false,Animator:new(i,false)))
end end end function frontal_spawn(t,e,n,o)local i,r,a,l,d,f=parse_frontal_bounds(e,n)for e=r,l,f do for n=i,a,d do
if(n~=0or e~=0)add(particles,Particle:new(t+Vec:new(n,e),false,Animator:new(o,false)))
end end end Animator={}function Animator:new(e,n)obj={data=e.data,sprite_size=e.size or 8,animation_frame=1,frame_duration=e.ticks_per_frame,tick=0,dir=1,continuous=n}setmetatable(obj,self)self.__index=self return obj end function Animator:update()self.tick=(self.tick+1)%self.frame_duration
if(self.tick~=0)return
if Animator.finished(self)then
if(self.continuous)self.animation_frame=1
return true end self.animation_frame+=self.dir return end function Animator:finished()
if(self.dir==1)return self.animation_frame>=#self.data
return self.animation_frame<=1end function Animator:draw(t,o)local n,e=Vec:new(t,o),self.data[self.animation_frame]
if(e.offset)n+=Vec:new(e.offset)
spr(e.sprite,Vec.unpack(n))end function Animator:get_sprite()return self.data[self.animation_frame].sprite end BorderRect={}function BorderRect:new(e,n,t,o,i)obj={position=e,size=e+n,border=t,base=o,thickness=i}setmetatable(obj,self)self.__index=self return obj end function BorderRect:draw()rectfill(self.position.x-self.thickness,self.position.y-self.thickness,self.size.x+self.thickness,self.size.y+self.thickness,self.border)rectfill(self.position.x,self.position.y,self.size.x,self.size.y,self.base)end function BorderRect:resize(e,n)
if(self.position~=e)self.position=e
if(self.size~=n+e)self.size=n+e
end function BorderRect:reposition(e)
if(self.position==e)return
local n=self.size-self.position self.position=e self.size=self.position+n end Menu={}function Menu:new(o,i,e,n,t,r,a,l,d,f)obj={name=o,prev=i,position=Vec:new(e,n),selector=Animator:new(global_table_data.animation_data.menu_selector,true),up_arrow=Animator:new(global_table_data.animation_data.up_arrow,true),down_arrow=Animator:new(global_table_data.animation_data.down_arrow,true),content=t,content_draw=r,rect=BorderRect:new(Vec:new(e,n),Vec:new(10+5*longest_menu_str(t),38),l,a,f),text=d,pos=1,enable=false,ticks=5,max_ticks=5,dir=0}setmetatable(obj,self)self.__index=self return obj end function Menu:draw()
if(not self.enable)return
local e,n=self.pos-1,self.pos+1
if(e<1)e=#self.content
if(n>#self.content)n=1
if(self.content_draw)self.content_draw(self.pos,self.position,self.content[self.pos].color)
BorderRect.draw(self.rect)Animator.draw(self.selector,Vec.unpack(self.position+Vec:new(2,15)))local t=(self.rect.size.x+self.rect.position.x)\2-self.up_arrow.sprite_size\2Animator.draw(self.up_arrow,t,self.position.y-self.rect.thickness)Animator.draw(self.down_arrow,t,self.rect.size.y-self.rect.thickness)local o=self.position.x+10local t={self.dir,self.ticks/self.max_ticks,self.position}if self.ticks<self.max_ticks then if self.dir>0then print_with_outline(self.content[e].text,combine_and_unpack(menu_scroll(12,10,7,unpack(t)),self.content[e].color))elseif self.dir<0then print_with_outline(self.content[n].text,combine_and_unpack(menu_scroll(12,10,27,unpack(t)),self.content[n].color))end else print_with_outline(self.content[e].text,o,self.position.y+7,unpack(self.content[e].color))print_with_outline(self.content[n].text,o,self.position.y+27,unpack(self.content[n].color))end print_with_outline(self.content[self.pos].text,combine_and_unpack(menu_scroll(10,12,17,unpack(t)),self.content[self.pos].color))end function Menu:update()
if(not self.enable)return
Animator.update(self.selector)Animator.update(self.up_arrow)Animator.update(self.down_arrow)
if(self.ticks>=self.max_ticks)return
self.ticks+=1end function Menu:move()
if(not self.enable)return
if(self.ticks<self.max_ticks)return
local n,e=controls()
if(e==0)return
self.pos+=e self.dir=e
if(self.pos<1)self.pos=#self.content
if(self.pos>#self.content)self.pos=1
self.ticks=0end function Menu:invoke()local e=self.content[self.pos]
if(e.callback==nil)return
if e.args then e.callback(unpack(e.args))else e.callback()end end function menu_scroll(n,r,t,i,o,e)local a,l=t-10,t+10local d=lerp(e.x+n,e.x+r,o)local n=e.y+t if i<0then n=lerp(e.y+a,n,o)elseif i>0then n=lerp(e.y+l,n,o)end return{d,n}end Vec={}function Vec:new(e,t)local n=nil if type(e)=="table"then n={x=e[1],y=e[2]}else n={x=e,y=t}end setmetatable(n,self)self.__index=self self.__add=function(e,n)return Vec:new(e.x+n.x,e.y+n.y)end self.__sub=function(e,n)return Vec:new(e.x-n.x,e.y-n.y)end self.__mul=function(e,n)return Vec:new(e.x*n,e.y*n)end self.__div=function(e,n)return Vec:new(e.x/n,e.y/n)end self.__eq=function(e,n)return e.x==n.x and e.y==n.y end self.__tostring=function(e)return"("..e.x..", "..e.y..")"end self.__concat=function(e,n)return type(e)=="table"and Vec.__tostring(e)..n or e..Vec.__tostring(n)end return n end function Vec:unpack()return self.x,self.y end function Vec:clamp(e,n)self.x,self.y=mid(self.x,e,n),mid(self.y,e,n)end function Vec:floor()return Vec:new(flr(self.x),flr(self.y))end function Vec:clone()return Vec:new(self.x,self.y)end function Vec:distance(e)return sqrt((self.x-e.x)^2+(self.y-e.y)^2)end function normalize(e)return type(e)=="table"and Vec:new(normalize(e.x),normalize(e.y))or flr(mid(e,-1,1))end function lerp(e,n,t)if type(e)=="table"then return Vec:new(lerp(e.x,n.x,t),lerp(e.y,n.y,t))else return e+(n-e)*t end end Projectile={}function Projectile:new(o,n,i,e)local t=max(abs(n.x),abs(n.y))obj={position=Vec:new(Vec.unpack(o)),dir=Vec:new(n.x/t,n.y/t),theta=i,sprite=e.sprite,size=e.pixel_size,height=e.height,speed=e.speed,damage=e.damage,trail=global_table_data.animation_data[e.trail_animation_key],lifespan=e.lifespan,ticks=0}setmetatable(obj,self)self.__index=self return obj end function Projectile:update()self.ticks=(self.ticks+1)%self.speed
if(self.ticks>0)return
local n={}for e in all(enemies)do
if(Projectile.collider(self,e))add(n,e)
end if#n>0then for e in all(n)do e.hp-=self.damage
if(e.type==8and e.hp<=0)del(enemies,e)
break end add(particles,Particle:new(Vec.clone(self.position),false,Animator:new(self.trail)))del(projectiles,self)return end add(particles,Particle:new(self.position,false,Animator:new(self.trail)))self.position+=self.dir self.lifespan-=1if self.position.x<0or self.position.x>15or self.position.y<0or self.position.y>15or self.lifespan<0then del(projectiles,self)end end function Projectile:draw()draw_sprite_shadow(self.sprite,self.position*8,self.height,self.size,self.theta)draw_sprite_rotated(self.sprite,self.position*8,self.size,self.theta)end function Projectile:collider(e)local n=self.position*self.size+Vec:new(self.size,self.size)/2local t=e.position*8+Vec:new(4,4)local e=self.size+4local o=Vec.distance(n,t)return o<=e end TextScroller={}function TextScroller:new(n,t,o,i)local e=BorderRect:new(unpack(i))obj={speed=n,rect=e,color=o,char_pos=1,text_pos=1,internal_tick=0,is_done=false,width=flr(e.size.x/5),max_lines=flr(e.size.y/16)-1,enable=true}setmetatable(obj,self)self.__index=self TextScroller.load(obj,t)return obj end function TextScroller:draw()
if(not self.enable)return
BorderRect.draw(self.rect)local n=sub(self.data[self.text_pos],1,self.char_pos)local e,t=split(n,"\n"),sub(self.data[self.text_pos],self.char_pos+1,#self.data[self.text_pos])local o=n..generate_garbage(t,self.rect.size.x,#e[#e],self.max_lines,#e\2)print_with_outline(o,self.rect.position.x+4,self.rect.position.y+4,unpack(self.color))if self.is_done then local e=self.text_pos>=#self.data and"❎ to close"or"❎ to continue"print_with_outline(e,self.rect.position.x+4,self.rect.size.y-7,unpack(self.color))end end function TextScroller:update()
if(not self.enable or self.is_done or self.text_pos>#self.data)return
self.internal_tick=(self.internal_tick+1)%self.speed
if(self.internal_tick==0)self.char_pos+=1
self.is_done=self.char_pos>#self.data[self.text_pos]end function TextScroller:next()
if(not self.enable or not self.is_done)return
if(self.text_pos+1>#self.data)return true
self.text_pos+=1self.char_pos,self.is_done=1end function TextScroller:load(o,e)
if(e)self.color=e
local e,t=self.width,""for i,n in pairs(split(o," "))do if#n+1<=e then t..=n.." "e-=#n+1elseif#n<=e then t..=n e-=#n else t..="\n"..n.." "e=self.width-#n+1end end self.data,e={},0local n,o="",split(t,"\n")for i,t in pairs(o)do if e<=self.max_lines then n..=t.."\n\n"e+=1else add(self.data,n)n,e=t.."\n\n",1end
if(i==#o)add(self.data,n)
end self.char_pos,self.text_pos,self.internal_tick,self.is_done=1,1,0end function generate_garbage(i,r,a,l,d)local e,t,n,o="",d,1,a*5for a=1,#i do
if(t>l)break
if o+n*9>r then e..="\n\n"t+=1n,o=1,0else e..=chr(204+flr(rnd(49)))end n+=1end return e end function _init()global_table_data=unpack_table(global_table_str)cartdata(global_table_data.cart_name)reset_game()end function _draw()cls()if game_state=="menu"then main_menu_draw_loop()elseif game_state=="credits"then credits_draw_loop()elseif game_state=="map"then map_draw_loop()elseif game_state=="game"then game_draw_loop()end end function _update()if game_state=="menu"then main_menu_loop()elseif game_state=="credits"then credits_loop()elseif game_state=="map"then map_loop()elseif game_state=="game"then
if(player_health<=0)reset_game()
if shop_enable then shop_loop()else game_loop()end end end function main_menu_draw_loop()map(unpack(global_table_data.splash_screens[1].mget_shift))print_text_center("untitled tower defense",1,7,1)if menu_enemy then Enemy.draw(menu_enemy,true)Enemy.draw(menu_enemy)end Menu.draw(get_menu"main")end function credits_draw_loop()map(unpack(global_table_data.splash_screens[1].mget_shift))print_text_center("credits",credit_y_offsets[1],7,1)print_with_outline("jasper:\n  • game director\n  • programmer",10,credit_y_offsets[2],7,1)print_with_outline("jeren:\n  • core programmer\n  • devops",10,credit_y_offsets[3],7,1)print_with_outline("jimmy:\n  • artist\n  • sound engineer",10,credit_y_offsets[4],7,1)print_with_outline("kaoushik:\n  • programmer",10,credit_y_offsets[5],7,1)end function map_draw_loop()local e=get_menu"map"pal(global_table_data.palettes.dark_mode)map(unpack(global_table_data.map_data[e.pos].mget_shift))pal()Menu.draw(e)print_text_center("map select",5,7,1)end function game_draw_loop()local e=global_table_data.map_data[loaded_map]local n=global_table_data.tower_templates[selected_menu_tower_id]map(unpack(e.mget_shift))
if(manifested_tower_ref==nil and not sell_mode)draw_tower_attack_overlay(n)
if manifested_tower_ref and manifested_tower_ref.type=="sharp"then draw_line_overlay(manifested_tower_ref)end foreach(towers,Tower.draw)foreach(enemies,function(e)Enemy.draw(e,true)end)foreach(enemies,Enemy.draw)foreach(projectiles,Projectile.draw)foreach(particles,Particle.draw)
if(shop_enable)foreach(menus,Menu.draw)
if not shop_enable and not enemies_active and incoming_hint~=nil then for n=1,#incoming_hint do Animator.draw(incoming_hint[n],Vec.unpack((Vec:new(e.enemy_spawn_location)+Vec:new(e.movement_direction)*(n-1))*8))end end ui_draw_loop(n)end function ui_draw_loop(e)print_with_outline("scrap: "..coins,0,1,7,0)print_with_outline("♥ "..player_health,103,1,8,0)print_with_outline("mode: "..(manifest_mode and"manifest"or"sell"),1,108,7,0)if shop_enable and get_active_menu()then print_with_outline("game paused [ wave "..wave_round+freeplay_rounds.." ]",18,16,7,0)print_with_outline(get_active_menu().prev and"❎ select\n🅾️ go back to previous menu"or"❎ select\n🅾️ close menu",1,115,7,0)else if manifest_mode then if manifested_tower_ref then print_with_outline("🅾️ unmanifest",1,122,7,0)print_with_outline(Tower.get_cooldown_str(manifested_tower_ref),1,115,manifested_tower_ref.type=="tack"and 3or(manifested_tower_ref.manifest_cooldown>0and 8or 3),0)end Animator.update(manifest_selector)Animator.draw(manifest_selector,Vec.unpack(selector.position))else
if(not manifested_tower_ref)print_with_outline("🅾️ open menu",1,122,7,0)
end local n=is_in_table(selector.position/8,towers,true)sell_selector.dir=n and 1or-1if n and not manifested_tower_ref then if manifest_mode then print_with_outline("❎ manifest",1,115,7,0)else print_with_outline("❎ sell",1,115,7,0)Animator.update(sell_selector)Animator.draw(sell_selector,Vec.unpack(selector.position))end else if sell_mode then Animator.update(sell_selector)Animator.draw(sell_selector,Vec.unpack(selector.position))else if not manifested_tower_ref then local o,n,t=selector.position/8,7,"❎ buy & place "..e.name if e.cost>coins then t,n="can't afford "..e.name,8elseif e.type=="floor"~=(grid[o.y][o.x]=="path")then t,n="can't place "..e.name.." here",8end print_with_outline(t,1,115,n,0)end end end end end function main_menu_loop()local n,t=global_table_data.splash_screens[1],global_table_data.enemy_templates if pathing==nil then pathing=parse_path(n)end if not menu_enemy then local e=t[flr(rnd(#t))+1]menu_enemy=Enemy:new(n.enemy_spawn_location,e.hp,e.step_delay\2,e.sprite_index,e.type,e.damage,e.height)else update_enemy_position(menu_enemy,true)end Menu.update(get_menu"main")if btnp(❎)then Menu.invoke(get_menu"main")end Menu.move(get_menu"main")end function credits_loop()
if(btnp(🅾️))game_state="menu"
for e=1,5do credit_y_offsets[e]-=1if credit_y_offsets[e]<-15then credit_y_offsets[e]+=145end end end function map_loop()local e=get_menu"map"Menu.update(e)if btnp(❎)then Menu.invoke(e)e.enable=false game_state="game"return end Menu.move(e)end function shop_loop()foreach(menus,Menu.update)if btnp(🅾️)then if get_active_menu().prev==nil then shop_enable=false menus[1].enable=false return else swap_menu_context(get_active_menu().prev)end end if btnp(❎)then Menu.invoke(get_active_menu())end foreach(menus,Menu.move)end function game_loop()
if(auto_start_wave)start_round()
if btnp(🅾️)then if manifested_tower_ref==nil then shop_enable=true get_menu"game".enable=true return else unmanifest_tower()end end if btnp(❎)then if manifested_tower_ref then local e=manifested_tower_ref.type if e=="tack"then Tower.manifested_nova(manifested_tower_ref)elseif e=="rail"then Tower.manifested_lightning_blast(manifested_tower_ref)elseif e=="frontal"then Tower.manifested_hale_blast(manifested_tower_ref)end else local e=selector.position/8if is_in_table(e,towers,true)then if manifest_mode then manifest_tower_at(e)else refund_tower_at(e)end else place_tower(e)end end end if not lock_cursor then selector.position+=Vec:new(controls())*8Vec.clamp(selector.position,0,120)if manifested_tower_ref then if manifested_tower_ref.type=="floor"then Tower.manifested_torch_trap(manifested_tower_ref)elseif manifested_tower_ref.type=="sharp"then Tower.manifested_sharp_rotation(manifested_tower_ref)end end end foreach(towers,Tower.cooldown)if enemies_active then foreach(enemies,update_enemy_position)foreach(towers,Tower.attack)if start_next_wave then start_next_wave=false wave_cor=cocreate(spawn_enemy)end if wave_cor and costatus(wave_cor)~="dead"then coresume(wave_cor)else wave_cor=nil end end foreach(projectiles,Projectile.update)foreach(particles,Particle.tick)foreach(animators,Animator.update)
if(not enemies_active and incoming_hint)foreach(incoming_hint,Animator.update)
foreach(enemies,kill_enemy)foreach(particles,destroy_particle)if enemies_active and#enemies==0and enemies_remaining==0then enemies_active=false sfx(global_table_data.sfx_data.round_complete)coins+=15end end function print_with_outline(e,n,t,o,i)
?e,n-1,t,i
?e,n+1,t
?e,n,t-1
?e,n,t+1
?e,n,t,o
end function print_text_center(e,n,t,o)print_with_outline(e,64-#e*5\2,n,t,o)end function controls()if btnp(⬆️)then return 0,-1elseif btnp(⬇️)then return 0,1elseif btnp(⬅️)then return-1,0elseif btnp(➡️)then return 1,0end return 0,0end function increase_enemy_health(e)local n=global_table_data.freeplay_stats return{e.hp*(1+(n.hp-1)*((wave_round+freeplay_rounds)/15)),max(e.step_delay-n.speed*freeplay_rounds,n.min_step_delay),e.sprite_index,e.type,e.damage,e.height}end function is_in_table(e,o,i)for n,t in pairs(o)do if i then
if(e==t.position)return true,n
else
if(e==t)return true,n
end end end function add_enemy_at_to_table(n,t,o)for e in all(enemies)do if e.position==n then add(t,e)
if(not o)return
end end end function draw_sprite_rotated(n,i,e,t,s)local u,h=n%16*8,n\16*8local r,a=sin(t/360),cos(t/360)local n=e\2-.5for l=0,e-1do for d=0,e-1do local f,c=l-n,d-n local t=flr(f*a-c*r+n)local o=flr(f*r+c*a+n)if t>=0and t<e and o>=0and o<=e then local e=sget(u+t,h+o)if e~=global_table_data.palettes.transparent_color_id or s then pset(i.x+l,i.y+d,e)end end end end end function draw_sprite_shadow(n,t,e,o,i)pal(global_table_data.palettes.shadows)draw_sprite_rotated(n,t+Vec:new(e,e),o,i)pal()end function parse_direction(e)
if(e.x>0)return 90
if(e.x<0)return 270
if(e.y>0)return 180
if(e.y<0)return 0
end function parse_frontal_bounds(e,r)local n,t,o,i,a,l=-1,1,1,e,1,1if r.x>0then n,t,o,i=1,-1,e,1elseif r.x<0then n,t,o,i,a=-1,-1,-e,1,-1elseif r.y<0then n,t,o,i,l=-1,-1,1,-e,-1end return n,t,o,i,a,l end function combine_and_unpack(n,t)local e={}for t in all(n)do add(e,t)end for n in all(t)do add(e,n)end return unpack(e)end function round_to(n,t)local e=10*t local t=flr(n*e)return t/e end function check_tile_flag_at(e,n)return fget(mget(Vec.unpack(e)),n)end function acos(e)return atan2(e,-sqrt(1-e*e))end function save_byte(e,n)poke(e,n)return e+1end function save_int(e,n)poke4(e,n)return e+4end function unpack_table(n)local o,t,i,e={},1,0,1while e<=#n do if n[e]=="{"then i+=1elseif n[e]=="}"then i-=1
if(i>0)goto unpack_table_continue
insert_key_val(sub(n,t,e),o)t=e+1
if(e+2>#n)goto unpack_table_continue
t+=1e+=1elseif i==0then if n[e]==","then insert_key_val(sub(n,t,e-1),o)t=e+1elseif e==#n then insert_key_val(sub(n,t),o)end end::unpack_table_continue::e+=1end return o end function insert_key_val(n,t)local o,e=split_key_value_str(n)if o==nil then add(t,e)else local n if e[1]=="{"and e[-1]=="}"then n=unpack_table(sub(e,2,#e-1))elseif e=="True"then n=true elseif e=="False"then n=false else n=tonum(e)or e end if n=="inf"then n=32767end t[o]=n end end function convert_to_array_or_table(n)local e=sub(n,2,#n-1)
if(str_contains_char(e,"{"))return unpack_table(e)
if(not str_contains_char(e,"="))return split(e,",",true)
return unpack_table(e)end function split_key_value_str(e)local n=split(e,"=")local t=tonum(n[1])or n[1]if e[1]=="{"and e[-1]=="}"then return nil,convert_to_array_or_table(e)end local n=sub(e,#(tostr(t))+2)if n[1]=="{"and n[-1]=="}"then return t,convert_to_array_or_table(n)end return t,n end function str_contains_char(e,n)for t=1,#e do
if(e[t]==n)return true
end end
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
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3f883f8888b88488888484
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3f3f888888b8b884848484
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3f8888888884888484b484
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f883f8888b888888484848084
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f8888888888848484848484
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f888888888884848484b480
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d1d1d3f1d88b8888884848480848080
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002f2f9b9b9b9b9b9b9797979797939393
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d3d3f3d3d888888b88884b484b480b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f8888b88884848484808080
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3f888888888484808480b0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3f8888b8b8848484848080
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f888888b8848484b4808480
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3f3f888888b884b4b48480
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3f8888888888848484b480
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3f3f3f88888488b88484b4
__gff__
0000000000000000000000000000000000000000000000000001010102020201000000000000000000000202020102010000000000000000000002020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020102020201020202010202020102010201020102010201020102010201020202020202020202020202020202020201010102010101020101010201010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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