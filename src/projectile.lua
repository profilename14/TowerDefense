Projectile = {}
function Projectile:new(start, dir_, rot, data)
  obj = {
    position = Vec.clone(start),
    dir = Vec.clone(dir_),
    theta = rot,
    sprite = data.sprite,
    size = data.pixel_size,
    height = data.height,
    speed = data.speed,
    damage = data.damage,
    trail = global_table_data.animation_data[data.trail_animation_key],
    -- internal
    ticks = 0
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Projectile:update()
  self.ticks = (self.ticks + 1) % self.speed
  if (self.ticks > 0) return

  local hits = {}
  add_enemy_at_to_table(self.position, hits, true)
  if #hits > 0 then 
    for enemy in all(hits) do enemy.hp -= self.damage end 
    add(particles, Particle:new(self.position, false, Animator:new(self.trail)))
    del(projectiles, self)
    return
  end
  add(particles, Particle:new(self.position, false, Animator:new(self.trail)))
  
  self.position += self.dir
  if self.position.x < 0 or self.position.x > 15 or self.position.y < 0 or self.position.y > 15 then 
    del(projectiles, self)
  end
end
function Projectile:draw()
  draw_sprite_shadow(self.sprite, self.position*8, self.height, self.size, self.theta)
  draw_sprite_rotated(self.sprite, self.position*8, self.size, self.theta) 
end