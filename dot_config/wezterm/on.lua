local wezterm = require("wezterm")
local utils = require("utils")
local keybinds = require("keybinds")
local act = wezterm.action

---------------------------------------------------------------
--- wezterm on
---------------------------------------------------------------
wezterm.on("update-status", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	local process_name = pane:get_foreground_process_name()

	if process_name and (process_name:find("pwsh") or process_name:find("powershell")) then
		overrides.color_scheme = "nightfox"
		overrides.font = wezterm.font("Moralerspace Radon HW")
		overrides.window_background_opacity = 0.85
	else
		overrides.color_scheme = "Catppuccin Mocha"
		overrides.font = wezterm.font("Moralerspace Neon HW")
		overrides.window_background_opacity = 0.65
	end

	window:set_config_overrides(overrides)
end)

-- edit screen size
local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():set_inner_size(960, 512)
end)
