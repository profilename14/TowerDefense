Enemy = {}
function Enemy:new(location, enemy_data)
  obj = { 
    x = location[1], y = location[2],
    hp = enemy_data.hp, 
    step_delay = enemy_data.step_delay,
    current_step = 0,
    is_frozen = false,
    frozen_tick = 0,
    burning_tick = 0,
    gfx = enemy_data.sprite_index,
    reward = enemy_data.reward,
    damage = enemy_data.damage,
    pos = 1
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Enemy:step()
  self.current_step = (self.current_step + 1) % self.step_delay
  if (self.current_step ~= 0) return false

  if self.burning_tick > 0 then 
    self.burning_tick -= 1
    self.hp -= 2
    local px, py, _ = Enemy.get_pixel_location(self)
    add(particles, Particle:new(px, py, true, Animator:new(animation_data.burn, false)))
  end

  if (not self.is_frozen) return true 
  self.frozen_tick = max(self.frozen_tick - 1, 0)
  if (self.frozen_tick ~= 0) return false
  self.is_frozen = false
  return true
end
function Enemy:get_pixel_location()
  local n, prev = pathing[self.pos], {x=map_data[loaded_map].enemy_spawn_location[1], y=map_data[loaded_map].enemy_spawn_location[2]}
  if (self.pos - 1 >= 1) prev = pathing[self.pos-1]
  local px, py = self.x * 8, self.y * 8
  if not self.is_frozen then 
    px = lerp(prev.x * 8, n.x * 8, self.current_step / self.step_delay)
    py = lerp(prev.y * 8, n.y * 8, self.current_step / self.step_delay)
  end
  return px, py, n
end
function Enemy:draw()
  if (self.hp <= 0) return
  local px, py, n = Enemy.get_pixel_location(self)
  local dir = {normalize(n.x - self.x), normalize(n.y - self.y)}
  draw_sprite_rotated(self.gfx, px, py, 8, parse_direction(dir))
end

function kill_enemy(enemy)
  if (enemy.hp > 0) return
  coins += enemy.reward
  del(enemies, enemy)
end

function update_enemy_position(enemy)
  if (not Enemy.step(enemy)) return
  enemy.x = pathing[enemy.pos].x
  enemy.y = pathing[enemy.pos].y
  enemy.pos += 1
  if (enemy.pos < #pathing + 1) return
  player_health -= enemy.damage 
  del(enemies, enemy)
end

function parse_path()
  local path_tiles = {}
  for iy=0, 16 do
    for ix=0, 16 do
      local mx = ix + map_data[loaded_map].mget_shift[1]
      local my = iy + map_data[loaded_map].mget_shift[2]
      for _, id in pairs(map_data[loaded_map].path_id) do
        if (mget(mx, my) == id) then 
          add(path_tiles, { x = mx, y = my })
        end
      end
    end
  end

  local path = {}
  local dir = {x=map_data[loaded_map].movement_direction[1],y=map_data[loaded_map].movement_direction[2]}
  local ending = {
    x=map_data[loaded_map].enemy_end_location[1] + map_data[loaded_map].mget_shift[1], 
    y=map_data[loaded_map].enemy_end_location[2] + map_data[loaded_map].mget_shift[2]
  }
  local cur = {
    x = map_data[loaded_map].enemy_spawn_location[1] + map_data[loaded_map].mget_shift[1] + dir.x, 
    y = map_data[loaded_map].enemy_spawn_location[2] + map_data[loaded_map].mget_shift[2] + dir.y
  }
  while not (cur.x == ending.x and cur.y == ending.y) do 
    local north = {x=cur.x, y=cur.y-1}
    local south = {x=cur.x, y=cur.y+1}
    local west = {x=cur.x-1, y=cur.y}
    local east = {x=cur.x+1, y=cur.y}
    local state = false
    local direction = nil
    if dir.x == 1 then -- east 
      state, direction = check_direction(east, {north, south}, path_tiles, path)
    elseif dir.x == -1 then -- west
      state, direction = check_direction(west, {north, south}, path_tiles, path)
    elseif dir.y == 1 then -- south
      state, direction = check_direction(south, {west, east}, path_tiles, path)
    elseif dir.y == -1 then -- north
      state, direction = check_direction(north, {west, east}, path_tiles, path)
    end
    assert(state, "Failed to find path at: "..cur.x..", "..cur.y.." in direction: "..dir.x..", "..dir.y.." end: "..ending.x..", "..ending.y)
    if state then 
      dir = {x=normalize(direction.x-cur.x), y=normalize(direction.y-cur.y)}
      cur = {x=direction.x, y=direction.y}
    else 
    end
  end
  return path
end

function check_direction(direction, fail_directions, path_tiles, path)
  if (direction == nil) return false, nil
  local state, index = is_in_table(direction, path_tiles)
  if state then
    local tile = {
      x = path_tiles[index].x - map_data[loaded_map].mget_shift[1],
      y = path_tiles[index].y - map_data[loaded_map].mget_shift[2]
    } 
    add(path, tile)
  else 
    return check_direction(fail_directions[1], {fail_directions[2]}, path_tiles, path)
  end
  return true, direction
end

function spawn_enemy()
  while enemies_remaining > 0 do 
    enemy_current_spawn_tick = (enemy_current_spawn_tick + 1) % enemy_required_spawn_ticks
    if (is_there_something_at(map_data[loaded_map].enemy_spawn_location[1], map_data[loaded_map].enemy_spawn_location[2], enemies)) goto spawn_enemy_continue
    if (enemy_current_spawn_tick ~= 0) goto spawn_enemy_continue 
    enemy_data_from_template = increase_enemy_health(enemy_templates[wave_data[wave_round][enemies_remaining]])
    printh(enemy_data_from_template.hp)
    add(enemies, Enemy:new(map_data[loaded_map].enemy_spawn_location, enemy_data_from_template))
    enemies_remaining -= 1
    ::spawn_enemy_continue:: 
    yield()
  end
end
