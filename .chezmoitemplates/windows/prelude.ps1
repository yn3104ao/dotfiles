# ---------------------------------------------------------------------------
# Shared prelude for the chezmoi-managed Windows scripts in .chezmoiscripts.
#
# Keep this file (and every .ps1 script) ASCII-only and compatible with
# Windows PowerShell 5.1: chezmoi runs .ps1 scripts with powershell.exe, which
# decodes BOM-less files with the ANSI code page (e.g. CP932 on Japanese
# Windows), so multi-byte characters such as emoji can corrupt string literals.
# ---------------------------------------------------------------------------

# When chezmoi is started from PowerShell 7, it passes on pwsh's PSModulePath,
# and Windows PowerShell 5.1 then loads the PowerShell 7 builds of the built-in
# modules (e.g. Get-FileHash disappears). Restore the Windows PowerShell paths
# before any module is auto-loaded; child processes inherit the fixed value.
if ($PSVersionTable.PSEdition -ne 'Core') {
    $modulePaths = @(
        (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'WindowsPowerShell\Modules')
        [Environment]::GetEnvironmentVariable('PSModulePath', 'User')
        [Environment]::GetEnvironmentVariable('PSModulePath', 'Machine')
    ) | Where-Object { $_ }
    $env:PSModulePath = $modulePaths -join ';'
    Get-Module -Name 'Microsoft.PowerShell.*' | Where-Object { $_.ModuleBase -notlike "$PSHOME*" } | Remove-Module -Force
}

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$script:ScriptName = 'windows'

function Write-Step([string]$Message) {
    Write-Host "[chezmoi] [$script:ScriptName] $Message"
}

# Installers (winget, safe-chain, ...) only persist PATH changes to the
# registry, while chezmoi hands every script the PATH it was started with.
# Merge the persisted Machine/User PATH back in so new tools are found.
function Update-SessionPath {
    $entries = @(
        $env:Path
        [Environment]::GetEnvironmentVariable('Path', 'Machine')
        [Environment]::GetEnvironmentVariable('Path', 'User')
    ) -join ';' -split ';'
    $seen = @{}
    $merged = foreach ($entry in $entries) {
        if ($entry -and -not $seen.ContainsKey($entry.ToLowerInvariant())) {
            $seen[$entry.ToLowerInvariant()] = $true
            $entry
        }
    }
    $env:Path = $merged -join ';'
}

# Native commands never throw, and a script that "ends normally" exits with 0,
# so chezmoi would record a failed run_once/run_onchange script as done.
# Check $LASTEXITCODE explicitly and throw so that chezmoi sees exit code 1.
function Invoke-Native([string]$FilePath, [string[]]$Arguments = @()) {
    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "'$FilePath $($Arguments -join ' ')' failed with exit code $LASTEXITCODE"
    }
}

# Run a native command only for its exit code. In 5.1, redirected stderr turns
# into ErrorRecords, which would be fatal under ErrorActionPreference = Stop.
function Test-Native([string]$FilePath, [string[]]$Arguments = @()) {
    if (-not (Get-Command $FilePath -ErrorAction SilentlyContinue)) {
        return $false
    }
    $ErrorActionPreference = 'Continue'
    & $FilePath @Arguments *> $null
    return ($LASTEXITCODE -eq 0)
}

function Install-WingetPackage([string]$Id) {
    if (Test-Native 'winget' @('list', '--exact', '--id', $Id, '--accept-source-agreements')) {
        Write-Step "$Id is already installed. Skipping."
        return
    }
    Write-Step "Installing $Id..."
    Invoke-Native 'winget' @('install', '--source', 'winget', '--exact', '--id', $Id, '--accept-package-agreements', '--accept-source-agreements')
}

function Initialize-NativeMethods {
    if ('Chezmoi.NativeMethods' -as [type]) {
        return
    }
    Add-Type -Namespace Chezmoi -Name NativeMethods -MemberDefinition @'
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
public static extern System.IntPtr SendMessageTimeout(System.IntPtr hWnd, uint Msg, System.UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out System.UIntPtr lpdwResult);

[DllImport("gdi32.dll", CharSet = CharSet.Unicode)]
public static extern int AddFontResource(string lpFileName);
'@
}

# Notify running applications (Explorer, terminals, ...) about a change, e.g.
# WM_SETTINGCHANGE (0x1A) after editing the user PATH or WM_FONTCHANGE (0x1D).
function Send-BroadcastMessage([uint32]$Message, [string]$Parameter) {
    Initialize-NativeMethods
    $lParam = if ($Parameter) { $Parameter } else { [NullString]::Value }
    $result = [UIntPtr]::Zero
    [void][Chezmoi.NativeMethods]::SendMessageTimeout([IntPtr]0xffff, $Message, [UIntPtr]::Zero, $lParam, 2, 5000, [ref]$result)
}

function Add-FontResource([string]$Path) {
    Initialize-NativeMethods
    return [Chezmoi.NativeMethods]::AddFontResource($Path)
}
