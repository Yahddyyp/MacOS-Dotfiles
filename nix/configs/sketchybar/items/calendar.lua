local colors = require("colors")
local sbar = require("sketchybar")

local HOME = os.getenv("HOME")
local WATCHER = HOME .. "/.config/sketchybar/helpers/network-watcher"

local popup_open = false
local uptime_token = 0

sbar.add("event", "network_update")

local date_item = sbar.add("item", "date", {
	position = "right",
	icon = {
		string = "􀧞",
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

local function apply_network(connected, vpn)
	if not connected then
		date_item:set({ icon = { color = colors.red } })
		network_item:set({ label = { string = "Disconnected" } })
		vpn_item:set({ label = { string = "Disconnected" } })
		return
	end

	date_item:set({
		icon = { color = vpn and colors.green or colors.mauve },
	})
	network_item:set({
		label = { string = "Connected" },
	})
	vpn_item:set({
		label = { string = vpn and "VPN Connected" or "VPN Disconnected" },
	})
end

local function update_date()
	date_item:set({
		label = {
			string = os.date("%a %d %b  -  %I:%M %p"),
		},
	})
end

local function update_uptime()
	sbar.exec("sysctl -n kern.boottime", function(result)
		local boot_time = result and tonumber(result:match("sec = (%d+)"))
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
			label = { string = "Up: " .. table.concat(parts, " ") },
		})
	end)
end

local function schedule_uptime_while_open(token)
	if not popup_open or token ~= uptime_token then
		return
	end
	update_uptime()
	local delay = (60 - os.date("*t").sec) + 0.05
	sbar.delay(delay, function()
		schedule_uptime_while_open(token)
	end)
end

local function set_popup(open)
	popup_open = open
	uptime_token = uptime_token + 1
	date_item:set({
		popup = { drawing = open and "on" or "off" },
	})
	if open then
		schedule_uptime_while_open(uptime_token)
	end
end

local function schedule_clock()
	update_date()
	local sec = os.date("*t").sec
	local delay = (60 - sec) + 0.05
	sbar.delay(delay, schedule_clock)
end

date_item:subscribe("network_update", function(env)
	apply_network(env.CONNECTED == "1", env.VPN == "1")
end)

date_item:subscribe("mouse.clicked", function()
	local next_state = not popup_open
	if next_state then
		update_date()
	end
	set_popup(next_state)
end)

date_item:subscribe("mouse.exited.global", function()
	if popup_open then
		set_popup(false)
	end
end)

date_item:subscribe("system_woke", function()
	update_date()
end)

schedule_clock()
update_uptime()

sbar.delay(0.2, function()
	sbar.exec(WATCHER .. " >/dev/null 2>&1 &")
end)
