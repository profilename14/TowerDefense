-- Tower Related
function choose_tower(id)
  selected_menu_tower_id = id
  get_active_menu().enable = false
  shop_enable = false
end

-- Enemy Related
function start_round()
  if not start_next_wave and #enemies == 0 then
    start_next_wave = true
    enemies_active = true
    wave_round += 1
    wave_round = min(wave_round, #wave_data)
    if wave_round == #wave_data then 
      freeplay_rounds += 1
    end
    enemies_remaining = #wave_data[wave_round]
    get_active_menu().enable = false
    shop_enable = false
  end
end

-- Menu Related
function get_active_menu()
  for _, menu in pairs(menus) do
    if (menu.enable) return menu
  end
end

function get_menu(name)
  for _, menu in pairs(menus) do
    if (menu.name == name) return menu
  end
end

function swap_menu_context(name)
  local menu = get_active_menu()
  menu.enable = false
  get_menu(name).enable = true
end

function longest_menu_str(data)
  local len = 0
  for _, str in pairs(data) do
    len = max(len, #str.text)
  end
  return len
end