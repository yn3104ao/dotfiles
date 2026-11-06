local wezterm = require("wezterm")
local utils = require("utils")
local keybinds = require("keybinds")
local act = wezterm.action

---------------------------------------------------------------
--- wezterm on
---------------------------------------------------------------
-- edit screen size
local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():set_inner_size(1280, 720)
end)
