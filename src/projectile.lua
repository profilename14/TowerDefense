Projectile = {}
function Projectile:new(start, dir_, rot, data)
  local max_d_v = max(abs(dir_.x), abs(dir_.y))
  obj = {
    position = Vec:new(Vec.unpack(start)),
    dir = Vec:new(dir_.x / max_d_v, dir_.y / max_d_v),
    theta = rot,
    sprite = data.sprite,
    size = data.pixel_size,
    height = data.height,
    speed = data.speed,
    damage = data.damage,
    trail = global_table_data.animation_data[data.trail_animation_key],
    lifespan = data.lifespan,
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
  for enemy in all(enemies) do 
    if (Projectile.collider(self, enemy)) add(hits, enemy) 
  end
  if #hits > 0 then 
    for enemy in all(hits) do 
      if enemy.type == 12 then
        enemy.hp -= self.damage / 2
      else
        enemy.hp -= self.damage
      end
      if (enemy.type == 8 and enemy.hp <= 0) del(enemies, enemy)
      -- Currently testing the balance of single target vs hitting all enemies on a tile.
      -- So far seems to be a good solution to the tower's current strength, but for enemy in all is left in case we revert.
      break
    end 
    add(particles, Particle:new(Vec.clone(self.position), false, Animator:new(self.trail)))
    del(projectiles, self)
    return
  end

  add(particles, Particle:new(self.position, false, Animator:new(self.trail)))

  self.position += self.dir
  self.lifespan -= 1
  if self.position.x < 0 or self.position.x > 15 or self.position.y < 0 or self.position.y > 15 or self.lifespan < 0 then 
    del(projectiles, self)
  end
end
function Projectile:draw()
  draw_sprite_shadow(self.sprite, self.position*8, self.height, self.size, self.theta)
  draw_sprite_rotated(self.sprite, self.position*8, self.size, self.theta)
end
function Projectile:collider(enemy)
  local self_center = self.position*self.size + Vec:new(self.size, self.size)/2
  local enemy_center = enemy.position*8 + Vec:new(4, 4)
  local touching_distance = self.size+4
  local dist = Vec.distance(self_center, enemy_center)
  return dist <= touching_distance
end