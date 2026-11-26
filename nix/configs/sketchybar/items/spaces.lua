local colors = require("colors")
local settings = require("settings")
local icons = require("icons")
local sbar = require("sketchybar")

local dark_bg = colors.space_bg
local light_bg = colors.mauve

local YABAI = "/run/current-system/sw/bin/yabai"

local spaces = {}
local last_strips = {}

local function get_icon(app)
	return icons[app] or icons["Default"] or ":default:"
end

for _, sid in ipairs(settings.space_sids) do
	local space = sbar.add("space", "space." .. sid, {
		space = sid,
		icon = {
			string = tostring(sid),
			color = light_bg,
			padding_left = 10,
			padding_right = 4,
		},
		label = {
			string = " —",
			font = settings.icon_font .. ":Regular:18.0",
			padding_right = 20,
			y_offset = -2,
			color = light_bg,
		},
		background = {
			color = dark_bg,
			border_color = colors.surface_border,
			border_width = 1,
		},
		click_script = YABAI .. " -m space --focus " .. sid,
	})

	spaces[sid] = space

	space:subscribe("space_change", function(env)
		local selected = env.SELECTED == "true"

		sbar.animate("tanh", 5, function()
			space:set({
				icon = {
					color = selected and dark_bg or light_bg,
				},
				label = {
					color = selected and dark_bg or light_bg,
				},
				background = {
					color = selected and light_bg or dark_bg,
					border_color = selected and dark_bg or colors.surface_border,
				},
			})
		end)
	end)
end

local function update_space_windows()
	sbar.exec(YABAI .. " -m query --windows 2>/dev/null", function(result)
		if type(result) ~= "table" then
			return
		end

		local space_apps = {}

		for _, win in ipairs(result) do
			if not win["is-minimized"] and win.role == "AXWindow" then
				local sid = win.space
				local app = win.app

				if sid and app and app ~= "" then
					space_apps[sid] = space_apps[sid] or {}
					space_apps[sid][app] = true
				end
			end
		end

		for _, sid in ipairs(settings.space_sids) do
			local item = spaces[sid]
			if item then
				local apps = space_apps[sid]
				local strip = " —"

				if apps then
					local ordered = {}
					for app in pairs(apps) do
						ordered[#ordered + 1] = app
					end
					table.sort(ordered)

					local parts = {}
					for _, app in ipairs(ordered) do
						parts[#parts + 1] = get_icon(app)
					end
					strip = " " .. table.concat(parts, " ") .. " "
				end

				if last_strips[sid] ~= strip then
					last_strips[sid] = strip
					item:set({
						label = { string = strip },
					})
				end
			end
		end
	end)
end

sbar.add("event", "space_windows_change")

local space_watcher = sbar.add("item", "space_watcher", {
	drawing = false,
})

local windows_update_pending = false

local function schedule_windows_update()
	if windows_update_pending then
		return
	end

	windows_update_pending = true

	sbar.delay(0.15, function()
		windows_update_pending = false
		update_space_windows()
	end)
end

space_watcher:subscribe({ "space_windows_change", "front_app_switched" }, schedule_windows_update)

sbar.delay(0.5, update_space_windows)
