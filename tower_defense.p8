pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
transparent_color_id = 0
animation_data={
spark={
data={
{sprite=10},
{sprite=11},
{sprite=12}
},
ticks_per_frame=2
},
blade={
data={
{sprite=13},
{sprite=14},
{sprite=15}
},
ticks_per_frame=2
},
frost={
data={
{sprite=48},
{sprite=49},
{sprite=50}
},
ticks_per_frame=2
},
burn={
data={
{sprite=51},
{sprite=52},
{sprite=53}
},
ticks_per_frame=2
},
incoming_hint={
data={
{sprite=4,offset={0,0}},
{sprite=4,offset={1,0}},
{sprite=4,offset={2,0}},
{sprite=4,offset={1,0}}
},
ticks_per_frame=5
},
blade_circle={
data={
{sprite=76},
{sprite=77},
{sprite=78},
{sprite=79},
{sprite=78},
{sprite=77}
},
ticks_per_frame=3
},
lightning_lance={
data={
{sprite=108},
{sprite=109}
},
ticks_per_frame=5,
},
hale_howitzer={
data={
{sprite=92},
{sprite=93}
},
ticks_per_frame=5,
},
fire_pit={
data={
{sprite=124},
{sprite=125},
{sprite=126},
{sprite=127},
{sprite=126},
{sprite=125}
},
ticks_per_frame=5,
}
}
map_data={
{
name = "curves",
mget_shift = {0, 0},
enemy_spawn_location={0,1},
enemy_end_location={15,11},
movement_direction={1,0},
},
{
name = "loop",
mget_shift = {16, 0},
enemy_spawn_location={0,1},
enemy_end_location={15,11},
movement_direction={1,0},
},
{
name = "straight",
mget_shift = {32, 0},
enemy_spawn_location={0,1},
enemy_end_location={15,2},
movement_direction={1,0},
},
{
name = "u-turn",
mget_shift = {48, 0},
enemy_spawn_location={0,1},
enemy_end_location={0,6},
movement_direction={1,0},
}
}
map_meta_data={
path_flag_id=0,
non_path_flag_id=1,
map_func_static={0,0,16,16}
}
tower_templates={
{
name = "sword circle",
damage=2,
radius=1,
animation=animation_data.blade_circle,
cost=25,
type = "tack",
attack_delay=10,
icon_data=16,
disable_icon_rotation=true
},
{
name = "lightning lance",
damage=5,
radius=5,
animation=animation_data.lightning_lance,
cost=55,
type = "rail", 
attack_delay=25,
icon_data=18,
disable_icon_rotation=false
},
{
name = "hale howitzer",
damage=5,--freezedelay;!notdamage
radius=2,
animation=animation_data.hale_howitzer,
cost=25,
type = "frontal", 
attack_delay=30,
icon_data=20,
disable_icon_rotation=false
},
{
name = "fire pit",
damage=3,--firetickduration
radius=0,
animation=animation_data.fire_pit,
cost=25,
type = "floor", 
attack_delay=15,
icon_data=22,
disable_icon_rotation=true
}
}
shop_ui_data={
x={128/4-10,128/2-10,128*3/4-10,128-10},
y={128/2},
background=136,
blank=140
}
freeplay_stats={
hp=3,
speed=1,
min_step_delay=3
}
enemy_templates={
{
hp=10,
step_delay=10,
sprite_index=5,
reward=3,
damage=1
},
{
hp=10,
step_delay=8,
sprite_index=6,
reward=5,
damage=2
},
{
hp=25,
step_delay=12,
sprite_index=7,
reward=7,
damage=5
},
{
hp=20,
step_delay=9,
sprite_index=5,
reward=3,
damage=4
},
{
hp=15,
step_delay=5,
sprite_index=6,
reward=5,
damage=5
},
{
hp=70,
step_delay=13,
sprite_index=7,
reward=7,
damage=10
}
}
wave_data={
{1,1,1},
{1,1,1,1,1,1},
{2,1,2,1,2,1,1},
{1,2,2,1,2,2,1,2,2,2},
{3,3,3,3,2,2,2,2,3,2,3,1},
{2,2,2,2,2,2,2,2,1,3,3,3,1,2,2,2,2,2,2},
{3,3,3,3,3,3,1,1,1,3,3,3,3,4,4,4,4,4},
{1,4,4,4,4,4,1,1,1,4,4,4,4,4,1,1,1},
{2,3,2,3,2,3,2,3,2,3,2,3,2,3,4,4,4,4,4},
{1,4,4,4,4,2,2,2,2,2,2,2,5,5,5,5},
{2,5,5,5,5,5,2,3,3,3,3,2,2,4,1},
{5,5,3,3,3,5,2,4,4,4,4,3,3,3,3,2,2,2},
{5,5,3,3,3,5,5,5,5,3,3,3,3,5,5,5,5,5,5},
{3,3,3,3,3,3,5,2,5,2,5,2,6,6,6},
{4,3,4,3,4,3,5,5,5,5,6,6,6,6,6,6,5,5,5,5,5,5,5,5}
}
map_draw_data={
path=0,
other=6
}
sfx_data={
round_complete=10
}
function reset_game()
selector = {
x=64,y=64,
sprite_index=1,
size=1
}
shop_selector = {
sprite_index=128,
size=3,
pos=0
}
map_selector = {
x = shop_ui_data.x[shop_selector.pos + 1]-20,
y=shop_ui_data.y[1]-20,
sprite_index=128,
size=3,
pos=0
}
option_selector = {
sprite_index=2,
size=1,
pos=1
}
coins=50
player_health=100
enemy_required_spawn_ticks=10
tile_display={attack=9,idle=8}
enemies_remaining=10
enemy_current_spawn_tick=0
enemies_active=false
shop_enable=false
option_enable=false
map_menu_enable=true
start_next_wave=false
wave_cor = nil
incoming_hint={}
direction={0,-1}
grid={}--16x16cellstates
towers={}
enemies={}
particles={}
animators = {}
end
Enemy={}
function Enemy:new(location, enemy_data)
obj={
x=location[1],y=location[2],
hp=enemy_data.hp,
step_delay=enemy_data.step_delay,
current_step=0,
is_frozen=false,
frozen_tick=0,
burning_tick=0,
gfx=enemy_data.sprite_index,
reward=enemy_data.reward,
damage=enemy_data.damage,
pos=1
}
setmetatable(obj,self)
self.__index=self
return obj
end
function Enemy:step()
self.current_step=(self.current_step+1)%self.step_delay
if (self.current_step ~= 0) return false
if self.burning_tick > 0 then 
self.burning_tick-=1
self.hp-=2
local px, py, _ = Enemy.get_pixel_location(self)
add(particles, Particle:new(px, py, true, Animator:new(animation_data.burn, false)))
end
if (not self.is_frozen) return true 
self.frozen_tick=max(self.frozen_tick-1,0)
if (self.frozen_tick ~= 0) return false
self.is_frozen=false
return true
end
function Enemy:get_pixel_location()
local n, prev = pathing[self.pos], unpack_to_coord(map_data[loaded_map].enemy_spawn_location)
if (self.pos - 1 >= 1) prev = pathing[self.pos-1]
local px, py = self.x * 8, self.y * 8
if not self.is_frozen then 
px=lerp(prev.x*8,n.x*8,self.current_step/self.step_delay)
py=lerp(prev.y*8,n.y*8,self.current_step/self.step_delay)
end
return px, py, n
end
function Enemy:draw()
if (self.hp <= 0) return
local px, py, n = Enemy.get_pixel_location(self)
local dir = {normalize(n.x - self.x), normalize(n.y - self.y)}
draw_sprite_rotated(self.gfx,px,py,8,parse_direction(dir))
end
function kill_enemy(enemy)
if (enemy.hp > 0) return
coins+=enemy.reward
del(enemies,enemy)
end
function update_enemy_position(enemy)
if (not Enemy.step(enemy)) return
enemy.x=pathing[enemy.pos].x
enemy.y=pathing[enemy.pos].y
enemy.pos+=1
if (enemy.pos < #pathing + 1) return
player_health-=enemy.damage
del(enemies,enemy)
end
function parse_path()
local map_shift = map_data[loaded_map].mget_shift
local map_enemy_spawn_location = map_data[loaded_map].enemy_spawn_location
local path_tiles = {}
for iy=0, 15 do
for ix=0, 15 do
local map_cord = vec2_add(pack(ix, iy), map_shift)
if fget(mget(unpack(map_cord)), map_meta_data.path_flag_id) then 
add(path_tiles, unpack_to_coord(map_cord))
end
end
end
local path = {}
local dir = unpack_to_coord(map_data[loaded_map].movement_direction)
local ending = unpack_to_coord(vec2_add(map_data[loaded_map].enemy_end_location, map_shift))
local cur = {
x = map_enemy_spawn_location[1] + map_shift[1] + dir.x, 
y = map_enemy_spawn_location[2] + map_shift[2] + dir.y
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
state,direction=check_direction(south,{west,east},path_tiles,path)
elseif dir.y == -1 then -- north
state, direction = check_direction(north, {west, east}, path_tiles, path)
end
assert(state, "Failed to find path at: "..cur.x..", "..cur.y.." in direction: "..dir.x..", "..dir.y.." end: "..ending.x..", "..ending.y)
if state then 
dir = {x=normalize(direction.x-cur.x), y=normalize(direction.y-cur.y)}
cur={x=direction.x,y=direction.y}
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
add(path,tile)
else
return check_direction(fail_directions[1], {fail_directions[2]}, path_tiles, path)
end
return true, direction
end
function spawn_enemy()
while enemies_remaining > 0 do 
enemy_current_spawn_tick=(enemy_current_spawn_tick+1)%enemy_required_spawn_ticks
if (is_there_something_at(unpack(map_data[loaded_map].enemy_spawn_location), enemies)) goto spawn_enemy_continue
if (enemy_current_spawn_tick ~= 0) goto spawn_enemy_continue 
enemy_data_from_template = increase_enemy_health(enemy_templates[wave_data[wave_round][enemies_remaining]])
printh(enemy_data_from_template.hp)
add(enemies,Enemy:new(map_data[loaded_map].enemy_spawn_location,enemy_data_from_template))
enemies_remaining-=1
::spawn_enemy_continue::
yield()
end
end
Tower={}
function Tower:new(dx, dy, tower_template_data, direction)
obj={
x=dx,y=dy,
dmg=tower_template_data.damage,
radius=tower_template_data.radius,
attack_delay=tower_template_data.attack_delay,
current_attack_ticks=0,
cost=tower_template_data.cost,
type=tower_template_data.type,
dir=direction,
animator = Animator:new(tower_template_data.animation, true)
}
add(animators, obj.animator)
setmetatable(obj,self)
self.__index=self
return obj 
end
function Tower:attack()
self.current_attack_ticks=(self.current_attack_ticks+1)%self.attack_delay
if (self.current_attack_ticks > 0) return
if self.type == "tack" then
Tower.apply_damage(self,Tower.nova_collision(self))
elseif self.type == "rail" then
Tower.apply_damage(self,Tower.raycast(self))
elseif self.type == "frontal" then 
Tower.freeze_enemies(self,Tower.frontal_collision(self))
elseif self.type == "floor" then 
local hits = {}
add_enemy_at_to_table(self.x,self.y,hits)
foreach(hits, function(enemy) enemy.burning_tick += self.dmg end)
end
end
function Tower:raycast()
if (self.dir[1] == 0 and self.dir[2] == 0) return nil
local hits = {}
for i=1, self.radius do 
add_enemy_at_to_table(self.x+i*self.dir[1],self.y+i*self.dir[2],hits)
end
if (#hits > 0) raycast_spawn(self.x, self.y, self.radius, self.dir, animation_data.spark)
return hits
end
function Tower:nova_collision()
local hits = {}
for y=-self.radius, self.radius do
for x=-self.radius, self.radius do
if (x ~= 0 or y ~= 0) add_enemy_at_to_table(self.x + x, self.y + y, hits)
end
end
if (#hits > 0) nova_spawn(self.x, self.y, self.radius, animation_data.blade)
return hits
end
function Tower:frontal_collision()
local hits = {}
local fx, fy, flx, fly, ix, iy = parse_frontal_bounds(self.radius, unpack(self.dir))
for y=fy, fly, iy do
for x=fx, flx, ix do
if (x ~= 0 or y ~= 0) add_enemy_at_to_table(self.x + x, self.y + y, hits)
end
end
if (#hits > 0) frontal_spawn(self.x, self.y, self.radius, self.dir, animation_data.frost)
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
enemy.is_frozen=true
enemy.frozen_tick=self.dmg
end
end
end
function Tower:draw()
draw_sprite_rotated(
Animator.get_sprite(self.animator),
self.x*8, self.y*8, self.animator.sprite_size,
parse_direction(self.dir)
)
end
function place_tower(x, y)
if (grid[y][x] == "tower") return false
if (coins < tower_templates[shop_selector.pos + 1].cost) return false
local tower_type = tower_templates[shop_selector.pos + 1].type 
if ((tower_type == "floor") ~= (grid[y][x] == "path")) return false 
add(towers, Tower:new(x, y, tower_templates[shop_selector.pos + 1], direction))
coins -= tower_templates[shop_selector.pos + 1].cost
grid[y][x] = "tower"
return true
end
Particle={}
function Particle:new(dx, dy, pixel_perfect, animator_)
obj={
x=dx,y=dy,
is_pxl_perfect = pixel_perfect or false,
animator = animator_,
}
setmetatable(obj,self)
self.__index=self
return obj
end
function Particle:tick()
return Animator.update(self.animator)
end
function Particle:draw()
if (Animator.finished(self.animator)) return 
if self.is_pxl_perfect then 
Animator.draw(self.animator, self.x, self.y)
else
Animator.draw(self.animator, self.x*8, self.y*8)
end
end
function destroy_particle(particle)
if (not Animator.finished(particle.animator)) return
del(particles,particle)
end
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
local fx, fy, flx, fly, ix, iy = parse_frontal_bounds(radius, unpack(direction))
for y=fy, fly, iy do
for x=fx, flx, ix do
if (x ~= 0 or y ~= 0) add(particles, Particle:new(dx + x, dy + y, false, Animator:new(data, false)))
end
end
end
Animator = {} -- updated from tower_defence
function Animator:new(animation_data, continuous_)
obj={
data=animation_data.data,
sprite_size = animation_data.size or 8,
spin_enable=animation_data.rotation,
theta=0,
animation_frame=1,
frame_duration=animation_data.ticks_per_frame,
tick=0,
continuous=continuous_
}
setmetatable(obj,self)
self.__index=self
return obj
end
function Animator:update()
self.tick=(self.tick+1)%self.frame_duration
self.theta=(self.theta+5)%360
if (self.tick ~= 0) return false
if Animator.finished(self) then 
if (self.continuous) Animator.reset(self)
return true
end
self.animation_frame+=1
return false
end
function Animator:finished()
return self.animation_frame >= #self.data
end
function Animator:draw(dx, dy, direction)
local x,y=dx,dy 
if self.data[self.animation_frame].offset then 
x+=self.data[self.animation_frame].offset[1]
y+=self.data[self.animation_frame].offset[2]
end
if self.spin_enable then 
draw_sprite_rotated(
self.data[self.animation_frame].sprite,
x,y,self.sprite_size,self.theta
)
else
spr(self.data[self.animation_frame].sprite,x,y)
end
end
function Animator:get_sprite()
return self.data[self.animation_frame].sprite
end
function Animator:reset()
self.animation_frame=1
end
function print_with_outline(text, dx, dy, text_color, outline_color)
?text,dx-1,dy,outline_color
?text,dx+1,dy
?text,dx,dy-1
?text,dx,dy+1
?text,dx,dy,text_color
end
function print_tower_cost(cost, dx, dy)
print_with_outline("C"..cost, dx, dy, (cost > coins) and 8 or 7, 0)
end
function dist(posA, posB) 
local x = posA.x - posB.x
local y = posA.y - posB.y
return sqrt(x * x + y * y)
end
function normalize(val)
return flr(mid(val, -1, 1))
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
hp=enemy_data.hp+freeplay_stats.hp*freeplay_rounds,
step_delay=max(enemy_data.step_delay-freeplay_stats.speed*freeplay_rounds,freeplay_stats.min_step_delay),
sprite_index=enemy_data.sprite_index,
reward=enemy_data.reward,
damage=enemy_data.damage
}
end
function move_ui_selector(sel, dx, shift, offset, delta)
sel.pos = (sel.pos + ((dx < 0) and -shift or shift)) % #shop_ui_data.x
sel.x=shop_ui_data.x[sel.pos+offset]-delta
end
function is_in_table(val, table)
for i, obj in pairs(table) do
if (val.x == obj.x and val.y == obj.y) return true, i 
end
end
function is_there_something_at(dx, dy, table)
return is_in_table(unpack_to_coord(pack(dx, dy)), table) and true or false
end
function placable_tile_location(x, y)
return fget(mget(x, y), map_meta_data.non_path_flag_id)
end
function add_enemy_at_to_table(dx, dy, table)
for _, enemy in pairs(enemies) do
if (enemy.x == dx and enemy.y == dy) then
add(table,enemy)
return
end
end
end
function draw_sprite_rotated(sprite_id, x, y, size, theta, is_opaque)
local sx, sy = (sprite_id % 16) * 8, (sprite_id \ 16) * 8 
local sine, cosine = sin(theta / 360), cos(theta / 360)
local shift = flr(size*0.5) - 0.5
for mx=0, size-1 do 
for my=0, size-1 do 
local dx, dy = mx-shift, my-shift
local xx = flr(dx*cosine-dy*sine+shift)
local yy = flr(dx*sine+dy*cosine+shift)
if xx >= 0 and xx < size and yy >= 0 and yy <= size then
local id = sget(sx+xx, sy+yy)
if id ~= transparent_color_id or is_opaque then 
pset(x+mx,y+my,id)
end
end
end
end
end
function parse_direction(direction)
local dx, dy = unpack(direction)
if (dx > 0) return 90
if (dx < 0) return 270
if (dy > 0) return 180
if (dy < 0) return 0
end
function vec2_add(vec1, vec2)
return {vec1[1] + vec2[1], vec1[2] + vec2[2]}
end
function unpack_to_coord(vec1)
return {x=vec1[1], y=vec1[2]}
end
function refund_tower_at(dx, dy)
for _, tower in pairs(towers) do
if tower.x == dx and tower.y == dy then
grid[dy][dx] = "empty"
if (tower.type == "floor") grid[dy][dx] = "path"
coins+=tower.cost\2
del(animators, tower.animator) 
del(towers,tower)
end
end
end
function parse_frontal_bounds(radius, dx, dy)
local fx, fy, flx, fly, ix, iy = -1, 1, 1, radius, 1, 1
if dx > 0 then -- east
fx,fy,flx,fly=1,-1,radius,1
elseif dx < 0 then -- west
fx,fy,flx,fly,ix=-1,-1,-radius,1,-1
elseif dy < 0 then -- north
fx,fy,flx,fly,iy=-1,-1,1,-radius,-1
end
return fx, fy, flx, fly, ix, iy
end
function game_draw_loop()
map(
unpack(map_data[loaded_map].mget_shift),
unpack(map_meta_data)
)
foreach(towers, Tower.draw)
foreach(enemies, Enemy.draw)
foreach(particles, Particle.draw)
if (shop_enable) draw_shop_icons()
if shop_enable then 
if option_enable then 
draw_selector(option_selector) 
else
draw_selector(shop_selector) 
end
else
if not enemies_active and incoming_hint ~= nil then 
local dx, dy = unpack(map_data[loaded_map].enemy_spawn_location)
local dir = map_data[loaded_map].movement_direction
for i=1, #incoming_hint do 
Animator.draw(incoming_hint[i], (dx + (i - 1) * dir[1])*8, (dy + (i - 1) * dir[2])*8)
end
end
draw_selector(selector) 
end
print_with_outline("scrap: "..coins, 0, 1, 7, 0)
print_with_outline("♥ "..player_health, 103, 1, 8, 0)
if shop_enable then
print_with_outline("game paused [ wave "..(wave_round+freeplay_rounds).." ]", 18, 16, 7, 0)
print_with_outline("start round", shop_ui_data.x[1]-6, 33, 7, 0)
print_with_outline("map menu", shop_ui_data.x[3]-6, 33, 7, 0)
local len = #tower_templates[shop_selector.pos + 1].name
print_with_outline(tower_templates[shop_selector.pos + 1].name, 128/2-(len*2), 108, 7, 0)
print_with_outline("❎ rotate | 🅾️ close shop", 1, 120, 7, 0)
draw_shop_cost()
draw_shop_dmg()
else
local text = "❎ buy & place | 🅾️ open shop"
if (is_there_something_at(selector.x / 8, selector.y / 8, towers)) text = "❎ sell | 🅾️ open shop"
print_with_outline(text,1,122,7,0)
end
end
function draw_map_overview(map_id, xoffset, yoffset)
local mxshift, myshift = unpack(map_data[map_id].mget_shift)
for y=0, 15 do
for x=0, 15 do
pset(x + xoffset, y + yoffset, placable_tile_location(x + mxshift, y + myshift) and map_draw_data.other or map_draw_data.path)
end
end
end
function draw_shop_icons()
for i=1, #tower_templates do 
local id = tower_templates[i].icon_data
if (tower_templates[i].disable_icon_rotation) then 
rectfill(shop_ui_data.x[i]-20,shop_ui_data.y[1]-20,shop_ui_data.x[i]+3,shop_ui_data.y[1]+3,0)
spr(id,shop_ui_data.x[i]-16,shop_ui_data.y[1]-16,2,2)
else
draw_sprite_rotated(shop_ui_data.background,shop_ui_data.x[i]-20,shop_ui_data.y[1]-20,24,parse_direction(direction),true)
draw_sprite_rotated(id,shop_ui_data.x[i]-16,shop_ui_data.y[1]-16,16,parse_direction(direction))
end
end
end
function draw_shop_cost()
for i=1, #tower_templates do
print_tower_cost(tower_templates[i].cost,shop_ui_data.x[i]-4,shop_ui_data.y[1]-6)
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
spr(sel.sprite_index,sel.x,sel.y,sel.size,sel.size)
end
function _init()
reset_game()
end
function _draw()
cls()
if map_menu_enable then 
for i=1, #map_data do
draw_map_overview(i,shop_ui_data.x[i]-16,shop_ui_data.y[1]-16)
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
function load_game(map_id)
wave_round=0
freeplay_rounds=0
loaded_map=map_id
pathing=parse_path()
shop_selector.x = shop_ui_data.x[shop_selector.pos + 1]-20
shop_selector.y = shop_ui_data.y[1]-20
option_selector.x = shop_ui_data.x[1]-16
option_selector.y = 32
for i=1, 3 do
add(incoming_hint, Animator:new(animation_data.incoming_hint, true))
end
for y=0, 15 do 
grid[y]={}
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
map_menu_enable=false
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
shop_enable=false
return
end
if btnp(❎) then 
if option_enable then 
if option_selector.pos == 1 and not start_next_wave and #enemies == 0 then
start_next_wave=true
enemies_active=true
wave_round+=1
wave_round=min(wave_round,#wave_data)
if wave_round == #wave_data then 
freeplay_rounds+=1
end
enemies_remaining=#wave_data[wave_round]
elseif option_selector.pos == 3 then 
reset_game()
map_menu_enable=true
end
shop_enable=false
return
else
direction={direction[2]*-1,direction[1]}
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
shop_enable=true
return
end
if btnp(❎) then 
local dx = selector.x / 8
local dy = selector.y / 8
if is_there_something_at(dx, dy, towers) then 
refund_tower_at(dx,dy)
else
place_tower(dx,dy)
end
end
local dx, dy = controls()
selector.x = mid(selector.x + dx * 8, 0, 120)
selector.y = mid(selector.y + dy * 8, 0, 120)
if enemies_active then 
foreach(enemies, update_enemy_position)
foreach(towers, Tower.attack)
if start_next_wave then 
start_next_wave=false
wave_cor = cocreate(spawn_enemy)
end
if wave_cor and costatus(wave_cor) != 'dead' then
coresume(wave_cor)
else
wave_cor = nil
end
end
foreach(particles, Particle.tick)
foreach(animators, Animator.update)
if (not enemies_active and incoming_hint) foreach(incoming_hint, Animator.update)
foreach(enemies, kill_enemy)
foreach(particles, destroy_particle)
if enemies_active and #enemies == 0 and enemies_remaining == 0 then 
enemies_active=false
sfx(sfx_data.round_complete)
end
end
__gfx__
112211228887788877700000777777770077000000a99a000001100000033000000000000000000070000000a0000000000000000000d000000d000000d00000
112211228000000878877000788888870788700006999960000110000003300000000000000000007a0a0000aa000a000000a000000d200000d2d00000d20000
2211221180000008788887707888888707888700061111600cc66cc000033000000000000000000097aaa0007aa0aaa09a00aa0000d21d0000d12dd000d12ddd
221122117000000707888887788888870078887000999900ccc11ccc069339600000000000000000097aaa007aaaaaaa097aa770d21002d00d20012d00200120
11221122700000070788888778888887007888700099990000c11c0006333360000000000000000000979aa07a07a0970097a0990d20012dd21002d002100200
112211228000000878888770788888870788870006999960000110000633336000000000000000000009097a970090070009700000d12d000dd21d00ddd21d00
221122118000000878877000788888870788700006899860000110000633336000000000000000000000009709000009000090000002d000000d2d0000002d00
22112211888778887770000077777777007700000000000000c11c00063333600000000000000000000000090000000000000000000d00000000d00000000d00
00000d00001000000000000a0a000000000000000000000000080000000800800000000000077000000770000000000055555555555555555555555500000000
00000dd0011000000000007556000000000770777700777000880008888800880000000000077000000770000000000055666651556666515566665100000000
000002dd1110000000000655556a0000077777c7c77c766700800888998000080000000000077000000770000000000056666661566666615666666100000000
0000022dd110000000000aa55aaaa00007ccc76ccc667c7000008899998800000000000077777000000777770007777756666661566666615666666177777000
00000222dd10000000a99a9a9999940001667667c667cc1000888999a99800080000000077777000000777770007777756666651556666515566666177777000
11111d222dd222dd0a0aaa05500000a0011677c66677c1100888999aa99880880000000000000000000000000007700056666511511111115556666100077000
0111dd2002222dd000a7aaa7777770000116c7c7767cc110888999aaaa9988800000000000000000000000000007700055665166666666666655665100077000
001ddd000022dd000066777aaaa7660001166777c77c111088899aa7aa9998880000000000000000000000000007700051111160000000000611111100077000
00dd2200002dd100000000055000aa0001116c7cc7cc11108899aa77aaa998880777700000077770000000000000000055555560000770000655555500000000
0dd2222002dd11100009999999aaa0a00111cc7c77cc1110089aaa777aa998807888870000788887066666666666666055665160000770000655665100000000
dd222dd222d111110044aaa4444444a001111cc777c11110089aa77777aa99887887700000077887065555555555556056666160000770000656666100000000
000001dd222000000a0000055000000000111c7777c111000899a777777a99887870000000000787065566515566516056666160000770000656666177777777
0000011dd2200000a07777aa7777770000111cccc7c111000889a777777a99807870000000000787065666615666616056666160000770000656666177777777
00000111dd20000006aa77777777776000011cccc7c110000089aa77777a98800700000000000070065666615666616056666160000770000656666100000000
000001100dd000000a666666666a66a0000111cccc11100000089a7777a998000000000000000000065566515566516055665160000770000655665100000000
0000010000d00000aaaaaa0550aa0a0a0000111cc1110000000089a77a9980000000000000000000065111115111116051111160000770000651111100000000
0c667670660007760000c00000800000000080008000008000000000000000000000000000000000065555555555556055555560000000000655555555555555
ccc66c7006777766066ccc0000088000000880080008880000000000000000000000000000000000065566515566516055665566666666666655665155666651
7c67ccc0677767700777c60000008808000888000088800000000000000000000700000000000070065666615666616056666555555555555556666156666661
76766c6707c777706c76776000888800008888000888880000000000000000007870000000000787065666615666616056666651556666515566666156666661
776777767ccc7c60ccc77760008998800889998008a9998000000000000000007870000000000787065566515566516056666661566666615666666156666661
766767c707c7ccc60c7676700899a980089aa98008aaa98000000000000000007887700000077887065111115111116056666661566666615666666156666661
67776ccc07777c7000067700089a7a8008a7aa80087a7a8000000000000000007888870000788887066666666666666055666651556666515566665155666651
007677c6006707770000000000877a8000877a000087780000000000000000000777700000077770000000000000000051111111511111115111111151111111
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0000200000d200000000000d0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d2210d2000dd20000d2210ddd2210d20
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d11d120001d11d000d11d220d11d120
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00110021002dd0110012000d00110
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100d00dd2001200210011001100d00
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021d11d00d11210022d11d00021d11d0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002d0122d0002dd00dd0122d002d0122d
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0000000000d000000002d00d000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067c606000ccc7000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067ccc670077c77700000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000607c77077777c7760000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000177c7107177c7160000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000117c110611771100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111110011111100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111110011111100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111100001111000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090490a00a0940a00000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a09a00a090a90000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a05776009067750a0000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a90000009a0090000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000577600006775000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009aa900009aa9000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006777550057776600000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000094000000490000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000080000000800000000800
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000698600006896000065890000659800
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000068a9160068a916006189a6006198960
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000589a9500598a950059a8850059a9850
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000059a7a50059a7a5005a7a95005a7a950
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000619a1600619a160061a9160061a9160
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000655600006556000065560000655600
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
077770000000000000077770aaaaaaaa00000000000000000000000000000000000000000088880000000000aaaaaaaa00000000000000000000000000000000
788887000000000000788887aaaaaaaa00000000000000000000000000000000000000000888888000000000aaaaaaaa00000000000000000000000000000000
788770000000000000077887aaaaaaaa00000000000000000000000000000000000000008888888800000000aaaaaaaa00000000000000000000000000000000
787000000000000000000787aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
787000000000000000000787aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
070000000000000000000070aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
070000000000000000000070aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
787000000000000000000787aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
787000000000000000000787aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
788770000000000000077887aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
788887000000000000788887aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
077770000000000000077770aaaaaaaa00000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000001010102020201000000000000000000000202020102010000000000000000000002020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1d1d1d1d1d1d1d1d1d1d1d1d1e3f3f3f1d1d1d1d1d1d1d1d1d1d1d1d1e3f3f3f1d1d1d1d1d1d1d1d1d1e3f3f3f3f3f3f1d1d1d1d1d1d1d1e3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f1f2e3f3f3f2f2f2f2f2f2f2f2f2f2f2f1f2e3f3f3f2f2f2f2f2f2f2f2f1f3a1d1d1d1d1d1d2f2f2f2f2f2f1f2e3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d3d3d3d3d3d3d3d3d3d2b2d2e3f3f3f3d3d3d3d3d3d3d3d3d3d2b2d2e3f3f3f3d3d3d3d3d3d3d2b1a2f2f2f2f2f2f2f3d3d3d3d3d2b2d2e3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f2c2d2e3f3f3f3f3f3f3f3f3f3f3f3f3f2c2d2e3f3f3f3f3f3f3f3f3f3f3c3d3d3d3d3d3d3d3d3f3f3f3f3f2c2d2e3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f2c2d2e3f3f3f3f3f3f3f3f3f3f3f3f3f2c2d2e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f2c2d2e3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f1c1d1d1d1d1d3b2d2e3f3f3f3f3f3f3f1c1d1d1d1d1d3b2d3a1d1d1e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f1d1d1d1d1d3b2d2e3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c1b2f2f2f2f2f192e3f3f3f3f3f3f3f2c1b2f2f2f2f2f2d2f2f1f2e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f2f2f2f2f2f2f192e3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c2d2a3d3d3d3d3d3e3f3f3f3f3f3f3f2c2d2a3d3d3d2b2d2a2b2d2e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3d3d3d3d3d3d3d3e3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c2d2e3f3f3f3f3f3f3f3f3f3f3f3f3f2c2d2e3f3f3f2c2d2e2c2d2e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c2d2e3f3f3f3f3f3f3f3f3f3f3f3f3f2c2d2e3f3f3f2c2d2e2c2d2e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c2d3a1d1d1d1d1d1d1d1d1d3f3f3f3f2c2d3a1d1d1d3b2d2e2c2d3a3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f2c1a2f2f2f2f2f2f2f2f2f2f3f3f3f3f2c1a2f2f2f2f2f192e2c1a2f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3c3d3d3d3d3d3d3d3d3d3d3d3f3f3f3f3c3d3d3d3d3d3d3d3e3c3d3d3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00060000250512b051330513d05100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000200c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c043000000000000000
291000000000000000021400202502110020400212002015021400202502110020400212002015021400201002140020200211502040021200201002140020250211002040021250201002140020100214502013
9110000021040211201d11021040230201c11021140230201a0101a140211202301024040241202f1102d04021040211201d11021040230201c11021140230201a0101a140211202301024040241202f1102d040
011000000000000000280452302524015210452302523015280452302524015210452302523015280452302524015210452302523015280452302524015210452302523015280452302524015210452302523015
0601000028650276501b650275000b5001f5001e50021500254502545028450302503230032200321003d7003f7003f5003f7003f70034700327002e6002b2002820025200212001d2001a2001f7000000000000
9f0200000c2400e2401054011530130301503017720187201a7201c72000000000000000000000000000000000000000000000000000000003220032200322003220032200322003220032200312003120031200
0003000027050300501d7001d7001e7001e7001c7001c70021700207001e7001c7001b7001970018700167001470013700117000f7000d7000c70000000000000000000000000000000000000000000000000000
490f0000363502c35032350283502d34022340283301f330243201e32018320183101831000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
480300000a6500000006630000000000000000000000000000000000000000000000000001e600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c000004110071100e110121201a100000000c30000000000000070000700006000060000600006000060000600000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 01464344
00 01024344
00 01024344
00 01024304
00 01024304
00 01424304
00 01424304
00 01420304
00 01420304
00 01020304
00 01020304
00 01020344
00 01020344
00 01420344
02 01420344
