local wezterm = require 'wezterm'
local keybinds = require 'keybinds'
local utils = require 'utils'
local appearance = require 'appearance'
local launcher = require 'launcher'
local config = wezterm.config_builder()

require("on")

-- Detection in launcher.apply runs child processes, so it must be called here
-- in the config body (see dot_wezterm.lua), not from module top-level code.
launcher.apply(config, utils.generate_session_name())
appearance.apply(config)

-- ==========================================
-- Other settings
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
