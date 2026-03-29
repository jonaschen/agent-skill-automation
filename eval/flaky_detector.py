import json
import os
import sys

def calculate_flip_rate(history):
    if len(history) < 2:
        return 0.0
    flips = 0
    for i in range(1, len(history)):
        if history[i] != history[i-1]:
            flips += 1
    return flips / (len(history) - 1)

def get_status(history, threshold=0.4, min_runs=5):
    if len(history) < min_runs:
        pass_rate = sum(history) / len(history) if history else 0.0
        return "INSUFFICIENT_DATA", 0.0, 0.0, pass_rate
    
    flip_rate = calculate_flip_rate(history)
    pass_rate = sum(history) / len(history)
    
    # Logic from CANVAS.md: flip rate > 40% means flaky
    is_flaky = flip_rate > threshold
    
    # Confidence score: simple implementation
    # More runs = more confidence
    confidence = min(len(history) / 10.0, 1.0)
    
    status = "FLAKY" if is_flaky else "STABLE"
    return status, confidence, flip_rate, pass_rate

def main():
    history_file = 'eval/flaky_history.json'
    
    if not os.path.exists(history_file):
        # Create empty history if it doesn't exist
        with open(history_file, 'w') as f:
            json.dump({"test_results": {}}, f)
            
    with open(history_file, 'r') as f:
        data = json.load(f)
        
    test_results = data.get("test_results", {})

    if len(sys.argv) < 2:
        # Show all
        print(f"{'Test':<10} | {'Status':<15} | {'Flip Rate':<10} | {'Pass Rate':<10} | {'Confidence':<10}")
        print("-" * 65)
        for test_id, history in sorted(test_results.items()):
            status, conf, flip, pass_r = get_status(history)
            print(f"{test_id:<10} | {status:<15} | {flip:.2f}      | {pass_r:.2f}      | {conf:.2f}")
    else:
        test_id = sys.argv[1]
        if test_id not in test_results:
            print(f"NOT_FOUND: {test_id}")
            sys.exit(1)
        
        history = test_results[test_id]
        status, conf, flip, pass_r = get_status(history)
        print(f"{status} (Confidence: {conf:.2f}, Flip Rate: {flip:.2f}, Pass Rate: {pass_r:.2f})")

if __name__ == "__main__":
    main()
