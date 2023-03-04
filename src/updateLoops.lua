function main_menu_loop()
  local map_dat, enemy_temps = global_table_data.splash_screens[1], global_table_data.enemy_templates

  if pathing == nil then 
    pathing = parse_path(map_dat)
  end

  if not menu_enemy then 
    local enemy = enemy_temps[flr(rnd(#enemy_temps))+1]
    menu_enemy = Enemy:new(
      map_dat.enemy_spawn_location, 
      enemy.hp,
      enemy.step_delay \ 2,
      enemy.sprite_index,
      enemy.type,
      enemy.damage,
      enemy.height
    )
  else 
    update_enemy_position(menu_enemy, true)
  end

  Menu.update(get_menu("main"))

  if btnp(❎) then 
    Menu.invoke(get_menu("main"))
  end

  Menu.move(get_menu("main"))
end

function credits_loop()
  if (btnp(🅾️)) game_state = "menu"

  for i=1, 5 do 
    credit_y_offsets[i] -= 1
    if credit_y_offsets[i] < -15 then 
      credit_y_offsets[i] += 157
    end
  end
end

function map_loop()
  local map_menu = get_menu("map")
  Menu.update(map_menu)

  if btnp(❎) then
    Menu.invoke(map_menu)
    map_menu.enable = false
    game_state = "game" 
    return
  end

  Menu.move(map_menu)
end

function shop_loop()
  foreach(menus, Menu.update)
  
  if btnp(🅾️) then -- disable shop
    if get_active_menu().prev == nil then 
      shop_enable = false
      menus[1].enable = false
      return
    else
      swap_menu_context(get_active_menu().prev)
    end
  end
  if btnp(❎) then 
    Menu.invoke(get_active_menu())
  end

  foreach(menus, Menu.move)
end

function game_loop()
  if (auto_start_wave) start_round()

  if btnp(🅾️) then
    if manifested_tower_ref == nil then
      shop_enable = true
      get_menu("game").enable = true
      return
    else
      unmanifest_tower()
    end
  end
  if btnp(❎) then 
    if manifested_tower_ref then
      local type = manifested_tower_ref.type
      if type == "tack" then 
        Tower.manifested_nova(manifested_tower_ref)
      elseif type == "rail" then 
        Tower.manifested_lightning_blast(manifested_tower_ref)
      elseif type == "frontal" then 
        Tower.manifested_hale_blast(manifested_tower_ref)
      end
    else 
      local position = selector.position/8
      if is_in_table(position, towers, true) then 
        if manifest_mode then
          manifest_tower_at(position)
        else
          refund_tower_at(position)
        end
      else
        place_tower(position)
      end
    end
  end

  -- Allow for cursor movement if not locked
  if not lock_cursor then
    selector.position += Vec:new(controls()) * 8
    Vec.clamp(selector.position, 0, 120)
    if manifested_tower_ref then 
      if manifested_tower_ref.type == "floor" then
        Tower.manifested_torch_trap(manifested_tower_ref)
      elseif manifested_tower_ref.type == "sharp" then 
        Tower.manifested_sharp_rotation(manifested_tower_ref)
      end
    end
  end

  foreach(towers, Tower.cooldown)

  -- update objs
  if enemies_active then 
    foreach(enemies, update_enemy_position)
    foreach(towers, Tower.attack)
    if start_next_wave then 
      start_next_wave = false
      wave_cor = cocreate(spawn_enemy)
    end
    if wave_cor and costatus(wave_cor) ~= 'dead' then
      coresume(wave_cor)
    else
      wave_cor = nil
    end
  end
  -- update particles
  foreach(projectiles, Projectile.update)
  foreach(particles, Particle.tick)
  foreach(animators, Animator.update)
  if (not enemies_active and incoming_hint) foreach(incoming_hint, Animator.update)
  -- clean up tables
  foreach(enemies, kill_enemy)
  foreach(particles, destroy_particle)
  if enemies_active and #enemies == 0 and enemies_remaining == 0 then 
    enemies_active = false 
    --Our old round finished sound got lost in the music additions.
    sfx(global_table_data.sfx_data.round_complete)
    coins += 15
  end
end
