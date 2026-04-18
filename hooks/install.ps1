# shell — one-command hook installer for Gemini CLI, Claude Code, and Codex (Windows PowerShell)
# Installs: SessionStart hook (auto-load rules) + UserPromptSubmit hook (mode tracking)
# Usage: powershell -ExecutionPolicy Bypass -File hooks\install.ps1
#   or:  powershell -ExecutionPolicy Bypass -File hooks\install.ps1 -Force
param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Require node
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: 'node' is required to install the shell hooks (used to merge" -ForegroundColor Red
    Write-Host "       the hook config into settings.json safely)." -ForegroundColor Red
    Write-Host "       Install Node.js from https://nodejs.org and re-run this script." -ForegroundColor Red
    exit 1
}

$EcoDir = if ($env:GEMINI_CONFIG_DIR) { $env:GEMINI_CONFIG_DIR } 
          elseif ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR }
          elseif ($env:CODEX_CONFIG_DIR) { $env:CODEX_CONFIG_DIR }
          elseif (Test-Path (Join-Path $env:USERPROFILE ".gemini")) { Join-Path $env:USERPROFILE ".gemini" }
          elseif (Test-Path (Join-Path $env:USERPROFILE ".claude")) { Join-Path $env:USERPROFILE ".claude" }
          elseif (Test-Path (Join-Path $env:USERPROFILE ".codex")) { Join-Path $env:USERPROFILE ".codex" }
          else { Join-Path $env:USERPROFILE ".gemini" } # Default

$HooksDir = Join-Path $EcoDir "hooks"
$Settings = Join-Path $EcoDir "settings.json"
$RepoUrl = "https://raw.githubusercontent.com/JuliusBrussee/shell/main/hooks"

$HookFiles = @("package.json", "shell-config.js", "shell-activate.js", "shell-mode-tracker.js", "shell-statusline.sh", "shell-statusline.ps1")

# Resolve source
$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { $null }

# Check if already installed
if (-not $Force) {
    $AllFilesPresent = $true
    foreach ($hook in $HookFiles) {
        if (-not (Test-Path (Join-Path $HooksDir $hook))) {
            $AllFilesPresent = $false
            break
        }
    }

    $HooksWired = $false
    $HasStatusLine = $false
    if ($AllFilesPresent -and (Test-Path $Settings)) {
        try {
            $settingsObj = Get-Content $Settings -Raw | ConvertFrom-Json
            $hasS.H.E.L.L.Hook = {
                param([string]$eventName)
                if (-not $settingsObj.hooks) { return $false }
                $entries = $settingsObj.hooks.$eventName
                if (-not $entries) { return $false }
                foreach ($entry in $entries) {
                    if ($entry.hooks) {
                        foreach ($hookDef in $entry.hooks) {
                            if ($hookDef.command -and $hookDef.command.Contains("shell")) {
                                return $true
                            }
                        }
                    }
                }
                return $false
            }
            $HooksWired = (& $hasS.H.E.L.L.Hook "SessionStart") -and (& $hasS.H.E.L.L.Hook "UserPromptSubmit")
            $HasStatusLine = $null -ne $settingsObj.statusLine
        } catch {
            $HooksWired = $false
            $HasStatusLine = $false
        }
    }

    if ($AllFilesPresent -and $HooksWired -and $HasStatusLine) {
        Write-Host "S.H.E.L.L. hooks already installed in $HooksDir"
        Write-Host "  Re-run with -Force to overwrite: powershell -File hooks\install.ps1 -Force"
        Write-Host ""
        Write-Host "Nothing to do. Hooks are already in place."
        exit 0
    }
}

if ($Force -and (Test-Path (Join-Path $HooksDir "shell-activate.js"))) {
    Write-Host "Reinstalling shell hooks (-Force)..."
} else {
    Write-Host "Installing shell hooks..."
}

# 1. Ensure hooks dir exists
if (-not (Test-Path $HooksDir)) {
    New-Item -ItemType Directory -Path $HooksDir -Force | Out-Null
}

# 2. Copy or download hook files
foreach ($hook in $HookFiles) {
    $dest = Join-Path $HooksDir $hook
    $localSource = if ($ScriptDir) { Join-Path $ScriptDir $hook } else { $null }

    if ($localSource -and (Test-Path $localSource)) {
        Copy-Item $localSource $dest -Force
    } else {
        Invoke-WebRequest -Uri "$RepoUrl/$hook" -OutFile $dest -UseBasicParsing
    }
    Write-Host "  Installed: $dest"
}

# 3. Wire hooks + statusline into settings.json (idempotent)
if (-not (Test-Path $Settings)) {
    Set-Content -Path $Settings -Value "{}"
}

# Back up existing settings.json
Copy-Item $Settings "$Settings.bak" -Force

$env:SHELL_SETTINGS = $Settings -replace '\\', '/'
$env:SHELL_HOOKS_DIR = $HooksDir -replace '\\', '/'

$nodeScript = @'
const fs = require('fs');
const settingsPath = process.env.SHELL_SETTINGS;
const hooksDir = process.env.SHELL_HOOKS_DIR;
const managedStatusLinePath = hooksDir + '/shell-statusline.ps1';
const settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
if (!settings.hooks) settings.hooks = {};

// SessionStart
if (!settings.hooks.SessionStart) settings.hooks.SessionStart = [];
const hasStart = settings.hooks.SessionStart.some(e =>
  e.hooks && e.hooks.some(h => h.command && h.command.includes('shell'))
);
if (!hasStart) {
  settings.hooks.SessionStart.push({
    hooks: [{
      type: 'command',
      command: 'node "' + hooksDir + '/shell-activate.js"',
      timeout: 5,
      statusMessage: 'Loading S.H.E.L.L. mode...'
    }]
  });
}

// UserPromptSubmit
if (!settings.hooks.UserPromptSubmit) settings.hooks.UserPromptSubmit = [];
const hasPrompt = settings.hooks.UserPromptSubmit.some(e =>
  e.hooks && e.hooks.some(h => h.command && h.command.includes('shell'))
);
if (!hasPrompt) {
  settings.hooks.UserPromptSubmit.push({
    hooks: [{
      type: 'command',
      command: 'node "' + hooksDir + '/shell-mode-tracker.js"',
      timeout: 5,
      statusMessage: 'Tracking S.H.E.L.L. mode...'
    }]
  });
}

// Statusline
if (!settings.statusLine) {
  settings.statusLine = {
    type: 'command',
    command: 'powershell -ExecutionPolicy Bypass -File "' + managedStatusLinePath + '"'
  };
  console.log('  Statusline badge configured.');
} else {
  const cmd = typeof settings.statusLine === 'string'
    ? settings.statusLine
    : (settings.statusLine.command || '');
  if (cmd.includes(managedStatusLinePath)) {
    console.log('  Statusline badge already configured.');
  } else {
    console.log('  NOTE: Existing statusline detected - shell badge NOT added.');
    console.log('        See hooks/README.md to add the badge to your existing statusline.');
  }
}

fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n');
console.log('  Hooks wired in settings.json');
'@

node -e $nodeScript

Write-Host ""
Write-Host "Done! Restart your agent to activate." -ForegroundColor Green
Write-Host ""
Write-Host "What's installed:"
Write-Host "  - SessionStart hook: auto-loads S.H.E.L.L. rules every session"
Write-Host "  - Mode tracker hook: updates statusline badge when you switch modes"
Write-Host "    (/shell strict, /shell axiomatic, /shell-commit, etc.)"
Write-Host "  - Statusline badge: shows [SHELL] or [SHELL:AXIOMATIC] etc."
