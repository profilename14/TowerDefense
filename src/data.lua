local global_table_str --[[remove]]
--[[json global_table_str ../data.json]]

-- Game
function reset_game()
  -- Game Data -- Modify at will
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
  coins, player_health, enemy_required_spawn_ticks, credit_y_offsets, lock_cursor = 30, 50, 10, {
    30, 45, 75, 105, 140
  }
  text_flag = false

  -- -- temp 
  text_place_holder = global_table_data.dialogue.placeholder
  text_scroller = TextScroller:new(1, text_place_holder.text, text_place_holder.color, {
    Vec:new(3, 80), Vec:new(96, 45), 8, 6, 3
  })
  text_scroller.enable = false
  
  
  -- Internal Data -- Don't modify
  enemy_current_spawn_tick, manifest_mode, sell_mode, manifested_tower_ref, enemies_active, shop_enable, start_next_wave, wave_cor, pathing, menu_enemy = 0
  direction, game_state, selected_menu_tower_id = Vec:new(0, -1), "menu", 1
  grid, towers, enemies, particles, animators, incoming_hint, menus, projectiles = {}, {}, {}, {}, {}, {}, {}, {}
  music(-1)
  for i, menu_dat in pairs(menu_data) do add(menus, Menu:new(unpack(menu_dat))) end
  tower_stats_background_rect = BorderRect:new(Vec:new(0, 0), Vec:new(20, 38), 8, 5, 2)
  tower_rotation_background_rect = BorderRect:new(Vec:new(0, 0), Vec:new(24, 24), 8, 5, 2)
  sell_selector = Animator:new(global_table_data.animation_data.sell)
  manifest_selector = Animator:new(global_table_data.animation_data.manifest)
  manifest_selector.dir = -1
  get_menu("main").enable = true
end