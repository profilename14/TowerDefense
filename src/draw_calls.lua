function game_draw_loop()
  map(
    map_data[loaded_map].data[1], 
    map_data[loaded_map].data[2], 
    map_data[loaded_map].data[3], 
    map_data[loaded_map].data[4], 
    map_data[loaded_map].data[5], 
    map_data[loaded_map].data[6]
  )
  -- towers
  foreach(towers, Tower.draw)
  -- enemies
  foreach(enemies, Enemy.draw)
  -- particles
  foreach(particles, Particle.draw)
  -- shop
  if (shop_enable) draw_shop_icons()
  -- selector
  if shop_enable then 
    if option_enable then 
      draw_selector(option_selector) 
    else
      draw_selector(shop_selector) 
    end
  else 
    if not enemies_active and incoming_hint ~= nil then 
      local dx = map_data[loaded_map].enemy_spawn_location[1]
      local dy = map_data[loaded_map].enemy_spawn_location[2]
      local dir = map_data[loaded_map].movement_direction
      for i=1, #incoming_hint do 
        Animator.draw(incoming_hint[i], (dx + (i - 1) * dir[1])*8, (dy + (i - 1) * dir[2])*8)
      end
    end
    draw_selector(selector) 
  end
  -- UI
  print_with_outline("scrap: "..coins, 0, 1, 7, 0)
  print_with_outline("♥ "..player_health, 103, 1, 8, 0)
  if shop_enable then
    print_with_outline("game paused [ wave "..(wave_round+freeplay_rounds).." ]", 18, 16, 7, 0)
    print_with_outline("start round", shop_ui_data.x[1]-6, 33, 7, 0)
    print_with_outline("map menu", shop_ui_data.x[3]-6, 33, 7, 0)
    local len = #tower_templates[shop_selector.pos + 1].name
    print_with_outline(tower_templates[shop_selector.pos + 1].name, 128/2-(len*2), 108, 7, 0)
    print_with_outline("❎ rotate | 🅾️ close shop", 1, 120, 7, 0)
    -- draw_attack_tiles(tower_templates[shop_selector.pos + 1], 128/2 - 8, shop_ui_data.y[1] + 24)
    draw_shop_cost()
    draw_shop_dmg()
  else 
    local text = "❎ buy & place | 🅾️ open shop"
    if (is_there_something_at(selector.x / 8, selector.y / 8, towers)) text = "❎ sell | 🅾️ open shop"
    print_with_outline(text, 1, 122, 7, 0)
  end
end

function draw_map_overview(map_id, xoffset, yoffset)
  local mxshift = map_data[map_id].mget_shift[1]
  local myshift = map_data[map_id].mget_shift[2]
  for y=0, 15 do
    for x=0, 15 do
      local is_not_path = placable_tile_location(x + mxshift, y + myshift, map_id)
      if is_not_path then 
        pset(x + xoffset, y + yoffset, map_draw_data.other)
      else 
        pset(x + xoffset, y + yoffset, map_draw_data.path)
      end
    end
  end
end

function draw_attack_tiles(tower_template, dx, dy)
  if tower_template.type == "tack" then 
    for y=-tower_template.radius, tower_template.radius do
      for x=-tower_template.radius, tower_template.radius do
        if (x ~= 0 or y ~= 0) spr(tile_display.attack, dx + x * 8, dy + y * 8)
      end
    end
    spr(tower_template.sprite_data[1][2], dx, dy)
  elseif tower_template.type == "rail" then 
    local shift = (tower_template.radius + 1) / 2 - 1
    for x=1, tower_template.radius do
      if (x > 0) spr(tile_display.attack, dx + x * 8 - (shift * 8), dy)
    end
    spr(tower_template.sprite_data[1][2], dx - (shift * 8), dy)
  elseif tower_template.type == "frontal" then 
    for y=-1, 1 do
      for x=1, tower_template.radius do 
        spr(tile_display.attack, dx + x * 8, dy + y * 8)
      end
    end
    spr(tower_template.sprite_data[1][2], dx, dy)
  elseif tower_template.type == "floor" then 
    spr(tile_display.attack, dx, dy)
    spr(tower_template.sprite_data[1][2], dx, dy)
  end
end

function draw_shop_icons()
  -- local fx, fy = get_flip_direction(direction)
  for i=1, #tower_templates do 
    if (tower_templates[i].disable_icon_rotation) then 
      palt(0, false)
      spr(shop_ui_data.blank, shop_ui_data.x[i] - 20, shop_ui_data.y[1] - 20, 3, 3)
      palt()
      local id = tower_templates[i].icon_data
      spr(id, shop_ui_data.x[i] - 16, shop_ui_data.y[1] - 16, 2, 2)
    else
      local id = shop_ui_data.background
      draw_sprite_rotated(id, shop_ui_data.x[i]-20, shop_ui_data.y[1]-20, 24, parse_direction(direction), true)
      id = tower_templates[i].icon_data
      draw_sprite_rotated(id, shop_ui_data.x[i]-16, shop_ui_data.y[1]-16, 16, parse_direction(direction))
    end
  end
end

function draw_shop_cost()
  for i=1, #tower_templates do
    print_tower_cost(tower_templates[i].cost, shop_ui_data.x[i] - 4, shop_ui_data.y[1] - 6)
  end
end

function draw_shop_dmg()
  for i=1, #tower_templates do
    local type = tower_templates[i].type
    if type == "tack" or type == "rail" then 
      print_with_outline("D"..tower_templates[i].damage, shop_ui_data.x[i] - 4, shop_ui_data.y[1], 8, 0)
    else 
      print_with_outline("T"..tower_templates[i].damage, shop_ui_data.x[i] - 4, shop_ui_data.y[1], 12, 0)
    end
  end
end

function draw_selector(sel)
  spr(sel.sprite_index, sel.x, sel.y, sel.size, sel.size)
end