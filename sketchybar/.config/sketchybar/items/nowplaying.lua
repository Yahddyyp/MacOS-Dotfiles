local colors = require("colors")

local nowplaying = {
	app = nil,
	track = nil,
	artist = nil,
	album = nil,
	state = "stopped",
	empty_count = 0,
}

local media_item = sbar.add("item", "media", {
	position = "right",
	icon = {
		string = "􀑪",
		color = colors.mauve,
		font = "CaskaydiaCove Nerd Font:16.0",
		padding_left = 10,
		padding_right = 4,
	},
	label = {
		color = colors.text,
		font = "CaskaydiaCove Nerd Font:Bold:14.0",
		max_chars = 50,
		padding_left = 6,
		padding_right = 10,
	},
	background = {
		color = colors.surface,
		border_color = colors.surface_border,
		border_width = 1,
		corner_radius = 8,
		height = 30,
	},
	drawing = false,
})

media_item:subscribe("mouse.entered", function()
	sbar.animate("tanh", 5, function()
		media_item:set({ background = { border_color = colors.mauve } })
	end)
end)

media_item:subscribe("mouse.exited", function()
	sbar.animate("tanh", 5, function()
		media_item:set({ background = { border_color = colors.surface_border } })
	end)
end)

local osascript_busy = false
local function update_nowplaying()
	-- pgrep check runs every tick regardless of osascript state (instant, won't hang)
	sbar.exec("pgrep -q Spotify && echo spotify || pgrep -q Music && echo music || echo none", function(app)
		if not app or app == "none" then
			if nowplaying.state ~= "stopped" then
				nowplaying.state = "stopped"
				media_item:set({ drawing = false, label = { string = "" } })
			end
			return
		end

		-- Skip osascript if previous one is still pending (e.g. slow Spotify response)
		if osascript_busy then return end
		osascript_busy = true

		sbar.exec(
			[[osascript -e '
      set output to ""
      tell application "System Events"
        if exists (process "Spotify") then
          tell application "Spotify"
            try
              set output to "Spotify||" & name of current track & "||" & artist of current track & "||" & player state
            end try
          end tell
        end if
        if output is "" then
          if exists (process "Music") then
            tell application "Music"
              try
                set output to "Music||" & name of current track & "||" & artist of current track & "||" & player state
              end try
            end tell
          end if
        end if
      end tell
      return output
    ']],
			function(result)
				osascript_busy = false

				if not result or result == "" then
					if nowplaying.state ~= "stopped" then
						nowplaying.state = "stopped"
						media_item:set({ drawing = false, label = { string = "" } })
					end
					return
				end

				local app, title, artist_name, state = result:match("(.-)||(.-)||(.-)||(.+)")
				if not title then
					if nowplaying.state ~= "stopped" then
						nowplaying.state = "stopped"
						media_item:set({ drawing = false, label = { string = "" } })
					end
					return
				end

				local prev_state = nowplaying.state

				nowplaying.app = app
				nowplaying.track = title
				nowplaying.artist = artist_name or ""
				nowplaying.state = state

				local label = (artist_name or "") .. " - " .. title
				if #label > 50 then
					label = label:sub(1, 47):gsub("%s+$", "") .. "..."
				end

				if prev_state == "stopped" or not prev_state then
					media_item:set({
						drawing = true,
						icon = { string = "􀑪" },
						label = { string = label },
					})
					sbar.animate("tanh", 6, function()
						media_item:set({ background = { border_color = colors.mauve } })
					end)
					sbar.delay(0.3, function()
						sbar.animate("tanh", 5, function()
							media_item:set({ background = { border_color = colors.surface_border } })
						end)
					end)
				else
					media_item:set({
						icon = { string = "􀑪" },
						label = { string = label },
					})
				end
			end
		)
	end)
end

-- Periodic check via sbar.delay (reliable, no update_freq dependency)
local function schedule_check()
	sbar.delay(3, function()
		update_nowplaying()
		schedule_check()
	end)
end

sbar.add("event", "media_change", "com.spotify.client.PlaybackStateChanged")
sbar.add("event", "media_change", "com.apple.Music.playerInfo")

local watcher = sbar.add("item", "media.watcher", {
	drawing = false,
	icon = { drawing = false },
	label = { drawing = false },
	background = { drawing = false },
})

watcher:subscribe("media_change", function()
	update_nowplaying()
end)

update_nowplaying()
schedule_check()
