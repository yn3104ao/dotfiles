local M = {}
local wezterm = require("wezterm")
local act = wezterm.action
local utils = require("utils")

--- ==========================================
--   Key Bindings (Launcher Launch)
-- ==========================================
M.default_keybinds = {
	-- Luncher
	{
		key = 'L',
		mods = 'CTRL|SHIFT',
		-- Enable menu selection via fuzzy search
		action = act.ShowLauncherArgs { flags = 'FUZZY|TABS|LAUNCH_MENU_ITEMS' },
	},

	-- Copy and Paste
	{ key = "c", mods = "CTRL|SHIFT", action = act({ CopyTo = "Clipboard" }) },
	{ key = "v", mods = "CTRL|SHIFT", action = act({ PasteFrom = "Clipboard" }) },

	-- Font size
	{ key = "=", mods = "CTRL", action = "ResetFontSize" },
	{ key = "+", mods = "CTRL|SHIFT", action = "IncreaseFontSize" },
	{ key = "-", mods = "CTRL", action = "DecreaseFontSize" },
	{ key = "0", mods = "CTRL", action = "ResetFontSize" },

	--Reload config
	{ key = "z", mods = "CTRL|SHIFT", action = "ReloadConfiguration" },

	--Close tab without confirmation
	{ key = "q", mods = "ALT", action = act({ CloseCurrentPane = { confirm = false } }) },
	{ key = "w", mods = "CTRL|SHIFT", action = act({ CloseCurrentPane = { confirm = false } }) },

	-- For Debugging
	{ key = 'L', mods = 'CTRL', action = act.ShowDebugOverlay },
}

M.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act({ CompleteSelection = "PrimarySelection" }),
	},
	{
		event = { Up = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = act({ CompleteSelection = "Clipboard" }),
	},
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = "OpenLinkAtMouseCursor",
	},
}


function M.create_keybinds()
	return utils.merge_lists(M.default_keybinds, M.my_keybinds)
end

return M
