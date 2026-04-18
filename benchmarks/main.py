import argparse
import datetime as dt
import json
import os
import sys
import yaml
from pathlib import Path

from typing import Optional, List, Dict, Any

from core.runner import run_agent_cli, get_agent_version
from core.metrics import count_tokens, calculate_savings, get_stats

BENCHMARKS_DIR = Path(__file__).parent
SKILLS_DIR = BENCHMARKS_DIR.parent / "skills"
PROMPTS_FILE = BENCHMARKS_DIR / "prompts" / "dev_questions.yaml"
SNAPSHOTS_DIR = BENCHMARKS_DIR / "data" / "snapshots"

TERSE_PREFIX = "Answer concisely."

def load_prompts() -> List[Dict[str, Any]]:
    with open(PROMPTS_FILE, "r") as f:
        return yaml.safe_load(f)

def cmd_run(args: Any):
    prompts_data = load_prompts()
    prompts = [p["prompt"] for p in prompts_data]
    skills = sorted(p.name for p in SKILLS_DIR.iterdir() if (p / "SKILL.md").exists())
    
    print(f"=== Running Benchmarks: {len(prompts)} prompts ===")
    
    snapshot: Dict[str, Any] = {
        "metadata": {
            "generated_at": dt.datetime.now(dt.timezone.utc).isoformat(),
            "agent_cli_version": get_agent_version(),
            "model": args.model or "default",
            "terse_prefix": TERSE_PREFIX,
        },
        "prompts": prompts,
        "arms": {},
    }
    
    print("-> Running baseline")
    snapshot["arms"]["__baseline__"] = [run_agent_cli(p, model=args.model) for p in prompts]
    
    print("-> Running terse control")
    snapshot["arms"]["__terse__"] = [run_agent_cli(p, system=TERSE_PREFIX, model=args.model) for p in prompts]
    
    for skill in skills:
        print(f"-> Running skill: {skill}")
        skill_md = (SKILLS_DIR / skill / "SKILL.md").read_text()
        system = f"{TERSE_PREFIX}\n\n{skill_md}"
        snapshot["arms"][skill] = [run_agent_cli(p, system=system, model=args.model) for p in prompts]
        
    SNAPSHOTS_DIR.mkdir(parents=True, exist_ok=True)
    out_file = SNAPSHOTS_DIR / "results.json"
    with open(out_file, "w") as f:
        json.dump(snapshot, f, ensure_ascii=False, indent=2)
    print(f"Done! Saved to {out_file}")

def cmd_report(args):
    snapshot_file = SNAPSHOTS_DIR / "results.json"
    if not snapshot_file.exists():
        print("Error: results.json not found. Run 'run' first.")
        return
        
    with open(snapshot_file, "r") as f:
        data = json.load(f)
        
    arms = data["arms"]
    terse_tokens = [count_tokens(o) for o in arms["__terse__"]]
    total_terse = sum(terse_tokens)
    
    print(f"Report Generated: {data['metadata']['generated_at']}")
    print("| Skill | Median | Mean | Tokens (skill / terse) |")
    print("|-------|--------|------|-------------------------|")
    
    for skill, outputs in arms.items():
        if skill.startswith("__"): continue
        skill_tokens = [count_tokens(o) for o in outputs]
        savings = calculate_savings(skill_tokens, terse_tokens)
        stats = get_stats(savings)
        print(f"| **{skill}** | {stats['median']:+.0f}% | {stats['mean']:+.0f}% | {sum(skill_tokens)} / {total_terse} |")

def main():
    parser = argparse.ArgumentParser(description="SHELL Benchmark Suite")
    subparsers = parser.add_subparsers(dest="command")
    
    run_parser = subparsers.add_parser("run", help="Run the benchmarks")
    run_parser.add_argument("--model", help="Agent model alias (e.g., flash, pro)")
    
    subparsers.add_parser("report", help="Generate report from last run")
    
    args = parser.parse_args()
    if args.command == "run":
        cmd_run(args)
    elif args.command == "report":
        cmd_report(args)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
