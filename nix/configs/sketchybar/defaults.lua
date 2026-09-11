local colors = require("colors")
local settings = require("settings")

sbar.default({
  padding_left = settings.padding,
  padding_right = settings.padding,
  icon = {
    font = settings.font .. ":16.0",
    color = colors.mauve,
    padding_left = settings.icon_padding,
    padding_right = 4,
  },
  label = {
    font = settings.font .. ":Bold:14.0",
    color = colors.mauve,
    padding_left = settings.label_padding,
    padding_right = settings.icon_padding,
  },
  background = {
    color = colors.surface,
    border_color = colors.surface_border,
    border_width = 1,
    corner_radius = 8,
    height = settings.item_height,
  },
  blur_radius = 30,
})
