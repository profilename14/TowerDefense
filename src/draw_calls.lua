function game_draw_loop()
  map(unpack(global_table_data.map_data[loaded_map].mget_shift))
  -- tower attack hint overlay
  local tower_details = global_table_data.tower_templates[selected_menu_tower_id]
  draw_tower_attack_overlay(tower_details)
  -- towers
  foreach(towers, Tower.draw)
  -- enemy shadows
  foreach(enemies, function (enemy) Enemy.draw(enemy, true) end)
  -- enemies
  foreach(enemies, Enemy.draw)
  -- particles
  foreach(particles, Particle.draw)
  -- shop
  if (shop_enable) foreach(menus, Menu.draw)
  -- selector
  if not shop_enable and not enemies_active and incoming_hint ~= nil then 
    for i=1, #incoming_hint do 
      Animator.draw(incoming_hint[i], Vec.unpack(
        (Vec:new(global_table_data.map_data[loaded_map].enemy_spawn_location) + 
        Vec:new(global_table_data.map_data[loaded_map].movement_direction) * 
        (i-1))*8
      ))
    end
  end
  -- UI
  print_with_outline("scrap: "..coins, 0, 1, 7, 0)
  print_with_outline("♥ "..player_health, 103, 1, 8, 0)
  local mode = manifest_mode and "manifest" or "sell"
  print_with_outline("mode: "..mode, 1, 108, 7, 0)
  if shop_enable and get_active_menu() then
    print_with_outline("game paused [ wave "..(wave_round+freeplay_rounds).." ]", 18, 16, 7, 0)
    if get_active_menu().prev then
      print_with_outline("❎ select\n🅾️ go back to previous menu", 1, 115, 7, 0)
    else
      print_with_outline("❎ select\n🅾️ close menu", 1, 115, 7, 0)
    end
  else 
    if is_in_table(selector.position/8, towers, true) then
      Animator.update(sell_selector)
      Animator.draw(sell_selector, Vec.unpack(selector.position))
      if manifest_mode == false then
        print_with_outline("❎ sell", 1, 115, 7, 0)
      else
        print_with_outline("❎ manifest", 1, 115, 7, 0)
      end
    else
      spr(selector.sprite_index, Vec.unpack(selector.position))
      Animator.reset(sell_selector)
      local position, text, color = selector.position/8, "❎ buy & place "..tower_details.name, 7
      if tower_details.cost > coins then
        text, color = "can't afford "..tower_details.name, 8
      elseif (tower_details.type == "floor") ~= (grid[position.y][position.x] == "path") then 
        text, color = "can't place "..tower_details.name.." here", 8
      end
      print_with_outline(text, 1, 115, color, 0)
    end
    print_with_outline("🅾️ open menu", 1, 122, 7, 0)
  end
end

function map_draw_loop()
  local map_menu = get_menu("map")
  pal(global_table_data.palettes.dark_mode)
  map(unpack(global_table_data.map_data[map_menu.pos].mget_shift))
  pal()
  Menu.draw(map_menu)
  print_text_center("map select", 5, 7, 1)
end