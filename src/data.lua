-- Game Data -- Modify at will
transparent_color_id = 0
animation_data = {
  spark = {
    data = { 
      {sprite = 10},
      {sprite = 11},
      {sprite = 12}
    },
    ticks_per_frame = 2
  },
  blade = {
    data = { 
      {sprite = 13},
      {sprite = 14},
      {sprite = 15}
    },
    ticks_per_frame = 2
  },
  frost = {
    data = { 
      {sprite = 48},
      {sprite = 49},
      {sprite = 50}
    },
    ticks_per_frame = 2
  },
  burn = {
    data = { 
      {sprite = 51},
      {sprite = 52},
      {sprite = 53}
    },
    ticks_per_frame = 2
  },
  incoming_hint = {
    data = {
      {sprite = 4, offset = {0, 0}},
      {sprite = 4, offset = {1, 0}},
      {sprite = 4, offset = {2, 0}},
      {sprite = 4, offset = {1, 0}}
    },
    ticks_per_frame = 5
  },
  blade_circle = {
    data = {
      {sprite = 76},
      {sprite = 77},
      {sprite = 78},
      {sprite = 79},
      {sprite = 78},
      {sprite = 77}
    },
    ticks_per_frame = 3
  },
  lightning_lance = {
    data = {
      {sprite = 108},
      {sprite = 109}
    },
    ticks_per_frame = 5, 
  },
  hale_howitzer = {
    data = {
      {sprite = 92},
      {sprite = 93}
    },
    ticks_per_frame = 5, 
  }
}
map_data = {
  {
    name = "curves",
    data = {0, 0, 0, 0, 16, 16},
    path_id = {45, 47, 25, 26, 27, 31},
    mget_shift = {0, 0},
    enemy_spawn_location = { 0, 1 },
    enemy_end_location = { 15, 11 },
    movement_direction = {1, 0},
    allowed_tiles = { 28, 29, 30, 42, 43, 44, 46, 58, 59, 60, 61, 62, 63}
  },
  {
    name = "loop",
    data = {16, 0, 0, 0, 16, 16},
    path_id = {45, 47, 25, 26, 27, 31},
    mget_shift = {16, 0},
    enemy_spawn_location = { 0, 1 },
    enemy_end_location = { 15, 11 },
    movement_direction = {1, 0},
    allowed_tiles = { 28, 29, 30, 42, 43, 44, 46, 58, 59, 60, 61, 62, 63}
  },
  {
    name = "straight",
    data = {32, 0, 0, 0, 16, 16},
    path_id = {45, 47, 25, 26, 27, 31},
    mget_shift = {32, 0},
    enemy_spawn_location = { 0, 1 },
    enemy_end_location = { 15, 2 },
    movement_direction = {1, 0},
    allowed_tiles = { 28, 29, 30, 42, 43, 44, 46, 58, 59, 60, 61, 62, 63}
  },
  {
    name = "u-turn",
    data = {48, 0, 0, 0, 16, 16},
    path_id = {45, 47, 25, 26, 27, 31},
    mget_shift = {48, 0},
    enemy_spawn_location = { 0, 1 },
    enemy_end_location = { 0, 6 },
    movement_direction = {1, 0},
    allowed_tiles = { 28, 29, 30, 42, 43, 44, 46, 58, 59, 60, 61, 62, 63}
  }
}  
tower_templates = {
  {
    name = "sword circle",
    damage = 2,
    radius = 1,
    animation = animation_data.blade_circle,
    cost = 25,
    type = "tack",
    attack_delay = 10,
    icon_data = 16,
    disable_icon_rotation = true
  },
  { 
    name = "lightning lance",
    damage = 5,
    radius = 5,
    animation = animation_data.lightning_lance,
    cost = 55,
    type = "rail", 
    attack_delay = 25,
    icon_data = 18,
    disable_icon_rotation = false
  },
  {
    name = "hale howitzer",
    damage = 5, -- freeze delay; ! not damage
    radius = 2,
    animation = animation_data.hale_howitzer, 
    cost = 25,
    type = "frontal", 
    attack_delay = 30,
    icon_data = 20,
    disable_icon_rotation = false
  },
  { 
    name = "fire pit",
    damage = 3, -- fire tick duration
    radius = 0,
    sprite_data = {
      { 124, 124 },
      { 125, 125 },
      { 126, 126 },
      { 127, 127 },
      { 126, 126 },
      { 125, 125 },
    },
    ticks_per_frame = 5, 
    cost = 25,
    type = "floor", 
    attack_delay = 15,
    icon_data = 70,
    disable_icon_rotation = true
  }
}
shop_ui_data = {
  x = {128 / 4 - 10, 128/2 - 10, 128 * 3 / 4 - 10, 128 - 10},
  y = {128 / 2},
  background = 136,
  blank = 140
}
freeplay_stats = {
  hp = 3,
  speed = 1,
  min_step_delay = 3
}
enemy_templates = {
  {
    hp = 10,
    step_delay = 10,
    sprite_index = 5,
    reward = 3,
    damage = 1
  },
  {
    hp = 10,
    step_delay = 8,
    sprite_index = 6,
    reward = 5,
    damage = 2
  },
  {
    hp = 25,
    step_delay = 12,
    sprite_index = 7,
    reward = 7,
    damage = 5
  },
  {
    hp = 20,
    step_delay = 9,
    sprite_index = 5,
    reward = 3,
    damage = 4
  },
  {
    hp = 15,
    step_delay = 5,
    sprite_index = 6,
    reward = 5,
    damage = 5
  },
  {
    hp = 70,
    step_delay = 13,
    sprite_index = 7,
    reward = 7,
    damage = 10
  }
}
wave_data = {
  {1, 1, 1},
  {1, 1, 1, 1, 1, 1},
  {2, 1, 2, 1, 2, 1, 1},
  {1, 2, 2, 1, 2, 2, 1, 2, 2, 2},
  {3, 3, 3, 3, 2, 2, 2, 2, 3, 2, 3, 1},
  {2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 3, 3, 1, 2, 2, 2, 2, 2, 2},
  {3, 3, 3, 3, 3, 3, 1, 1, 1, 3, 3, 3, 3, 4, 4, 4, 4, 4},
  {1, 4, 4, 4, 4, 4, 1, 1, 1, 4, 4, 4, 4, 4, 1, 1, 1},
  {2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 4, 4, 4, 4, 4},
  {1, 4, 4, 4, 4, 2, 2, 2, 2, 2, 2, 2, 5, 5, 5, 5},
  {2, 5, 5, 5, 5, 5, 2, 3, 3, 3, 3, 2, 2, 4, 1},
  {5, 5, 3, 3, 3, 5, 2, 4, 4, 4, 4, 3, 3, 3, 3, 2, 2, 2},
  {5, 5, 3, 3, 3, 5, 5, 5, 5, 3, 3, 3, 3, 5, 5, 5, 5, 5, 5},
  {3, 3, 3, 3, 3, 3, 5, 2, 5, 2, 5, 2, 6, 6, 6},
  {4, 3, 4, 3, 4, 3, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 5, 5, 5, 5, 5, 5, 5, 5}
}
map_draw_data = {
  path = 0,
  other = 6
}
sfx_data = {
  round_complete = 10
}

function reset_game()
  -- Game Data -- Modify at will
  selector = {
    x = 64, y = 64,
    sprite_index = 1,
    size = 1
  }
  shop_selector = {
    sprite_index = 128,
    size = 3,
    pos = 0
  }
  map_selector = {
    x = shop_ui_data.x[shop_selector.pos + 1]-20,
    y = shop_ui_data.y[1]-20,
    sprite_index = 128,
    size = 3,
    pos = 0
  }
  option_selector = {
    sprite_index = 2,
    size = 1,
    pos = 1
  }
  coins = 50
  player_health = 100
  enemy_required_spawn_ticks = 10
  tile_display = {attack=9, idle=8}
  -- Internal Data -- Don't modify
  enemies_remaining = 10
  enemy_current_spawn_tick = 0
  enemies_active = false
  shop_enable = false
  option_enable = false
  map_menu_enable = true
  start_next_wave = false
  wave_cor = nil
  incoming_hint = {}
  direction = { 0, -1 }
  grid = {} -- 16 x 16 cell states
  towers = {}
  enemies = {}
  particles = {}
  animators = {}
end