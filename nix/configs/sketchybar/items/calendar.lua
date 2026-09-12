local colors = require("colors")
local sbar = require("sketchybar")

local date_item = sbar.add("item", "date", {
	position = "right",

	icon = {
		string = "􀧞",
		color = colors.mauve,
	},

	label = {
		color = colors.text,
	},

	update_freq = 5,

	popup = {
		align = "center",
		y_offset = -2,

		background = {
			color = colors.surface,
			border_color = colors.surface_border,
			border_width = 1,
			corner_radius = 10,
		},
	},
})

local function make_popup_item(name, icon, label)
	return sbar.add("item", name, {
		position = "popup.date",

		icon = {
			string = icon,
			color = colors.mauve,
			padding_left = 10,
		},

		label = {
			string = label,
			color = colors.text,
			font = "Maple Mono NF:Bold:13.0",
			width = 220,
			padding_right = 10,
		},

		background = {
			drawing = false,
		},
	})
end

local network_item = make_popup_item("date.network", "󰖩", "Checking...")

local vpn_item = make_popup_item("date.vpn", "󰒝", "Checking...")

local uptime_item = make_popup_item("date.uptime", "􀐫", "Checking...")

local function update_network()
	sbar.exec("route get default 2>/dev/null | awk '/interface:/{print $2}'", function(iface)
		if not iface or iface == "" then
			date_item:set({
				icon = {
					color = colors.red,
				},
			})

			network_item:set({
				label = {
					string = "Disconnected",
				},
			})

			vpn_item:set({
				label = {
					string = "Disconnected",
				},
			})

			return
		end

		iface = iface:match("%S+")

		local vpn = iface:match("^utun") ~= nil

		date_item:set({
			icon = {
				color = vpn and colors.green or colors.mauve,
			},
		})

		network_item:set({
			label = {
				string = "Connected",
			},
		})

		vpn_item:set({
			label = {
				string = vpn and "VPN Connected" or "VPN Disconnected",
			},
		})
	end)
end

local function update_date()
	local now = os.time()

	date_item:set({
		label = {
			string = os.date("%a %d %b  -  %I:%M %p", now),
		},
	})
end

local function update_uptime()
	sbar.exec("sysctl -n kern.boottime", function(result)
		if not result or result == "" then
			return
		end

		local boot_time = result:match("sec = (%d+)")

		if not boot_time then
			return
		end

		boot_time = tonumber(boot_time)

		if not boot_time then
			return
		end

		local uptime_seconds = os.time() - boot_time

		local days = math.floor(uptime_seconds / 86400)
		local hours = math.floor((uptime_seconds % 86400) / 3600)
		local minutes = math.floor((uptime_seconds % 3600) / 60)

		local parts = {}

		if days > 0 then
			table.insert(parts, days .. "d")
		end

		if hours > 0 or days > 0 then
			table.insert(parts, hours .. "h")
		end

		table.insert(parts, minutes .. "m")

		uptime_item:set({
			label = {
				string = "Up: " .. table.concat(parts, " "),
			},
		})
	end)
end

date_item:subscribe("mouse.entered", function()
	sbar.animate("tanh", 5, function()
		date_item:set({
			background = {
				border_color = colors.mauve,
			},
		})
	end)
end)

date_item:subscribe("mouse.exited", function()
	sbar.animate("tanh", 5, function()
		date_item:set({
			background = {
				border_color = colors.surface_border,
			},
		})
	end)
end)

date_item:subscribe("mouse.clicked", function()
	update_network()
	update_date()
	update_uptime()

	date_item:set({
		popup = {
			drawing = "toggle",
		},
	})
end)

date_item:subscribe("routine", function()
	update_date()
	update_network()

	if date_item:query().popup.drawing == "on" then
		update_uptime()
	end
end)

update_date()
update_network()
update_uptime()
