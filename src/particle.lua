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
  if self.is_pxl_perfect then 
    Animator.draw(self.animator, self.x, self.y)
  else
    Animator.draw(self.animator, self.x*8, self.y*8)
  end
end

function destroy_particle(particle)
  if (not Animator.finished(particle.animator)) return
  del(particles, particle)
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
  local fx, fy, flx, fly, ix, iy = parse_frontal_bounds(radius, unpack(direction))
  for y=fy, fly, iy do
    for x=fx, flx, ix do
      if (x ~= 0 or y ~= 0) add(particles, Particle:new(dx + x, dy + y, false, Animator:new(data, false)))
    end
  end
end