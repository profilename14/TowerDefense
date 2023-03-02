-- Tower Defence v1.14.10
-- By Jeren (Code), Jasper (Art & Sound), Jimmy (Art & Music)

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
function _init() reset_game() end

function _draw()
  cls()
  TextScroller.draw(text_scroller)
  -- if map_menu_enable then map_draw_loop() else game_draw_loop() end
end

function _update()
  -- TEMP
  TextScroller.update(text_scroller)

  if btnp(❎) then 
    if TextScroller.next(text_scroller) then 
      if flag then 
        text_scroller.enable = false
      else
        TextScroller.load(text_scroller, "chicken butt", {8, 1})
        flag = true
      end
    end
  end
  -- if map_menu_enable then 
  --   map_loop()
  -- else 
  --   if (player_health <= 0) reset_game()
  --   if shop_enable then shop_loop() else game_loop() end
  -- end
end

-- Draw Calls
#include src/draw_calls.lua
-- Update Calls
#include src/updateLoops.lua
-- Utility/Helper Functions
#include src/helpers.lua
#include src/serialization.lua
-- #include src/debug.lua
