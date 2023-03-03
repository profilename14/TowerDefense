-- FOR REFERENCE IN DATA.LUA:
-- 1 = car, 2 = plane, 3 = tank, 4 = lab cart, 5 = ice truck, 6 = trailblazer, 7 = auxillium bot
-- 8 = carrier, 9 = cargo car, 10 = first boss, 11 = spy plane (type 0 when invisible), 12 = swarmer
-- 13 = remote missile, 14 = shield generator, 15 = mech, 16 = robber, 17 = The Emperor (last boss)
Enemy = {}
function Enemy:new(location, hp_, step_delay_, sprite_id, type_, damage_, height_)
  obj = { 
    position = Vec:new(location),
    hp = hp_, 
    step_delay = step_delay_,
    current_step = 0,
    is_frozen = false,
    frozen_tick = 0,
    burning_tick = 0,
    gfx = sprite_id,
    type = type_,
    damage = damage_,
    height = height_,
    pos = 1,
    spawn_location = Vec:new(location)
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
    -- Sense the reward system was retired, I'm just recycling it into an ID system.
    if self.type == 6 then
      self.hp -= 0.5
    elseif self.type == 5 then
      self.hp -= 5
    else
      self.hp -= 2
    end
    local p, _ = Enemy.get_pixel_location(self)
    add(particles, Particle:new(p, true, Animator:new(global_table_data.animation_data.burn, false)))
  end

  if (not self.is_frozen) return true 
  if self.type == 6 then
    -- Trailblazers are frozen a little longer and take damage.
    self.frozen_tick = max(self.frozen_tick - 0.8, 0)
    self.hp -= 2
  elseif self.type == 5 then
    -- Ice trucks are frozen for only 1/8 the time
    self.frozen_tick = max(self.frozen_tick - 8, 0)
  else
    self.frozen_tick = max(self.frozen_tick - 1, 0)
  end
  if (self.frozen_tick ~= 0) return false
  self.is_frozen = false
  return true
end
function Enemy:get_pixel_location()
  local n, prev = pathing[self.pos], self.spawn_location
  if (self.pos - 1 >= 1) prev = pathing[self.pos-1]
  local pos = self.position * 8
  if (not self.is_frozen) pos = lerp(prev*8, n*8, self.current_step / self.step_delay)
  return pos, n
end
function Enemy:draw(is_shadows)
  if (self.hp <= 0) return
  -- Spyplanes will spawn visible, and every tick they have a chance to go invisible (then a lower chance to reappear)
  -- While RNG based, it works pretty well in gameplay for making them threatening (but never unfair, especially as unmanifested towers see them).
  if self.type == 11 then
    local go_invisible = flr(rnd(7))
    if (go_invisible == 0) self.type = 0
  elseif self.type == 0 then
    local go_visible = flr(rnd(12))
    if (go_visible == 0) self.type = 11
    return
  end
  local p, n = Enemy.get_pixel_location(self)
  local theta = parse_direction(normalize(n-self.position))
  if is_shadows then
    if (self.type == 0) return
    draw_sprite_shadow(self.gfx, p, self.height, 8, theta)
  else
    draw_sprite_rotated(self.gfx, p, 8, theta)
  end
end

function kill_enemy(enemy)
  if (enemy.hp > 0) return
  -- To save tokens, the Carrier literally just morphs into a car.
  if enemy.type == 8 then
    enemy.gfx, enemy.type, enemy.height, enemy.hp, enemy.step_delay = 94, 9, 2, 20, 10
  else
    del(enemies, enemy)
  end
end

function update_enemy_position(enemy, is_menu)
  if (not Enemy.step(enemy)) return
  enemy.position = pathing[enemy.pos]
  enemy.pos += 1
  if (enemy.pos < #pathing + 1) return
  if is_menu then 
    menu_enemy = nil
  else
    player_health -= enemy.damage 
    if (enemy.type == 16) coins -= 10
    del(enemies, enemy)
  end
end

function parse_path(map_override)
  local map_dat = map_override or global_table_data.map_data[loaded_map]
  local map_shift, map_enemy_spawn_location, path_tiles = Vec:new(map_dat.mget_shift), Vec:new(map_dat.enemy_spawn_location), {}
  for iy=0, 15 do
    for ix=0, 15 do
      local map_cord = Vec:new(ix, iy) + map_shift
      if check_tile_flag_at(map_cord, global_table_data.map_meta_data.path_flag_id) then 
        add(path_tiles, map_cord)
      end
    end
  end

  local path, dir, ending = {}, Vec:new(map_dat.movement_direction), Vec:new(map_dat.enemy_end_location) + map_shift
  local cur = map_enemy_spawn_location + map_shift + dir
  while cur ~= ending do 
    local north,south,west,east = Vec:new(cur.x, cur.y-1),Vec:new(cur.x, cur.y+1),Vec:new(cur.x-1, cur.y),Vec:new(cur.x+1, cur.y)
    local state,direct = false
    if dir.x == 1 then -- east 
      state, direct = check_direction(east, {north, south}, path_tiles, path, map_shift)
    elseif dir.x == -1 then -- west
      state, direct = check_direction(west, {north, south}, path_tiles, path, map_shift)
    elseif dir.y == 1 then -- south
      state, direct = check_direction(south, {west, east}, path_tiles, path, map_shift)
    elseif dir.y == -1 then -- north
      state, direct = check_direction(north, {west, east}, path_tiles, path, map_shift)
    end
    assert(state, "Failed to find path at: "..cur.." in direction: "..dir.." end: "..ending)
    if state then 
      dir = normalize(direct - cur)
      cur = direct
    else 
    end
  end
  return path
end

function check_direction(direct, fail_directions, path_tiles, path, shift)
  if (direct == nil) return
  local state, index = is_in_table(direct, path_tiles)
  if state then
    add(path, path_tiles[index] - shift)
  else 
    return check_direction(fail_directions[1], {fail_directions[2]}, path_tiles, path, shift)
  end
  return true, direct
end

function spawn_enemy()
  while enemies_remaining > 0 do 
    enemy_current_spawn_tick = (enemy_current_spawn_tick + 1) % enemy_required_spawn_ticks
    if (is_in_table(Vec:new(global_table_data.map_data[loaded_map].enemy_spawn_location), enemies, true)) goto spawn_enemy_continue
    if enemy_current_spawn_tick == 0 then
      local enemy_data = increase_enemy_health(global_table_data.enemy_templates[global_table_data[global_table_data.wave_set[cur_level] or "wave_data"][wave_round][enemies_remaining]])
      add(enemies, Enemy:new(global_table_data.map_data[loaded_map].enemy_spawn_location, unpack(enemy_data)))
      enemies_remaining -= 1
    end
    ::spawn_enemy_continue:: 
    yield()
  end
end
