#!/usr/bin/env python3
import sys
import os
import re
import difflib

def calculate_sns(old_file, new_file):
    """
    Calculates the Structural Novelty Score (SNS) between two agent definitions.
    SNS = (1 - Similarity) + delta_tools + delta_roles
    """
    if not os.path.exists(old_file) or not os.path.exists(new_file):
        return 1.0 # High novelty if one doesn't exist

    with open(old_file, 'r') as f:
        old_content = f.read()
    with open(new_file, 'r') as f:
        new_content = f.read()

    # 1. Text Similarity (Simple proxy for embedding distance for now)
    s = difflib.SequenceMatcher(None, old_content, new_content)
    text_novelty = 1.0 - s.ratio()

    # 2. Tool Delta
    old_tools = set(re.findall(r'tools:\s*\[(.*?)\]', old_content))
    new_tools = set(re.findall(r'tools:\s*\[(.*?)\]', new_content))
    tool_delta = len(new_tools - old_tools) * 0.2

    # 3. Role/Capability Delta
    old_roles = len(re.findall(r'## Role', old_content))
    new_roles = len(re.findall(r'## Role', new_content))
    role_delta = max(0, new_roles - old_roles) * 0.1

    sns = text_novelty + tool_delta + role_delta
    return round(sns, 4)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: sns_compute.py <old_agent> <new_agent>")
        sys.exit(1)
    
    score = calculate_sns(sys.argv[1], sys.argv[2])
    print(score)
