-- Tower Related
function choose_tower(id)
  selected_menu_tower_id = id
  get_active_menu().enable = false
  shop_enable = false
end

function display_tower_info(tower_id, position, text_color)
  local offset = Vec:new(-1, -31)
  local tower_details = tower_templates[tower_id]
  local texts = {
    {text = tower_details.name}, 
    {text = tower_details.prefix..": "..tower_details.damage}
  }
  BorderRect.resize(
    tower_stats_background_rect,
    position + offset, 
    Vec:new(longest_menu_str(texts)*5 + 24,27
  ))
  BorderRect.draw(tower_stats_background_rect)
  print_with_outline(
    tower_details.name,
    combine_and_unpack({Vec.unpack(position + offset + Vec:new(4, 2))},
    text_color
  ))
  print_with_outline(
    tower_details.prefix..": "..tower_details.damage,
    combine_and_unpack({Vec.unpack(position + offset + Vec:new(4, 14))},
    {7, 0}
  ))
  print_with_outline(
    "cost: "..tower_details.cost, 
    combine_and_unpack({Vec.unpack(position + offset + Vec:new(4, 21))},
    {(coins >= tower_details.cost) and 3 or 8, 0}
  ))
  spr(
    tower_details.icon_data, 
    combine_and_unpack({
      Vec.unpack(tower_stats_background_rect.position + Vec:new(longest_menu_str(texts)*5 + 4, 6))
    },{2, 2}
  ))
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