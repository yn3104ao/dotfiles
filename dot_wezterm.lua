local wezterm = require("wezterm")

-- ==========================================
-- Load Plugins
-- ==========================================
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup()


-- ==========================================
-- Override Original Config
-- ==========================================
config = require("config")

return config
