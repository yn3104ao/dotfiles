local wezterm = require 'wezterm'
local keybinds = require 'keybinds'
local utils = require 'utils'
local config = wezterm.config_builder()

local gpus = wezterm.gui.enumerate_gpus()
local session_name = utils.generate_session_name()
local target_triple = wezterm.target_triple or ''
local is_windows = target_triple:find('windows') ~= nil
local is_linux = target_triple:find('linux') ~= nil

require("on")

local function child_process_succeeds(args)
  local ok, success = pcall(function()
    return wezterm.run_child_process(args)
  end)

  return ok and success
end

local function windows_program_available(program)
  return child_process_succeeds({ 'where.exe', program })
end

-- PowerShell 7 from the Store is an app execution alias, which io.open cannot
-- see and which is missing from PATH when WezTerm is started by a launcher with
-- a stale environment. Fall back to absolute paths, verified by running them.
local function find_pwsh()
  local function probe(args)
    local ok, success = pcall(wezterm.run_child_process, args)
    return ok and success
  end

  if probe({ 'where.exe', 'pwsh.exe' }) then
    return 'pwsh.exe'
  end
  local candidates = { 'C:/Program Files/PowerShell/7/pwsh.exe' }
  local local_app_data = os.getenv('LOCALAPPDATA')
  if local_app_data then
    table.insert(candidates, 1, local_app_data:gsub('\\', '/') .. '/Microsoft/WindowsApps/pwsh.exe')
  end
  for _, path in ipairs(candidates) do
    if probe({ path, '-NoProfile', '-Command', 'exit' }) then
      return path
    end
  end
  return 'powershell.exe'
end

-- wsl.exe exists on every Windows install (as a stub that offers to install
-- WSL), so check that the distribution is actually registered instead.
local function wsl_distro_available(distro)
  local ok, success, stdout = pcall(wezterm.run_child_process, { 'wsl.exe', '--list', '--quiet' })
  if not (ok and success and stdout) then
    return false
  end

  -- wsl.exe writes UTF-16LE; dropping the NUL bytes is enough for ASCII names.
  for name in stdout:gsub('\0', ''):gmatch('[^\r\n]+') do
    if name == distro then
      return true
    end
  end
  return false
end

-- ==========================================
-- 1. Default Settings
-- ==========================================
-- Launch mode is "auto": WSL (Ubuntu) when registered, otherwise PowerShell.
-- Every shell attaches to zellij when it is installed and falls back to the
-- bare shell otherwise (e.g. before mise has provisioned zellij).
local function first_line(s)
  return s and s:match('[^\r\n]+')
end

local function command_path(program)
  local ok, success, stdout = pcall(wezterm.run_child_process, { 'where.exe', program })
  if ok and success then
    return first_line(stdout)
  end
  return nil
end

local function file_exists(path)
  local f = path and io.open(path, 'r')
  if f then
    f:close()
    return true
  end
  return false
end

-- Git Bash lives next to git.exe (<root>\cmd\git.exe -> <root>\bin\bash.exe).
-- Never use a bare "bash": on Windows it can be the WSL launcher.
local function find_git_bash()
  local candidates = {}
  local git = command_path('git.exe')
  local root = git and git:gsub('\\', '/'):match('^(.*)/cmd/git%.exe$')
  if root then
    table.insert(candidates, root .. '/bin/bash.exe')
  end
  table.insert(candidates, 'C:/Program Files/Git/bin/bash.exe')
  local local_app_data = os.getenv('LOCALAPPDATA')
  if local_app_data then
    table.insert(candidates, local_app_data:gsub('\\', '/') .. '/Programs/Git/bin/bash.exe')
  end
  for _, path in ipairs(candidates) do
    if file_exists(path) then
      return path
    end
  end
  return nil
end

-- POSIX shell snippet: attach to zellij if present, otherwise a plain login shell.
local function zellij_or_shell(name)
  return 'command -v zellij >/dev/null 2>&1 && exec zellij attach -c ' .. name .. ' || exec bash -l'
end

local function pwsh_zellij_command(name)
  -- Run through the profile (ZELLIJ_CONFIG_DIR / HOME); SHELL makes zellij panes use this shell.
  return "if (Get-Command zellij -ErrorAction SilentlyContinue) { $env:SHELL = (Get-Process -Id $PID).Path; zellij attach -c "
    .. name .. '; exit }'
end

local default_prog
if is_windows then
  local has_wsl = wsl_distro_available('Ubuntu')
  local powershell = find_pwsh()
  local git_bash = find_git_bash()

  local pwsh_session = session_name .. '-pwsh'
  local bash_session = session_name .. '-bash'

  if has_wsl then
    default_prog = { 'wsl.exe', '~', '-d', 'Ubuntu', 'bash', '-l', '-c', zellij_or_shell(session_name) }
  else
    default_prog = { powershell, '-NoLogo', '-NoExit', '-Command', pwsh_zellij_command(pwsh_session) }
  end

  -- ==========================================
  -- 2. Launcher Menu (Ctrl+Shift+L): only shells that exist
  -- ==========================================
  config.launch_menu = {
    { label = '󰨊  PowerShell', args = { powershell, '-NoLogo' } },
    {
      label = '󰨊  PowerShell + zellij',
      args = { powershell, '-NoLogo', '-NoExit', '-Command', pwsh_zellij_command(pwsh_session) },
    },
  }
  if git_bash then
    table.insert(config.launch_menu, { label = '  Git Bash', args = { git_bash, '-l', '-i' } })
    table.insert(config.launch_menu, {
      label = '  Git Bash + zellij',
      args = { git_bash, '-l', '-c', zellij_or_shell(bash_session) },
    })
  end
  if has_wsl then
    table.insert(config.launch_menu, { label = '  Ubuntu (Clean Shell)', args = { 'wsl.exe', '~', '-d', 'Ubuntu' } })
  end
else
  default_prog = { 'bash', '-l', '-c', zellij_or_shell(session_name) }
  config.launch_menu = {
    {
      label = '  Bash',
      args = { 'bash', '-l' },
    },
  }
end
config.default_prog = default_prog

-- WezTerm's built-in SSH client cannot use the 1Password agent (a Windows named
-- pipe), so SSH domains fail with "PUBLIC_KEY: Denied". List the Host entries of
-- ~/.ssh/config in the launcher and run the system ssh, which does use the agent.
config.ssh_domains = {}
for _, domain in ipairs(wezterm.default_ssh_domains()) do
  if domain.name:find('^SSH:') then
    local host = domain.remote_address
    table.insert(config.launch_menu, { label = '󰣀  ' .. domain.name, args = { 'ssh', host } })
    -- Attach to zellij on the remote when installed, else a login shell.
    table.insert(config.launch_menu, {
      label = '󰣀  ' .. domain.name .. ' + zellij',
      args = {
        'ssh',
        '-t',
        host,
        'command -v zellij >/dev/null 2>&1 && exec zellij attach -c ' .. session_name .. ' || exec $SHELL -l',
      },
    })
  end
end

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

config.window_background_opacity = 0.65
if gpus[1] then
  config.webgpu_preferred_adapter = gpus[1]
end
config.front_end = "WebGpu"
if is_windows then
  config.win32_system_backdrop = 'Acrylic'
end

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
