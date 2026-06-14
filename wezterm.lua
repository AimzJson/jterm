local wezterm = require 'wezterm'
local config = wezterm.config_builder()

local is_mac = wezterm.target_triple:find('darwin') ~= nil
local is_windows = wezterm.target_triple:find('windows') ~= nil
local home = wezterm.home_dir
local new_tab_key = is_mac and 'SUPER' or 'CTRL|SHIFT'
local mod_key = is_mac and 'SUPER|SHIFT' or 'CTRL|SHIFT'

-- Performance
config.check_for_updates = false
config.front_end = 'WebGpu'
config.webgpu_power_preference = 'HighPerformance'
config.cursor_blink_rate = 0
config.audible_bell = 'Disabled'
config.scrollback_lines = 3500

-- Startup layout
local function make_grid(window, pane)
  local top_right = pane:split { direction = 'Right', size = 0.35 }
  pane:split { direction = 'Bottom', size = 0.5 }
  top_right:split { direction = 'Bottom', size = 0.5 }
  pane:activate()
end

wezterm.on('gui-startup', function()
  local _, pane, window = wezterm.mux.spawn_window {}
  local gui = window:gui_window()
  if is_mac then
    gui:toggle_fullscreen()
  else
    gui:maximize()
  end
  wezterm.time.call_after(0.8, function()
    make_grid(window, pane)
  end)
end)

-- macOS specific
if is_mac then
  config.native_macos_fullscreen_mode = true
  config.macos_window_background_blur = 20
end

-- Font
config.font = wezterm.font 'Iosevka Nerd Font'
config.font_size = 14

-- Pane styling
config.inactive_pane_hsb = {
  saturation = 0.7,
  brightness = 0.4,
}

-- Colours
config.colors = {
  foreground = '#E0F5D8',
  background = '#080E08',

  cursor_bg = '#7FD46E',
  cursor_fg = '#080E08',
  cursor_border = '#7FD46E',

  selection_fg = '#080E08',
  selection_bg = '#7FD46E',

  ansi = {
    '#080E08',
    '#2D4A1E',
    '#3A8A3A',
    '#7FD46E',
    '#1A3A1A',
    '#4A8A4A',
    '#5AAF7A',
    '#E0F5D8',
  },
  brights = {
    '#1A2A1A',
    '#5A9A3A',
    '#5AAF5A',
    '#7FD46E',
    '#3A7A3A',
    '#9ACA9A',
    '#7FD46E',
    '#F0FFF0',
  },

  tab_bar = {
    background = '#080E08',
    active_tab = {
      bg_color = '#1A3D1A',
      fg_color = '#E0F5D8',
      intensity = 'Bold',
    },
    inactive_tab = {
      bg_color = '#0F1F0F',
      fg_color = '#4A6A4A',
    },
    inactive_tab_hover = {
      bg_color = '#162B16',
      fg_color = '#5AAF5A',
    },
    new_tab = {
      bg_color = '#080E08',
      fg_color = '#4A6A4A',
    },
    new_tab_hover = {
      bg_color = '#0F1F0F',
      fg_color = '#5AAF5A',
    },
  },
}

-- Background image
config.background = {
  {
    source = { File = wezterm.config_dir .. '/background.png' },
    width = '100%',
    height = '100%',
    hsb = { brightness = 1.0 },
  },
  {
    source = { Color = '#080E08' },
    opacity = 0.95,
    width = '100%',
    height = '100%',
  },
}

-- Tab bar
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 32


-- Right status: battery · date · time
wezterm.on('update-right-status', function(window, pane)
  -- Battery
  local battery = ''
  local ok, battery_info = pcall(wezterm.battery_info)
  if ok and battery_info and #battery_info > 0 then
    local b = battery_info[1]
    local pct = math.floor(b.state_of_charge * 100)
    local icon = b.state == 'Charging' and '↑ ' or '⚡ '
    battery = icon .. pct .. '%'
  end

  local function sep()
    return {
      { Foreground = { Color = '#4A6A4A' } },
      { Text = '  ·  ' },
    }
  end

  local items = {}

  if battery ~= '' then
    table.insert(items, { color = '#5AAF5A', text = battery })
  end
  table.insert(items, { color = '#5AAF5A', text = wezterm.strftime '%a %d %b' })
  table.insert(items, { color = '#E0F5D8', text = wezterm.strftime '%H:%M' })

  local segments = { { Text = '  ' } }
  for i, item in ipairs(items) do
    table.insert(segments, { Foreground = { Color = item.color } })
    table.insert(segments, { Text = item.text })
    if i < #items then
      for _, s in ipairs(sep()) do table.insert(segments, s) end
    end
  end
  table.insert(segments, { Text = '  ' })

  window:set_right_status(wezterm.format(segments))
end)

-- Hyperlinks
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Keybindings
config.keys = {
  {
    key = 't',
    mods = new_tab_key,
    action = wezterm.action_callback(function(window, _)
      local _, pane = window:mux_window():spawn_tab {}
      make_grid(window, pane)
    end),
  },
  -- Pane navigation
  { key = 'LeftArrow',  mods = mod_key, action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = mod_key, action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = mod_key, action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = mod_key, action = wezterm.action.ActivatePaneDirection 'Down' },
  -- Pane zoom
  { key = 'z', mods = mod_key, action = wezterm.action.TogglePaneZoomState },
}

-- Window
config.enable_scroll_bar = false
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

return config
