-- Tower Related
function choose_tower(id)
  selected_menu_tower_id, get_active_menu().enable, shop_enable = id
end

function display_tower_info(tower_id, position, text_color)
  local position_offset, tower_details = position + Vec:new(-1, -31), global_table_data.tower_templates[tower_id]
  local texts = {
    {text = tower_details.name, color = text_color}, 
    {text = tower_details.prefix..": "..tower_details.damage, color = {7, 0}},
    {text = "cost: "..tower_details.cost, color = {(coins >= tower_details.cost) and 3 or 8, 0}}
  }
  local longest_str_len = longest_menu_str(texts)*5+4
  tower_stats_background_rect = BorderRect:new(position_offset, Vec:new(longest_str_len + 20,27), 8, 5, 2)
  BorderRect.draw(tower_stats_background_rect)
  for i, data in pairs(texts) do 
    print_with_outline(data.text, combine_and_unpack({Vec.unpack(position_offset + Vec:new(4, i == 1 and 2 or 7*i))}, data.color))
  end
  spr(
    tower_details.icon_data, 
    combine_and_unpack(
      {Vec.unpack(tower_stats_background_rect.position + Vec:new(longest_str_len, 6))},
      {2, 2}
  ))
end

function display_tower_rotation(menu_pos, position)
  local tower_details, position_offset = global_table_data.tower_templates[selected_menu_tower_id], position + Vec:new(0, -28)
  tower_rotation_background_rect = BorderRect:new(position_offset, Vec:new(24, 24), 8, 5, 2)
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

function rotate_clockwise()
  direction = Vec:new(-direction.y, direction.x)
end

-- Enemy Related
function start_round()
  if (start_next_wave or #enemies ~= 0) return
  start_next_wave,enemies_active = true,true

  local wave_set_for_num = global_table_data.wave_set[cur_level] or "wave_data"
  max_waves = #global_table_data[wave_set_for_num]

  if (wave_round == max_waves and freeplay_rounds == 0) freeplay_rounds = wave_round
  if freeplay_rounds > 0 then
    -- During freeplay, one of the last 3 waves are played randomly. Don't make a level with only 2 waves.
    freeplay_rounds += 1
    wave_round = max_waves
    wave_round -= flr(rnd(3))
  else
    wave_round = wave_round + 1
  end

  enemies_remaining, get_active_menu().enable, shop_enable = #global_table_data[wave_set_for_num][wave_round]
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
  get_active_menu().enable, get_menu(name).enable = false, true
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

function parse_menu_content(content)
  if type(content) == "table" then 
    local cons = {}
    for con in all(content) do
      add(cons, {
        text = con.text,
        color = con.color or {7, 0},
        callback = _ENV[con.callback],
        args = con.args
      }) 
    end
    return cons
  end
  return _ENV[content]()
end

function toggle_mode()
  sfx(48)
  manifest_mode, sell = not manifest_mode
  sell_mode = not sell_mode
end

function swap_to_credits()
  game_state = "credits" 
end

-- Game State Related
function new_game()
  reset_game()
  game_state="map"
  swap_menu_context("map")
end

function load_map(map_id, wave, freeplay)
  pal()
  manifest_mode, auto_start_wave = true
  wave_round = wave or 0
  freeplay_rounds = freeplay or 0
  loaded_map, cur_level = map_id, map_id
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
  music(global_table_data.music_data[cur_level] or 0)

  if wave_round == 0 and freeplay_rounds == 0 then 
    text_scroller.enable = true
    local text_place_holder = global_table_data.dialogue.dialogue_intros[cur_level]
    TextScroller.load(text_scroller, text_place_holder.text, text_place_holder.color)
  else
    load_wave_text()
  end
end

function save_game()
  local start_address = 0x5e00
  -- health
  start_address = save_byte(start_address, player_health)
  -- scrap
  start_address = save_int(start_address, coins)
  -- map id
  start_address = save_byte(start_address, loaded_map)
  -- wave
  start_address = save_byte(start_address, freeplay_rounds == 0 and wave_round or #global_table_data[global_table_data.wave_set[cur_level] or "wave_data"])
  -- current dialouge color palette
  start_address = save_byte(start_address, encode(text_scroller.color[1], text_scroller.color[2], 4))
  -- freeplay round
  start_address = save_int(start_address, freeplay_rounds)
  -- current tower count
  start_address = save_byte(start_address, #towers)
  -- save towers
  for tower in all(towers) do 
    local rot = round_to(tower.rot / 90) % 4
    for i, t in pairs(global_table_data.tower_templates) do 
      if t.type == tower.type then 
        start_address = save_byte(start_address, encode(i, rot, 3))
        start_address = save_byte(start_address, encode(tower.position.x, tower.position.y, 4))
        break
      end
    end
  end
end

function save_state()
  if (enemies_active) return
  save_game()
  get_active_menu().enable = false
  shop_enable = false
end

function save_and_quit()
  if (enemies_active) return
  save_game()
  reset_game()
end

function quit()
  reset_game() 
end

function load_game_state()
  if (@0x5e00 <=0) return
  reset_game()
  get_menu("main").enable = false
  
  local start_address, tower_data, hp, scrap, map_id, wav, freeplay = 0x5e00, {}
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
  -- current dialouge color palette
  text_scroller.color = pack(@start_address)
  start_address += 1
  -- freeplay round
  freeplay = $start_address
  start_address += 4
  -- towers
  local tower_count = @start_address 
  start_address += 1
  for i=1, tower_count do 
    local id, rot = decode(@start_address, 3, 0x7)
    start_address += 1
    local x, y = decode(@start_address, 4, 0xf)
    start_address += 1
    add(tower_data, {
      id, rot + 1, Vec:new(x, y)
    })
  end

  load_map(map_id, wav, freeplay)
  player_health, coins = hp, scrap 
  -- TODO: calculate what the freeplay enemies will be
  for tower in all(tower_data) do 
    direction = Vec:new(global_table_data.direction_map[tower[2]])
    place_tower(tower[3], tower[1])
  end
  game_state = "game"
end