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