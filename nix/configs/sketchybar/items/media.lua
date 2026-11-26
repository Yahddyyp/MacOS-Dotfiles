local colors = require("colors")
local sbar = require("sketchybar")
local settings = require("settings")

local HOME = os.getenv("HOME")
local HELPERS = HOME .. "/.config/sketchybar/helpers"

local media_cover = sbar.add("item", "media.cover", {
	position = "right",
	icon = {
		string = "􀑪 ",
		font = settings.font .. ":16.0",
		color = colors.mauve,
		padding_left = 10,
		padding_right = 4,
	},
	label = {
		padding_left = 6,
		padding_right = 10,
		color = colors.text,
		font = settings.font .. ":Bold:14.0",
		max_chars = 50,
	},
	drawing = false,
	background = {
		color = colors.surface,
		border_color = colors.surface_border,
		border_width = 1,
		corner_radius = 8,
		height = 30,
	},
})

media_cover:subscribe("mouse.clicked", function()
	sbar.exec(HELPERS .. "/media-click.sh")
end)

sbar.delay(0.2, function()
	sbar.exec("/usr/bin/perl " .. HELPERS .. "/media-watcher.pl >/dev/null 2>&1 &")
end)
