Particle = {}
function Particle:new(pos, pixel_perfect, animator_)
  obj = {
    position = pos,
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
    Animator.draw(self.animator, Vec.unpack(self.position))
  else
    Animator.draw(self.animator, Vec.unpack(self.position*8))
  end
end

function destroy_particle(particle)
  if (not Animator.finished(particle.animator)) return
  del(particles, particle)
end

-- particle spawing
function raycast_spawn(position, range, dir, data)
  for i=1, range do 
    add(particles, Particle:new(position + dir * i, false, Animator:new(data, false)))
  end
end

function nova_spawn(position, radius, data)
  for y=-radius, radius do
    for x=-radius, radius do
      if (x ~= 0 or y ~= 0) add(particles, Particle:new(position + Vec:new(x, y), false, Animator:new(data, false)))
    end
  end
end

function frontal_spawn(position, radius, dir, data)
  local fx, fy, flx, fly, ix, iy = parse_frontal_bounds(radius, dir)
  for y=fy, fly, iy do
    for x=fx, flx, ix do
      if (x ~= 0 or y ~= 0) add(particles, Particle:new(position + Vec:new(x, y), false, Animator:new(data, false)))
    end
  end
end