#!/usr/bin/env node
// shell — shared configuration resolver
//
// Resolution order for default mode:
//   1. SHELL_DEFAULT_MODE environment variable
//   2. Config file defaultMode field:
//      - $XDG_CONFIG_HOME/shell/config.json (any platform, if set)
//      - ~/.config/shell/config.json (macOS / Linux fallback)
//      - %APPDATA%\shell\config.json (Windows fallback)

const fs = require('fs');
const path = require('path');
const os = require('os');

const VALID_MODES = [
  'off', 'verbose', 'strict', 'axiomatic', 'soap',
  'commit', 'review', 'compress'
];

function getEcosystem() {
  if (process.env.GEMINI_CONFIG_DIR || fs.existsSync(path.join(os.homedir(), '.gemini'))) return 'gemini';
  if (process.env.CLAUDE_CONFIG_DIR || fs.existsSync(path.join(os.homedir(), '.claude'))) return 'claude';
  if (process.env.CODEX_CONFIG_DIR || fs.existsSync(path.join(os.homedir(), '.codex'))) return 'codex';
  return 'gemini'; // Default
}

function getConfigDir(ecosystem) {
  const eco = ecosystem || getEcosystem();
  const envVar = eco.toUpperCase() + '_CONFIG_DIR';
  
  if (process.env[envVar]) return process.env[envVar];

  const dirName = '.' + eco;
  if (process.platform === 'win32') {
    return path.join(
      process.env.APPDATA || path.join(os.homedir(), 'AppData', 'Roaming'),
      dirName.slice(1)
    );
  }
  return path.join(os.homedir(), dirName);
}

function getConfigPath(ecosystem) {
  return path.join(getConfigDir(ecosystem), 'shell-config.json');
}

function getDefaultMode() {
  // 1. Environment variable (highest priority)
  const envMode = process.env.SHELL_DEFAULT_MODE;
  if (envMode && VALID_MODES.includes(envMode.toLowerCase())) {
    return envMode.toLowerCase();
  }

  // 2. Config file
  try {
    const configPath = getConfigPath();
    const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    if (config.defaultMode && VALID_MODES.includes(config.defaultMode.toLowerCase())) {
      return config.defaultMode.toLowerCase();
    }
  } catch (e) {
    // Config file doesn't exist or is invalid — fall through
  }

  // 3. Default
  return 'strict';
}

// Symlink-safe flag file write.
// Refuses symlinks at the target file and at the immediate parent directory,
// uses O_NOFOLLOW where available, writes atomically via temp + rename with
// 0600 permissions. Protects against local attackers replacing the predictable
// flag path (~/.gemini/.shell-active) with a symlink to clobber other files.
function safeWriteFlag(flagPath, content) {
  try {
    const flagDir = path.dirname(flagPath);
    fs.mkdirSync(flagDir, { recursive: true });

    // Refuse if the parent directory itself is a symlink (attacker redirect).
    try {
      if (fs.lstatSync(flagDir).isSymbolicLink()) return;
    } catch (e) {
      return;
    }

    // Refuse if the target already exists as a symlink.
    try {
      if (fs.lstatSync(flagPath).isSymbolicLink()) return;
    } catch (e) {
      if (e.code !== 'ENOENT') return;
    }

    const tempPath = path.join(flagDir, `.shell-active.${process.pid}.${Date.now()}`);
    const O_NOFOLLOW = typeof fs.constants.O_NOFOLLOW === 'number' ? fs.constants.O_NOFOLLOW : 0;
    const flags = fs.constants.O_WRONLY | fs.constants.O_CREAT | fs.constants.O_EXCL | O_NOFOLLOW;
    let fd;
    try {
      fd = fs.openSync(tempPath, flags, 0o600);
      fs.writeSync(fd, String(content));
      try { fs.fchmodSync(fd, 0o600); } catch (e) { /* best-effort on Windows */ }
    } finally {
      if (fd !== undefined) fs.closeSync(fd);
    }
    fs.renameSync(tempPath, flagPath);
  } catch (e) {
    // Silent fail — flag is best-effort
  }
}

// Symlink-safe, size-capped, whitelist-validated flag file read.
// Symmetric with safeWriteFlag: refuses symlinks at the target, caps the read,
// and rejects anything that isn't a known mode. Returns null on any anomaly.
const MAX_FLAG_BYTES = 64;

function readFlag(flagPath) {
  try {
    let st;
    try {
      st = fs.lstatSync(flagPath);
    } catch (e) {
      return null;
    }
    if (st.isSymbolicLink() || !st.isFile()) return null;
    if (st.size > MAX_FLAG_BYTES) return null;

    const O_NOFOLLOW = typeof fs.constants.O_NOFOLLOW === 'number' ? fs.constants.O_NOFOLLOW : 0;
    const flags = fs.constants.O_RDONLY | O_NOFOLLOW;
    let fd;
    let out;
    try {
      fd = fs.openSync(flagPath, flags);
      const buf = Buffer.alloc(MAX_FLAG_BYTES);
      const n = fs.readSync(fd, buf, 0, MAX_FLAG_BYTES, 0);
      out = buf.slice(0, n).toString('utf8');
    } finally {
      if (fd !== undefined) fs.closeSync(fd);
    }

    const raw = out.trim().toLowerCase();
    if (!VALID_MODES.includes(raw)) return null;
    return raw;
  } catch (e) {
    return null;
  }
}

module.exports = { getDefaultMode, getConfigDir, getConfigPath, VALID_MODES, safeWriteFlag, readFlag, getEcosystem };
