-- defining hyper key (mapped to fn through karabiner)
local hyper = { 'ctrl', 'cmd', 'alt', 'shift' }

-- make alerts look nicer
hs.alert.defaultStyle.strokeColor = { white = 1, alpha = 0 }
hs.alert.defaultStyle.fillColor = { white = 0.05, alpha = 0.75 }
hs.alert.defaultStyle.radius = 10

-- global settings
hs.window.animationDuration = 0
M = 10 -- window margin

APPS = {
  'Alacritty',
  'Terminal',
  'iTerm2',
  'Brave',
  'Google Chrome',
  'Safari',
  'Calendar',
  'WhatsApp',
  'Messages',
  'Spotify',
  'RStudio',
  'Visual Studio Code',
  'Spark',
  'Slack',
  'Notion'
}

-- apps
local term = hs.application.get('Alacritty')

-- watchers
local function hider(appName, eventType)
  if (eventType == hs.application.watcher.hidden) then
    print(appName, eventType)
  end
end

local watcher1 = hs.application.watcher.new(hider)
watcher1:start()

-------------------
-- WINDOW MANAGMENT
-------------------

-- grid
hs.grid.MARGINX    = 10
hs.grid.MARGINY    = 15
hs.grid.GRIDWIDTH  = 2
hs.grid.GRIDHEIGHT = 3
hs.hotkey.bind(hyper, 'g', hs.grid.show)

-- pushing windows around
function push(win, m, x, y, w, h)
  if win == nil then
    local win = hs.window.focusedWindow()
  end
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + max.w * x + m
  f.y = max.y + max.h * y + m
  f.w = max.w * w - 2 * m
  f.h = max.h * h - 2 * m
  win:setFrame(f)
end

function pushPx(win, x, y, w, h)
  if win == nil then
    local win = hs.window.focusedWindow()
  end
  local f = win:frame()
  f.x = x
  f.y = y
  f.w = w
  f.h = h
  win:setFrame(f)
end

full        = { x = 0, y = 0, w = 1, h = 1 }
left        = { x = 0, y = 0, w = .5, h = 1 }
right       = { x = .5, y = 0, w = .5, h = 1 }
top         = { x = 0, y = 0, w = 1, h = .5 }
bottom      = { x = 0, y = .5, w = 1, h = .5 }
topleft     = { x = 0, y = 0, w = .5, h = .5 }
topright    = { x = .5, y = 0, w = .5, h = .5 }
bottomleft  = { x = 0, y = .5, w = .5, h = .5 }
bottomright = { x = .5, y = .5, w = .5, h = .5 }

function pushFull(win, m) push(win, m, 0, 0, 1, 1) end

function pushLeft(win, m) push(win, m, 0, 0, .5, 1) end

function pushRight(win, m) push(win, m, .5, 0, .5, 1) end

function pushTop(win, m) push(win, m, 0, 0, 1, .5) end

function pushBottom(win, m) push(win, m, 0, .5, 1, .5) end

function pushTopLeft(win, m) push(win, m, 0, 0, .5, .5) end

function pushTopRight(win, m) push(win, m, .5, 0, .5, .5) end

function pushBottomLeft(win, m) push(win, m, 0, .5, .5, .5) end

function pushBottomRight(win, m) push(win, m, .5, .5, .5, .5) end

function checkPos(m)
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  if (f.x == max.x + max.w * left.x + m and
      f.y == max.y + max.h * left.y + m and
      f.w == max.w * left.w - 2 * m and
      f.h == max.h * left.h - 2 * m) then
    return 'left'
  elseif (f.x == max.x + max.w * right.x + m and
      f.y == max.y + max.h * right.y + m and
      f.w == max.w * right.w - 2 * m and
      f.h == max.h * right.h - 2 * m) then
    return 'right'
  elseif (f.x == max.x + max.w * top.x + m and
      f.y == max.y + max.h * top.y + m and
      f.w == max.w * top.w - 2 * m and
      f.h == max.h * top.h - 2 * m) then
    return 'top'
  elseif (f.x == max.x + max.w * bottom.x + m and
      f.y == max.y + max.h * bottom.y + m and
      f.w == max.w * bottom.w - 2 * m and
      f.h == max.h * bottom.w - 2 * m) then
    return 'bottom'
  elseif (f.x == max.x + max.w * 0 + m and
      f.y == max.y + max.h * 0 + m and
      f.w == max.w * 1 - 2 * m and
      f.h == max.h * 1 - 2 * m) then
    return 'full'
  elseif (f.x == max.x + max.w * .5 + m and
      f.y == max.y + max.h * .5 + m and
      f.w == max.w * .5 - 2 * m and
      f.h == max.h * .5 - 2 * m) then
    return 'bottom-right'
  elseif (f.x == max.x + max.w * 0 + m and
      f.y == max.y + max.h * .5 + m and
      f.w == max.w * .5 - 2 * m and
      f.h == max.h * .5 - 2 * m) then
    return 'bottom-left'
  elseif (f.x == max.x + max.w * .5 + m and
      f.y == max.y + max.h * 0 + m and
      f.w == max.w * .5 - 2 * m and
      f.h == max.h * .5 - 2 * m) then
    return 'top-right'
  elseif (f.x == max.x + max.w * 0 + m and
      f.y == max.y + max.h * 0 + m and
      f.w == max.w * .5 - 2 * m and
      f.h == max.h * .5 - 2 * m) then
    return 'top-left'
  else
    return 'else'
  end
