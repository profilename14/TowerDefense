Animator = {} -- updated from tower_defence
function Animator:new(animation_data, continuous_)
  obj = {
    data = animation_data.data,
    sprite_size = animation_data.size or 8,
    animation_frame = 1,
    frame_duration = animation_data.ticks_per_frame,
    tick = 0,
    dir = 1,
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
  self.animation_frame += self.dir
  return false
end
function Animator:set_direction(dir)
  self.dir = dir
end
function Animator:finished()
  if (self.dir == 1) return self.animation_frame >= #self.data
  return self.animation_frame <= 1
end
function Animator:draw(dx, dy)
  local position,frame = Vec:new(dx, dy),self.data[self.animation_frame]
  -- if positions were given to the animation array
  if (frame.offset) position += Vec:new(frame.offset)
  spr(frame.sprite,Vec.unpack(position))
end
function Animator:get_sprite()
  return self.data[self.animation_frame].sprite
end
function Animator:reset()
  self.animation_frame = 1
end