-- Caps Lock is remapped to F18 via hidutil (see LaunchAgent
-- ~/Library/LaunchAgents/com.local.KeyRemapping.plist).
--
-- Tap F18         -> Escape
-- Hold F18 + hjkl -> Left / Down / Up / Right

local hyper = hs.hotkey.modal.new()
local hyperUsed = false

hs.hotkey.bind({}, "F18", function()
  hyperUsed = false
  hyper:enter()
end, function()
  hyper:exit()
  if not hyperUsed then
    hs.eventtap.keyStroke({}, "escape", 0)
  end
end)

local arrows = { h = "left", j = "down", k = "up", l = "right" }
for key, arrow in pairs(arrows) do
  local press = function()
    hyperUsed = true
    hs.eventtap.keyStroke({}, arrow, 0)
  end
  hyper:bind({}, key, press, nil, press)
end

hs.alert.show("hammerspoon loaded")
