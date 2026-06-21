local colors = require("colors")

local battery = sbar.add("item", "battery", {
	position = "right",
	icon = {
		color = colors.mauve,
	},
	label = {
		color = colors.text,
	},
	update_freq = 0,
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
		font = "CaskaydiaCove Nerd Font:Bold:13.0",
		width = 130,
		padding_right = 10,
		scroll_texts = "off",
	},
	background = { drawing = false },
})

local function get_battery_icon(percentage, charging)
	if charging then
		return "􀋦"
	end
	if percentage >= 90 then
		return "􀛨"
	end
	if percentage >= 60 then
		return "􀺸"
	end
	if percentage >= 30 then
		return "􀺶"
	end
	if percentage >= 10 then
		return "􀛩"
	end
	return "􀛪"
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

		local charging = info:find("AC Power") ~= nil
		local icon = get_battery_icon(percentage, charging)

		sbar.animate("tanh", 6, function()
			battery:set({
				icon = { string = icon },
				label = { string = percentage .. "%" },
			})
		end)

		if charging then
			battery_info:set({
				icon = { string = "􀋦" },
				label = { string = "Charging" },
			})
		else
			local time_remaining = info:match("(%d+:%d+)")
			if time_remaining and time_remaining ~= "0:00" then
				battery_info:set({
					icon = { string = "􀐫" },
					label = { string = time_remaining .. " remaining" },
				})
			else
				battery_info:set({
					icon = { string = icon },
					label = { string = "Calculating..." },
				})
			end
		end
	end)
end

battery:subscribe({ "system_woke", "power_source_change" }, update_battery)

battery:subscribe("mouse.entered", function()
	sbar.animate("tanh", 5, function()
		battery:set({ background = { border_color = colors.mauve } })
	end)
end)

battery:subscribe("mouse.exited", function()
	sbar.animate("tanh", 5, function()
		battery:set({ background = { border_color = colors.surface_border } })
	end)
end)

battery:subscribe("mouse.clicked", function()
	battery:set({ popup = { drawing = "toggle" } })
	if battery:query().popup.drawing == "on" then
		update_battery()
	end
end)

update_battery()
