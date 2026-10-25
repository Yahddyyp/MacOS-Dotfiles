local colors = require("colors")
local sbar = require("sketchybar")

local media_cover = sbar.add("item", "media.cover", {
	position = "right",
	icon = {
		string = "􀑪 ",
		font = "Maple Mono NF:16.0",
		color = colors.mauve,
		padding_left = 10,
		padding_right = 4,
	},
	label = {
		padding_left = 6,
		padding_right = 10,
		color = colors.text,
		font = "Maple Mono NF:Bold:14.0",
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

local MEDIA_CLICK = os.getenv("HOME") .. "/.config/sketchybar/helpers/media-click.sh"
media_cover:subscribe("mouse.clicked", function()
	sbar.exec(MEDIA_CLICK)
end)

sbar.delay(0.2, function()
	local WATCHER = os.getenv("HOME") .. "/.config/sketchybar/helpers/media-watcher.pl"
	sbar.exec(WATCHER .. " >/dev/null 2>&1 &")
end)
