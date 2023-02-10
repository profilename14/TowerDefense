-- Tower Defence v1.14.10
-- By Jeren (Code), Jasper (Art & Sound), Jimmy (Art & Music)
#include src/data.lua
-- Classes
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

Particle = {}
function Particle:new(dx, dy, pixel_perfect, animator_)
  obj = {
    x = dx, y = dy,
    is_pxl_perfect = pixel_perfect or false,
    animator = animator_,
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Particle:tick()
  return Animator.update(self.animator)
end
function Particle:draw()
  if (Animator.finished(self.animator)) return 
  local id = Animator.sprite_id(self.animator)
  if self.is_pxl_perfect then 
    spr(id, self.x, self.y)
  else
    spr(id, self.x*8, self.y*8)
  end
end

Animator = {}
function Animator:new(data, continuous_)
  obj = {
    sprite_data = data.sprite_data,
    animation_frame = 1,
    frame_duration = data.ticks_per_frame,
    tick = 0,
    continuous = continuous_
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Animator:update()
  self.tick = (self.tick + 1) % self.frame_duration
  if (self.tick ~= 0) return false
  if Animator.finished(self) then 
    if (self.continuous) Animator.reset(self)
    return true
  end
  self.animation_frame += 1
  return false
end
function Animator:finished()
  return self.animation_frame >= #self.sprite_data
end
function Animator:sprite_id()
  return self.sprite_data[self.animation_frame]
end
function Animator:reset()
  self.animation_frame = 1
end

-- Pico8
function _init()
  reset_game()
end

function _draw()
  cls()
  if map_menu_enable then 
    for i=1, #map_data do
      draw_map_overview(i, shop_ui_data.x[i]-16, shop_ui_data.y[1]-16)
    end
    print_with_outline("choose a map to play", 25, 1, 7, 0)
    local len = #map_data[map_selector.pos + 1].name
    print_with_outline(map_data[map_selector.pos + 1].name, 128/2-(len*2), 108, 7, 0)
    draw_selector(map_selector)
  else
    game_draw_loop()
  end
end

function _update()
  if map_menu_enable then 
    map_loop()
  else 
    if (player_health <= 0) reset_game()
    if shop_enable then shop_loop() else game_loop() end
  end
end

-- Game
function load_game(map_id)
  wave_round = 0
  freeplay_rounds = 0
  loaded_map = map_id
  pathing = parse_path()
  shop_selector.x = shop_ui_data.x[shop_selector.pos + 1]-20
  shop_selector.y = shop_ui_data.y[1]-20
  option_selector.x = shop_ui_data.x[1]-16
  option_selector.y = 32
  for i=1, 3 do
    add(incoming_hint, Animator:new(hud_data.incoming_hint, true))
  end
  for y=0, 15 do 
    grid[y] = {}
    for x=0, 15 do 
      grid[y][x] = "empty"
      local mx = x + map_data[loaded_map].mget_shift[1]
      local my = y + map_data[loaded_map].mget_shift[2]
      if (not placable_tile_location(mx, my)) grid[y][x] = "path" 
    end
  end
  music(0)
end

function map_loop()
  if btnp(❎) then 
    load_game(map_selector.pos + 1)
    map_menu_enable = false 
    return
  end

  local dx, dy = controls()
  if dx < 0 then 
    map_selector.pos = (map_selector.pos - 1) % #map_data
    map_selector.x = shop_ui_data.x[map_selector.pos + 1]-20
  elseif dx > 0 then 
    map_selector.pos = (map_selector.pos + 1) % #map_data
    map_selector.x = shop_ui_data.x[map_selector.pos + 1]-20
  end
end

function shop_loop()
  if btnp(🅾️) then -- disable shop
    shop_enable = false
    return
  end
  if btnp(❎) then 
    if option_enable then 
      if option_selector.pos == 1 and not start_next_wave and #enemies == 0 then
        start_next_wave = true
        enemies_active = true
        wave_round += 1
        wave_round = min(wave_round, #wave_data)
        if wave_round == #wave_data then 
          freeplay_rounds += 1
        end
        enemies_remaining = #wave_data[wave_round]
      elseif option_selector.pos == 3 then 
        reset_game()
        map_menu_enable = true
      end
      shop_enable = false
      return
    else
      direction = { direction[2] * -1, direction[1] }
    end
  end

  local dx, dy = controls()
  if (dy ~= 0) option_enable = not option_enable
  
  if (dx == 0) return
  if option_enable then
    move_ui_selector(option_selector, dx, 2, 0, 16) 
  else
    move_ui_selector(shop_selector, dx, 1, 1, 20)
  end
end

function game_loop()
  if btnp(🅾️) then
    shop_enable = true
    return
  end
  if btnp(❎) then 
    local dx = selector.x / 8
    local dy = selector.y / 8
    if is_there_something_at(dx, dy, towers) then 
      refund_tower_at(dx, dy)
    else
      place_tower(dx, dy)
    end
  end

  local dx, dy = controls()
  selector.x = clamp(selector.x + dx * 8, 0, 120)
  selector.y = clamp(selector.y + dy * 8, 0, 120)

  -- update objs
  if enemies_active then 
    foreach(enemies, update_enemy_position)
    foreach(towers, Tower.attack)
    if start_next_wave then 
      start_next_wave = false
      wave_cor = cocreate(spawn_enemy)
    end
    if wave_cor and costatus(wave_cor) != 'dead' then
      coresume(wave_cor)
    else
      wave_cor = nil
    end
  end
  -- update particles
  foreach(particles, Particle.tick)
  foreach(animators, Animator.update)
  if (not enemies_active and incoming_hint) foreach(incoming_hint, Animator.update)
  -- clean up tables
  foreach(enemies, kill_enemy)
  foreach(particles, destroy_particle)
  if enemies_active and #enemies == 0 and enemies_remaining == 0 then 
    enemies_active = false 
    sfx(sfx_data.round_complete)
  end
end

function spawn_enemy()
  while enemies_remaining > 0 do 
    enemy_current_spawn_tick = (enemy_current_spawn_tick + 1) % enemy_required_spawn_ticks
    if (is_there_something_at(map_data[loaded_map].enemy_spawn_location[1], map_data[loaded_map].enemy_spawn_location[2], enemies)) goto spawn_enemy_continue
    if (enemy_current_spawn_tick ~= 0) goto spawn_enemy_continue 
    enemy_data_from_template = increase_enemy_health(enemy_templates[wave_data[wave_round][enemies_remaining]])
    printh(enemy_data_from_template.hp)
    add(enemies, Enemy:new(map_data[loaded_map].enemy_spawn_location, enemy_data_from_template))
    -- else
    --   local enemy_data_from_template = enemy_templates[wave_data[wave_round][enemies_remaining]]
    --   add(enemies, Enemy:new(map_data[loaded_map].enemy_spawn_location, enemy_data_from_template))
    -- end
    enemies_remaining -= 1
    ::spawn_enemy_continue:: 
    yield()
  end
end

function kill_enemy(enemy)
  if (enemy.hp > 0) return
  coins += enemy.reward
  del(enemies, enemy)
end

function destroy_particle(particle)
  if (not Animator.finished(particle.animator)) return
  del(particles, particle)
end

function update_enemy_position(enemy)
  if (not Enemy.step(enemy)) return
  enemy.x = pathing[enemy.pos].x
  enemy.y = pathing[enemy.pos].y
  enemy.pos += 1
  if (enemy.pos < #pathing + 1) return
  player_health -= enemy.damage 
  del(enemies, enemy)
end

function parse_path()
  local path_tiles = {}
  for iy=0, 16 do
    for ix=0, 16 do
      local mx = ix + map_data[loaded_map].mget_shift[1]
      local my = iy + map_data[loaded_map].mget_shift[2]
      for _, id in pairs(map_data[loaded_map].path_id) do
        if (mget(mx, my) == id) then 
          add(path_tiles, { x = mx, y = my })
        end
      end
    end
  end

  local path = {}
  local dir = {x=map_data[loaded_map].movement_direction[1],y=map_data[loaded_map].movement_direction[2]}
  local ending = {
    x=map_data[loaded_map].enemy_end_location[1] + map_data[loaded_map].mget_shift[1], 
    y=map_data[loaded_map].enemy_end_location[2] + map_data[loaded_map].mget_shift[2]
  }
  local cur = {
    x = map_data[loaded_map].enemy_spawn_location[1] + map_data[loaded_map].mget_shift[1] + dir.x, 
    y = map_data[loaded_map].enemy_spawn_location[2] + map_data[loaded_map].mget_shift[2] + dir.y
  }
  while not (cur.x == ending.x and cur.y == ending.y) do 
    local north = {x=cur.x, y=cur.y-1}
    local south = {x=cur.x, y=cur.y+1}
    local west = {x=cur.x-1, y=cur.y}
    local east = {x=cur.x+1, y=cur.y}
    local state = false
    local direction = nil
    if dir.x == 1 then -- east 
      state, direction = check_direction(east, {north, south}, path_tiles, path)
    elseif dir.x == -1 then -- west
      state, direction = check_direction(west, {north, south}, path_tiles, path)
    elseif dir.y == 1 then -- south
      state, direction = check_direction(south, {west, east}, path_tiles, path)
    elseif dir.y == -1 then -- north
      state, direction = check_direction(north, {west, east}, path_tiles, path)
    end
    assert(state, "Failed to find path at: "..cur.x..", "..cur.y.." in direction: "..dir.x..", "..dir.y.." end: "..ending.x..", "..ending.y)
    if state then 
      dir = {x=normalize(direction.x-cur.x), y=normalize(direction.y-cur.y)}
      cur = {x=direction.x, y=direction.y}
    else 
    end
  end
  return path
end

function check_direction(direction, fail_directions, path_tiles, path)
  if (direction == nil) return false, nil
  local state, index = is_in_table(direction, path_tiles)
  if state then
    local tile = {
      x = path_tiles[index].x - map_data[loaded_map].mget_shift[1],
      y = path_tiles[index].y - map_data[loaded_map].mget_shift[2]
    } 
    add(path, tile)
  else 
    return check_direction(fail_directions[1], {fail_directions[2]}, path_tiles, path)
  end
  return true, direction
end

function place_tower(x, y)
  -- check if there is a tower here
  if (grid[y][x] == "tower") return false
  -- check if player has the money
  if (coins < tower_templates[shop_selector.pos + 1].cost) return false
  -- spawn the tower
  local tower_type = tower_templates[shop_selector.pos + 1].type 
  if ((tower_type == "floor") ~= (grid[y][x] == "path")) return false 
  add(towers, Tower:new(x, y, tower_templates[shop_selector.pos + 1], direction))
  coins -= tower_templates[shop_selector.pos + 1].cost
  grid[y][x] = "tower"
  return true
end

-- Text Helpers
function print_with_outline(text, dx, dy, text_color, outline_color)
  print(text, dx - 1, dy, outline_color)
  print(text, dx + 1, dy, outline_color)
  print(text, dx, dy-1, outline_color)
  print(text, dx, dy+1, outline_color)
  print(text, dx, dy, text_color)
end

function print_tower_cost(cost, dx, dy)
  local color = 7
  if (cost > coins) color = 8
  print_with_outline("C"..cost, dx, dy, color, 0)
end

-- Utility/Helper Functions
function dist(posA, posB) 
  local x = posA.x - posB.x
  local y = posA.y - posB.y
  return sqrt(x * x + y * y)
end

function clamp(val, min_val, max_val)
  return min(max(min_val, val), max_val)
end 

function normalize(val)
  return flr(clamp(val, -1, 1))
end

function lerp(start, last, rate)
  return start + (last - start) * rate
end

function controls()
  if btnp(⬆️) then return 0, -1
  elseif btnp(⬇️) then return 0, 1
  elseif btnp(⬅️) then return -1, 0
  elseif btnp(➡️) then return 1, 0
  end
  return 0, 0
end

function increase_enemy_health(enemy_data)
  return {
    hp = enemy_data.hp + freeplay_stats.hp * freeplay_rounds,
    step_delay = max(enemy_data.step_delay - freeplay_stats.speed * freeplay_rounds, freeplay_stats.min_step_delay),
    sprite_index = enemy_data.sprite_index,
    reward = enemy_data.reward,
    damage = enemy_data.damage
  }
end

function move_ui_selector(sel, dx, shift, offset, delta)
  local inc = shift
  if (dx < 0) inc = -shift
  sel.pos = (sel.pos + inc) % #shop_ui_data.x
  sel.x = shop_ui_data.x[sel.pos + offset]-delta
end

function is_in_table(val, table)
  for i=1, #table do 
    if (val.x == table[i].x and val.y == table[i].y) return true, i 
  end
  return false, -1
end

function get_flip_direction(direction)
  return (direction[1] == -1), (direction[2] == -1)
end

function placable_tile_location(x, y, map_id)
  local map_index = loaded_map
  if (map_id ~= nil) map_index = map_id
  local sprite_id = mget(x, y)
  for i=1, #map_data[map_index].allowed_tiles do 
    if (sprite_id == map_data[map_index].allowed_tiles[i]) return true
  end
  return false
end

function add_enemy_at_to_table(dx, dy, table, single_only)
  for _, enemy in pairs(enemies) do
    if (enemy.x == dx and enemy.y == dy) then
      add(table, enemy)
      if (single_only) return
    end
  end
end

function parse_direction(data, dir)
  if dir[1] == 0 and dir[2] ~= 0 then 
    return data[1]
  elseif dir[1] ~= 0 and dir[2] == 0 then
    return data[2]
  end
end

function is_there_something_at(dx, dy, table)
  for _, obj in pairs(table) do
    if (obj.x == dx and obj.y == dy) return true 
  end
  return false
end

function refund_tower_at(dx, dy)
  for _, tower in pairs(towers) do
    if tower.x == dx and tower.y == dy then
      grid[dy][dx] = "empty"
      if (tower.type == "floor") grid[dy][dx] = "path"
      coins += flr(tower.cost / 2) 
      del(animators, tower.animator) 
      del(towers, tower)
    end
  end
end

function parse_frontal_bounds(dx, dy, radius)
  -- Default South
  local fx, fy, flx, fly, ix, iy = -1, 1, 1, radius, 1, 1

  if dx > 0 then -- east
    fx, fy, flx, fly = 1, -1, radius, 1
  elseif dx < 0 then -- west
    fx, fy, flx, fly, ix = -1, -1, -radius, 1, -1
  elseif dy < 0 then -- north
    fx, fy, flx, fly, iy = -1, -1, 1, -radius, -1
  end
  return fx, fy, flx, fly, ix, iy
end

-- particle spawing
function raycast_spawn(dx, dy, range, direction, data)
  for i=1, range do 
    add(particles, Particle:new(dx + (i * direction[1]), dy + (i * direction[2]), false, Animator:new(data, false)))
  end
end

function nova_spawn(dx, dy, radius, data)
  for y=-radius, radius do
    for x=-radius, radius do
      if (x ~= 0 or y ~= 0) add(particles, Particle:new(dx + x, dy + y, false, Animator:new(data, false)))
    end
  end
end

function frontal_spawn(dx, dy, radius, direction, data)
  local fx, fy, flx, fly, ix, iy = parse_frontal_bounds(direction[1], direction[2], radius)
  for y=fy, fly, iy do
    for x=fx, flx, ix do
      if (x ~= 0 or y ~= 0) add(particles, Particle:new(dx + x, dy + y, false, Animator:new(data, false)))
    end
  end
end

-- Draw Calls
function game_draw_loop()
  map(
    map_data[loaded_map].data[1], 
    map_data[loaded_map].data[2], 
    map_data[loaded_map].data[3], 
    map_data[loaded_map].data[4], 
    map_data[loaded_map].data[5], 
    map_data[loaded_map].data[6]
  )
  -- towers
  foreach(towers, Tower.draw)
  -- enemies
  foreach(enemies, Enemy.draw)
  -- particles
  foreach(particles, Particle.draw)
  -- shop
  if (shop_enable) draw_shop_icons()
  -- selector
  if shop_enable then 
    if option_enable then 
      draw_selector(option_selector) 
    else
      draw_selector(shop_selector) 
    end
  else 
    if not enemies_active and incoming_hint ~= nil then 
      local dx = map_data[loaded_map].enemy_spawn_location[1]
      local dy = map_data[loaded_map].enemy_spawn_location[2]
      local dir = map_data[loaded_map].movement_direction
      for i=1, #incoming_hint do 
        spr(Animator.sprite_id(incoming_hint[i]), (dx + (i - 1) * dir[1])*8, (dy + (i - 1) * dir[2])*8) 
      end
    end
    draw_selector(selector) 
  end
  -- UI
  print_with_outline("scrap: "..coins, 0, 1, 7, 0)
  print_with_outline("♥ "..player_health, 103, 1, 8, 0)
  if shop_enable then
    print_with_outline("game paused [ wave "..(wave_round+freeplay_rounds).." ]", 18, 16, 7, 0)
    print_with_outline("start round", shop_ui_data.x[1]-6, 33, 7, 0)
    print_with_outline("map menu", shop_ui_data.x[3]-6, 33, 7, 0)
    local len = #tower_templates[shop_selector.pos + 1].name
    print_with_outline(tower_templates[shop_selector.pos + 1].name, 128/2-(len*2), 108, 7, 0)
    print_with_outline("❎ rotate | 🅾️ close shop", 1, 120, 7, 0)
    draw_attack_tiles(tower_templates[shop_selector.pos + 1], 128/2 - 8, shop_ui_data.y[1] + 24)
    draw_shop_cost()
    draw_shop_dmg()
  else 
    local text = "❎ buy & place | 🅾️ open shop"
    if (is_there_something_at(selector.x / 8, selector.y / 8, towers)) text = "❎ sell | 🅾️ open shop"
    print_with_outline(text, 1, 122, 7, 0)
  end
end

function draw_map_overview(map_id, xoffset, yoffset)
  local mxshift = map_data[map_id].mget_shift[1]
  local myshift = map_data[map_id].mget_shift[2]
  for y=0, 15 do
    for x=0, 15 do
      local is_not_path = placable_tile_location(x + mxshift, y + myshift, map_id)
      if is_not_path then 
        pset(x + xoffset, y + yoffset, map_draw_data.other)
      else 
        pset(x + xoffset, y + yoffset, map_draw_data.path)
      end
    end
  end
end

function draw_attack_tiles(tower_template, dx, dy)
  if tower_template.type == "tack" then 
    for y=-tower_template.radius, tower_template.radius do
      for x=-tower_template.radius, tower_template.radius do
        if (x ~= 0 or y ~= 0) spr(tile_display.attack, dx + x * 8, dy + y * 8)
      end
    end
    spr(tower_template.sprite_data[1][2], dx, dy)
  elseif tower_template.type == "rail" then 
    local shift = (tower_template.radius + 1) / 2 - 1
    for x=1, tower_template.radius do
      if (x > 0) spr(tile_display.attack, dx + x * 8 - (shift * 8), dy)
    end
    spr(tower_template.sprite_data[1][2], dx - (shift * 8), dy)
  elseif tower_template.type == "frontal" then 
    for y=-1, 1 do
      for x=1, tower_template.radius do 
        spr(tile_display.attack, dx + x * 8, dy + y * 8)
      end
    end
    spr(tower_template.sprite_data[1][2], dx, dy)
  elseif tower_template.type == "floor" then 
    spr(tile_display.attack, dx, dy)
    spr(tower_template.sprite_data[1][2], dx, dy)
  end
end

function draw_shop_icons()
  local fx, fy = get_flip_direction(direction)
  for i=1, #tower_templates do 
    palt(0, false)
    palt(14, false)
    if (tower_templates[i].disable_icon_rotation) then 
      spr(shop_ui_data.blank, shop_ui_data.x[i] - 20, shop_ui_data.y[1] - 20, 3, 3)
      palt()
      spr(parse_direction(tower_templates[i].icon_data, direction), shop_ui_data.x[i] - 16, shop_ui_data.y[1] - 16, 2, 2)
    else
      spr(parse_direction(shop_ui_data.background, direction), shop_ui_data.x[i] - 20, shop_ui_data.y[1] - 20, 3, 3, fx, fy)
      palt()
      spr(parse_direction(tower_templates[i].icon_data, direction), shop_ui_data.x[i] - 16, shop_ui_data.y[1] - 16, 2, 2, fx, fy)
    end
  end
end

function draw_shop_cost()
  for i=1, #tower_templates do
    print_tower_cost(tower_templates[i].cost, shop_ui_data.x[i] - 4, shop_ui_data.y[1] - 6)
  end
end

function draw_shop_dmg()
  for i=1, #tower_templates do
    local type = tower_templates[i].type
    if type == "tack" or type == "rail" then 
      print_with_outline("D"..tower_templates[i].damage, shop_ui_data.x[i] - 4, shop_ui_data.y[1], 8, 0)
    else 
      print_with_outline("T"..tower_templates[i].damage, shop_ui_data.x[i] - 4, shop_ui_data.y[1], 12, 0)
    end
  end
end

function draw_selector(sel)
  spr(sel.sprite_index, sel.x, sel.y, sel.size, sel.size)
end