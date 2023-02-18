-- Game Data -- Modify at will
global_table_str = "tower_icon_background=68,palettes={transparent_color_id=0,dark_mode={1=0,5=1,6=5,7=6},attack_tile={0=2,7=14},shadows={0=0,1=0,2=0,3=0,4=0,5=0,6=0,7=0,8=0,9=0,10=0,11=0,12=0,13=0,14=0,15=0}},sfx_data={round_complete=10},freeplay_stats={hp=2,speed=1,min_step_delay=3},map_meta_data={path_flag_id=0,non_path_flag_id=1},map_data={{name=curves,mget_shift={0,0},enemy_spawn_location={0,1},enemy_end_location={15,11},movement_direction={1,0}},{name=loop,mget_shift={16,0},enemy_spawn_location={0,1},enemy_end_location={15,11},movement_direction={1,0}},{name=straight,mget_shift={32,0},enemy_spawn_location={0,1},enemy_end_location={15,2},movement_direction={1,0}},{name=u-turn,mget_shift={48,0},enemy_spawn_location={0,1},enemy_end_location={0,6},movement_direction={1,0}}},animation_data={spark={data={{sprite=10},{sprite=11},{sprite=12}},ticks_per_frame=2},blade={data={{sprite=13},{sprite=14},{sprite=15}},ticks_per_frame=2},frost={data={{sprite=48},{sprite=49},{sprite=50}},ticks_per_frame=2},burn={data={{sprite=51},{sprite=52},{sprite=53}},ticks_per_frame=2},incoming_hint={data={{sprite=2,offset={0,0}},{sprite=2,offset={1,0}},{sprite=2,offset={2,0}},{sprite=2,offset={1,0}}},ticks_per_frame=5},blade_circle={data={{sprite=76},{sprite=77},{sprite=78},{sprite=79},{sprite=78},{sprite=77}},ticks_per_frame=3},lightning_lance={data={{sprite=108},{sprite=109}},ticks_per_frame=5},hale_howitzer={data={{sprite=92},{sprite=93}},ticks_per_frame=5},fire_pit={data={{sprite=124},{sprite=125},{sprite=126},{sprite=127},{sprite=126},{sprite=125}},ticks_per_frame=5},menu_selector={data={{sprite=6,offset={0,0}},{sprite=7,offset={-1,0}},{sprite=8,offset={-2,0}},{sprite=9,offset={-3,0}},{sprite=8,offset={-2,0}},{sprite=7,offset={-1,0}}},ticks_per_frame=3},up_arrow={data={{sprite=54,offset={0,0}},{sprite=54,offset={0,-1}},{sprite=54,offset={0,-2}},{sprite=54,offset={0,-1}}},ticks_per_frame=3},down_arrow={data={{sprite=55,offset={0,0}},{sprite=55,offset={0,1}},{sprite=55,offset={0,2}},{sprite=55,offset={0,1}}},ticks_per_frame=3},sell={data={{sprite=1},{sprite=56},{sprite=40},{sprite=24}},ticks_per_frame=3}},tower_templates={{name=sword circle,text_color={2,13},damage=4,prefix=damage,radius=1,animation_key=blade_circle,cost=25,type=tack,attack_delay=20,icon_data=16,disable_icon_rotation=True},{name=lightning lance,text_color={10,9},damage=5,prefix=damage,radius=5,animation_key=lightning_lance,cost=45,type=rail,attack_delay=25,icon_data=18,disable_icon_rotation=False},{name=hale howitzer,text_color={12,7},damage=5,prefix=delay,radius=2,animation_key=hale_howitzer,cost=30,type=frontal,attack_delay=30,icon_data=20,disable_icon_rotation=False},{name=torch trap,text_color={9,8},damage=5,prefix=duration,radius=0,animation_key=fire_pit,cost=20,type=floor,attack_delay=15,icon_data=22,disable_icon_rotation=True}},enemy_templates={{hp=10,step_delay=10,sprite_index=3,reward=3,damage=1,height=2},{hp=10,step_delay=8,sprite_index=4,reward=5,damage=2,height=6},{hp=25,step_delay=12,sprite_index=5,reward=7,damage=5,height=2},{hp=8,step_delay=12,sprite_index=3,reward=5,damage=1,height=2}},wave_data={{4,4,4},{1,4,1,4,1,4},{2,4,2,1,2,4,1},{1,2,2,4,2,2,1,2,2,2},{3,3,3,3,2,2,2,2,4,2,3,1},{2,2,2,2,2,2,2,2,4,3,3,3,1,2,2,2,2,2,2},{3,3,3,3,3,3,1,4,1,3,3,3,3,1,1,1,1,1},{1,1,1,1,1,1,1,1,1,2,2,2,2,2,1,1,1},{2,3,2,3,2,3,2,3,2,3,2,3,2,3,2,3,2,3,2,3},{1,3,3,3,3,3,2,2,2,2,2,2,2,3,3,3,3,3},{2,3,3,3,3,3,2,3,3,3,3,2,2,4,1},{2,2,3,3,3,2,2,4,4,2,2,3,3,3,3,2,2,2},{2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,2,2,2,2,2},{3,3,3,3,3,3,4,2,4,2,4,2,3,3,3,3,3,3,3,3},{3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3}}"

