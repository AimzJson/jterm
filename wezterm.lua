local wezterm = require 'wezterm'
local config = wezterm.config_builder()

local is_mac = wezterm.target_triple:find('darwin') ~= nil
local is_windows = wezterm.target_triple:find('windows') ~= nil
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
  config.macos_window_background_blur = 40
end

-- Font
config.font = wezterm.font 'GeistMono NFM'
config.font_size = 14

-- Pane styling
config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.6,
}

-- Tokyo Night
config.colors = {
  foreground = '#C0CAF5',
  background = '#1A1B26',

  cursor_bg = '#C0CAF5',
  cursor_fg = '#1A1B26',
  cursor_border = '#C0CAF5',

  selection_fg = '#C0CAF5',
  selection_bg = '#283457',

  ansi = {
    '#15161E',
    '#F7768E',
    '#9ECE6A',
    '#E0AF68',
    '#7AA2F7',
    '#BB9AF7',
    '#7DCFFF',
    '#A9B1D6',
  },
  brights = {
    '#414868',
    '#F7768E',
    '#9ECE6A',
    '#E0AF68',
    '#7AA2F7',
    '#BB9AF7',
    '#7DCFFF',
    '#C0CAF5',
  },
}

-- Frosted glass
config.window_background_opacity = 0.8
config.window_decorations = 'RESIZE'

-- Tab bar (used for status bar)
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.show_new_tab_button_in_tab_bar = false

config.colors.tab_bar = {
  background = '#16161E',
  active_tab   = { bg_color = '#16161E', fg_color = '#C0CAF5' },
  inactive_tab = { bg_color = '#16161E', fg_color = '#414868' },
  new_tab      = { bg_color = '#16161E', fg_color = '#414868' },
}

local function sep()
  return {
    { Foreground = { Color = '#414868' } },
    { Text = '  ◆  ' },
  }
end

wezterm.on('update-right-status', function(window)
  local segments = {}

  for _, b in ipairs(wezterm.battery_info()) do
    local plugged_in = b.state == 'Charging' or b.state == 'Full'
    local icon = plugged_in and '⚡' or '🔋'
    local pct = math.floor(b.state_of_charge * 100) .. '%'
    for _, v in ipairs({
      { Foreground = { Color = '#9ECE6A' } },
      { Text = icon .. ' ' .. pct },
    }) do table.insert(segments, v) end
    for _, v in ipairs(sep()) do table.insert(segments, v) end
  end

  local date = wezterm.strftime '%a %b %-d'
  local time = wezterm.strftime '%H:%M'

  for _, v in ipairs({
    { Foreground = { Color = '#A9B1D6' } }, { Text = date },
  }) do table.insert(segments, v) end
  for _, v in ipairs(sep()) do table.insert(segments, v) end
  for _, v in ipairs({
    { Foreground = { Color = '#7AA2F7' } }, { Text = time .. '  ' },
  }) do table.insert(segments, v) end

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
  { key = 'LeftArrow',  mods = mod_key, action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = mod_key, action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = mod_key, action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = mod_key, action = wezterm.action.ActivatePaneDirection 'Down' },
  { key = 'z',          mods = mod_key, action = wezterm.action.TogglePaneZoomState },
}

-- Window
config.enable_scroll_bar = false
config.window_padding = {
  left = 20,
  right = 20,
  top = 20,
  bottom = 20,
}

return config
