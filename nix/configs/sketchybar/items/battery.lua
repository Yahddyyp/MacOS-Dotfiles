local colors = require("colors")
local sbar = require("sketchybar")

local HOME = os.getenv("HOME")
local WATCHER = HOME .. "/.config/sketchybar/helpers/battery-watcher"

local show_time = false
local is_charging = false
local cached_pct = nil
local cached_time = nil

sbar.add("event", "battery_update")

local battery = sbar.add("item", "battery", {
	position = "right",
	icon = { color = colors.mauve },
	label = { color = colors.text },
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

local function get_icon_color(percentage, charging)
	if charging then
		return colors.green
	elseif percentage <= 15 then
		return colors.red
	elseif percentage <= 30 then
		return colors.yellow
	else
		return colors.mauve
	end
end

local function format_minutes(mins)
	if not mins or mins <= 0 then
		return nil
	end
	return string.format("%d:%02d", math.floor(mins / 60), mins % 60)
end

local function render_battery()
	if not cached_pct then
		return
	end

	local display = cached_pct .. "%"
	if not is_charging and show_time and cached_time then
		display = cached_time
	end

	sbar.animate("tanh", 6, function()
		battery:set({
			icon = {
				string = get_battery_icon(cached_pct, is_charging),
				color = get_icon_color(cached_pct, is_charging),
			},
			label = {
				string = display,
			},
		})
	end)
end

battery:subscribe("battery_update", function(env)
	local pct = tonumber(env.PERCENTAGE)
	if not pct then
		return
	end

	cached_pct = pct
	is_charging = (env.CHARGING == "1")
	cached_time = format_minutes(tonumber(env.TIME_REMAINING))

	if is_charging or not cached_time then
		show_time = false
	end

	render_battery()
end)

battery:subscribe("mouse.clicked", function()
	if is_charging or not cached_time then
		return
	end

	show_time = not show_time
	render_battery()
end)

sbar.delay(0.2, function()
	sbar.exec(WATCHER .. " >/dev/null 2>&1 &")
end)
