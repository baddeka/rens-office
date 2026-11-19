# Installs Rens Office on Windows and starts it. Paste into PowerShell:
#
#   irm https://raw.githubusercontent.com/baddeka/spaceeeeee/HEAD/install.ps1 | iex
#
# It gets what's missing (Git, uv, which brings its own Python, and Claude Code), puts the office in
# your user folder under rens-office, adds a Rens Office shortcut to the desktop and the Start menu,
# asks you to sign in to your Claude account once, and opens the office. Run it again any time: it
# only updates what is there.

$ErrorActionPreference = 'Continue'
$Repo = if ($env:RENS_OFFICE_REPO) { $env:RENS_OFFICE_REPO } else { 'https://github.com/baddeka/spaceeeeee' }
$Dir = if ($env:RENS_OFFICE_DIR) { $env:RENS_OFFICE_DIR } else { Join-Path $HOME 'rens-office' }

function Step([string]$Text) { Write-Host "`n==> $Text" -ForegroundColor Cyan }
function Have([string]$Name) { [bool](Get-Command $Name -ErrorAction SilentlyContinue) }
function Update-SessionPath {
  # Installers add to the saved PATH; this window only sees it once it is read again.
  $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
  $user = [Environment]::GetEnvironmentVariable('Path', 'User')
  $env:Path = (Join-Path $HOME '.local\bin') + ";$user;$machine"
}

function Install-RensOffice {
  Update-SessionPath

  if (-not (Have 'git')) {
    Step 'Installing Git (Claude Code needs it on Windows too)'
    if (Have 'winget') {
      winget install --id Git.Git --exact --source winget --accept-package-agreements --accept-source-agreements
      Update-SessionPath
    }
    if (-not (Have 'git')) {
      Write-Host 'Install Git from https://git-scm.com/download/win, then run this again.'
      return
    }
  }

  if (-not (Have 'uv')) {
    Step 'Installing uv, which brings its own Python'
    powershell -NoProfile -ExecutionPolicy Bypass -Command 'irm https://astral.sh/uv/install.ps1 | iex'
    Update-SessionPath
  }

  if (-not (Have 'claude')) {
    Step 'Installing Claude Code'
    powershell -NoProfile -ExecutionPolicy Bypass -Command 'irm https://claude.ai/install.ps1 | iex'
    Update-SessionPath
  }

  if (Test-Path (Join-Path $Dir '.git')) {
    Step "Updating Rens Office in $Dir"
    git -C $Dir pull --ff-only
    if ($LASTEXITCODE -ne 0) { Write-Host 'Could not update; keeping the version that is there.' }
  } elseif (Test-Path $Dir) {
    Write-Host "$Dir already exists and is not Rens Office. Move it away, or set RENS_OFFICE_DIR, and run this again."
    return
  } else {
    Step "Downloading Rens Office into $Dir"
    git clone --quiet $Repo $Dir
    if ($LASTEXITCODE -ne 0) {
      Write-Host 'Could not download Rens Office. Check the internet connection and run this again.'
      return
    }
  }

  Step 'Adding Rens Office to the desktop and the Start menu'
  $shell = New-Object -ComObject WScript.Shell
  foreach ($folder in @([Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('Programs'))) {
    $link = $shell.CreateShortcut((Join-Path $folder 'Rens Office.lnk'))
    $link.TargetPath = Join-Path $Dir 'Rens Office.bat'
    $link.WorkingDirectory = $Dir
    $link.Description = 'Rens Office'
    $link.Save()
  }

  Step 'Starting Rens Office'
  # The launcher sets up Python, asks you to sign in to Claude if nobody is, and opens the office.
  & (Join-Path $Dir 'Rens Office.bat')
}

Install-RensOffice
