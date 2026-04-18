# shell — statusline badge script for Gemini CLI, Claude Code, and Codex
# Reads the shell mode flag file and outputs a colored badge.

$EcoDir = if ($env:GEMINI_CONFIG_DIR) { $env:GEMINI_CONFIG_DIR } 
          elseif ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR }
          elseif ($env:CODEX_CONFIG_DIR) { $env:CODEX_CONFIG_DIR }
          elseif (Test-Path "$HOME\.gemini") { "$HOME\.gemini" }
          elseif (Test-Path "$HOME\.claude") { "$HOME\.claude" }
          elseif (Test-Path "$HOME\.codex") { "$HOME\.codex" }
          else { exit 0 }

$Flag = Join-Path $EcoDir ".shell-active"
if (-not (Test-Path $Flag)) { exit 0 }

# Refuse reparse points
try {
    $Item = Get-Item -LiteralPath $Flag -Force -ErrorAction Stop
    if ($Item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { exit 0 }
    if ($Item.Length -gt 64) { exit 0 }
} catch {
    exit 0
}

$Mode = ""
try {
    $Raw = Get-Content -LiteralPath $Flag -TotalCount 1 -ErrorAction Stop
    if ($null -ne $Raw) { $Mode = ([string]$Raw).Trim() }
} catch {
    exit 0
}

# Whitelist-validate
$Mode = $Mode.ToLowerInvariant()
$Mode = ($Mode -replace '[^a-z0-9-]', '')

$Valid = @('off','verbose','strict','axiomatic','soap','commit','review','compress')
if (-not ($Valid -contains $Mode)) { exit 0 }

$Esc = [char]27
if ([string]::IsNullOrEmpty($Mode) -or $Mode -eq "strict") {
    [Console]::Write("${Esc}[38;5;172m[S.H.E.L.L.]${Esc}[0m")
} else {
    $Suffix = $Mode.ToUpperInvariant()
    [Console]::Write("${Esc}[38;5;172m[S.H.E.L.L.:$Suffix]${Esc}[0m")
}
