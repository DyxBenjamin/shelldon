#!/usr/bin/env python3
"""Local verification runner for S.H.E.L.L. install surfaces."""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class CheckFailure(RuntimeError):
    pass


def section(title: str) -> None:
    print(f"\n== {title} ==")


def ensure(condition: bool, message: str) -> None:
    if not condition:
        raise CheckFailure(message)


def run(
    args: list[str],
    *,
    cwd: Path = ROOT,
    env: dict[str, str] | None = None,
    check: bool = True,
) -> subprocess.CompletedProcess[str]:
    merged_env = os.environ.copy()
    if env:
        merged_env.update(env)
    result = subprocess.run(
        args,
        cwd=cwd,
        env=merged_env,
        text=True,
        capture_output=True,
        check=False,
    )
    if check and result.returncode != 0:
        raise CheckFailure(
            f"Command failed ({result.returncode}): {' '.join(args)}\n"
            f"stdout:\n{result.stdout}\n"
            f"stderr:\n{result.stderr}"
        )
    return result


def read_json(path: Path) -> object:
    return json.loads(path.read_text())


def verify_synced_files() -> None:
    section("Synced Files")
    skill_source = ROOT / "skills/shell/SKILL.md"
    rule_source = ROOT / "rules/shell-activate.md"

    skill_copies = [
        ROOT / "plugins/shell/skills/shell/SKILL.md",
    ]
    for copy in skill_copies:
        if copy.exists():
            ensure(copy.read_text() == skill_source.read_text(), f"Skill copy mismatch: {copy}")

    rule_copies = [
        ROOT / ".github/copilot-instructions.md",
    ]
    for copy in rule_copies:
        if copy.exists():
            ensure(copy.read_text() == rule_source.read_text(), f"Rule copy mismatch: {copy}")

    print("Synced copies OK")


def verify_manifests_and_syntax() -> None:
    section("Manifests And Syntax")

    manifest_paths = [
        ROOT / ".agents/plugins/marketplace.json",
        ROOT / ".claude-plugin/plugin.json",
        ROOT / ".claude-plugin/marketplace.json",
        ROOT / ".codex/hooks.json",
        ROOT / "gemini-extension.json",
        ROOT / "plugins/shell/.codex-plugin/plugin.json",
    ]
    for path in manifest_paths:
        if path.exists():
            read_json(path)

    run(["node", "--check", "hooks/shell-config.js"])
    run(["node", "--check", "hooks/shell-activate.js"])
    run(["node", "--check", "hooks/shell-mode-tracker.js"])
    run(["bash", "-n", "hooks/install.sh"])
    run(["bash", "-n", "hooks/uninstall.sh"])
    run(["bash", "-n", "hooks/shell-statusline.sh"])

    # Ensure install/uninstall scripts include shell-config.js
    install_sh = (ROOT / "hooks/install.sh").read_text()
    uninstall_sh = (ROOT / "hooks/uninstall.sh").read_text()
    ensure("shell-config.js" in install_sh, "install.sh missing shell-config.js")
    ensure("shell-config.js" in uninstall_sh, "uninstall.sh missing shell-config.js")

    print("JSON manifests and JS/bash syntax OK")


def verify_powershell_static() -> None:
    section("PowerShell Static Checks")
    install_text = (ROOT / "hooks/install.ps1").read_text()
    uninstall_text = (ROOT / "hooks/uninstall.ps1").read_text()
    statusline_text = (ROOT / "hooks/shell-statusline.ps1").read_text()

    ensure("shell-config.js" in install_text, "install.ps1 missing shell-config.js")
    ensure("shell-config.js" in uninstall_text, "uninstall.ps1 missing shell-config.js")
    ensure("shell-statusline.ps1" in install_text, "install.ps1 missing statusline.ps1")
    ensure("shell-statusline.ps1" in uninstall_text, "uninstall.ps1 missing statusline.ps1")
    ensure("-AsHashtable" not in install_text, "install.ps1 should stay compatible with Windows PowerShell 5.1")
    ensure(
        "powershell -ExecutionPolicy Bypass -File" in install_text,
        "install.ps1 missing PowerShell statusline command",
    )
    ensure("[S.H.E.L.L." in statusline_text, "shell-statusline.ps1 missing badge output")

    print("Windows install path statically wired")


def load_compress_modules():
    sys.path.insert(0, str(ROOT / "skills/shell-compress"))
    import scripts.benchmark  # noqa: F401
    import scripts.cli as cli
    import scripts.compress  # noqa: F401
    import scripts.detect as detect
    import scripts.validate as validate

    return cli, detect, validate


def verify_compress_fixtures() -> None:
    section("Compress Fixtures")
    _, detect, validate = load_compress_modules()

    fixtures = sorted((ROOT / "tests/shell-compress").glob("*.original.md"))
    ensure(fixtures, "No shell-compress fixtures found")

    for original in fixtures:
        compressed = original.with_name(original.name.replace(".original.md", ".md"))
        ensure(compressed.exists(), f"Missing compressed fixture for {original.name}")
        result = validate.validate(original, compressed)
        ensure(result.is_valid, f"Fixture validation failed for {compressed.name}: {result.errors}")
        ensure(detect.should_compress(compressed), f"Fixture should be compressible: {compressed.name}")

    print(f"Validated {len(fixtures)} shell-compress fixture pairs")


def verify_hook_install_flow() -> None:
    section("Hook Flow Verification")

    ensure(shutil.which("node") is not None, "node is required for hook verification")
    ensure(shutil.which("bash") is not None, "bash is required for hook verification")

    with tempfile.TemporaryDirectory(prefix="shell-verify-") as temp_root:
        temp_root_path = Path(temp_root)
        home = temp_root_path / "home"
        gemini_dir = home / ".gemini"
        gemini_dir.mkdir(parents=True)

        existing_settings = {
            "statusLine": {"type": "command", "command": "bash /tmp/existing-statusline.sh"},
            "hooks": {"Notification": [{"hooks": [{"type": "command", "command": "echo keep-me"}]}]},
        }
        (gemini_dir / "settings.json").write_text(json.dumps(existing_settings, indent=2) + "\n")

        run(["bash", "hooks/install.sh"], env={"HOME": str(home), "GEMINI_CONFIG_DIR": str(gemini_dir)})

        settings = read_json(gemini_dir / "settings.json")
        hooks = settings["hooks"]
        ensure(settings["statusLine"]["command"] == "bash /tmp/existing-statusline.sh", "install.sh clobbered existing statusLine")
        ensure("SessionStart" in hooks, "SessionStart hook missing after install")
        ensure("UserPromptSubmit" in hooks, "UserPromptSubmit hook missing after install")

        activate = run(
            ["node", "hooks/shell-activate.js"],
            env={"HOME": str(home), "GEMINI_CONFIG_DIR": str(gemini_dir)},
        )
        ensure("S.H.E.L.L. MODE ACTIVE" in activate.stdout, "activation output missing S.H.E.L.L. banner")
        ensure((gemini_dir / ".shell-active").read_text() == "strict", "activation flag should default to strict")

    print("Hook install/uninstall flow OK")


def main() -> int:
    checks = [
        verify_synced_files,
        verify_manifests_and_syntax,
        verify_powershell_static,
        verify_compress_fixtures,
        verify_hook_install_flow,
    ]

    try:
        for check in checks:
            check()
    except CheckFailure as exc:
        print(f"\nFAIL: {exc}", file=sys.stderr)
        return 1

    print("\nAll local verification checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
