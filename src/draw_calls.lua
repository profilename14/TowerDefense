function game_draw_loop()
  map(
    unpack(map_data[loaded_map].mget_shift),
    unpack(map_meta_data)
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
      local dx, dy = unpack(map_data[loaded_map].enemy_spawn_location)
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
    draw_shop_cost()
    draw_shop_dmg()
  else 
    local text = "❎ buy & place | 🅾️ open shop"
    if (is_there_something_at(selector.x / 8, selector.y / 8, towers)) text = "❎ sell | 🅾️ open shop"
    print_with_outline(text, 1, 122, 7, 0)
  end
end

function draw_map_overview(map_id, xoffset, yoffset)
  local mxshift, myshift = unpack(map_data[map_id].mget_shift)
  for y=0, 15 do
    for x=0, 15 do
      pset(x + xoffset, y + yoffset, placable_tile_location(x + mxshift, y + myshift) and map_draw_data.other or map_draw_data.path)
    end
  end
end

function draw_shop_icons()
  for i=1, #tower_templates do 
    local id = tower_templates[i].icon_data
    if (tower_templates[i].disable_icon_rotation) then 
      rectfill(shop_ui_data.x[i] - 20, shop_ui_data.y[1] - 20, shop_ui_data.x[i]+3, shop_ui_data.y[1]+3, 0)
      spr(id, shop_ui_data.x[i] - 16, shop_ui_data.y[1] - 16, 2, 2)
    else
      draw_sprite_rotated(shop_ui_data.background, shop_ui_data.x[i]-20, shop_ui_data.y[1]-20, 24, parse_direction(direction), true)
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