local colors = require("colors")
local icons = require("icons")

local current_app = ""
local update_token = 0

local front_app = sbar.add("item", "front_app", {
  position = "left",
  icon = {
    font = "sketchybar-app-font:Regular:18.0",
    color = colors.mauve,
  },
  label = {
    color = colors.text,
  },
  background = {
    color = colors.base_alpha,
    border_color = colors.base_border,
    border_width = 1,
  },
})

front_app:subscribe("front_app_switched", function(env)
  local app = env.INFO
  if app == nil or app == "" or app == "null" or app == current_app then return end

  update_token = update_token + 1
  local this_token = update_token

  sbar.delay(0.04, function()
    if this_token ~= update_token then return end
    current_app = app
    front_app:set({
      label = { string = app },
      icon = { string = icons[app] },
    })
  end)
end)

front_app:subscribe("mouse.entered", function()
  sbar.animate("tanh", 5, function()
    front_app:set({ background = { border_color = colors.mauve } })
  end)
end)

front_app:subscribe("mouse.exited", function()
  sbar.animate("tanh", 5, function()
    front_app:set({ background = { border_color = colors.base_border } })
  end)
end)
