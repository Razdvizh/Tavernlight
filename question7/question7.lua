-- I looked up other modules in OTClient and modules tutorial in github wiki to solve this task.
-- video link: https://youtu.be/9EJF_o99bow
local loop = nil
local window = nil
local button = nil

-- Called at the launch of the client.
function init()
  -- Setup functions to call when player connects to the server.
  connect(g_game,
  { 
    onLogin = online,
    onGameEnd = offline 
  })

  -- Instead of creating and destroying user interface each time player enters or leaves the server, construct it once and then manipulate visibility.
  -- This means that invisible user interface will be occupying memory, but changing visibility is faster than creating and destroying UI.
  -- I chose this approach because players value FPS and persistent frametime more than available RAM.

  -- P.S. I understand that this particular example has very low impact on FPS or memory, and difference between these approaches
  -- will be signifcant only on much higher numbers of UI elements.
  window = g_ui.displayUI('question7.otui') -- create main window.
  button = window:getChildById('button')
  window:hide() -- hide it immediately, otherwise it will show up on the login screen.
end

-- Called at the termination of the client (when closing application).
function terminate()
  -- Setup functions to call when player disconnects from the server, I wasn't able to figure out why all other modules put this in `terminate()`.
  disconnect(g_game,
  {
    onLogin = online,
    onGameEnd = offline 
  })

  -- Release resources.
  window:destroy()
  removeEvent(loop)
end

-- Show window and start moving.
function online()
  window:show()
  local UPDATE_RATE_MS = 30 -- rate at which jump button moves, in milliseconds.
  loop = cycleEvent(moveLeft, UPDATE_RATE_MS)
end

-- Hide window and stop moving.
function offline()
  window:hide()
  removeEvent(loop)
end

-- Teleport jump button to random position within window bounds.
function jump()
  button:setMarginTop(math.random(0, window:getHeight() - button:getHeight() * 2.5))
  button:setMarginRight(math.random(0, window:getWidth() - button:getWidth() * 1.75))
end

local function move()
  -- How many pixels jump button will travel per cycle. Positive values go left, negative values go right.
  local DISTANCE = 1
  button:setMarginRight(button:getMarginRight() + DISTANCE)
end

-- Move jump button if within window bounds, jump to random position otherwise.
function moveLeft()
  local bCanMove = button:getMarginRight() + button:getWidth() * 1.5 < window:getWidth()
  if bCanMove then
    move()
  else
    jump()
  end
end
