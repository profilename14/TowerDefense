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
  -- tower attack hint overlay
  if (manifested_tower_ref == nil and not sell_mode) draw_tower_attack_overlay(tower_details)
  if manifested_tower_ref and manifested_tower_ref.type == "sharp" then 
    draw_line_overlay(manifested_tower_ref)
  end
  -- towers
  foreach(towers, Tower.draw)
  -- enemy shadows
  foreach(enemies, function (enemy) Enemy.draw(enemy, true) end)
  -- enemies
  foreach(enemies, Enemy.draw)
  -- particles
  foreach(projectiles, Projectile.draw)
  foreach(particles, Particle.draw)
  -- shop
  if (shop_enable) foreach(menus, Menu.draw)
  -- selector
  if not shop_enable and not enemies_active and incoming_hint ~= nil then 
    for i=1, #incoming_hint do 
      Animator.draw(incoming_hint[i], Vec.unpack(
        (Vec:new(map_data.enemy_spawn_location) + Vec:new(map_data.movement_direction) * (i-1))*8
      ))
    end
  end
  -- UI
  ui_draw_loop(tower_details)
end

function ui_draw_loop(tower_details)
  -- static/always present
  print_with_outline("scrap: "..coins, 0, 1, 7, 0)
  print_with_outline("♥ "..player_health, 103, 1, 8, 0)
  local mode = manifest_mode and "manifest" or "sell"
  print_with_outline("mode: "..mode, 1, 108, 7, 0)

  -- shop ui
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