Vec = {}
function Vec:new(dx, dy)
  local obj = nil
  if type(dx) == "table" then 
    obj = {x=dx[1],y=dx[2]}
  else
    obj={x=dx,y=dy}
  end
  setmetatable(obj, self)
  self.__index = self
  self.__add = function(a, b)
    return Vec:new(a.x+b.x,a.y+b.y)
  end
  self.__sub = function(a, b)
    return Vec:new(a.x-b.x,a.y-b.y)
  end
  self.__mul = function(a, scalar)
    return Vec:new(a.x*scalar,a.y*scalar)
  end
  self.__div = function(a, scalar)
    return Vec:new(a.x/scalar,a.y/scalar)
  end
  self.__eq = function(a, b)
    return (a.x==b.x and a.y==b.y)
  end
  return obj
end
function Vec:unpack()
  return self.x, self.y
end
function Vec:clamp(min, max)
  self.x, self.y = mid(self.x, min, max), mid(self.y, min, max)
end
function Vec:to_str()
  return "("..self.x..", "..self.y..")"
end

function normalize(val)
  if type(val) == "table" then 
    return Vec:new(normalize(val.x), normalize(val.y))
  else
    return flr(mid(val, -1, 1))
  end
end

function lerp(start, last, rate)
  if type(start) == "table" then 
    return lerp(start.x, last.x, rate), lerp(start.y, last.y, rate)
  else
    return start + (last - start) * rate
  end
end