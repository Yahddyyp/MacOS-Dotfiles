local sbar = require("sketchybar")

local media_cover = sbar.add("item", "media.cover", {
	position = "right",
	icon = {
		string = "􀑪 ",
		font = "Maple Mono NF:16.0",
		color = 0xffcba6f7,
		padding_left = 10,
		padding_right = 4,
	},
	label = {
		padding_left = 6,
		padding_right = 10,
		color = 0xffcdd6f4,
		font = "Maple Mono NF:Bold:14.0",
		max_chars = 50,
	},
	drawing = false,
	update_freq = 2,
	background = {
		color = 0xcc1e1e2e,
		border_color = 0x44cba6f7,
		border_width = 1,
		corner_radius = 8,
		height = 30,
	},
})

media_cover:subscribe("mouse.entered", function()
	sbar.animate("tanh", 3, function()
		media_cover:set({ background = { border_color = 0xffcba6f7 } })
	end)
end)

media_cover:subscribe("mouse.exited", function()
	sbar.animate("tanh", 3, function()
		media_cover:set({ background = { border_color = 0x44cba6f7 } })
	end)
end)

local function update_media()
	sbar.exec("~/.config/sketchybar/helpers/media.sh", function()
		-- media.sh handles the sketchybar update itself
	end)
end

media_cover:subscribe("routine", update_media)
