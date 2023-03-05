Tower = {}
function Tower:new(pos, tower_template_data, direction)
  obj = { 
    position = pos,
    dmg = tower_template_data.damage,
    radius = tower_template_data.radius, 
    attack_delay = tower_template_data.attack_delay,
    current_attack_ticks = 0,
    cooldown = tower_template_data.cooldown,
    manifest_cooldown = -1,
    being_manifested = false,
    being_boosted = false,
    cost = tower_template_data.cost,
    type = tower_template_data.type,
    dir = direction,
    rot = parse_direction(direction),
    enable = true,
    animator = Animator:new(global_table_data.animation_data[tower_template_data.animation_key], true)
  }
  add(animators, obj.animator)
  setmetatable(obj, self)
  self.__index = self 
  return obj 
end
function Tower:attack()
  if (not self.enable) return
  if self.being_manifested and self.type == "tack" then 
    -- ensure damage is awlays updated to the cooldown.
    self.dmg = min(self.manifest_cooldown, 100) / 15
  end

  self.current_attack_ticks = (self.current_attack_ticks + 1) % (self.being_boosted and self.attack_delay \ 2 or self.attack_delay)
  if (self.current_attack_ticks > 0) return
  self.being_boosted = false

  if self.type == "tack" then
    Tower.apply_damage(self, Tower.nova_collision(self), self.dmg)
  elseif self.type == "floor" then 
    local hits = {}
    add_enemy_at_to_table(self.position, hits)
    foreach(hits, function(enemy) enemy.burning_tick += self.dmg end)
  elseif self.type == "sharp" then 
    add(projectiles, Projectile:new(self.position, self.dir, self.rot, global_table_data.projectiles.rocket))
  elseif not self.being_manifested then
    if self.type == "rail" then
      Tower.apply_damage(self, raycast(self.position, self.radius, self.dir), self.dmg)
    elseif self.type == "frontal" then 
      Tower.freeze_enemies(self, Tower.frontal_collision(self))
    end
  end
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
  local tower_type = self.type
  for enemy in all(targets) do
    if enemy.hp > 0 then
      local enemy_type, dmg = enemy.type, damage
      if (tower_type == "tack" and enemy_type == 7) or (tower_type == "rail" and enemy_type == 14) then
        dmg = damage \ 2
      elseif (tower_type == "rail" and enemy_type == 7) or (tower_type == "tack" and enemy_type == 15) then
        dmg *= 2
      end
      enemy.hp -= dmg
    end
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
  if (not self.enable) return
  local p,sprite,theta = self.position*8,Animator.get_sprite(self.animator), (self.type == "sharp" or self.type == "clock") and self.rot or parse_direction(self.dir)
  if (self.being_boosted) spr(global_table_data.boosted_decal, p.x, p.y)
  draw_sprite_shadow(sprite, p, 2, self.animator.sprite_size, theta)
  draw_sprite_rotated(sprite, p, self.animator.sprite_size, theta)
end
function Tower:cooldown()
  self.manifest_cooldown = max(self.manifest_cooldown-1, 0)
end
function Tower:get_cooldown_str()
  if (self.type == "floor" or self.type == "sharp" or self.type == "clock") return "⬆️⬇️⬅️➡️ position"
  if (self.type == "tack") return "❎ activate ("..self.dmg.."D)"
  if (self.manifest_cooldown == 0) return "❎ activate"
  return "❎ activate ("..self.manifest_cooldown.."t)"
end
function Tower:manifested_lightning_blast()
  if (self.manifest_cooldown > 0) return 
  self.manifest_cooldown = self.cooldown

  local dir, anchor, damage = (selector.position / 8 - self.position) / 8, self.position + Vec:new(1, 0), self.dmg * 2

  for i=1, 3 do 
    Tower.apply_damage(self, raycast(anchor, 64, dir), damage)
    anchor.x -= 1
  end
  anchor += Vec:new(2, 1)
  for i=1, 3 do
    Tower.apply_damage(self, raycast(anchor, 64, dir), damage)
    anchor.y -= 1
  end
end
function Tower:manifested_hale_blast()
  if (self.manifest_cooldown > 0) return
  self.manifest_cooldown = self.cooldown

  local pos = selector.position / 8
  local hits, locations = {}, {
    pos, -- center
    pos + Vec:new(0, 1),  -- south
    pos + Vec:new(0, -1), -- north
    pos + Vec:new(-1, 0), -- west
    pos + Vec:new(1, 0)   -- east
  }
  for location in all(locations) do 
    add_enemy_at_to_table(location, hits, true)
  end
  spawn_particles_at(locations, global_table_data.animation_data.frost)
  Tower.freeze_enemies(self, hits)
  Tower.apply_damage(self, hits, self.dmg\4)
