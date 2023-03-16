TextScroller = {}
function TextScroller:new(char_delay, rect_data, text_data, color_palette)
  local brect = BorderRect:new(unpack(rect_data))
  obj = {
    speed = char_delay,
    rect = brect,
    color = color_palette or {7, 0},
    char_pos = 1,
    text_pos = 1,
    internal_tick = 0,
    is_done = false,
    width = flr(brect.size.x/5),
    max_lines = flr(brect.size.y/16)-5,
    enable = true
  }
  setmetatable(obj, self)
  self.__index = self
  if (text_data) TextScroller.load(obj, text_data)
  return obj
end
function TextScroller:draw()
  if (not self.enable) return
  BorderRect.draw(self.rect)
  local before = sub(self.data[self.text_pos], 1, self.char_pos)
  local lines, end_text = split(before, "\n"), sub(self.data[self.text_pos], self.char_pos+1, #self.data[self.text_pos])

  local result, line, pos, buffer = before, #lines\2, 1, (#lines[#lines])*5
  for i=1, #end_text do 
    if (line > self.max_lines) break
    if (buffer + pos*9) > self.rect.size.x then 
      result ..= "\n\n"
      line += 1
      pos, buffer = 1, 0
    else
      result ..= chr(204 + flr(rnd(49))) 
    end
    pos += 1
  end

  print_with_outline(result, self.rect.position.x + 4, self.rect.position.y + 4, unpack(self.color))
  if self.is_done then 
    print_with_outline("🅾️ to close", self.rect.position.x + 4, self.rect.size.y - 7, unpack(self.color))
  end
end
function TextScroller:update()
  if (not self.enable or self.is_done or self.text_pos > #self.data) return
  self.internal_tick = (self.internal_tick + 1) % self.speed
  if (self.internal_tick == 0) self.char_pos += 1
  self.is_done = self.char_pos > #self.data[self.text_pos]
  if (self.is_done) TextScroller.next(self)
end
function TextScroller:next()
  if (not self.enable or not self.is_done) return 
  if(self.text_pos >= #self.data) return true
  self.text_pos += 1
  self.char_pos, self.is_done = 1
end
function TextScroller:skip()
  if (not self.enable) return 
  self.char_pos = #self.data[self.text_pos]
end
function TextScroller:load(text, color_palette)
  if text == "" then
    self.is_done, self.enable = true
    return
  end
  if (color_palette) self.color = color_palette
  local counter, buffer = self.width, ""
  for _, word in pairs(split(text, " ")) do
    if #word + 1 <= counter then 
      buffer ..= word.." "
      counter -= #word + 1
    elseif #word <= counter then 
      buffer ..= word
      counter -= #word 
    else
      buffer ..= "\n"..word.." "
      counter = self.width - #word + 1 
    end
  end
  self.data, counter = {}, 0
  local line_buffer, lines = "", split(buffer, "\n")
  for i, line in pairs(lines) do
    if counter <= self.max_lines then
      line_buffer ..= line.."\n\n"
      counter += 1
    else 
      add(self.data, line_buffer)
      line_buffer, counter = line.."\n\n", 1
    end
    if (i == #lines) add(self.data, line_buffer)
  end
  self.char_pos, self.text_pos, self.internal_tick, self.is_done = 1, 1, 0
end