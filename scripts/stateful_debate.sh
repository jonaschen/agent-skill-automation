#!/bin/bash
# scripts/stateful_debate.sh — Surgical & Stateful 2-session debate

DISCUSSION_LOG="knowledge_base/agentic-ai/discussions/stateful_debate_log.md"
mkdir -p "$(dirname "$DISCUSSION_LOG")"
echo "# Stateful Research Debate Log" > "$DISCUSSION_LOG"
echo "Date: $(date)" >> "$DISCUSSION_LOG"

# Helper to extract just the Role & Mission section to avoid "Orientation" errors
extract_identity() {
    local file=$1
    # Extract from "## Role & Mission" to the next "##" section or end of file
    sed -n '/## Role & Mission/,/##/p' "$file" | sed '$d'
}

echo "------------------------------------------------"
echo "Initializing Lead Session..."
LEAD_CORE=$(extract_identity .gemini/agents/agentic-ai-research-lead.md)
gemini -y -p "Identity: You are the agentic-ai-research-lead. 
$LEAD_CORE
INSTRUCTION: You are in a strategic debate. Acknowledge and wait." > /dev/null
sleep 2
LEAD_ID=$(gemini --list-sessions | grep -m 1 "agentic-ai-research-lead" | grep -oP '\d+(?=\.)' | head -n 1)

echo "Initializing Researcher Session..."
RESEARCHER_CORE=$(extract_identity .gemini/agents/agentic-ai-researcher.md)
gemini -y -p "Identity: You are the agentic-ai-researcher. 
$RESEARCHER_CORE
INSTRUCTION: You are in a technical debate. Acknowledge and wait." > /dev/null
sleep 2
RESEARCHER_ID=$(gemini --list-sessions | grep -m 1 "agentic-ai-researcher" | grep -oP '\d+(?=\.)' | head -n 1)

if [ -z "$LEAD_ID" ] || [ -z "$RESEARCHER_ID" ]; then
    echo "ERROR: Could not capture Session IDs. Please check 'gemini --list-sessions'."
    exit 1
fi

echo "Sessions Started: Lead=$LEAD_ID, Researcher=$RESEARCHER_ID"
echo "------------------------------------------------"

LAST_MESSAGE="Hello. Let's discuss Strategic Priorities S1 (Auto-improvement) and S3 (Portability). Lead, provide your opening directive regarding how we should prioritize the Gemini transition in our Roadmap."

for round in {1..3}; do
  echo -e "\n=== ROUND $round ===\n"

  # LEAD's TURN
  echo "Lead (Session $LEAD_ID) is thinking..."
  LEAD_RESPONSE=$(gemini -r "$LEAD_ID" -y -p "The researcher said: '$LAST_MESSAGE'. 
  Action: Provide your strategic guidance for Round $round. Focus on the Roadmap and alignment with project goals.
  Constraint: Output ONLY your response to the researcher. No meta-commentary.")
  sleep 1
  
  echo -e "LEAD:\n$LEAD_RESPONSE"
  echo -e "\n## ROUND $round: LEAD\n$LEAD_RESPONSE" >> "$DISCUSSION_LOG"
  LAST_MESSAGE="$LEAD_RESPONSE"

  # RESEARCHER's TURN
  echo "Researcher (Session $RESEARCHER_ID) is thinking..."
  RESEARCHER_RESPONSE=$(gemini -r "$RESEARCHER_ID" -y -p "The Lead said: '$LAST_MESSAGE'. 
  Action: Provide your technical analysis for Round $round. Focus on the feasibility of MCP and A2A integration for the Gemini transition.
  Constraint: Output ONLY your response to the lead. No meta-commentary.")
  sleep 1
  
  echo -e "RESEARCHER:\n$RESEARCHER_RESPONSE"
  echo -e "\n## ROUND $round: RESEARCHER\n$RESEARCHER_RESPONSE" >> "$DISCUSSION_LOG"
  LAST_MESSAGE="$RESEARCHER_RESPONSE"
done

echo -e "\n------------------------------------------------"
echo "Discussion concluded. Log: $DISCUSSION_LOG"
