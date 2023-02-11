-- Tower Defence v1.14.10
-- By Jeren (Code), Jasper (Art & Sound), Jimmy (Art & Music)

-- Forward Declaring Functions
#include src/forwardDeclares.lua
-- Game Data and Reset Data
#include src/data.lua
-- Classes
#include src/enemy.lua
#include src/tower.lua
#include src/particle.lua
#include src/animator.lua
#include src/borderRect.lua
#include src/menu.lua

-- Utility/Helper Functions
#include src/helpers.lua
#include src/vec.lua

-- Draw Calls
#include src/draw_calls.lua

-- Pico8
function _init()
  reset_game()
end

function _draw()
  cls()
  if map_menu_enable then 
    for i=1, #map_data do
      draw_map_overview(i, shop_ui_data.x[i]-16, shop_ui_data.y[1]-16)
    end
    print_with_outline("choose a map to play", 25, 1, 7, 0)
    local len = #map_data[map_selector.pos + 1].name
    print_with_outline(map_data[map_selector.pos + 1].name, 128/2-(len*2), 108, 7, 0)
    draw_selector(map_selector)
  else
    game_draw_loop()
  end
end

function _update()
  if map_menu_enable then 
    map_loop()
  else 
    if (player_health <= 0) reset_game()
    if shop_enable then shop_loop() else game_loop() end
  end
end

-- Game
function load_game(map_id)
  wave_round = 0
  freeplay_rounds = 0
  loaded_map = map_id
  pathing = parse_path()
  for i=1, 3 do
    add(incoming_hint, Animator:new(animation_data.incoming_hint, true))
  end
  for y=0, 15 do 
    grid[y] = {}
    for x=0, 15 do 
      grid[y][x] = "empty"
      local map_coords = Vec:new(x, y) + Vec:new(map_data[loaded_map].mget_shift)
      if (not placable_tile_location(map_coords)) grid[y][x] = "path" 
    end
  end
  music(0)
  menus = {}
  for i, menu_dat in pairs(menu_data) do
    add(menus, Menu:new(unpack(menu_dat)))
  end
  tower_stats_background_rect = BorderRect:new(Vec:new(0, 0), Vec:new(20, 38), 8, 5, 2)
  sell_selector = Animator:new(animation_data.sell)
end

function map_loop()
  if btnp(❎) then 
    load_game(map_selector.pos + 1)
    map_menu_enable = false 
    return
  end

  local dx, dy = controls()
  if dx < 0 then 
    map_selector.pos = (map_selector.pos - 1) % #map_data
    map_selector.x = shop_ui_data.x[map_selector.pos + 1]-20
  elseif dx > 0 then 
    map_selector.pos = (map_selector.pos + 1) % #map_data
    map_selector.x = shop_ui_data.x[map_selector.pos + 1]-20
  end
end

function shop_loop()
  foreach(menus, Menu.update)
  
  if btnp(🅾️) then -- disable shop
    if get_active_menu().prev == nil then 
      shop_enable = false
      menus[1].enable = false
      return
    else
      swap_menu_context(get_active_menu().prev)
    end
  end
  if btnp(❎) then 
    Menu.invoke(get_active_menu())
  end

  foreach(menus, Menu.move)
end

function game_loop()
  if btnp(🅾️) then
    shop_enable = true
    menus[1].enable = true
    return
  end
  if btnp(❎) then 
    local position = selector.position/8
    if is_in_table(position, towers, true) then 
      refund_tower_at(position)
    else
      place_tower(position)
    end
  end

  selector.position += Vec:new(controls()) * 8
  Vec.clamp(selector.position, 0, 120)

  -- update objs
  if enemies_active then 
    foreach(enemies, update_enemy_position)
    foreach(towers, Tower.attack)
    if start_next_wave then 
      start_next_wave = false
      wave_cor = cocreate(spawn_enemy)
    end
    if wave_cor and costatus(wave_cor) ~= 'dead' then
      coresume(wave_cor)
    else
      wave_cor = nil
    end
  end
  -- update particles
  foreach(particles, Particle.tick)
  foreach(animators, Animator.update)
  if (not enemies_active and incoming_hint) foreach(incoming_hint, Animator.update)
  -- clean up tables
  foreach(enemies, kill_enemy)
  foreach(particles, destroy_particle)
  if enemies_active and #enemies == 0 and enemies_remaining == 0 then 
    enemies_active = false 
    sfx(sfx_data.round_complete)
  end
end
