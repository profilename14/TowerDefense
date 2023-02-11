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
    spr(selector.sprite_index, Vec.unpack(selector.position))
  end
  -- UI
  print_with_outline("scrap: "..coins, 0, 1, 7, 0)
  print_with_outline("♥ "..player_health, 103, 1, 8, 0)
  if shop_enable then
    print_with_outline("game paused [ wave "..(wave_round+freeplay_rounds).." ]", 18, 16, 7, 0)
    if get_active_menu().prev == nil then
      print_with_outline("❎ select\n🅾️ close menu", 1, 115, 7, 0)
    else
      print_with_outline("❎ select\n🅾️ go back to previous menu", 1, 115, 7, 0)
    end
  else 
    if is_in_table(selector.position/8, towers, true) then
      print_with_outline("❎ sell | 🅾️ open menu", 1, 120, 7, 0)
    else
      print_with_outline(
        "❎ buy & place "..tower_templates[selected_menu_tower_id].name.."\n🅾️ open menu", 
        1, 115, 7, 0)
    end
  end
end

function draw_map_overview(map_id, xoffset, yoffset)
  local map_shift = Vec:new(map_data[map_id].mget_shift)
  for y=0, 15 do
    for x=0, 15 do
      pset(x + xoffset, y + yoffset, placable_tile_location(Vec:new(x, y)+map_shift) and map_draw_data.other or map_draw_data.path)
    end
  end
end

function draw_selector(sel)
  spr(sel.sprite_index, sel.x, sel.y, sel.size, sel.size)
end