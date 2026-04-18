import math
import sys
import json
import argparse

def beta_pdf(x, a, b):
    if x < 0 or x > 1:
        return 0
    # Use log-gamma to prevent overflow: B(a,b) = exp(lgamma(a) + lgamma(b) - lgamma(a+b))
    try:
        log_beta = math.lgamma(a) + math.lgamma(b) - math.lgamma(a+b)
        return math.exp((a-1) * math.log(x) + (b-1) * math.log(1-x) - log_beta)
    except (OverflowError, ZeroDivisionError, ValueError):
        return 0

def beta_cdf(x, a, b):
    if x <= 0: return 0
    if x >= 1: return 1
    
    # Numerical integration using trapezoidal rule for the incomplete beta function
    n_steps = 1000
    step = x / n_steps
    integral = 0
    # Prior log-beta calculation for normalization
    log_beta = math.lgamma(a) + math.lgamma(b) - math.lgamma(a+b)
    
    for i in range(n_steps):
        x_i = (i + 0.5) * step
        # Calculate pdf(x_i) via log space
        try:
            val = math.exp((a-1) * math.log(x_i) + (b-1) * math.log(1-x_i) - log_beta)
            integral += val
        except (OverflowError, ValueError):
            continue
    
    return integral * step

def find_percentile(p, a, b):
    low, high = 0.0, 1.0
    for _ in range(20): # Binary search for precision ~1e-6
        mid = (low + high) / 2
        if beta_cdf(mid, a, b) < p:
            low = mid
        else:
            high = mid
    return low

def get_stats(results):
    """
    results: list of "PASS", "FAIL:*", "SKIP:*"
    Returns dict with posterior_mean, ci_lower, ci_upper (95%)
    """
    k = results.count("PASS")
    # Count anything starting with "FAIL"
    fails = sum(1 for r in results if r.startswith("FAIL"))
    skipped = sum(1 for r in results if r.startswith("SKIP"))
    n = k + fails

    # Prior: Beta(1,1) - Uniform
    # Posterior: Beta(k+1, n-k+1)
    a, b = k + 1, (n - k) + 1

    
    mean = a / (a + b)
    ci_lower = find_percentile(0.025, a, b)
    ci_upper = find_percentile(0.975, a, b)
    
    return {
        "passes": k,
        "total_non_skipped": n,
        "skipped": skipped,
        "posterior_mean": round(mean, 4),
        "ci_lower": round(ci_lower, 4),
        "ci_upper": round(ci_upper, 4)
    }

def main():
    parser = argparse.ArgumentParser(description="Bayesian Evaluation Module")
    parser.add_argument("--results", nargs="+", help="List of PASS/FAIL/SKIP results")
    parser.add_argument("--passes", type=int, help="Number of passing tests (use with --total)")
    parser.add_argument("--total", type=int, help="Total number of tests (use with --passes)")
    parser.add_argument("--compare", nargs=2, metavar=("OLD_JSON", "NEW_JSON"),
                        help="Compare two results; exits 0 if new is significantly better")

    args = parser.parse_args()

    if args.compare:
        with open(args.compare[0]) as f: old = json.load(f)
        with open(args.compare[1]) as f: new = json.load(f)

        print(f"Old: {old['posterior_mean']:.3f} CI [{old['ci_lower']:.3f}, {old['ci_upper']:.3f}]")
        print(f"New: {new['posterior_mean']:.3f} CI [{new['ci_lower']:.3f}, {new['ci_upper']:.3f}]")

        # Rule: New CI lower > Old CI upper (no overlap)
        improved = new['ci_lower'] > old['ci_upper']
        print(f"Significant Improvement: {'✅ YES' if improved else '❌ NO'}")
        sys.exit(0 if improved else 1)

    if args.passes is not None and args.total is not None:
        # Synthesize a results list from pass/total counts
        results = ["PASS"] * args.passes + ["FAIL"] * (args.total - args.passes)
        print(json.dumps(get_stats(results), indent=2))
    elif args.results:
        print(json.dumps(get_stats(args.results), indent=2))
    elif not sys.stdin.isatty():
        results = sys.stdin.read().split()
        print(json.dumps(get_stats(results), indent=2))

if __name__ == "__main__":
    main()
