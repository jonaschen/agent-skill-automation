import sys
import json
import argparse
import subprocess
import os

def get_git_touch_points():
    """Returns a list of files currently modified or staged."""
    try:
        res = subprocess.run(["git", "status", "--porcelain"], capture_output=True, text=True)
        files = []
        for line in res.stdout.strip().split('\n'):
            if line:
                # Porcelain format: XY path
                files.append(line[3:].strip())
        return files
    except:
        return []

def analyze_depth(touch_points):
    """
    Dimension 1 (35%): Cross-module dependency depth.
    Measures how many unique directories are touched.
    """
    if not touch_points:
        return 0.5 # default prior
    
    modules = set()
    for f in touch_points:
        parts = f.split('/')
        if len(parts) > 1:
            modules.add(parts[0])
        else:
            modules.add(".")
            
    # Normalize: 1 module = 0.2, 3+ modules = 1.0
    score = min(len(modules) * 0.3, 1.0)
    return score

def analyze_rollback(touch_points):
    """
    Dimension 2 (25%): State rollback probability.
    High cost for DB schemas, core logic, or infra config.
    """
    if not touch_points:
        return 0.5
        
    high_risk_ext = {'.sql', '.json', '.yaml', '.yml', '.sh'}
    risk_count = 0
    for f in touch_points:
        _, ext = os.path.splitext(f)
        if ext in high_risk_ext:
            risk_count += 1
            
    # Normalize: >20% high-risk files = 1.0
    ratio = risk_count / len(touch_points)
    score = min(ratio * 5, 1.0)
    return score

def analyze_coherence(task_description):
    """
    Dimension 3 (25%): Context coherence requirement.
    Searches for keywords indicating monolithic vs isolated tasks.
    """
    if not task_description:
        return 0.5
        
    high_coherence_keywords = ['refactor', 'migrate', 'audit', 'global', 'architectural']
    low_coherence_keywords = ['add', 'create', 'new', 'isolated', 'independent']
    
    desc = task_description.lower()
    score = 0.5
    for word in high_coherence_keywords:
        if word in desc: score += 0.1
    for word in low_coherence_keywords:
        if word in desc: score -= 0.1
        
    return max(min(score, 1.0), 0.0)

def get_historical_failure():
    """
    Dimension 4 (15%): Historical parallel failure rate.
    Reads from local history db.
    """
    history_file = "eval/tci_history.json"
    if os.path.exists(history_file):
        try:
            with open(history_file) as f:
                data = json.load(f)
                return data.get("global_parallel_failure_rate", 0.5)
        except:
            pass
    return 0.5

def compute_tci(dep_score, rollback_score, coherence_score, failure_rate):
    tci = (
        0.35 * dep_score +
        0.25 * rollback_score +
        0.25 * coherence_score +
        0.15 * failure_rate
    )
    return round(tci, 4)

def select_topology(tci):
    if tci < 0.35:
        return "Track A (Multi-Agent Scrum)"
    elif tci < 0.65:
        return "Track B (Monolithic Flagship - Conservative Default)"
    else:
        return "Track B (Monolithic Flagship)"

def main():
    parser = argparse.ArgumentParser(description="Real-State TCI Calculator")
    parser.add_argument("--desc", help="Task description for coherence analysis")
    parser.add_argument("--json", action="store_true", help="Output results in JSON format")
    args = parser.parse_args()

    touch_points = get_git_touch_points()
    
    dep_score = analyze_depth(touch_points)
    rollback_score = analyze_rollback(touch_points)
    coherence_score = analyze_coherence(args.desc)
    failure_rate = get_historical_failure()

    tci = compute_tci(dep_score, rollback_score, coherence_score, failure_rate)
    topology = select_topology(tci)

    result = {
        "context": {
            "touch_points": touch_points,
            "description_provided": bool(args.desc)
        },
        "metrics": {
            "dependency_depth": dep_score,
            "rollback_probability": rollback_score,
            "context_coherence": coherence_score,
            "historical_failure_rate": failure_rate
        },
        "tci_score": tci,
        "topology": topology
    }

    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print(f"📊 Real-State TCI Computation")
        print(f"--------------------------")
        print(f"Touch Points: {len(touch_points)} files")
        print(f"TCI Score:    {tci}")
        print(f"Topology:     {topology}")
        print(f"--------------------------")
        if tci >= 0.35 and tci < 0.65:
            print("⚠️ Note: Medium coupling detected. defaulting to Track B.")

if __name__ == "__main__":
    main()
