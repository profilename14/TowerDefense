--[[json global_table_str ../data.json]]

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
        {text = "options", color = {7, 0}, callback = swap_menu_context, args = {"options"}},
        {text = "rotate tower", color = {7, 0}, 
          callback = function()
            direction = Vec:new(-direction.y, direction.x)
          end
        }
      },
      display_tower_rotation,
      5, 8, 7, 3
    },
    { "towers", "main", 5, 70, get_tower_data_for_menu(), display_tower_info, 5, 8, 7, 3 },
    {
      "options", "main",
      5, 70, 
      {
        {text = "start round", color = {7, 0}, callback = start_round},
        {text = "map select", color = {7, 0}, 
          callback = function()
            get_active_menu().enable = false
            reset_game()
            map_menu_enable = true
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
  coins = 50
  player_health = 100
  enemy_required_spawn_ticks = 10
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