local colors = require("colors")
local sbar = require("sketchybar")

local VOLUME_HELPER = os.getenv("HOME") .. "/.config/sketchybar/helpers/sketchybar-volume"

local volume_icon = sbar.add("item", "volume_icon", {
	position = "right",

	icon = {
		font = "Maple Mono NF:16.0",
		color = colors.mauve,
	},

	label = {
		font = "Maple Mono NF:Bold:14.0",
		color = colors.text,
	},

	popup = {
		align = "center",

		background = {
			color = colors.surface,
			border_color = colors.surface_border,
			border_width = 1,
			corner_radius = 6,
			height = 18,
		},

		y_offset = -2,
	},
})

local volume_slider = sbar.add("slider", "volume_slider", 150, {
	position = "popup.volume_icon",

	slider = {
		background = {
			height = 4,
			corner_radius = 2,
			color = 0xff313244,
		},

		highlight_color = colors.mauve,

		knob = {
			string = "􀀁",
			drawing = false,
			font = "Maple Mono NF:15.0",
		},
	},

	background = {
		drawing = false,
	},

	padding_left = 10,
	padding_right = 10,
})

local function get_volume_icon(volume)
	if volume == 0 then
		return "􀊣"
	elseif volume <= 29 then
		return "􀊥"
	elseif volume <= 69 then
		return "􀊧"
	else
		return "􀊩"
	end
end

local function set_volume(volume)
	volume = math.floor(tonumber(volume) or 0)
	volume = math.max(0, math.min(100, volume))

	volume_icon:set({
		icon = {
			string = get_volume_icon(volume),
		},
		label = {
			string = volume .. "%",
		},
	})

	volume_slider:set({
		slider = {
			percentage = volume,
		},
	})
end

local function update_volume()
	sbar.exec(VOLUME_HELPER, function(result)
		local volume = tonumber(result)

		if volume then
			set_volume(volume)
		end
	end)
end

local function set_system_volume(volume)
	volume = math.floor(tonumber(volume) or 0)
	volume = math.max(0, math.min(100, volume))

	sbar.exec(VOLUME_HELPER .. " " .. volume, function()
		set_volume(volume)
	end)
end

volume_icon:subscribe("volume_change", function(env)
	local volume = tonumber(env.INFO)

	if volume then
		set_volume(volume)
	end
end)

volume_icon:subscribe("mouse.entered", function()
	volume_icon:set({
		background = {
			border_color = colors.mauve,
			border_width = 1,
		},
	})
end)

volume_icon:subscribe("mouse.exited", function()
	volume_icon:set({
		background = {
			border_color = colors.surface_border,
			border_width = 1,
		},
	})
end)

volume_slider:subscribe("mouse.clicked", function(env)
	local percentage = tonumber(env.PERCENTAGE)

	if percentage then
		set_system_volume(percentage)
	end
end)

local function show_popup()
	volume_icon:set({
		popup = {
			drawing = true,
		},
	})

	volume_slider:set({
		slider = {
			knob = {
				drawing = true,
			},
		},
	})
end

local function hide_popup()
	volume_icon:set({
		popup = {
			drawing = false,
		},
	})

	volume_slider:set({
		slider = {
			knob = {
				drawing = false,
			},
		},
	})
end

volume_icon:subscribe("mouse.clicked", function()
	local info = volume_icon:query()

	if info.popup and info.popup.drawing == "on" then
		hide_popup()
	else
		show_popup()
	end
end)

volume_slider:subscribe("mouse.entered", function()
	volume_slider:set({
		slider = {
			knob = {
				drawing = true,
			},
		},
	})
end)

volume_slider:subscribe("mouse.exited", function()
	volume_slider:set({
		slider = {
			knob = {
				drawing = false,
			},
		},
	})
end)

update_volume()
