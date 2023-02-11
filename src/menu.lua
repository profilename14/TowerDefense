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
    enable = false
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

  print_with_outline(self.content[top].text, self.x+10, self.y+7, unpack(self.content[top].color))
  print_with_outline(self.content[self.pos].text, self.x+12, self.y+17, unpack(self.content[self.pos].color))
  print_with_outline(self.content[bottom].text, self.x+10, self.y+27, unpack(self.content[bottom].color))
end
function Menu:update()
  if (not self.enable) return
  Animator.update(self.selector)
  if #self.content > 3 then
    Animator.update(self.up_arrow)
    Animator.update(self.down_arrow)
  end
end
function Menu:move()
  if (not self.enable) return
  local _, dy = controls()
  if (dy == 0) return
  self.pos += dy 
  if (self.pos < 1) self.pos = #self.content 
  if (self.pos > #self.content) self.pos = 1
end
function Menu:invoke()
  if (self.content[self.pos].callback == nil) return
  if self.content[self.pos].args then
    self.content[self.pos].callback(unpack(self.content[self.pos].args))
  else
    self.content[self.pos].callback()
  end
end