local colors = require("colors")

local date_item = sbar.add("item", "date", {
  position = "right",
  icon = {
    string = "􀧞",
    color = colors.mauve,
  },
  label = {
    color = colors.text,
  },
	update_freq = 15,
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

local function make_popup_item(name, icon_str, label_str)
  return sbar.add("item", name, {
    position = "popup.date",
    icon = {
      string = icon_str,
      color = colors.mauve,
      padding_left = 10,
    },
    label = {
      string = label_str or "",
      color = colors.text,
      font = "CaskaydiaCove Nerd Font:Bold:13.0",
      width = 220,
      padding_right = 10,
    },
    background = { drawing = false },
  })
end

local wifi_item = make_popup_item("date.wifi", "󰤨", "Scanning...")
local band_item = make_popup_item("date.band", "󰖩", "Connected")
local vpn_item = make_popup_item("date.vpn", "󰒝", "Checking...")
local uptime_item = make_popup_item("date.uptime", "􀐫", "Up: ...")

local net_cache = { prev_time = 0, prev_in = 0, prev_out = 0 }

local function format_speed(bytes_per_sec)
  if bytes_per_sec >= 1048576 then return string.format("%.1f MB/s", bytes_per_sec / 1048576)
  elseif bytes_per_sec >= 1024 then return string.format("%.1f KB/s", bytes_per_sec / 1024) end
  return math.floor(bytes_per_sec) .. " B/s"
end

local function update_network_info()
  sbar.exec("route get default 2>/dev/null | grep interface | awk '{print $2}'", function(iface)
    if not iface or iface == "" then
      date_item:set({ icon = { color = colors.red } })
      wifi_item:set({ label = { string = "Disconnected" } })
      return
    end
    iface = iface:match("%S+") or ""
    local vpn = iface:find("^utun") and true or false
    date_item:set({ icon = { color = vpn and colors.green or colors.mauve } })
    vpn_item:set({ label = { string = vpn and "Connected" or "Disconnected" } })
    band_item:set({ label = { string = "Connected" } })

    sbar.exec("netstat -ib -I " .. iface .. " 2>/dev/null | grep '<Link#' | head -1 | awk '{print $7, $10}'", function(net_info)
      if not net_info then return end
      local current_in, current_out = net_info:match("(%d+)%s+(%d+)")
      if current_in and current_out then
        current_in = tonumber(current_in)
        current_out = tonumber(current_out)
        local now = os.time()
        local diff = now - net_cache.prev_time
        if net_cache.prev_time > 0 and diff > 0 then
          wifi_item:set({ label = { string = "⇣ " .. format_speed((current_in - net_cache.prev_in)/diff) .. "  ⇡ " .. format_speed((current_out - net_cache.prev_out)/diff) } })
        end
        net_cache.prev_time, net_cache.prev_in, net_cache.prev_out = now, current_in, current_out
      end
    end)

    sbar.exec("uptime", function(up)
      if not up or up == "" then return end
      local up_str = up:match("up%s+(.-),%s+%d+%s+user") or ""
      up_str = up_str:gsub("^%s*(.-)%s*$", "%1")
      local days = up_str:match("(%d+)%s+day")
      local h, m = up_str:match("(%d+):(%d+)")
      local parts = {}
      if days then table.insert(parts, days .. "d") end
      if h then table.insert(parts, h .. "h") end
      if m then table.insert(parts, m .. "m") end
      local label = "Up: "
      if #parts > 0 then
        label = label .. table.concat(parts, " ")
      else
        local mins = up_str:match("(%d+)%s+min")
        label = label .. (mins or "<1") .. "m"
      end
      uptime_item:set({ label = { string = label } })
    end)
  end)
end

local function update_date()
  local now = os.time()
  local date_str = os.date("%a %d %b  -  %I:%M %p", now)
  date_item:set({ label = { string = date_str } })
end

date_item:subscribe("mouse.entered", function()
  sbar.animate("tanh", 5, function()
    date_item:set({ background = { border_color = colors.mauve } })
  end)
end)

date_item:subscribe("mouse.exited", function()
  sbar.animate("tanh", 5, function()
    date_item:set({ background = { border_color = colors.surface_border } })
  end)
end)

date_item:subscribe("mouse.clicked", function()
  update_network_info()
  update_date()
  date_item:set({ popup = { drawing = "toggle" } })
end)

date_item:subscribe("routine", function()
  update_date()
  if date_item:query().popup.drawing == "on" then
    update_network_info()
  end
end)

update_date()
