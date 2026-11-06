local wezterm = require 'wezterm'

-- Shell / executable detection for the launcher. wezterm.run_child_process
-- cannot yield inside require, so these only run when called from the config
-- body (loaded with dofile), never at module load time.
local M = {}

local function probe(args)
  local ok, success = pcall(wezterm.run_child_process, args)
  return ok and success
end

local function command_path(program)
  local ok, success, stdout = pcall(wezterm.run_child_process, { 'where.exe', program })
  if ok and success then
    return stdout and stdout:match('[^\r\n]+')
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

-- PowerShell 7 from the Store is an app execution alias, which io.open cannot
-- see and which is missing from PATH when WezTerm is started by a launcher with
-- a stale environment. Fall back to absolute paths, verified by running them.
function M.find_pwsh()
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

-- Git Bash lives next to git.exe (<root>\cmd\git.exe -> <root>\bin\bash.exe).
-- Never use a bare "bash": on Windows it can be the WSL launcher.
function M.find_git_bash()
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

-- wsl.exe exists on every Windows install (as a stub that offers to install
-- WSL), so check that the distribution is actually registered instead.
function M.wsl_distro_available(distro)
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

return M
