import statistics
import tiktoken
from typing import List, Dict

ENCODING = tiktoken.get_encoding("o200k_base")

def count_tokens(text: str) -> int:
    return len(ENCODING.encode(text))

def calculate_savings(skill_tokens: List[int], control_tokens: List[int]) -> List[float]:
    return [
        (1 - (s / t)) * 100 if t else 0.0
        for s, t in zip(skill_tokens, control_tokens)
    ]

def get_stats(data_list: List[float]) -> Dict[str, float]:
    if not data_list:
        return {"median": 0, "mean": 0, "min": 0, "max": 0, "stdev": 0}
    return {
        "median": statistics.median(data_list),
        "mean": statistics.mean(data_list),
        "min": min(data_list),
        "max": max(data_list),
        "stdev": statistics.stdev(data_list) if len(data_list) > 1 else 0
    }
