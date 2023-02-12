function debug_print_table(table, prefix, log_to_file)
  for k, v in pairs(table) do 
    if type(v) == "table" then 
      printh(prefix.."["..type(v).."]"..k.." = {", log_to_file)
      debug_print_table(v, "__"..prefix, log_to_file)
      printh(prefix.."}", log_to_file)
    else
      printh(prefix.."["..type(v).."]"..k.." = "..v, log_to_file)
    end
  end
end