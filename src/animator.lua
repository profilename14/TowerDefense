Animator = {} -- updated from tower_defence
function Animator:new(animation_data, continuous_)
  obj = {
    data = animation_data.data,
    sprite_size = animation_data.size or 8,
    spin_enable = animation_data.rotation,
    theta = 0,
    animation_frame = 1,
    frame_duration = animation_data.ticks_per_frame,
    tick = 0,
    continuous = continuous_
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Animator:update()
  self.tick = (self.tick + 1) % self.frame_duration
  self.theta = (self.theta + 5) % 360
  if (self.tick ~= 0) return false
  if Animator.finished(self) then 
    if (self.continuous) Animator.reset(self)
    return true
  end
  self.animation_frame += 1
  return false
end
function Animator:finished()
  return self.animation_frame >= #self.data
end
function Animator:draw(dx, dy)
  local x,y=dx,dy 
  -- if positions were given to the animation array
  if self.data[self.animation_frame].offset then 
    x += self.data[self.animation_frame].offset[1]
    y += self.data[self.animation_frame].offset[2]
  end
  if self.spin_enable then 
    draw_sprite_rotated(
      self.data[self.animation_frame].sprite,
      x, y, self.sprite_size, self.theta
    )
  else
    spr(self.data[self.animation_frame].sprite,x,y)
  end
end
function Animator:reset()
  self.animation_frame = 1
end