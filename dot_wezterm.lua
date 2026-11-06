local wezterm = require("wezterm")

-- ==========================================
-- Load Plugins
-- ==========================================
-- This will be replaced later with chezmoi's auto-placement
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup(
    {
        options = {
            icons_enabled = true,
            theme = 'Catppuccin Mocha',
            tabs_enabled = true,
            theme_overrides = {},
            section_separators = {
                left = wezterm.nerdfonts.ple_right_half_circle_thick,
                right = wezterm.nerdfonts.ple_left_half_circle_thick,
            },
            component_separators = {
                left = wezterm.nerdfonts.ple_right_soft_divider,
                right = wezterm.nerdfonts.ple_left_soft_divider,
            },
            tab_separators = {
                left = wezterm.nerdfonts.ple_right_half_circle_thick,
                right = wezterm.nerdfonts.ple_left_half_circle_thick,
            }
        },
        sections = {
            tabline_a = { ' ' .. wezterm.nerdfonts.cod_home .. ' ' },
            tabline_b = { ' ' .. wezterm.nerdfonts.cod_account .. ' ' },
            tabline_c = { ' ' },
            tab_active = { 'index' },
            tab_inactive = { 'index' },
            -- wmic (the plugin default) is gone on current Windows 11; query via PowerShell and poll rarely since the call blocks the GUI
            tabline_x = { { 'cpu', use_pwsh = true, throttle = 10 }, { 'ram', use_pwsh = true, throttle = 10 } },
            tabline_y = { { 'datetime', style = '%Y/%m/%d %H:%M', icon = wezterm.nerdfonts.md_calendar_clock, hour_to_icon = false } },
            tabline_z = { { 'domain' , padding = { left = 0, right = 1 } } },
        }
    }
)


-- ==========================================
-- Override Original Config
-- ==========================================
-- dofile instead of require: wezterm.run_child_process (used for shell detection) cannot yield inside require
config = dofile(assert(package.searchpath("config", package.path)))

return config
