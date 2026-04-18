import os
import shutil
import subprocess
from pathlib import Path
from typing import Optional

def run_agent_cli(prompt: str, system: Optional[str] = None, model: Optional[str] = None) -> str:
    agent_cmd = os.environ.get("SHELL_AGENT")
    if not agent_cmd:
        for cmd in ["gemini", "claude", "codex"]:
            if shutil.which(cmd):
                agent_cmd = cmd
                break
    if not agent_cmd: agent_cmd = "gemini"

    instr_file = Path("EVAL_INSTRUCTIONS.md")
    if system:
        instr_file.write_text(system)

    try:
        cmd = [agent_cmd]
        if "gemini" in agent_cmd:
            if model:
                cmd += ["-m", model]
            else:
                cmd += ["-m", "flash"]
            cmd += ["-p", prompt]
        else:
            cmd += ["-p", prompt]
            
        out = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return out.stdout.strip()
    finally:
        if instr_file.exists():
            instr_file.unlink()

def get_agent_version() -> str:
    agent_cmd = os.environ.get("SHELL_AGENT")
    if not agent_cmd:
        for cmd in ["gemini", "claude", "codex"]:
            if shutil.which(cmd):
                agent_cmd = cmd
                break
    if not agent_cmd: agent_cmd = "gemini"

    try:
        out = subprocess.run(
            [agent_cmd, "--version"], capture_output=True, text=True, check=True
        )
        return out.stdout.strip()
    except Exception:
        return "unknown"
