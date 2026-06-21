local colors = require("colors")
local settings = require("settings")

sbar.bar({
  position = "top",
  height = settings.bar_height,
  blur_radius = 30,
  color = colors.transparent,
  display = "main",
  topmost = "window",
  padding_left = 12,
  padding_right = 12,
})