end

-- left key
function left_key()
  curr = checkPos(M)
  if curr == 'top' then
    pushTopLeft(hs.window.focusedWindow(), M)
  elseif curr == 'right' then
    pushLeft(hs.window.focusedWindow(), M)
  elseif curr == 'bottom-right' then
    pushBottomLeft(hs.window.focusedWindow(), M)
  elseif curr == 'top-right' then
    pushTopLeft(hs.window.focusedWindow(), M)
  else
    pushLeft(hs.window.focusedWindow(), M)
  end
end

-- right key
function right_key()
  local curr = checkPos(M)
  if curr == 'top' then
    pushTopRight(hs.window.focusedWindow(), M)
  elseif curr == 'left' then
    pushRight(hs.window.focusedWindow(), M)
  elseif curr == 'bottom-left' then
    pushBottomRight(hs.window.focusedWindow(), M)
  elseif curr == 'top-left' then
    pushTopRight(hs.window.focusedWindow(), M)
  else
    pushRight(hs.window.focusedWindow(), M)
  end
end

-- up key
function up_key()
  local curr = checkPos(M)
  if curr == 'left' then
    pushTopLeft(hs.window.focusedWindow(), M)
  elseif curr == 'right' then
    pushTopRight(hs.window.focusedWindow(), M)
  elseif curr == 'bottom-left' then
    pushTopLeft(hs.window.focusedWindow(), M)
  elseif curr == 'bottom-right' then
    pushTopRight(hs.window.focusedWindow(), M)
  else
    pushTop(hs.window.focusedWindow(), M)
  end
end

-- down key
function down_key()
  local curr = checkPos(M)
  if curr == 'left' then
    pushBottomLeft(hs.window.focusedWindow(), M)
  elseif curr == 'right' then
    pushBottomRight(hs.window.focusedWindow(), M)
  elseif curr == 'top-left' then
    pushBottomLeft(hs.window.focusedWindow(), M)
  elseif curr == 'top-right' then
    pushBottomRight(hs.window.focusedWindow(), M)
  else
    pushBottom(hs.window.focusedWindow(), M)
  end
end

-- function to toggle fullscreen/ previous position
-- watch changed focus of windows
hs.window.filter.default:subscribe(
  hs.window.filter.windowFocused, function(window, appName)
  local f = window:frame()
  focused = { win = window, x = f.x, y = f.y, w = f.w, h = f.h }
  print("Focused: ", window:application():name())
end)

-- watch resize of windows
hs.window.filter.default:subscribe(
  hs.window.filter.windowMoved, function(window, appName)
  local f = window:frame()
  if checkPos(M) ~= 'full' then
    focused = { win = window, x = f.x, y = f.y, w = f.w, h = f.h }
    print("Moved: ", window:application():name())
  end
end)

function toggle_fullscreen()
  curr = checkPos(M)
  if curr ~= 'full' then
    local win = hs.window.focusedWindow()
    pushFull(win, M)
  else
    local win = hs.window.focusedWindow()
    pushPx(win, focused.x, focused.y, focused.w, focused.h)
  end
end

-- hyper + arrow keys/ yuio to move currently active window
hs.hotkey.bind(hyper, "up", function() up_key() end)
hs.hotkey.bind(hyper, "down", function() down_key() end)
hs.hotkey.bind(hyper, "right", function() right_key() end)
hs.hotkey.bind(hyper, "left", function() left_key() end)
hs.hotkey.bind(hyper, "i", function() up_key() end)
hs.hotkey.bind(hyper, "u", function() down_key() end)
hs.hotkey.bind(hyper, "o", function() right_key() end)
hs.hotkey.bind(hyper, "y", function() left_key() end)

-- hyper + f/enter to toggle full screen
hs.hotkey.bind(hyper, "f", function() toggle_fullscreen() end)
hs.hotkey.bind(hyper, "return", function() toggle_fullscreen() end)

-- open term
hs.hotkey.bind('alt', 'space', function()
  if term then
    if term:isFrontmost() then
      term:hide()
    else
      term:activate()
      pushFull(term:focusedWindow(), M)
    end
  else
    hs.application.launchOrFocus("Alacritty")
    term = hs.application.get("Alacritty")
  end
  hs.window.animationDuration = 0
end)

-- reload configs with HYPER+R
hs.hotkey.bindSpec({ hyper, 'r' }, hs.reload)
hs.notify.show('Hammerspoon started/ reloaded!', '', '')
