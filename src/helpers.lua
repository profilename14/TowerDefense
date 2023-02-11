-- Text Helpers
function print_with_outline(text, dx, dy, text_color, outline_color)
  ?text,dx-1,dy,outline_color
  ?text,dx+1,dy
  ?text,dx,dy-1
  ?text,dx,dy+1
  ?text,dx,dy,text_color
end

function print_tower_cost(cost, dx, dy)
  print_with_outline("C"..cost, dx, dy, (cost > coins) and 8 or 7, 0)
end

-- Utility
function normalize(val)
  return flr(mid(val, -1, 1))
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

function is_in_table(val, table)
  for i, obj in pairs(table) do
    if (val.x == obj.x and val.y == obj.y) return true, i 
  end
end

function is_there_something_at(dx, dy, table)
  return is_in_table(unpack_to_coord(pack(dx, dy)), table) and true or false
end

function placable_tile_location(x, y)
  return fget(mget(x, y), map_meta_data.non_path_flag_id)
end

function add_enemy_at_to_table(dx, dy, table)
  for _, enemy in pairs(enemies) do
    if (enemy.x == dx and enemy.y == dy) then
      add(table, enemy)
      return
    end
  end
end

-- https://www.lexaloffle.com/bbs/?pid=52525 [modified for this game]
function draw_sprite_rotated(sprite_id, x, y, size, theta, is_opaque)
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
        if id ~= transparent_color_id or is_opaque then 
          pset(x+mx, y+my, id)
        end
      end
    end
  end
end

function parse_direction(direction)
  local dx, dy = unpack(direction)
  if (dx > 0) return 90
  if (dx < 0) return 270
  if (dy > 0) return 180
  if (dy < 0) return 0
end

function vec2_add(vec1, vec2)
  return {vec1[1] + vec2[1], vec1[2] + vec2[2]}
end

function unpack_to_coord(vec1)
  return {x=vec1[1], y=vec1[2]}
end

function parse_frontal_bounds(radius, dx, dy)
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

