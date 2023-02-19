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
  if (self.dir == Vec:new(0, 0)) return
  local hits = {}
  for i=1, self.radius do 
    add_enemy_at_to_table(self.position + self.dir * i, hits)
  end
  if (#hits > 0) raycast_spawn(self.position, self.radius, self.dir, global_table_data.animation_data.spark)
  return hits
end
-- Used for manifestation wby both the Hale Howitzer and Lightning Lance (probably). Can draw whatever type of line required.
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
function Tower:apply_damage(targets)
  for enemy in all(targets) do
    if (enemy.hp > 0) enemy.hp -= self.dmg
  end
end
function Tower:apply_custom_damage(damage_in, targets)
  for enemy in all(targets) do
    if (enemy.hp > 0) enemy.hp -= damage_in
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

function Tower:cooldown()
  if (self.manifest_cooldown >= 0) self.manifest_cooldown -= 1
end

function manifest_tower_at(position)
  for tower in all(towers) do
    if tower.position == position then
      manifesting_now = true
      if (tower.type == "tack") then
        manifesting_sword = true
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
        --reenable the sword circle tower to act as normal
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

function Tower:manifested_lightning_blast()
  local pos_sel = selector.position/8
  local xnum =  (pos_sel.x - self.position.x) / 8
  local ynum =  (pos_sel.y - self.position.y) / 8
  local direction = Vec:new(xnum, ynum)
  local selfpos = Vec:new(self.position.x+1, self.position.y)
  if (self.manifest_cooldown > 0) return
  self.manifest_cooldown = 200
  for i=1, 3 do
    Tower.apply_custom_damage(self, self.dmg * 2, Tower.custom_raycast(self, selfpos, 64, direction, global_table_data.animation_data.spark))
    selfpos.x -= 1
  end
  selfpos.x += 2
  selfpos.y += 1
  for i=1, 3 do
    Tower.apply_custom_damage(self, self.dmg * 2, Tower.custom_raycast(self, selfpos, 64, direction, global_table_data.animation_data.spark))
    selfpos.y -= 1
  end
end

function Tower:manifested_hale_blast()
  local pos = selector.position/8
  local southpos = Vec:new(pos.x, pos.y + 2)
  local westpos = Vec:new(pos.x - 2, pos.y)
  local north = Vec:new(0, -1)
  local east  = Vec:new(1, 0)
  if (self.manifest_cooldown > 0) return
  self.manifest_cooldown = 25
  -- Now that we know we can attack, freeze a 3x3 + shaped area and then deal damage in that same area.
  -- Note this will probably deal extra damage to the center area but we can just call that a feature.
  Tower.freeze_enemies(self, Tower.custom_raycast(self, southpos, 3, north, global_table_data.animation_data.frost))
  Tower.freeze_enemies(self, Tower.custom_raycast(self, westpos, 3, east, global_table_data.animation_data.frost))
  Tower.apply_custom_damage(self, self.dmg / 4, Tower.custom_raycast(self, southpos, 3, north, global_table_data.animation_data.frost))
  Tower.apply_custom_damage(self, self.dmg / 4, Tower.custom_raycast(self, westpos, 3, east, global_table_data.animation_data.frost))

end

function check_sword_circle_spin()

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