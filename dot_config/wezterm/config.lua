local wezterm = require 'wezterm'
local keybinds = require 'keybinds'
local utils = require 'utils'
local config = wezterm.config_builder()

local gpus = wezterm.gui.enumerate_gpus()
local session_name = utils.generate_session_name()
local target_triple = wezterm.target_triple or ''
local is_windows = target_triple:find('windows') ~= nil
local is_linux = target_triple:find('linux') ~= nil

require("on")

local function child_process_succeeds(args)
  local ok, success = pcall(function()
    return wezterm.run_child_process(args)
  end)

  return ok and success
end

local function windows_program_available(program)
  return child_process_succeeds({ 'where.exe', program })
end

-- ==========================================
-- 1. Default Settings
-- ==========================================
local zellij_command = 'zellij attach -c ' .. session_name
local powershell = 'powershell.exe'
local has_wsl = false

if is_windows then
  has_wsl = windows_program_available('wsl.exe')
  if windows_program_available('pwsh.exe') then
    powershell = 'pwsh.exe'
  end

  if has_wsl then
    config.default_prog = { 'wsl.exe', '~', '-d', 'Ubuntu', 'bash', '-l', '-c', zellij_command }
  else
    config.default_prog = { powershell, '-NoLogo' }
  end
elseif is_linux then
  config.default_prog = { 'bash', '-l', '-c', zellij_command }
else
  config.default_prog = { 'bash', '-l', '-c', zellij_command }
end

-- ==========================================
-- 2. Launcher Menu
-- ==========================================
if is_windows then
  config.launch_menu = {
    {
      label = '󰨊  PowerShell (Windows)',
      args = { powershell, '-NoLogo' },
    },
  }

  if has_wsl then
    table.insert(config.launch_menu, {
      label = '  Ubuntu (Clean Shell)',
      args = { 'wsl.exe', '~', '-d', 'Ubuntu' },
    })
  end
else
  config.launch_menu = {
    {
      label = '  Bash',
      args = { 'bash', '-l' },
    },
  }
end

-- ==========================================
-- 3. Exterior (Hyprland knockoff: Acrylic + Catppuccin)
-- ==========================================
config.color_scheme = 'Catppuccin Mocha'
config.font = wezterm.font('Moralerspace Neon HW')

config.window_decorations = "RESIZE"
config.window_padding = {
  left = "1cell",
  right = "1cell",
  top = "0.5cell",
  bottom = "0.5cell",
}

-- tab bar settings
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.enable_scroll_bar = false -- No scroll bar needed

config.window_background_opacity = 0
if gpus[1] then
  config.webgpu_preferred_adapter = gpus[1]
end
config.front_end = "WebGpu"
if is_windows then
  config.win32_system_backdrop = 'Acrylic'
end

-- ==========================================
-- 4. Other settings
-- ==========================================
config.keys = keybinds.create_keybinds()
config.mouse_bindings = keybinds.mouse_bindings
config.use_dead_keys = false
config.warn_about_missing_glyphs = false
config.animation_fps = 120
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.cursor_blink_rate = 0
config.adjust_window_size_when_changing_font_size = false
config.selection_word_boundary = " \t\n{}[]()\"'`,;:│=&!%"
config.exit_behavior = "CloseOnCleanExit"
config.window_close_confirmation = "AlwaysPrompt"
config.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(config.hyperlink_rules, {
	regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
	format = "https://github.com/$1/$3",
})

return config