-- Game
function reset_game()
  global_table_data = unpack_table(global_table_str)
  -- Game Data -- Modify at will
  menu_data = {
    {
      "main", nil,
      5, 70, 
      {
        {text = "towers", color = {7, 0}, callback = swap_menu_context, args = {"towers"}},
        {text = "misc", color = {7, 0}, callback = swap_menu_context, args = {"misc"}},
        {text = "rotate clockwise", color = {7, 0}, 
          callback = function()
            direction = Vec:new(-direction.y, direction.x)
          end
        },
        {text = "start round", color = {7, 0}, callback = start_round}
      },
      display_tower_rotation,
      5, 8, 7, 3
    },
    { "towers", "main", 5, 70, get_tower_data_for_menu(), display_tower_info, 5, 8, 7, 3 },
    {
      "misc", "main",
      5, 70, 
      {
        {text = "map select", color = {7, 0}, 
          callback = function()
            get_active_menu().enable = false
            reset_game()
            map_menu_enable = true
          end
        },
        {text = "manifest mode", color = {7, 0}, 
          callback = function()
            manifest_mode = true
            get_active_menu().enable = false
            shop_enable = false
          end
        },
        {text = "selling mode", color = {7, 0}, 
          callback = function()
            manifest_mode = false
            get_active_menu().enable = false
            shop_enable = false
          end
        }
      },
      nil,
      5, 8, 7, 3
    },
    { "map", nil, 5, 84, get_map_data_for_menu(), nil, 5, 8, 7, 3 }
  }
  selector = {
    position = Vec:new(64, 64),
    sprite_index = 1,
    size = 1
  }
  coins = 30
  player_health = 50
  enemy_required_spawn_ticks = 10
  -- If true, selecting towers manifests them. If false, selecting towers sells them.
  manifest_mode = true
  -- If true, the player is currently manifesting a tower. Else, they aren't and the game functions as normal.
  manifesting_now = true
  -- Internal Data -- Don't modify
  enemy_current_spawn_tick = 0
  map_menu_enable, enemies_active, shop_enable, start_next_wave, wave_cor = true
  direction = Vec:new(0, -1)
  grid, towers, enemies, particles, animators, incoming_hint, menus = {}, {}, {}, {}, {}, {}, {}
  music(-1)
  selected_menu_tower_id = 1
  for i, menu_dat in pairs(menu_data) do add(menus, Menu:new(unpack(menu_dat))) end
  tower_stats_background_rect = BorderRect:new(Vec:new(0, 0), Vec:new(20, 38), 8, 5, 2)
  tower_rotation_background_rect = BorderRect:new(Vec:new(0, 0), Vec:new(24, 24), 8, 5, 2)
  sell_selector = Animator:new(global_table_data.animation_data.sell)
  get_menu("map").enable = true
end