local colors = require("colors")
local sbar = require("sketchybar")

local show_time = false
local is_charging = false

local battery = sbar.add("item", "battery", {
	position = "right",

	icon = {
		color = colors.mauve,
	},

	label = {
		color = colors.text,
	},

	popup = {
		align = "center",
		y_offset = -2,
		background = {
			color = colors.surface,
			border_color = colors.surface_border,
			border_width = 1,
			corner_radius = 8,
		},
	},
})

local battery_info = sbar.add("item", "battery.info", {
	position = "popup.battery",

	icon = {
		string = "􀋦",
		color = colors.mauve,
		padding_left = 10,
	},

	label = {
		string = "Checking...",
		color = colors.text,
		font = "Maple Mono NF:Bold:13.0",
		width = 130,
		padding_right = 10,
	},

	background = {
		drawing = false,
	},
})

local function get_battery_icon(percentage, charging)
	if charging then
		return "􀋦"
	elseif percentage >= 90 then
		return "􀛨"
	elseif percentage >= 60 then
		return "􀺸"
	elseif percentage >= 30 then
		return "􀺶"
	elseif percentage >= 10 then
		return "􀛩"
	else
		return "􀛪"
	end
end

local function update_battery()
	sbar.exec("pmset -g batt", function(info)
		if not info then
			return
		end

		local percentage = info:match("(%d+)%%")
		if not percentage then
			return
		end

		percentage = tonumber(percentage)
		is_charging = info:find("AC Power") ~= nil

		if is_charging then
			show_time = false
		end

		local icon = get_battery_icon(percentage, is_charging)
		local time_remaining = info:match("(%d+:%d+)")

		local display = percentage .. "%"

		if not is_charging and show_time and time_remaining and time_remaining ~= "0:00" then
			display = time_remaining
		end

		sbar.animate("tanh", 6, function()
			battery:set({
				icon = {
					string = icon,
				},
				label = {
					string = display,
				},
			})
		end)

		-- Popup
		if is_charging then
			battery_info:set({
				icon = {
					string = "􀋦",
				},
				label = {
					string = "Charging",
				},
			})
		elseif time_remaining and time_remaining ~= "0:00" then
			battery_info:set({
				icon = {
					string = "􀐫",
				},
				label = {
					string = time_remaining .. " remaining",
				},
			})
		else
			battery_info:set({
				icon = {
					string = icon,
				},
				label = {
					string = "Calculating...",
				},
			})
		end
	end)
end

battery:subscribe("system_woke", update_battery)
battery:subscribe("power_source_change", update_battery)

battery:subscribe("mouse.entered", function()
	sbar.animate("tanh", 5, function()
		battery:set({
			background = {
				border_color = colors.mauve,
			},
		})
	end)
end)

battery:subscribe("mouse.exited", function()
	sbar.animate("tanh", 5, function()
		battery:set({
			background = {
				border_color = colors.surface_border,
			},
		})
	end)
end)

battery:subscribe("mouse.clicked", function()
	if is_charging then
		return
	end

	show_time = not show_time
	update_battery()
end)

update_battery()
