function map_loop()
  local map_menu = get_menu("map")
  Menu.update(map_menu)

  if btnp(❎) then
    Menu.invoke(map_menu)
    map_menu.enable = false
    map_menu_enable = false 
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
      menus[1].enable = true
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
    if manifesting_torch == true then
      -- FOR KAOUSHIK:
      -- Torch Trap logic goes here. Update the towers location to wherever its going by deleting the previous torch trap and making another.
      -- Make sure that deleting the torch trap in the previous location doesn't destroy other torch traps on the road! You might require a
      -- special flag set when you move onto another torch trap tile (and unset when you move onto empty space).
      -- To save space if this ends up taking a hefty amount of lines, consider putting this a function in tower.lua with the other 3 towers.
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
  foreach(particles, Particle.tick)
  foreach(animators, Animator.update)
  if (not enemies_active and incoming_hint) foreach(incoming_hint, Animator.update)
  -- clean up tables
  foreach(enemies, kill_enemy)
  foreach(particles, destroy_particle)
  if enemies_active and #enemies == 0 and enemies_remaining == 0 then 
    enemies_active = false 
    sfx(global_table_data.sfx_data.round_complete)
    coins += 15
  end
end
