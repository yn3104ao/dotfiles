local wezterm = require("wezterm")
local utils = require("utils")
local keybinds = require("keybinds")
local act = wezterm.action

-- selene: allow(unused_variable)
---@diagnostic disable-next-line: unused-local
local function create_tab_title(tab, tabs, panes, config, hover, max_width)
	-- local user_title = tab.active_pane.user_vars.panetitle
	local user_title = tab.active_pane.title
	if user_title ~= nil and #user_title > 0 then
		return user_title
	end
	-- pane:get_foreground_process_info().status

	local title = wezterm.truncate_right(utils.without_ext(tab.active_pane.foreground_process_name), max_width)
	if title == "" then
		local dir = string.gsub(tab.active_pane.title, "(.*[: ])(.*)]", "%2")
		dir = utils.convert_useful_path(dir)
		title = wezterm.truncate_right(dir, max_width)
	end

	local copy_mode, n = string.gsub(tab.active_pane.title, "(.+) mode: .*", "%1", 1)
	if copy_mode == nil or n == 0 then
		copy_mode = ""
	else
		copy_mode = copy_mode .. ": "
	end
	return copy_mode .. title
end

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

-- selene: allow(unused_variable)
---@diagnostic disable-next-line: unused-local
local function update_ssh_status(window, pane)
	local text = pane:get_domain_name()
	if text == "local" then
		text = ""
	end
	return {
		{ Attribute = { Italic = true } },
		{ Text = text .. " " },
	}
end

-- selene: allow(unused_variable)
---@diagnostic disable-next-line: unused-function, unused-local
local function display_ime_on_right_status(window, pane)
	local compose = window:composition_status()
	if compose then
		compose = "COMPOSING: " .. compose
	end
	window:set_right_status(compose)
end

-- selene: allow(unused_variable)
---@diagnostic disable-next-line: unused-local
local function display_copy_mode(window, pane)
	local name = window:active_key_table()
	if name then
		name = "Mode: " .. name
	end
	return { { Attribute = { Italic = false } }, { Text = name or "" } }
end

wezterm.on("update-right-status", function(window, pane)
	local ssh = update_ssh_status(window, pane)
	local copy_mode = display_copy_mode(window, pane)
	-- update_window_background(window, pane)
	local status = utils.merge_lists(ssh, copy_mode)
	window:set_right_status(wezterm.format(status))
end)

-- https://github.com/wez/wezterm/issues/2979#issuecomment-1447519267
local hacky_user_commands = {
	-- selene: allow(unused_variable)
	---@diagnostic disable-next-line: unused-local
	["scroll-up"] = function(window, pane, cmd_context)
		window:perform_action(wezterm.action({ ScrollByPage = -1 }), pane)
		-- wezterm.action({ ScrollByPage = -1 })
	end,
	-- selene: allow(unused_variable)
	---@diagnostic disable-next-line: unused-local
	["scroll-down"] = function(window, pane, cmd_context)
		window:perform_action(wezterm.action({ ScrollByPage = 1 }), pane)
	end,
}

wezterm.on("user-var-changed", function(window, pane, name, value)
	if name == "hacky-user-command" then
		local cmd_context = wezterm.json_parse(value)
		hacky_user_commands[cmd_context.cmd](window, pane, cmd_context)
		return
	end
end)

-- edit screen size
local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():set_inner_size(960, 512)
end)
