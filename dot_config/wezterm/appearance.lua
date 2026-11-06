local wezterm = require 'wezterm'

-- Exterior (Hyprland knockoff: Acrylic + Catppuccin)
local M = {}

function M.apply(config)
  config.color_scheme = 'Catppuccin Mocha'
  config.font = wezterm.font('Moralerspace Neon HW')

  config.window_decorations = 'RESIZE'
  config.window_padding = {
    left = '1cell',
    right = '1cell',
    top = '0.5cell',
    bottom = '0.5cell',
  }

  -- tab bar settings
  config.tab_bar_at_bottom = false
  config.use_fancy_tab_bar = false
  config.hide_tab_bar_if_only_one_tab = false
  config.enable_scroll_bar = false -- No scroll bar needed

  config.window_background_opacity = 0.65
  local gpus = wezterm.gui.enumerate_gpus()
  if gpus[1] then
    config.webgpu_preferred_adapter = gpus[1]
  end
  config.front_end = 'WebGpu'
  if (wezterm.target_triple or ''):find('windows') then
    config.win32_system_backdrop = 'Acrylic'
  end
end

return M
