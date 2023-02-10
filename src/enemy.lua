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
    add(particles, Particle:new(px, py, true, Animator:new(particle_data.burn, false)))
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
  spr(parse_direction(self.gfx, dir), px, py, 1, 1, get_flip_direction(dir))
end