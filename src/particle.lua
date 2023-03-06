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
  local pos = self.position
  if (not self.is_pxl_perfect) pos = pos * 8
  Animator.draw(self.animator, Vec.unpack(pos))
end

function destroy_particle(particle)
  if (not Animator.finished(particle.animator)) return
  del(particles, particle)
end

-- particle spawing
function spawn_particles_at(locations, animation_data)
  for location in all(locations) do 
    add(particles, Particle:new(location, false, Animator:new(animation_data, false)))
  end
end
