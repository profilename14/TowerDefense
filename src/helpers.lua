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

-- How enemy health works (note it scales beyond in freeplay):
-- stats.hp is a modifier for how much more hp will have by wave 15. Ex, 3 means 3x health.
-- the +1 and -1 are to ensure health scales from the default HP to the multiplied hp linearly.
function increase_enemy_health(enemy_data)
  local stats = global_table_data.freeplay_stats
  return 
    {
      enemy_data.hp * ( 1 + (stats.hp - 1) * ((wave_round+freeplay_rounds)/15) ),
      max(enemy_data.step_delay-stats.speed*freeplay_rounds,stats.min_step_delay),
      enemy_data.sprite_index,
      enemy_data.type,
      enemy_data.damage,
      enemy_data.height
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

function add_enemy_at_to_table(pos, table, multitarget)
  for enemy in all(enemies) do
    if enemy.position == pos then
      add(table, enemy)
      if (not multitarget) return
    end
  end
end

-- https://www.lexaloffle.com/bbs/?pid=52525 [modified for this game]
function draw_sprite_rotated(sprite_id, position, size, theta, is_opaque)
  local sx, sy, shift, sine, cosine = (sprite_id % 16) * 8, (sprite_id \ 16) * 8, size\2 - 0.5, sin(theta / 360), cos(theta / 360)
  for mx=0, size-1 do 
    for my=0, size-1 do 
      local dx, dy = mx-shift, my-shift
      local xx = flr(dx*cosine-dy*sine+shift)
      local yy = flr(dx*sine+dy*cosine+shift)
      if xx >= 0 and xx < size and yy >= 0 and yy <= size then
        local id = sget(sx+xx, sy+yy)
        if id ~= global_table_data.palettes.transparent_color_id or is_opaque then 
          pset(position.x+mx, position.y+my, id)
        end
      end
    end
  end
end

function draw_sprite_shadow(sprite, position, height, size, theta)
  pal(global_table_data.palettes.shadows)
  draw_sprite_rotated(sprite, position + Vec:new(height, height), size, theta)
  pal()
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

function combine_and_unpack(data1, data2)
  local data = {}
  for dat in all(data1) do
    add(data, dat)
  end
  for dat in all(data2) do
    add(data, dat)
  end
  return unpack(data)
end

function round_to(value, place)
  local mult = 10^(place or 0)
  return flr(value * mult + 0.5) / mult
end

function check_tile_flag_at(position, flag)
  return fget(mget(Vec.unpack(position)), flag)
end

function load_wave_text()
  local text_place_holder = global_table_data.dialogue[global_table_data.level_dialogue_set[cur_level] or "dialogue_level4"][wave_round]
  if text_place_holder then 
    text_scroller.enable = true
    TextScroller.load(text_scroller, text_place_holder.text, text_place_holder.color)
  end
end

-- https://www.lexaloffle.com/bbs/?tid=3142
function acos(x)
  return atan2(x,-sqrt(1-x*x))
end

function save_byte(address, value)
  poke(address, value)
  return address + 1
end

function save_int(address, value)
  poke4(address, value)
  return address + 4
end

function encode(a, b, a_w)
  return (a << a_w) | b
end

function decode(data, a_w, b_mask)
  return flr(data >>> a_w), data & b_mask
end