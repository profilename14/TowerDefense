local global_table_str --[[remove]]
--[[json global_table_str ../data.json]]

-- Game
function reset_game()
  global_table_data = unpack_table(global_table_str)
  -- Game Data -- Modify at will
  menu_data = {
    {
      "main", nil,
      5, 63, 
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
    { "towers", "main", 5, 63, get_tower_data_for_menu(), display_tower_info, 5, 8, 7, 3 },
    {
      "misc", "main",
      5, 63, 
      {
        {text = "map select", color = {7, 0}, 
          callback = function()
            get_active_menu().enable = false
            reset_game()
            map_menu_enable = true
          end
        },
        {
          text="toggle mode", color={7, 0},
          callback = function()
            manifest_mode = not manifest_mode
            sell_mode = not sell_mode
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
  player_health = 50
  enemy_required_spawn_ticks = 10
  lock_cursor = false

  -- temp 
  text = [[hi, this is a test. let's see if this is doable in pico-8. i'm not sure if pico-8 has multi-line strings or this is seen as one big string. i now know that pico-8 is smart enough to notice the whitespace in multi-line strings. let's see if this gives another screen.]]
  text_scroller = TextScroller:new(2, text, {7, 0}, {
    Vec:new(3, 3), Vec:new(100, 50), 8, 6, 3
  })
  
  -- If true, selecting towers manifests them. If false, selecting towers sells them.
  manifest_mode = false
  sell_mode = false
  manifested_tower_ref = nil

  -- Internal Data -- Don't modify
  enemy_current_spawn_tick = 0
  map_menu_enable, enemies_active, shop_enable, start_next_wave, wave_cor = true
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
  get_menu("map").enable = true
end