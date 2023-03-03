local global_table_str --[[remove]]
--[[json global_table_str ../data.json]]

-- Game
function reset_game()
  -- Game Data -- Modify at will
  menu_data = {
    {
      "main", nil,
      32, 64,
      {
        {
          text="new game", color={7, 0}, 
          callback=function()
            game_state = "map"
            swap_menu_context("map")
          end
        },
        {
          text="load game", color={7, 0},
          callback=function()
            reset_game()
            local hp, scrap, map_id, wav, freeplay = load_game()
            load_map(map_id)
            player_health = hp 
            coins = scrap
            wave_round = wav 
            freeplay_rounds = freeplay
            -- TODO: calculate what the freeplay enemies will be
            game_state = "game"
          end
        },
        {text="credits", color={7, 0}},
      },
      nil,
      5, 8, 7, 3
    },
    {
      "game", nil,
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
    { "towers", "game", 5, 63, get_tower_data_for_menu(), display_tower_info, 5, 8, 7, 3 },
    {
      "misc", "game",
      5, 63, 
      {
        {text = "map select", color = {7, 0}, 
          callback = function()
            reset_game()
            game_state = "map"
            swap_menu_context("map")
          end
        },
        {
          text="toggle mode", color={7, 0},
          callback = function()
            manifest_mode = not manifest_mode
            sell_mode = not sell_mode
          end
        },
        {
          text="save", color={7, 0},
          callback = function()
            save_game()
            get_active_menu().enable = false
            shop_enable = false
          end
        },
        {
          text="save and quit", color={7, 0},
          callback = function()
            save_game()
            reset_game()
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
  lock_cursor = false

  -- temp 
  text_place_holder = global_table_data.dialogue.placeholder
  text_scroller = TextScroller:new(1, text_place_holder.text, text_place_holder.color, {
    Vec:new(3, 3), Vec:new(100, 50), 8, 6, 3
  })
  
  
  -- Internal Data -- Don't modify
  -- If true, selecting towers manifests them. If false, selecting towers sells them.
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