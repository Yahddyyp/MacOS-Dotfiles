local colors = require("colors")
local settings = require("settings")
local icons = require("icons")
local sbar = require("sketchybar")

local dark_bg = 0xaa2a273f
local light_bg = colors.mauve

local YABAI = "/run/current-system/sw/bin/yabai"
local PATH_PREFIX = 'export PATH="/run/current-system/sw/bin:/opt/homebrew/bin:$PATH"; '

local spaces = {}

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
			font = "sketchybar-app-font:Regular:18.0",
			padding_right = 20,
			y_offset = -2,
			color = light_bg,
		},
		background = {
			color = dark_bg,
			border_color = colors.surface_border,
			border_width = 1,
		},

		-- Yabai
		click_script = YABAI .. " -m space --focus " .. sid,

		-- AeroSpace
		-- click_script = "/run/current-system/sw/bin/aerospace workspace " .. sid,
	})

	spaces[sid] = space

	local is_focused = (sid == 1)

	space:subscribe("space_change", function(env)
		local selected = env.SELECTED == "true"
		is_focused = selected
		sbar.animate("tanh", 5, function()
			space:set({
				icon = { color = selected and dark_bg or light_bg },
				label = { color = selected and dark_bg or light_bg },
				background = {
					color = selected and light_bg or dark_bg,
					border_color = selected and dark_bg or colors.surface_border,
				},
			})
		end)
	end)

	space:subscribe("mouse.entered", function()
		sbar.animate("tanh", 3, function()
			space:set({ background = { border_color = colors.mauve } })
		end)
	end)

	space:subscribe("mouse.exited", function()
		sbar.animate("tanh", 3, function()
			space:set({
				background = { border_color = is_focused and dark_bg or colors.surface_border },
			})
		end)
	end)
end

local function update_space_windows()
	sbar.exec(PATH_PREFIX .. YABAI .. " -m query --windows 2>/dev/null || echo '[]'", function(result)
		if not result then
			return
		end

		local all_windows = result
		if not all_windows or type(all_windows) ~= "table" then
			return
		end

		local space_apps = {}
		for _, win in ipairs(all_windows) do
			if not win["is-minimized"] and win.role == "AXWindow" then
				local sid = win.space
				local app = win.app
				if sid and app then
					if not space_apps[sid] then
						space_apps[sid] = {}
					end
					space_apps[sid][app] = true
				end
			end
		end

		for _, sid in ipairs(settings.space_sids) do
			local apps = space_apps[sid]
			local item = spaces[sid]
			if not item then
				goto continue
			end

			if apps then
				local icon_strip = " "
				for app, _ in pairs(apps) do
					icon_strip = icon_strip .. icons[app] .. " "
				end
				item:set({ label = { string = icon_strip } })
			else
				item:set({ label = { string = " —" } })
			end

			::continue::
		end
	end)

	-- AeroSpace version
	--
	-- for _, sid in ipairs(settings.space_sids) do
	--   sbar.exec(
	--     PATH_PREFIX .. '/run/current-system/sw/bin/aerospace list-windows --workspace '
	--       .. sid .. ' --format "%{app-name}"',
	--     function(result)
	--       local item = spaces[sid]
	--       if not item then return end
	--       if not result or result == "" then
	--         item:set({ label = { string = " —" } })
	--         return
	--       end
	--       local seen, icon_strip = {}, " "
	--       for app in result:gmatch("[^\r\n]+") do
	--         local icon = icons[app] or icons["Default"] or "?"
	--         if not seen[icon] then
	--           seen[icon] = true
	--           icon_strip = icon_strip .. icon .. " "
	--         end
	--       end
	--       item:set({ label = { string = icon_strip } })
	--     end
	--   )
	-- end
end

sbar.add("event", "space_windows_change")

local yabai_signal_cmd = PATH_PREFIX
	.. [=[
yabai -m signal --remove 2>/dev/null
yabai -m signal --add event=space_changed action='sketchybar --trigger space_change'
yabai -m signal --add event=window_focused action='sketchybar --trigger space_windows_change'
]=]
sbar.exec(yabai_signal_cmd)

local space_watcher = sbar.add("item", "space_watcher", {
	position = "center",
	background = { drawing = false },
	update_freq = 0,
})

local windows_update_pending = false

space_watcher:subscribe("space_windows_change", function()
	if windows_update_pending then
		return
	end
	windows_update_pending = true
	sbar.delay(0.3, function()
		windows_update_pending = false
		update_space_windows()
	end)
end)

update_space_windows()
