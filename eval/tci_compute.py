import sys
import json
import argparse

def compute_tci(dep_score, rollback_score, coherence_score, failure_rate):
    """
    Computes the Task Coupling Index (TCI) based on four dimensions.
    
    Formula:
    TCI = (depth_score * 0.35) + (rollback_prob * 0.25) + (coherence_score * 0.25) + (failure_rate * 0.15)
    """
    tci = (
        0.35 * dep_score +
        0.25 * rollback_score +
        0.25 * coherence_score +
        0.15 * failure_rate
    )
    return round(tci, 4)

def select_topology(tci):
    """
    Selects the execution topology based on the TCI score.
    """
    if tci < 0.35:
        return "Track A (Multi-Agent Scrum)"
    elif tci < 0.65:
        return "Track B (Monolithic Flagship - Conservative Default)"
    else:
        return "Track B (Monolithic Flagship)"

def main():
    parser = argparse.ArgumentParser(description="Task Coupling Index (TCI) Calculator")
    parser.add_argument("--depth", type=float, default=0.5, help="Dependency depth score (0.0-1.0)")
    parser.add_argument("--rollback", type=float, default=0.5, help="Rollback probability/cost score (0.0-1.0)")
    parser.add_argument("--coherence", type=float, default=0.5, help="Context coherence requirement (0.0-1.0)")
    parser.add_argument("--failure", type=float, default=0.5, help="Historical parallel failure rate (0.0-1.0)")
    parser.add_argument("--json", action="store_true", help="Output results in JSON format")

    args = parser.parse_args()

    tci = compute_tci(args.depth, args.rollback, args.coherence, args.failure)
    topology = select_topology(tci)

    result = {
        "metrics": {
            "dependency_depth": args.depth,
            "rollback_probability": args.rollback,
            "context_coherence": args.coherence,
            "historical_failure_rate": args.failure
        },
        "tci_score": tci,
        "topology": topology
    }

    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print(f"📊 TCI Computation Result")
        print(f"--------------------------")
        print(f"TCI Score: {tci}")
        print(f"Topology:  {topology}")
        print(f"--------------------------")
        if tci >= 0.35 and tci < 0.65:
            print("⚠️ Note: Medium coupling. conservative default to Track B.")

if __name__ == "__main__":
    main()
