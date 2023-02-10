-- Text Helpers
function print_with_outline(text, dx, dy, text_color, outline_color)
  print(text, dx - 1, dy, outline_color)
  print(text, dx + 1, dy, outline_color)
  print(text, dx, dy-1, outline_color)
  print(text, dx, dy+1, outline_color)
  print(text, dx, dy, text_color)
end

function print_tower_cost(cost, dx, dy)
  local color = 7
  if (cost > coins) color = 8
  print_with_outline("C"..cost, dx, dy, color, 0)
end

-- Utility
function dist(posA, posB) 
  local x = posA.x - posB.x
  local y = posA.y - posB.y
  return sqrt(x * x + y * y)
end

function clamp(val, min_val, max_val)
  return min(max(min_val, val), max_val)
end 

function normalize(val)
  return flr(clamp(val, -1, 1))
end

function lerp(start, last, rate)
  return start + (last - start) * rate
end

function controls()
  if btnp(⬆️) then return 0, -1
  elseif btnp(⬇️) then return 0, 1
  elseif btnp(⬅️) then return -1, 0
  elseif btnp(➡️) then return 1, 0
  end
  return 0, 0
end

function increase_enemy_health(enemy_data)
  return {
    hp = enemy_data.hp + freeplay_stats.hp * freeplay_rounds,
    step_delay = max(enemy_data.step_delay - freeplay_stats.speed * freeplay_rounds, freeplay_stats.min_step_delay),
    sprite_index = enemy_data.sprite_index,
    reward = enemy_data.reward,
    damage = enemy_data.damage
  }
end

function move_ui_selector(sel, dx, shift, offset, delta)
  local inc = shift
  if (dx < 0) inc = -shift
  sel.pos = (sel.pos + inc) % #shop_ui_data.x
  sel.x = shop_ui_data.x[sel.pos + offset]-delta
end

function is_in_table(val, table)
  for i=1, #table do 
    if (val.x == table[i].x and val.y == table[i].y) return true, i 
  end
  return false, -1
end

function placable_tile_location(x, y, map_id)
  local map_index = loaded_map
  if (map_id ~= nil) map_index = map_id
  local sprite_id = mget(x, y)
  for i=1, #map_data[map_index].allowed_tiles do 
    if (sprite_id == map_data[map_index].allowed_tiles[i]) return true
  end
  return false
end

function add_enemy_at_to_table(dx, dy, table, single_only)
  for _, enemy in pairs(enemies) do
    if (enemy.x == dx and enemy.y == dy) then
      add(table, enemy)
      if (single_only) return
    end
  end
end

-- https://www.lexaloffle.com/bbs/?pid=52525 [modified for this game]
function draw_sprite_rotated(sprite_id, x, y, size, theta)
  local sx, sy = (sprite_id % 16) * 8, (sprite_id \ 16) * 8 
  local sine, cosine = sin(theta / 360), cos(theta / 360)
  local shift = flr(size*0.5) - 0.5
  for mx=0, size-1 do 
    for my=0, size-1 do 
      local dx, dy = mx-shift, my-shift
      local xx = flr(dx*cosine-dy*sine+shift)
      local yy = flr(dx*sine+dy*cosine+shift)
      if xx >= 0 and xx < size and yy >= 0 and yy <= size then
        local id = sget(sx+xx, sy+yy)
        if id ~= transparent_color_id then 
          pset(x+mx, y+my, id)
        end
      end
    end
  end
end

-- temp
function parse_direction(direction)
  local dx, dy = direction[1], direction[2]
  if (dx > 0) return 90
  if (dx < 0) return 270
  if (dy > 0) return 180
  if (dy < 0) return 0
end

-- function parse_direction(data, dir)
--   if dir[1] == 0 and dir[2] ~= 0 then 
--     return data[1]
--   elseif dir[1] ~= 0 and dir[2] == 0 then
--     return data[2]
--   end
-- end

function get_flip_direction(direction)
  return pack((direction[1] == -1), (direction[2] == -1))
end

function draw_sprite_direction(sprite_id, size, x, y, fx, fy)
  local sx, sy = (sprite_id % 16) * size, flr(sprite_id / 16) * size
  sspr(sx, sy, size, size, x, y, size, size, fx, fy)
end

function is_there_something_at(dx, dy, table)
  for _, obj in pairs(table) do
    if (obj.x == dx and obj.y == dy) return true 
  end
  return false
end

function refund_tower_at(dx, dy)
  for _, tower in pairs(towers) do
    if tower.x == dx and tower.y == dy then
      grid[dy][dx] = "empty"
      if (tower.type == "floor") grid[dy][dx] = "path"
      coins += flr(tower.cost / 2) 
      del(animators, tower.animator) 
      del(towers, tower)
    end
  end
end

function parse_frontal_bounds(dx, dy, radius)
  -- Default South
  local fx, fy, flx, fly, ix, iy = -1, 1, 1, radius, 1, 1

  if dx > 0 then -- east
    fx, fy, flx, fly = 1, -1, radius, 1
  elseif dx < 0 then -- west
    fx, fy, flx, fly, ix = -1, -1, -radius, 1, -1
  elseif dy < 0 then -- north
    fx, fy, flx, fly, iy = -1, -1, 1, -radius, -1
  end
  return fx, fy, flx, fly, ix, iy
end

