local wezterm = require 'wezterm'
local shells = require 'shells'

-- Launch mode is "auto": WSL (Ubuntu) when registered, otherwise PowerShell.
-- Every shell attaches to zellij when it is installed and falls back to the
-- bare shell otherwise (e.g. before mise has provisioned zellij).
local M = {}

local is_windows = (wezterm.target_triple or ''):find('windows') ~= nil

-- POSIX shell snippet: attach to zellij if present, otherwise a plain login shell.
local function zellij_or_shell(name)
  return 'command -v zellij >/dev/null 2>&1 && exec zellij attach -c ' .. name .. ' || exec bash -l'
end

local function herdr_or_shell()
  return 'command -v herdr >/dev/null 2>&1 && exec herdr || exec bash -l'
end

local function pwsh_zellij_command(name)
  -- Run through the profile (ZELLIJ_CONFIG_DIR / HOME); SHELL makes zellij panes use this shell.
  return "if (Get-Command zellij -ErrorAction SilentlyContinue) { $env:SHELL = (Get-Process -Id $PID).Path; zellij attach -c "
    .. name .. '; exit }'
end

-- Falls back to the bare shell when herdr is not installed yet. The pane shell
-- (pwsh) is chosen by terminal.default_shell in the herdr config, not here.
local function pwsh_herdr_command()
  return "if (Get-Command herdr -ErrorAction SilentlyContinue) { herdr; exit }"
end

-- Launcher Menu (Ctrl+Shift+L): only shells that exist
local function apply_local_shells(config, session_name)
  if not is_windows then
    config.default_prog = { 'bash', '-l', '-c', zellij_or_shell(session_name) }
    config.launch_menu = {
      { label = '  Bash', args = { 'bash', '-l' } },
      { label = '  Bash + herdr', args = { 'bash', '-l', '-c', herdr_or_shell() } },
    }
    return
  end

  local has_wsl = shells.wsl_distro_available('Ubuntu')
  local powershell = shells.find_pwsh()
  local git_bash = shells.find_git_bash()

  local pwsh_session = session_name .. '-pwsh'
  local bash_session = session_name .. '-bash'

  if has_wsl then
    config.default_prog = { 'wsl.exe', '~', '-d', 'Ubuntu', 'bash', '-l', '-c', zellij_or_shell(session_name) }
  else
    config.default_prog = { powershell, '-NoLogo', '-NoExit', '-Command', pwsh_zellij_command(pwsh_session) }
  end

  config.launch_menu = {
    { label = '󰨊  PowerShell', args = { powershell, '-NoLogo' } },
    {
      label = '󰨊  PowerShell + zellij',
      args = { powershell, '-NoLogo', '-NoExit', '-Command', pwsh_zellij_command(pwsh_session) },
    },
    {
      label = '󰨊  PowerShell + herdr',
      args = { powershell, '-NoLogo', '-NoExit', '-Command', pwsh_herdr_command() },
    },
  }
  if git_bash then
    table.insert(config.launch_menu, { label = '  Git Bash', args = { git_bash, '-l', '-i' } })
    table.insert(config.launch_menu, {
      label = '  Git Bash + zellij',
      args = { git_bash, '-l', '-c', zellij_or_shell(bash_session) },
    })
    table.insert(config.launch_menu, {
      label = '  Git Bash + herdr',
      args = { git_bash, '-l', '-c', herdr_or_shell() },
    })
  end
  if has_wsl then
    table.insert(config.launch_menu, { label = '  Ubuntu (Clean Shell)', args = { 'wsl.exe', '~', '-d', 'Ubuntu' } })
    table.insert(config.launch_menu, {
      label = '  Ubuntu + herdr',
      args = { 'wsl.exe', '~', '-d', 'Ubuntu', 'bash', '-l', '-c', herdr_or_shell() },
    })
  end
end

-- WezTerm's built-in SSH client cannot use the 1Password agent (a Windows named
-- pipe), so SSH domains fail with "PUBLIC_KEY: Denied". List the Host entries of
-- ~/.ssh/config in the launcher and run the system ssh, which does use the agent.
local function apply_ssh_hosts(config, session_name)
  config.ssh_domains = {}
  -- Run `cmd` when its binary exists on the remote, else a login shell. A login
  -- shell is used first so PATH from the profile (mise shims) is available.
  local function remote_command(binary, cmd)
    return "exec $SHELL -lc 'command -v " .. binary .. ' >/dev/null 2>&1 && exec ' .. cmd .. " || exec $SHELL -l'"
  end

  for _, domain in ipairs(wezterm.default_ssh_domains()) do
    if domain.name:find('^SSH:') then
      local host = domain.remote_address
      table.insert(config.launch_menu, { label = '󰣀  ' .. domain.name, args = { 'ssh', host } })
      table.insert(config.launch_menu, {
        label = '󰣀  ' .. domain.name .. ' + zellij',
        args = { 'ssh', '-t', host, remote_command('zellij', 'zellij attach -c ' .. session_name) },
      })
      table.insert(config.launch_menu, {
        label = '󰣀  ' .. domain.name .. ' + herdr',
        args = { 'ssh', '-t', host, remote_command('herdr', 'herdr') },
      })
    end
  end
end

function M.apply(config, session_name)
  apply_local_shells(config, session_name)
  apply_ssh_hosts(config, session_name)
end

return M
