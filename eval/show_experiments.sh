#!/bin/bash
# eval/show_experiments.sh - Display optimization experiments from eval/experiment_log.json

LOG_FILE="eval/experiment_log.json"

if [ ! -f "$LOG_FILE" ]; then
    echo "❌ Error: $LOG_FILE not found."
    exit 0
fi

SKILL_NAME=$(jq -r '.skill_name' "$LOG_FILE")
echo "📊 Optimization Experiments for: $SKILL_NAME"
echo ""

# Table header
printf "%-5s | %-10s | %-8s | %-8s | %-8s | %-10s\n" "#" "Branch" "Base" "New" "Delta" "Committed"
echo "----------------------------------------------------------------------"

# Process experiments
# We'll calculate baseline/delta if they're not explicitly in the JSON
jq -c '.experiments[]' "$LOG_FILE" | while read -r exp; do
    ITER=$(echo "$exp" | jq -r '.iteration')
    BRANCH=$(echo "$exp" | jq -r '.branch')
    NEW_RATE=$(echo "$exp" | jq -r '.pass_rate')
    
    # Check if delta/baseline are present, if not, they'll be empty
    DELTA=$(echo "$exp" | jq -r '.delta // empty')
    BASELINE=$(echo "$exp" | jq -r '.baseline_rate // empty')
    
    # If delta is empty, we can't show it unless we keep state, but let's try to be smart
    # Actually, the JSON schema in the dev plan or CANVAS might be a bit different
    # than iteration 0. Let's just use what's available.
    
    OUTCOME=$(echo "$exp" | jq -r '.outcome')
    COMMITTED="no"
    if [ "$OUTCOME" == "commit" ]; then
        COMMITTED="yes"
    elif [ "$OUTCOME" == "base" ]; then
        COMMITTED="base"
    fi
    
    printf "%-5s | %-10s | %-8s | %-8s | %-8s | %-10s\n" "$ITER" "$BRANCH" "${BASELINE:-N/A}" "$NEW_RATE" "${DELTA:-N/A}" "$COMMITTED"
done

echo ""
# Summary
TOTAL_ITER=$(jq '.experiments | length' "$LOG_FILE")
BEST_RATE=$(jq -r '.experiments | map(.pass_rate) | max' "$LOG_FILE")
CONVERGED=$(jq -r '.converged // "unknown"' "$LOG_FILE")

echo "Summary:"
echo "  Total Iterations: $TOTAL_ITER"
echo "  Best Rate:       $BEST_RATE"
echo "  Convergence:     $CONVERGED"
