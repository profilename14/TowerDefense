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

function destroy_particle(particle)
  if (not Animator.finished(particle.animator)) return
  del(particles, particle)
end