Tower = {}
function Tower:new(dx, dy, tower_template_data, direction)
  obj = { 
    position = Vec:new(dx, dy),
    dmg = tower_template_data.damage,
    radius = tower_template_data.radius, 
    attack_delay = tower_template_data.attack_delay,
    current_attack_ticks = 0,
    cost = tower_template_data.cost,
    type = tower_template_data.type,
    dir = Vec:new(direction),
    animator = Animator:new(tower_template_data.animation, true)
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
    add_enemy_at_to_table(self.position, hits)
    foreach(hits, function(enemy) enemy.burning_tick += self.dmg end)
  end
end
function Tower:raycast()
  if (self.dir == Vec:new(0, 0)) return nil
  local hits = {}
  for i=1, self.radius do 
    add_enemy_at_to_table(self.position + self.dir * i, hits)
  end
  if (#hits > 0) raycast_spawn(self.position.x, self.position.y, self.radius, self.dir, animation_data.spark)
  return hits
end
function Tower:nova_collision()
  local hits = {}
  for y=-self.radius, self.radius do
    for x=-self.radius, self.radius do
      if (x ~= 0 or y ~= 0) add_enemy_at_to_table(self.position + Vec:new(x, y), hits)
    end
  end
  if (#hits > 0) nova_spawn(self.position.x, self.position.y, self.radius, animation_data.blade)
  return hits
end
function Tower:frontal_collision()
  local hits = {}
  local fx, fy, flx, fly, ix, iy = parse_frontal_bounds(self.radius, unpack(self.dir))
  for y=fy, fly, iy do
    for x=fx, flx, ix do
      if (x ~= 0 or y ~= 0) add_enemy_at_to_table(self.position + Vec:new(x, y), hits)
    end
  end
  if (#hits > 0) frontal_spawn(self.position.x, self.position.y, self.radius, self.dir, animation_data.frost)
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
  local p = self.position * 8
  draw_sprite_rotated(
    Animator.get_sprite(self.animator),
    p.x, p.y, self.animator.sprite_size,
    parse_direction(self.dir)
  )
end

function place_tower(x, y)
  -- check if there is a tower here
  if (grid[y][x] == "tower") return false
  -- check if player has the money
  if (coins < tower_templates[selected_menu_tower_id].cost) return false
  -- spawn the tower
  local tower_type = tower_templates[selected_menu_tower_id].type 
  if ((tower_type == "floor") ~= (grid[y][x] == "path")) return false 
  add(towers, Tower:new(x, y, tower_templates[selected_menu_tower_id], direction))
  coins -= tower_templates[selected_menu_tower_id].cost
  grid[y][x] = "tower"
  return true
end

function refund_tower_at(dx, dy)
  for _, tower in pairs(towers) do
    if tower.x == dx and tower.y == dy then
      grid[dy][dx] = "empty"
      if (tower.type == "floor") grid[dy][dx] = "path"
      coins += tower.cost \ 2
      del(animators, tower.animator) 
      del(towers, tower)
    end
  end
end
