local colors = require("colors")

-- Volume icon item
local volume_icon = sbar.add("item", "volume_icon", {
  position = "right",
  icon = { color = colors.mauve },
  label = { color = colors.text },
  popup = {
    align = "center",
    background = {
      color = colors.surface,
      border_color = colors.surface_border,
      border_width = 1,
      corner_radius = 6,
      height = 18,
    },
    y_offset = -2,
  },
})

-- Volume slider in popup
local volume_slider = sbar.add("slider", "volume_slider", 150, {
  position = "popup.volume_icon",
  slider = {
    background = {
      height = 4,
      corner_radius = 2,
      color = 0xff313244,
    },
    highlight_color = colors.mauve,
    knob = "􀀁",
  },
  background = { drawing = false },
  padding_left = 10,
  padding_right = 10,
})

local function get_volume_icon(volume)
  if volume == 0 then return "􀊣" end
  if volume <= 29 then return "􀊥" end
  if volume <= 69 then return "􀊧" end
  return "􀊩"
end

local function on_volume_change(env)
  local volume = tonumber(env.INFO) or 0
  local icon = get_volume_icon(volume)

  sbar.animate("tanh", 6, function()
    volume_icon:set({
      label = { string = volume .. "%" },
      icon = { string = icon },
    })
  end)
  volume_slider:set({ slider = { percentage = volume } })
end

local function on_slider_change()
  sbar.exec("sketchybar --query volume_slider", function(info)
    if info and info.slider then
      local percentage = math.floor(info.slider.percentage + 0.5)
      percentage = math.max(0, math.min(100, percentage))
      sbar.exec("osascript -e 'set volume output volume " .. percentage .. "'")
      local icon = get_volume_icon(percentage)
      volume_icon:set({
        label = { string = percentage .. "%" },
        icon = { string = icon },
      })
    end
  end)
end

volume_icon:subscribe("volume_change", on_volume_change)

-- Hover glow on volume icon
volume_icon:subscribe("mouse.entered", function()
  sbar.animate("tanh", 5, function()
    volume_icon:set({ background = { border_color = colors.mauve } })
  end)
end)

volume_icon:subscribe("mouse.exited", function()
  sbar.animate("tanh", 5, function()
    volume_icon:set({ background = { border_color = colors.surface_border } })
  end)
end)

volume_icon:subscribe("mouse.clicked", function()
  local current = volume_icon:query()
  if current and current.popup and current.popup.drawing == "on" then
    volume_icon:set({ popup = { drawing = false } })
    volume_slider:set({ slider = { knob = { drawing = false } } })
  else
    volume_icon:set({ popup = { drawing = true } })
    volume_slider:set({ slider = { knob = { drawing = true } } })
  end
end)

volume_slider:subscribe("mouse.clicked", function(env)
  if env.PERCENTAGE then
    local pct = math.floor(tonumber(env.PERCENTAGE) + 0.5)
    pct = math.max(0, math.min(100, pct))
    sbar.exec("osascript -e 'set volume output volume " .. pct .. "'")
    local icon = get_volume_icon(pct)
    volume_icon:set({
      label = { string = pct .. "%" },
      icon = { string = icon },
    })
    volume_slider:set({ slider = { percentage = pct } })
  end
end)

volume_slider:subscribe("mouse.entered", function()
  volume_slider:set({ slider = { knob = { drawing = true } } })
end)

volume_slider:subscribe("mouse.exited", function()
  volume_slider:set({ slider = { knob = { drawing = false } } })
end)
