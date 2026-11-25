local colors = require("colors")
local sbar = require("sketchybar")

local show_time = false
local is_charging = false
local has_time = false

local battery = sbar.add("item", "battery", {
	position = "right",
	update_freq = 30,

	icon = {
		color = colors.mauve,
	},

	label = {
		color = colors.text,
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
		has_time = time_remaining ~= nil and time_remaining ~= "0:00"

		if not has_time then
			show_time = false
		end

		local display = percentage .. "%"

		if not is_charging and show_time and has_time then
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
	end)
end

battery:subscribe("routine", update_battery)
battery:subscribe("system_woke", update_battery)
battery:subscribe("power_source_change", update_battery)

battery:subscribe("mouse.clicked", function()
	if is_charging or not has_time then
		return
	end

	show_time = not show_time
	update_battery()
end)

update_battery()
