-- Tower Defence v1.14.10
-- By Jeren (Code), Jasper (Art & Sound), Jimmy (Art & Music)

-- Game Data and Reset Data
#include src/data.lua
-- Classes
#include src/enemy.lua
#include src/tower.lua
#include src/particle.lua
#include src/animator.lua

-- Utility/Helper Functions
#include src/helpers.lua

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
  shop_selector.x = shop_ui_data.x[shop_selector.pos + 1]-20
  shop_selector.y = shop_ui_data.y[1]-20
  option_selector.x = shop_ui_data.x[1]-16
  option_selector.y = 32
  for i=1, 3 do
    add(incoming_hint, Animator:new(hud_data.incoming_hint, true))
  end
  for y=0, 15 do 
    grid[y] = {}
    for x=0, 15 do 
      grid[y][x] = "empty"
      local mx = x + map_data[loaded_map].mget_shift[1]
      local my = y + map_data[loaded_map].mget_shift[2]
      if (not placable_tile_location(mx, my)) grid[y][x] = "path" 
    end
  end
  music(0)
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
  if btnp(🅾️) then -- disable shop
    shop_enable = false
    return
  end
  if btnp(❎) then 
    if option_enable then 
      if option_selector.pos == 1 and not start_next_wave and #enemies == 0 then
        start_next_wave = true
        enemies_active = true
        wave_round += 1
        wave_round = min(wave_round, #wave_data)
        if wave_round == #wave_data then 
          freeplay_rounds += 1
        end
        enemies_remaining = #wave_data[wave_round]
      elseif option_selector.pos == 3 then 
        reset_game()
        map_menu_enable = true
      end
      shop_enable = false
      return
    else
      direction = { direction[2] * -1, direction[1] }
    end
  end

  local dx, dy = controls()
  if (dy ~= 0) option_enable = not option_enable
  
  if (dx == 0) return
  if option_enable then
    move_ui_selector(option_selector, dx, 2, 0, 16) 
  else
    move_ui_selector(shop_selector, dx, 1, 1, 20)
  end
end

function game_loop()
  if btnp(🅾️) then
    shop_enable = true
    return
  end
  if btnp(❎) then 
    local dx = selector.x / 8
    local dy = selector.y / 8
    if is_there_something_at(dx, dy, towers) then 
      refund_tower_at(dx, dy)
    else
      place_tower(dx, dy)
    end
  end

  local dx, dy = controls()
  selector.x = clamp(selector.x + dx * 8, 0, 120)
  selector.y = clamp(selector.y + dy * 8, 0, 120)

  -- update objs
  if enemies_active then 
    foreach(enemies, update_enemy_position)
    foreach(towers, Tower.attack)
    if start_next_wave then 
      start_next_wave = false
      wave_cor = cocreate(spawn_enemy)
    end
    if wave_cor and costatus(wave_cor) != 'dead' then
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
