-- Text Helpers
function print_with_outline(text, dx, dy, text_color, outline_color)
  ?text,dx-1,dy,outline_color
  ?text,dx+1,dy
  ?text,dx,dy-1
  ?text,dx,dy+1
  ?text,dx,dy,text_color
end

-- Utility
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

function is_in_table(val, table, is_entity)
  for i, obj in pairs(table) do
    if is_entity then 
      if (val == obj.position) return true, i 
    else
      if (val == obj) return true, i 
    end
  end
end

function placable_tile_location(coord)
  return fget(mget(coord.x, coord.y), map_meta_data.non_path_flag_id)
end

function add_enemy_at_to_table(pos, table)
  for _, enemy in pairs(enemies) do
    if enemy.position == pos then
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

function parse_direction(dir)
  if (dir.x > 0) return 90
  if (dir.x < 0) return 270
  if (dir.y > 0) return 180
  if (dir.y < 0) return 0
end

function parse_frontal_bounds(radius, position)
  -- Default South
  local fx, fy, flx, fly, ix, iy = -1, 1, 1, radius, 1, 1

  if position.x > 0 then -- east
    fx, fy, flx, fly = 1, -1, radius, 1
  elseif position.x < 0 then -- west
    fx, fy, flx, fly, ix = -1, -1, -radius, 1, -1
  elseif position.y < 0 then -- north
    fx, fy, flx, fly, iy = -1, -1, 1, -radius, -1
  end
  return fx, fy, flx, fly, ix, iy
end

