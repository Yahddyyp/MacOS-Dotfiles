local colors = require("colors")
local icons = require("icons")
local sbar = require("sketchybar")

local current_app = "Finder"
local update_token = 0

local function get_icon(app)
	return icons[app] or icons["Default"] or ":default:"
end

local front_app = sbar.add("item", "front_app", {
	position = "left",
	icon = {
		string = get_icon("Finder"),
		font = "sketchybar-app-font:Regular:18.0",
		color = colors.mauve,
	},
	label = {
		string = "Finder",
		color = colors.text,
	},
	background = {
		color = colors.base_alpha,
		border_color = colors.base_border,
		border_width = 1,
	},
})

local function on_focus(env)
	local app = env.INFO
	if not app or app == "" or app == "null" then
		app = "Finder"
	end

	update_token = update_token + 1
	local this_token = update_token

	sbar.delay(0.04, function()
		if this_token ~= update_token or app == current_app then
			return
		end

		current_app = app
		front_app:set({
			label = { string = app },
			icon = { string = get_icon(app) },
		})
	end)
end

front_app:subscribe({ "window_focus", "front_app_switched" }, on_focus)
