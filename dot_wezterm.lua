local wezterm = require("wezterm")

-- ==========================================
-- Load Plugins
-- ==========================================
-- This will be replaced later with chezmoi's auto-placement
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline = require("init")
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
            tabline_x = { 'cpu' , 'ram' },
            -- The time isn't updating (should it be synchronized with `update_right_status`?)
            tabline_y = { wezterm.nerdfonts.md_calender_clock .. ' ' .. wezterm.time():format('%Y/%m/%d %H:%M') .. ' ' },
            tabline_z = { { 'domain' , padding = { left = 0, right = 1 } } },
        }
    }
)


-- ==========================================
-- Override Original Config
-- ==========================================
config = require("config")

return config
