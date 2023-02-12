function unpack_table(str)
  local table,start,stack,i={},1,0,1
  while i <= #str do
    if str[i]=="{" then 
      stack+=1
    elseif str[i]=="}"then 
      stack-=1
      if(stack>0)goto unpack_table_continue
      insert_key_val(sub(str,start,i), table)
      start=i+1
      if(i+2>#str)goto unpack_table_continue
      start+=1
      i+=1
    elseif stack==0 then
      if str[i]=="," then
        insert_key_val(sub(str,start,i-1), table)
        start=i+1
      elseif i==#str then 
        insert_key_val(sub(str, start), table)
      end
    end
    ::unpack_table_continue::
    i+=1
  end
  return table
end

function insert_key_val(str, table)
  local key, val = split_key_value_str(str)
  if key == nil then
    add(table, val)
  else  
    table[key] = parse_value(val)
  end
end

function convert_to_array_or_table(str)
  local internal = sub(str, 2, #str-1)
  if (str_contains_char(internal, "{")) return unpack_table(internal) 
  if (not str_contains_char(internal, "=")) return split(internal, ",", true) 
  return unpack_table(internal)
end

function convert_nested_array_to_table(str)

end

function split_key_value_str(str)
  local parts = split(str, "=")
  local key = tonum(parts[1]) or parts[1]
  if str[1] == "{" and str[-1] == "}" then 
    return nil, convert_to_array_or_table(str)
  end
  local val = sub(str, #(tostr(key))+2)
  if val[1] == "{" and val[-1] == "}" then 
    return key, convert_to_array_or_table(val)
  end
  return key, val
end

function parse_value(value)
  if value[1] == "{" and value[-1] == "}" then 
    return unpack_table(sub(value, 2, #value-1))
  elseif value == "true" then 
    return true 
  elseif value == "false" then 
    return false 
  elseif tonum(value) then 
    return tonum(value)
  end
  return value
end

function str_char_count(str, char)
  local count = 0
  for i=1, #str do
    if (str[i] == char) count += 1
  end
  return count
end

function str_contains_char(str, char)
  for i=1, #str do
    if (str[i] == char) return true
  end
end