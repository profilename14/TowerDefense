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