local wezterm = require 'wezterm'
local keybinds = require 'keybinds'
local utils = require 'utils'
local config = wezterm.config_builder()

local gpus = wezterm.gui.enumerate_gpus()
local session_name = utils.generate_session_name()

require("on")

-- ==========================================
-- 1. Default Settings (Automatic Attachment to WSL)
-- ==========================================
config.default_prog = { 'wsl.exe', '~', '-d', 'Ubuntu', 'bash', '-l', '-c', 'zellij attach -c ' .. session_name }

-- ==========================================
-- 2. Launcher Menu (Windows Profile)
-- ==========================================
config.launch_menu = {
  {
    label = '󰨊  PowerShell (Windows)',
    args = { 'pwsh.exe', '-NoLogo' },
  },
  {
    label = '  Ubuntu (Clean Shell)',
    args = { 'wsl.exe', '~', '-d', 'Ubuntu' }, -- WSL without Zellij
  },
  -- If needed, Git Bash or CMD can also be added here.
}

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
config.webgpu_preferred_adapter = gpus[1]
config.front_end = "WebGpu"
config.win32_system_backdrop = 'Acrylic'

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
