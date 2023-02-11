Enemy = {}
function Enemy:new(location, enemy_data)
  obj = { 
    -- x = location[1], y = location[2],
    position = Vec:new(location),
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
  local n, prev = pathing[self.pos], Vec:new(map_data[loaded_map].enemy_spawn_location)
  if (self.pos - 1 >= 1) prev = pathing[self.pos-1]
  local px, py = Vec.unpack(self.position * 8)
  if not self.is_frozen then 
    px, py = lerp(prev*8, n*8, self.current_step / self.step_delay)
  end
  return px, py, n
end
function Enemy:draw()
  if (self.hp <= 0) return
  local px, py, n = Enemy.get_pixel_location(self)
  printh(Vec.to_str(n))
  printh(Vec.to_str(self.position))
  local dir = normalize(n-self.position)
  draw_sprite_rotated(self.gfx, px, py, 8, parse_direction(dir))
end

function kill_enemy(enemy)
  if (enemy.hp > 0) return
  coins += enemy.reward
  del(enemies, enemy)
end

function update_enemy_position(enemy)
  if (not Enemy.step(enemy)) return
  enemy.position = pathing[enemy.pos]
  enemy.pos += 1
  if (enemy.pos < #pathing + 1) return
  player_health -= enemy.damage 
  del(enemies, enemy)
end

function parse_path()
  local map_shift = Vec:new(map_data[loaded_map].mget_shift)
  local map_enemy_spawn_location = Vec:new(map_data[loaded_map].enemy_spawn_location)
  local path_tiles = {}
  for iy=0, 15 do
    for ix=0, 15 do
      local map_cord = Vec:new(ix, iy) + map_shift
      if fget(mget(Vec.unpack(map_cord)), map_meta_data.path_flag_id) then 
        add(path_tiles, map_cord)
      end
    end
  end

  local path = {}
  local dir = Vec:new(map_data[loaded_map].movement_direction)
  local ending = Vec:new(map_data[loaded_map].enemy_end_location) + map_shift
  local cur = map_enemy_spawn_location + map_shift + dir
  while cur ~= ending do 
    local north = Vec:new(cur.x, cur.y-1)
    local south = Vec:new(cur.x, cur.y+1)
    local west = Vec:new(cur.x-1, cur.y)
    local east = Vec:new(cur.x+1, cur.y)
    local state = false
    local direct = nil
    if dir.x == 1 then -- east 
      state, direct = check_direction(east, {north, south}, path_tiles, path)
    elseif dir.x == -1 then -- west
      state, direct = check_direction(west, {north, south}, path_tiles, path)
    elseif dir.y == 1 then -- south
      state, direct = check_direction(south, {west, east}, path_tiles, path)
    elseif dir.y == -1 then -- north
      state, direct = check_direction(north, {west, east}, path_tiles, path)
    end
    assert(state, "Failed to find path at: "..Vec.to_str(cur).." in direction: "..Vec.to_str(dir).." end: "..Vec.to_str(ending))
    if state then 
      dir = normalize(direct - cur)
      cur = direct
    else 
    end
  end
  return path
end

function check_direction(direct, fail_directions, path_tiles, path)
  if (direct == nil) return
  local state, index = is_in_table(direct, path_tiles)
  if state then
    add(path, path_tiles[index] - Vec:new(map_data[loaded_map].mget_shift))
  else 
    return check_direction(fail_directions[1], {fail_directions[2]}, path_tiles, path)
  end
  return true, direct
end

function spawn_enemy()
  while enemies_remaining > 0 do 
    enemy_current_spawn_tick = (enemy_current_spawn_tick + 1) % enemy_required_spawn_ticks
    if (is_there_something_at(enemies, unpack(map_data[loaded_map].enemy_spawn_location))) goto spawn_enemy_continue
    if (enemy_current_spawn_tick ~= 0) goto spawn_enemy_continue 
    enemy_data_from_template = increase_enemy_health(enemy_templates[wave_data[wave_round][enemies_remaining]])
    add(enemies, Enemy:new(map_data[loaded_map].enemy_spawn_location, enemy_data_from_template))
    enemies_remaining -= 1
    ::spawn_enemy_continue:: 
    yield()
  end
end
