Menu = {}
function Menu:new(menu_name, previous_menu, dx, dy, selector_data, up_arrow_data, down_arrow_data, menu_content, base_color, border_color, text_color, menu_thickness)
  obj = {
    name = menu_name,
    prev = previous_menu,
    x = dx, y = dy,
    selector = Animator:new(selector_data, true),
    up_arrow = Animator:new(up_arrow_data, true),
    down_arrow = Animator:new(down_arrow_data, true),
    content = menu_content,
    width = 10 + 5*longest_menu_str(menu_content),
    height = dy + 38,
    thickness = menu_thickness,
    -- colors
    base = base_color,
    border = border_color,
    text = text_color,
    -- internals
    pos = 1,
    enable = false,
    ticks = 5,
    max_ticks = 5,
    dir = 0
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Menu:draw()
  if (not self.enable) return

  local top, bottom = self.pos-1, self.pos+1
  if (top < 1) top = #self.content 
  if (bottom > #self.content) bottom = 1
  
  rectfill(
    self.x-self.thickness, self.y-self.thickness, 
    self.x+self.width+self.thickness, self.height+self.thickness, 
    self.border
  )
  rectfill(self.x, self.y, self.x+self.width, self.height, self.base)

  Animator.draw(self.selector, self.x+2, self.y+15)
  if #self.content > 3 then
    Animator.draw(self.up_arrow, self.width/2, self.y-self.thickness)
    Animator.draw(self.down_arrow, self.width/2, self.height-self.thickness)
  end

  local rate = self.ticks / self.max_ticks
  local base_pos_x = self.x+10
  if self.ticks < self.max_ticks then 
    if self.dir > 0 then 
      local lx, ly = menu_scroll(self.x, 12, 10, self.y, 0, 7, 17, self.dir, rate)
      print_with_outline(self.content[top].text, lx, ly, unpack(self.content[top].color))
    elseif self.dir < 0 then 
      local lx, ly = menu_scroll(self.x, 12, 10, self.y, 17, 27, 37, self.dir, rate)
      print_with_outline(self.content[bottom].text, lx, ly, unpack(self.content[bottom].color))
    end 
  else
    print_with_outline(self.content[top].text, base_pos_x, self.y+7, unpack(self.content[top].color))
    print_with_outline(self.content[bottom].text, base_pos_x, self.y+27, unpack(self.content[bottom].color))
  end

  local lmx, lmy = menu_scroll(self.x, 10, 12, self.y, 7, 17, 27, self.dir, rate)
  print_with_outline(self.content[self.pos].text, lmx, lmy, unpack(self.content[self.pos].color))

end
function Menu:update()
  if (not self.enable) return
  Animator.update(self.selector)
  if #self.content > 3 then
    Animator.update(self.up_arrow)
    Animator.update(self.down_arrow)
  end
  if (self.ticks >= self.max_ticks) return
  self.ticks += 1
end
function Menu:move()
  if (not self.enable) return
  if (self.ticks < self.max_ticks) return

  local _, dy = controls()
  if (dy == 0) return
  self.pos += dy 
  self.dir = dy
  if (self.pos < 1) self.pos = #self.content 
  if (self.pos > #self.content) self.pos = 1
  self.ticks = 0
end
function Menu:invoke()
  if (self.content[self.pos].callback == nil) return
  if self.content[self.pos].args then
    self.content[self.pos].callback(unpack(self.content[self.pos].args))
  else
    self.content[self.pos].callback()
  end
end

function menu_scroll(x, dx1, dx2, y, dy1, dy2, dy3, dir, rate)
  local lx = lerp(x+dx1, x+dx2, rate)
  local ly = y + dy2
  if dir < 0 then 
    ly = lerp(y + dy1, y + dy2, rate)
  elseif dir > 0 then 
    ly = lerp(y + dy3, y + dy2, rate)
  end
  return lx, ly
end
