local colors = require("colors")
local settings = require("settings")
local icons = require("icons")

local dark_bg  = 0xaa2a273f
local light_bg = colors.mauve

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
    click_script = "yabai -m space --focus " .. sid,
  })

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
  sbar.exec("yabai -m query --windows 2>/dev/null || echo '[]'", function(all_windows)
    if not all_windows or type(all_windows) ~= "table" then return end

    local space_apps = {}
    for _, win in ipairs(all_windows) do
      if not win["is-minimized"] and win.role == "AXWindow" then
        local sid = win.space
        local app = win.app
        if sid and app then
          if not space_apps[sid] then space_apps[sid] = {} end
          space_apps[sid][app] = true
        end
      end
    end

    for _, sid in ipairs(settings.space_sids) do
      local apps = space_apps[sid]
      if apps then
        local icon_strip = " "
        for app, _ in pairs(apps) do
          local icon = icons[app]
          icon_strip = icon_strip .. icon .. " "
        end
        sbar.set("space." .. sid, { label = { string = icon_strip } })
      else
        sbar.set("space." .. sid, { label = { string = " —" } })
      end
    end
  end)
end

sbar.add("event", "space_windows_change")

local yabai_signal_cmd = [=[
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

space_watcher:subscribe("space_windows_change", function()
  update_space_windows()
end)

update_space_windows()
