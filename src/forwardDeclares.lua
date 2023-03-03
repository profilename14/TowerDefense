-- Tower Related
function choose_tower(id)
  selected_menu_tower_id = id
  get_active_menu().enable = false
  shop_enable = false
end

function display_tower_info(tower_id, position, text_color)
  local position_offset = position + Vec:new(-1, -31)
  local tower_details = global_table_data.tower_templates[tower_id]
  local texts = {
    {text = tower_details.name}, 
    {text = tower_details.prefix..": "..tower_details.damage}
  }
  local longest_str_len = longest_menu_str(texts)*5+4
  BorderRect.resize(
    tower_stats_background_rect,
    position_offset, 
    Vec:new(longest_str_len + 20,27
  ))
  BorderRect.draw(tower_stats_background_rect)
  print_with_outline(
    tower_details.name,
    combine_and_unpack({Vec.unpack(position_offset + Vec:new(4, 2))},
    text_color
  ))
  print_with_outline(
    texts[2].text,
    combine_and_unpack({Vec.unpack(position_offset + Vec:new(4, 14))},
    {7, 0}
  ))
  print_with_outline(
    "cost: "..tower_details.cost, 
    combine_and_unpack({Vec.unpack(position_offset + Vec:new(4, 21))},
    {(coins >= tower_details.cost) and 3 or 8, 0}
  ))
  spr(
    tower_details.icon_data, 
    combine_and_unpack(
      {Vec.unpack(tower_stats_background_rect.position + Vec:new(longest_str_len, 6))},
      {2, 2}
  ))
end

function display_tower_rotation(menu_pos, position)
  local tower_details = global_table_data.tower_templates[selected_menu_tower_id]
  local position_offset = position + Vec:new(0, -28)
  BorderRect.reposition(tower_rotation_background_rect, position_offset)
  BorderRect.draw(tower_rotation_background_rect)

  local sprite_position = position_offset + Vec:new(4, 4)

  if tower_details.disable_icon_rotation then 
    spr(tower_details.icon_data, combine_and_unpack({Vec.unpack(sprite_position)},{2, 2}))
  else
    draw_sprite_rotated(global_table_data.tower_icon_background,
      position_offset, 24, parse_direction(direction)
    )
    draw_sprite_rotated(tower_details.icon_data, sprite_position, 16, parse_direction(direction))
  end
end

-- Enemy Related
function start_round()
  if (start_next_wave or #enemies ~= 0) return
  start_next_wave,enemies_active = true,true

  if cur_level == 2 then
    wave_set_for_num = 'wave_data_l2'
  elseif cur_level == 3 then
    wave_set_for_num = 'wave_data_l3'
  elseif cur_level == 4 then
    wave_set_for_num = 'wave_data_l4'
  elseif cur_level == 5 then
    wave_set_for_num = 'wave_data_l5'
  else
    wave_set_for_num = 'wave_data'
  end

  max_waves = #global_table_data[wave_set_for_num]

  wave_round = min(wave_round + 1, max_waves)
  if (wave_round == max_waves or freeplay_rounds > 0) freeplay_rounds += 1
  if (freeplay_rounds > 0) then
    -- During freeplay, one of the last 3 waves are played randomly. Don't make a level with only 2 waves.
    wave_round = max_waves
    wave_round -= flr(rnd(3))
  end

  enemies_remaining = #global_table_data[wave_set_for_num][wave_round]
  get_active_menu().enable = false
  shop_enable = false
end

-- Menu Related
function get_active_menu()
  for menu in all(menus) do
    if (menu.enable) return menu
  end
end

function get_menu(name)
  for menu in all(menus) do
    if (menu.name == name) return menu
  end
end

function swap_menu_context(name)
  get_active_menu().enable = false
  get_menu(name).enable = true
end

function longest_menu_str(data)
  local len = 0
  for str in all(data) do
    len = max(len, #str.text)
  end
  return len
end

function get_tower_data_for_menu()
  local menu_content = {}
  for i, tower_details in pairs(global_table_data.tower_templates) do
    add(menu_content, {
      text = tower_details.name,
      color = tower_details.text_color,
      callback = choose_tower, args = {i}
    })
  end
  return menu_content
end

function get_map_data_for_menu()
  local menu_content = {}
  for i, map_data in pairs(global_table_data.map_data) do
    add(menu_content, 
      {text = map_data.name, color = {7, 0}, callback = load_map, args = {i}}
    )
  end
  return menu_content
end

-- Game State Related
function load_map(map_id)
  pal()
  auto_start_wave = false
  manifest_mode = true
  wave_round = 0
  freeplay_rounds = 0
  loaded_map = map_id
  cur_level = map_id
  pathing = parse_path()
  for i=1, 3 do
    add(incoming_hint, Animator:new(global_table_data.animation_data.incoming_hint, true))
  end
  for y=0, 15 do 
    grid[y] = {}
    for x=0, 15 do 
      grid[y][x] = "empty"
      if (not check_tile_flag_at(Vec:new(x, y) + Vec:new(global_table_data.map_data[loaded_map].mget_shift), global_table_data.map_meta_data.non_path_flag_id)) grid[y][x] = "path" 
    end
  end
  if cur_level == 2 then music(15)
  elseif cur_level == 3 then music(22)
  elseif cur_level == 4 then music(27)
  -- Level 1 and 5
  else music(0)
  end
end

function save_game()
  local start_address = 0x5e00
  -- health
  poke(start_address, player_health) 
  start_address += 1
  -- scrap
  local tower_full_refund = 0
  for tower in all(towers) do 
    tower_full_refund += tower.cost
  end
  poke4(start_address, coins + tower_full_refund)
  start_address += 4
  -- map id
  poke(start_address, loaded_map)
  start_address += 1
  -- wave
  poke(start_address, wave_round)
  start_address += 1
  -- freeplay round
  poke4(start_address, freeplay_rounds)
  start_address += 4
end

function load_game()
  local start_address = 0x5e00
  local hp, scrap, map_id, wav, freeplay
  -- health
  hp = @start_address
  start_address += 1
  -- scrap
  scrap = $start_address
  start_address += 4
  -- map id
  map_id = @start_address
  start_address += 1
  -- wave
  wav = @start_address
  start_address += 1
  -- freeplay round
  freeplay = $start_address

  return hp, scrap, map_id, wav, freeplay
end