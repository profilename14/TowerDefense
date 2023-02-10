Tower = {}
function Tower:new(dx, dy, tower_template_data, direction)
  obj = { 
    x = dx, y = dy,
    dmg = tower_template_data.damage,
    radius = tower_template_data.radius, 
    attack_delay = tower_template_data.attack_delay,
    current_attack_ticks = 0,
    cost = tower_template_data.cost,
    type = tower_template_data.type,
    dir = direction,
    single_hit = tower_template_data.single_tile_hit_only,
    animator = Animator:new({
      sprite_data = tower_template_data.sprite_data,
      ticks_per_frame = tower_template_data.ticks_per_frame
    }, true),
  }
  add(animators, obj.animator)
  setmetatable(obj, self)
  self.__index = self 
  return obj 
end
function Tower:attack()
  self.current_attack_ticks = (self.current_attack_ticks + 1) % self.attack_delay
  if (self.current_attack_ticks > 0) return

  if self.type == "tack" then
    Tower.apply_damage(self, Tower.nova_collision(self))
  elseif self.type == "rail" then
    Tower.apply_damage(self, Tower.raycast(self))
  elseif self.type == "frontal" then 
    Tower.freeze_enemies(self, Tower.frontal_collision(self))
  elseif self.type == "floor" then 
    local hits = {}
    add_enemy_at_to_table(self.x, self.y, hits)
    foreach(hits, function(enemy) enemy.burning_tick += self.dmg end)
  end
end
function Tower:raycast()
  if (self.dir[1] == 0 and self.dir[2] == 0) return nil
  local hits = {}
  for i=1, self.radius do 
    add_enemy_at_to_table(self.x + i * self.dir[1] , self.y + i * self.dir[2], hits)
  end
  if (#hits > 0) raycast_spawn(self.x, self.y, self.radius, self.dir, particle_data.spark)
  return hits
end
function Tower:nova_collision()
  local hits = {}
  for y=-self.radius, self.radius do
    for x=-self.radius, self.radius do
      if (x ~= 0 or y ~= 0) add_enemy_at_to_table(self.x + x, self.y + y, hits, self.single_hit)
    end
  end
  if (#hits > 0) nova_spawn(self.x, self.y, self.radius, particle_data.blade)
  return hits
end
function Tower:frontal_collision()
  local hits = {}
  local fx, fy, flx, fly, ix, iy = parse_frontal_bounds(self.dir[1], self.dir[2], self.radius)
  for y=fy, fly, iy do
    for x=fx, flx, ix do
      if (x ~= 0 or y ~= 0) add_enemy_at_to_table(self.x + x, self.y + y, hits)
    end
  end
  if (#hits > 0) frontal_spawn(self.x, self.y, self.radius, self.dir, particle_data.frost)
  return hits
end
function Tower:apply_damage(targets)
  for _, enemy in pairs(targets) do
    if (enemy.hp > 0) enemy.hp -= self.dmg
  end
end
function Tower:freeze_enemies(targets)
  for _, enemy in pairs(targets) do
    if not enemy.is_frozen then 
      enemy.is_frozen = true
      enemy.frozen_tick = self.dmg
    end 
  end
end
function Tower:draw()
  local id = parse_direction(Animator.sprite_id(self.animator), self.dir)
  spr(id, self.x * 8, self.y * 8, 1, 1, get_flip_direction(self.dir))
end