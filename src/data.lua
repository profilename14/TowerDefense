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
      _ENV[menu_dat.hint],
      unpack(menu_dat.settings)
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
  coins, player_health, enemy_required_spawn_ticks, credit_y_offsets, letter_rot, lock_cursor, text_flag = 5000, 50, 10, global_table_data.credit_offsets, 0

  text_scroller = TextScroller:new(1, nil, {7, 0}, { Vec:new(3, 80), Vec:new(96, 45), 8, 6, 3 })
  text_scroller.enable = false
  
  -- Internal Data -- Don't modify
  enemy_current_spawn_tick, manifest_mode, sell_mode, manifested_tower_ref, enemies_active, shop_enable, start_next_wave, wave_cor, pathing, menu_enemy = 0
  direction, game_state, selected_menu_tower_id = Vec:new(0, -1), "menu", 1
  grid, towers, enemies, particles, animators, incoming_hint, menus, projectiles = {}, {}, {}, {}, {}, {}, {}, {}
  music(-1)
  for i, menu_dat in pairs(menu_data) do add(menus, Menu:new(unpack(menu_dat))) end
  sell_selector = Animator:new(global_table_data.animation_data.sell)
  manifest_selector = Animator:new(global_table_data.animation_data.manifest)
  manifest_selector.dir = -1
  get_menu("main").enable = true
end