end
function Tower:manifested_nova()
  -- The sword circle uses the cooldown system in a different kind of way: it stores the player's 
  -- rotation speed (to a max of 100/25=4 damage, with 3x attack speed).
  self.manifest_cooldown = min(self.manifest_cooldown + 9, 110)
  self.dmg = round_to(min(self.manifest_cooldown, 100) / 15, 2)
end
function Tower:manifested_torch_trap()
  local sel_pos = selector.position / 8
  if (grid[sel_pos.y][sel_pos.x] == "empty") return
  
  local prev = Vec:new(Vec.unpack(self.position))
  if grid[sel_pos.y][sel_pos.x] == "tower" then
    -- torch tower on path
    local shift = Vec:new(global_table_data.map_data[loaded_map].mget_shift)
    if (check_tile_flag_at(sel_pos+shift, 0) and prev ~= sel_pos) self.enable = false
    return
  end

  self.position, grid[sel_pos.y][sel_pos.x], grid[prev.y][prev.x], self.enable = sel_pos, "floor", "path", true
end
function Tower:manifested_sharp_rotation()
  self.dir = (selector.position / 8 - self.position)
  self.rot = acos(self.dir.y / sqrt(self.dir.x*self.dir.x + self.dir.y*self.dir.y))*360-180
  if (self.dir.x > 0) self.rot *= -1
  if (self.rot < 0) self.rot += 360
  if (self.rot > 360) self.rot -= 360
end

function raycast(position, radius, dir)
  if (dir == Vec:new(0, 0)) return
  local hits, particle_locations = {}, {}
  for i=1, radius do 
    local pos = Vec.floor(position + dir * i)
    add(particle_locations, pos)
    add_enemy_at_to_table(pos, hits)
  end
  if (#hits > 0 or manifested_tower_ref) spawn_particles_at(particle_locations, global_table_data.animation_data.spark)
  return hits
end

function manifest_tower_at(position)
  for tower in all(towers) do
    if tower.position == position then 
      if (tower.being_boosted) tower.being_boosted = false
      tower.being_manifested, manifested_tower_ref, manifest_selector.dir = true, tower, 1
      if tower.type == "tack" then
        lock_cursor, tower.attack_delay, tower.dmg = true, 10, 0
      elseif tower.type == "sharp" then
        tower.attack_delay /= 2
      end
    end
  end
end

function unmanifest_tower()
  manifested_tower_ref.being_manifested = false 
  manifest_selector.dir = -1
  lock_cursor = false
  if manifested_tower_ref.type == "tack" then
    local tower_details = global_table_data.tower_templates[1]
    manifested_tower_ref.attack_delay = tower_details.attack_delay
    manifested_tower_ref.dmg = tower_details.damage
  elseif manifested_tower_ref.type == "sharp" then
    manifested_tower_ref.attack_delay = global_table_data.tower_templates[5].attack_delay
  end
  manifested_tower_ref.enable = true
  manifested_tower_ref = nil
end

function place_tower(position, override)
  local tower_details = global_table_data.tower_templates[override or selected_menu_tower_id]
  if not override then 
    -- check if at max tower or 
    -- check if there is a tower here or
    -- check if player has the money or 
    -- spawn the tower
    if (#towers >= 64 or grid[position.y][position.x] == "tower" or coins < tower_details.cost or (tower_details.type == "floor") ~= (grid[position.y][position.x] == "path")) return
    coins -= tower_details.cost
  end
  add(towers, Tower:new(position, tower_details, direction))
  grid[position.y][position.x] = "tower"
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

function draw_line_overlay(tower)
  local color, pos = 8, (tower.position + Vec:new(0.5, 0.5))*8
  local ray = Vec.floor(tower.dir * tower.radius*8 + pos)

  if (tower.type == "clock") then
    color = 11
    for i=1, 16 do 
      for othertower in all(towers) do
        if othertower.position == Vec.floor(tower.position + tower.dir * i) and not othertower.being_manifested and othertower.type ~= "clock" and not othertower.being_boosted then
          othertower.being_boosted = true
          break
        end
      end
    end
  end
  if (ray ~= pos) line(pos.x, pos.y, ray.x, ray.y, color) 
end