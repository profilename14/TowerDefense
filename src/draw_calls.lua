function game_draw_loop()
  map(unpack(map_data[loaded_map].mget_shift))
  -- towers
  foreach(towers, Tower.draw)
  -- enemies
  foreach(enemies, Enemy.draw)
  -- particles
  foreach(particles, Particle.draw)
  -- shop
  if (shop_enable) foreach(menus, Menu.draw)
  -- selector
  if not shop_enable then 
    if not enemies_active and incoming_hint ~= nil then 
      local spawn_location = Vec:new(map_data[loaded_map].enemy_spawn_location)
      local dir = Vec:new(map_data[loaded_map].movement_direction)
      for i=1, #incoming_hint do 
        local position = (spawn_location + dir * (i-1))*8
        Animator.draw(incoming_hint[i], Vec.unpack(position))
      end
    end
  end
  -- UI
  print_with_outline("scrap: "..coins, 0, 1, 7, 0)
  print_with_outline("♥ "..player_health, 103, 1, 8, 0)
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
      print_with_outline("❎ sell\n🅾️ open menu", 1, 115, 7, 0)
    else
      spr(selector.sprite_index, Vec.unpack(selector.position))
      Animator.reset(sell_selector)
      local position = selector.position/8
      local tower_details = tower_templates[selected_menu_tower_id]
      local text, color = "❎ buy & place "..tower_details.name, 7
      if tower_details.cost > coins then
        text = "can't afford "..tower_details.name
        color = 8
      elseif (tower_details.type == "floor") ~= (grid[position.y][position.x] == "path") then 
        text = "can't place "..tower_details.name.." here"
        color = 8
      end
      print_with_outline(text, 1, 115, color, 0)
      print_with_outline("🅾️ open menu", 1, 122, 7, 0)
    end
  end
end

function map_draw_loop()
  local map_menu = get_menu("map")
  pal(palettes.dark_mode)
  map(unpack(map_data[map_menu.pos].mget_shift))
  pal()
  Menu.draw(map_menu)
  print_text_center("map select", 5, 7, 1)
end