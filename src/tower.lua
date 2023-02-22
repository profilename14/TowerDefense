Tower = {}
function Tower:new(pos, tower_template_data, direction)
  obj = { 
    position = pos,
    dmg = tower_template_data.damage,
    radius = tower_template_data.radius, 
    attack_delay = tower_template_data.attack_delay,
    current_attack_ticks = 0,
    manifest_cooldown = -1,
    cost = tower_template_data.cost,
    type = tower_template_data.type,
    dir = direction,
    animator = Animator:new(global_table_data.animation_data[tower_template_data.animation_key], true)
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
    if manifesting_sword and self.position == manifest_location then
      -- ensure damage is awlays updated to the cooldown.
      self.dmg = min(self.manifest_cooldown, 100) / 15
    end
    Tower.apply_damage(self, Tower.nova_collision(self), self.dmg)
  elseif self.type == "rail" then
    Tower.apply_damage(self, Tower.raycast(self), self.dmg)
  elseif self.type == "frontal" then 
    Tower.freeze_enemies(self, Tower.frontal_collision(self))
  elseif self.type == "floor" then 
    local hits = {}
    add_enemy_at_to_table(self.position, hits)
    foreach(hits, function(enemy) enemy.burning_tick += self.dmg end)
  end
end
function Tower:raycast()
  if (self.dir == Vec:new(0, 0)) return
  local hits = {}
  for i=1, self.radius do 
    add_enemy_at_to_table(self.position + self.dir * i, hits)
  end
  if (#hits > 0) raycast_spawn(self.position, self.radius, self.dir, global_table_data.animation_data.spark)
  return hits
end
-- Used for manifestation wby both the Hale Howitzer and Lightning Lance. Can draw whatever type of line required.
function Tower:custom_raycast(in_position, in_radius, in_direction, in_animation)
  if (in_direction == Vec:new(0, 0)) return
  local hits = {}
  for i=1, in_radius do 
    -- Round collision to nearest bit
    local cur_loc = in_position + in_direction * i
    cur_loc.x = ((flr(cur_loc.x))*8 )/ 8
    cur_loc.y = ((flr(cur_loc.y))*8 )/ 8
    add_enemy_at_to_table(cur_loc, hits)
  end
  custom_raycast_spawn(in_position, in_radius, in_direction, in_animation)
  return hits
end
function Tower:nova_collision()
  local hits, rad = {}, self.radius
  for y=-rad, rad do
    for x=-rad, rad do
      if (x ~= 0 or y ~= 0) add_enemy_at_to_table(self.position + Vec:new(x, y), hits)
    end
  end
  if (#hits > 0) nova_spawn(self.position, rad, global_table_data.animation_data.blade)
  return hits
end
function Tower:frontal_collision()
  local hits = {}
  local fx, fy, flx, fly, ix, iy = parse_frontal_bounds(self.radius, self.dir)
  for y=fy, fly, iy do
    for x=fx, flx, ix do
      if (x ~= 0 or y ~= 0) add_enemy_at_to_table(self.position + Vec:new(x, y), hits)
    end
  end
  if (#hits > 0) frontal_spawn(self.position, self.radius, self.dir, global_table_data.animation_data.frost)
  return hits
end
function Tower:apply_damage(targets, damage)
  for enemy in all(targets) do
    if (enemy.hp > 0) enemy.hp -= damage
  end
end
function Tower:freeze_enemies(targets)
  for enemy in all(targets) do
    if not enemy.is_frozen then 
      enemy.is_frozen = true
      enemy.frozen_tick = self.dmg
    end 
  end
end
function Tower:draw()
  local p,sprite,theta = self.position*8,Animator.get_sprite(self.animator),parse_direction(self.dir)
  draw_sprite_shadow(sprite, p, 2, self.animator.sprite_size, theta)
  draw_sprite_rotated(sprite, p, self.animator.sprite_size, theta)
end
function Tower:cooldown()
  if (self.manifest_cooldown >= 0) self.manifest_cooldown -= 1
end
function Tower:manifested_lightning_blast()
  local pos_sel = selector.position/8
  local xnum =  (pos_sel.x - self.position.x) / 8
  local ynum =  (pos_sel.y - self.position.y) / 8
  local direction = Vec:new(xnum, ynum)
  local selfpos = Vec:new(self.position.x+1, self.position.y)
  if (self.manifest_cooldown > 0) return
  self.manifest_cooldown = 5
  for i=1, 3 do
    Tower.apply_damage(self, Tower.custom_raycast(self, selfpos, 64, direction, global_table_data.animation_data.spark), self.dmg * 2)
    selfpos.x -= 1
  end
  selfpos.x += 2
  selfpos.y += 1
  for i=1, 3 do
    Tower.apply_damage(self, Tower.custom_raycast(self, selfpos, 64, direction, global_table_data.animation_data.spark), self.dmg * 2)
    selfpos.y -= 1
  end
end
function Tower:manifested_hale_blast()
  if (self.manifest_cooldown > 0) return
  self.manifest_cooldown = 25

  local pos = selector.position / 8
  local hits = {}
  add_enemy_at_to_table(pos, hits, true)  -- center
  add_enemy_at_to_table(pos + Vec:new(0, 1), hits, true)  -- south
  add_enemy_at_to_table(pos + Vec:new(0, -1), hits, true) -- north
  add_enemy_at_to_table(pos + Vec:new(-1, 0), hits, true) -- west
  add_enemy_at_to_table(pos + Vec:new(1, 0), hits, true)  -- east

  Tower.freeze_enemies(self, hits)
  Tower.apply_damage(self, hits, self.dmg\4)
end
 -- The sword circle uses the cooldown system in a different kind of way: it stores the player's 
 -- rotation speed (to a max of 100/25=4 damage, with 3x attack speed).
function Tower:check_sword_circle_spin()
  self.manifest_cooldown += 7
  self.manifest_cooldown = min(self.manifest_cooldown, 110)
  self.dmg = min(self.manifest_cooldown, 100) / 15
end

function manifest_tower_at(position)
  for tower in all(towers) do
    if tower.position == position then
      manifesting_now = true
      if (tower.type == "tack") then
        manifesting_sword = true
        tower.attack_delay = 10
        tower.dmg = 0
      elseif (tower.type == "rail") then
        manifesting_lightning = true
      elseif (tower.type == "frontal") then
        manifesting_hale = true
      elseif (tower.type == "floor") then
        manifesting_torch = true
      end
      
      manifest_location = position
    end
  end
end

function unmanifest_tower()
  manifesting_now = false
  manifesting_sword = false
  manifesting_lightning = false
  manifesting_hale = false
  manifesting_torch = false
  manifesting_sharp = false
  for tower in all(towers) do
    if tower.position == manifest_location then
      if (tower.type == "tack") then
        local tower_details = global_table_data.tower_templates[1]
        tower.attack_delay = tower_details.attack_delay
        tower.dmg = tower_details.damage
      elseif (tower.type == "rail") then
        --reenable the lightning lance tower to act as normal. If cursor color implementation is changed, change back to normal cursor. 
      elseif (tower.type == "frontal") then
        --reenable the hale howitzer tower to act as normal. If cursor color implementation is changed, change back to normal cursor. 
      elseif (tower.type == "floor") then
        --For the Torch Trap, its position will be updated every frame and the original tower will be deleted as soon as manifestation start. 
        --Ending manifestation will just place the torch trap wherever the cursor currently is.
      end
    end
  end
end

function place_tower(position)
  -- check if there is a tower here
  if (grid[position.y][position.x] == "tower") return false
  local tower_details = global_table_data.tower_templates[selected_menu_tower_id]
  -- check if player has the money
  if (coins < tower_details.cost) return false
  -- spawn the tower
  if ((tower_details.type == "floor") ~= (grid[position.y][position.x] == "path")) return false 
  add(towers, Tower:new(position, tower_details, direction))
  coins -= tower_details.cost
  grid[position.y][position.x] = "tower"
  return true
end

function refund_tower_at(position)
  for tower in all(towers) do
    if tower.position == position then
      grid[position.y][position.x] = "empty"
      if (tower.type == "floor") grid[position.y][position.x] = "path"
      coins += tower.cost \ 1.25
      del(animators, tower.animator) 
      del(towers, tower)
     end
  end
end

function draw_tower_attack_overlay(tower_details)
  local pos = selector.position/8
  palt(global_table_data.palettes.transparent_color_id, false)
  pal(global_table_data.palettes.attack_tile)
  local is_empty = grid[pos.y][pos.x] == "empty"
  local map_shift = Vec:new(global_table_data.map_data[loaded_map].mget_shift)
  if tower_details.type == "tack" and is_empty then 
    draw_nova_attack_overlay(tower_details.radius, pos, map_shift)
  elseif tower_details.type == "rail" and is_empty then 
    draw_ray_attack_overlay(tower_details.radius, pos, map_shift)
  elseif tower_details.type == "frontal" and is_empty then 
    draw_frontal_attack_overlay(tower_details.radius, pos, map_shift)
  elseif tower_details.type == "floor" and grid[pos.y][pos.x] == "path" then 
    spr(mget(Vec.unpack(pos+map_shift)), Vec.unpack(pos*8))
  end
  pal()
end

function draw_nova_attack_overlay(radius, pos, map_shift)
  for y=-radius, radius do
    for x=-radius, radius do
      if x ~=0 or y ~= 0 then 
        local tile_position = pos+Vec:new(x, y)
        spr(mget(Vec.unpack(tile_position+map_shift)), Vec.unpack(tile_position*8))
      end
    end
  end
end

function draw_ray_attack_overlay(radius, pos, map_shift)
  for i=1, radius do 
    local tile_position = pos+direction*i
    spr(mget(Vec.unpack(tile_position+map_shift)), Vec.unpack(tile_position*8))
  end
end

function draw_frontal_attack_overlay(radius, pos, map_shift)
  local fx, fy, flx, fly, ix, iy = parse_frontal_bounds(radius, direction)
  for y=fy, fly, iy do
    for x=fx, flx, ix do
      local tile_position = pos + Vec:new(x, y)
      spr(mget(Vec.unpack(tile_position+map_shift)), Vec.unpack(tile_position*8))
    end
  end
end