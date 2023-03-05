-- Tower Defence v1.14.10
-- By Jeren (Code), Jasper (Art, Code, & Design), Jimmy (Art & Music), and Kaoushik (Code)

-- Forward Declaring Functions
#include src/forwardDeclares.lua
-- Game Data and Reset Data
#include src/data.lua
-- Classes
#include src/enemy.lua
#include src/tower.lua
#include src/particle.lua
#include src/animator.lua
#include src/borderRect.lua
#include src/menu.lua
#include src/vec.lua
#include src/projectile.lua
#include src/textScroller.lua

-- Pico8
function _init() 
  --[[preserve]]global_table_data=unpack_table(global_table_str)
  --[[preserve]]cartdata(global_table_data.cart_name)
  reset_game() 
end

function _draw()
  cls()
  if game_state == "menu" then 
    main_menu_draw_loop()
  elseif game_state == "credits" then 
    credits_draw_loop()
  elseif game_state == "map" then 
    map_draw_loop()
  elseif game_state == "game" then 
    game_draw_loop()
  end
  TextScroller.draw(text_scroller)
end

function _update()
  if game_state == "menu" then 
    main_menu_loop()
  elseif game_state == "credits" then 
    credits_loop()
  elseif game_state == "map" then 
    map_loop()
  elseif game_state == "game" then 
    if (player_health <= 0) reset_game()
    if shop_enable then shop_loop() else game_loop() end
  end
  -- TEMP
  TextScroller.update(text_scroller)

  if btnp(🅾️) then 
    if TextScroller.next(text_scroller) then 
      text_scroller.enable = false
    end
  end
end

-- Draw Calls
#include src/draw_calls.lua
-- Update Calls
#include src/updateLoops.lua
-- Utility/Helper Functions
#include src/helpers.lua
#include src/serialization.lua
-- #include src/debug.lua
