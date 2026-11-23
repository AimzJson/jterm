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

-- Shell
if is_windows then
  config.default_prog = { 'pwsh', '-NoLogo' }
end

-- Startup layout
local function make_layout(pane)
  pane:split { direction = 'Bottom', size = 0.2 }
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
    make_layout(pane)
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
config.window_background_opacity = 0.9
config.window_decorations = 'RESIZE'

-- Windows equivalent of macos_window_background_blur
if is_windows then
  config.win32_system_backdrop = 'Acrylic'
end

-- Tab bar (used for status bar)
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 32

config.colors.tab_bar = {
  background = '#16161E',
  active_tab   = { bg_color = '#16161E', fg_color = '#C0CAF5' },
  inactive_tab = { bg_color = '#16161E', fg_color = '#414868' },
  new_tab      = { bg_color = '#16161E', fg_color = '#414868' },
}

-- Agent deck: tab status dots + notifications. Its built-in right status is
-- disabled so the counts render inside our own status handler below.
-- Registered before that handler so agent state is fresh when it reads counts.
local agent_deck = wezterm.plugin.require 'https://github.com/Eric162/wezterm-agent-deck'
agent_deck.apply_to_config(config, {
  update_interval = 1000,
  right_status = { enabled = false },
  colors = {
    working  = '#9ECE6A',
    waiting  = '#E0AF68',
    idle     = '#7AA2F7',
    inactive = '#414868',
  },
})

-- Agent quota exposes no API for its status text, only an update-status
-- handler that writes straight to the window. Capture that handler at
-- registration and run it against a stub window so the text can be composed
-- into our own right status instead of overwriting it.
local function capture_quota_status(plugin, opts)
  local handler
  local register = wezterm.on
  wezterm.on = function(event, callback)
    if event == 'update-status' then
      handler = callback
    else
      register(event, callback)
    end
  end
  plugin.apply_to_config(config, opts)
  wezterm.on = register

  return function(pane)
    if not handler then return '' end
    local text = ''
    handler({ set_right_status = function(_, status) text = status end }, pane)
    return text
  end
end

local quota_status = capture_quota_status(
  wezterm.plugin.require 'https://github.com/M-Marbouh/agent-quota.wezterm',
  {
    position = 'right',
    layout = 'compact',
    -- Drops providers whose CLI isn't running; Codex is never used here
    hide_inactive = true,
    -- Default CTRL+SHIFT+U would shadow WezTerm's built-in CharSelect
    dashboard_key = false,
  }
)

local function sep()
  return {
    { Foreground = { Color = '#414868' } },
    { Text = '  ◆  ' },
  }
end

local AGENT_STATUS_ORDER = { 'waiting', 'working' }

wezterm.on('update-status', function(window, pane)
  local segments = {}

  local quota = quota_status(pane)
  if quota ~= '' then
    table.insert(segments, { Text = quota })
    for _, v in ipairs(sep()) do table.insert(segments, v) end
  end

  local counts = agent_deck.count_agents_by_status()
  for _, status in ipairs(AGENT_STATUS_ORDER) do
    if counts[status] > 0 then
      for _, v in ipairs({
        { Foreground = { Color = agent_deck.get_status_color(status) } },
        { Text = agent_deck.get_status_icon(status) .. ' ' .. counts[status] .. ' ' .. status },
      }) do table.insert(segments, v) end
      for _, v in ipairs(sep()) do table.insert(segments, v) end
    end
  end

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
      make_layout(pane)
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
