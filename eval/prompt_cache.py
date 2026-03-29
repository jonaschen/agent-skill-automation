import json
import os
import hashlib
import time

CACHE_FILE = "eval/.prompt_cache.json"

class PromptCache:
    def __init__(self, cache_file=CACHE_FILE):
        self.cache_file = cache_file
        self.data = self._load()

    def _load(self):
        if os.path.exists(self.cache_file):
            try:
                with open(self.cache_file, 'r') as f:
                    return json.load(f)
            except:
                return {}
        return {}

    def _save(self):
        try:
            with open(self.cache_file, 'w') as f:
                json.dump(self.data, f, indent=2)
        except:
            pass

    def _hash(self, text):
        return hashlib.sha256(text.encode()).hexdigest()

    def get(self, prompt, description, expect_trigger):
        p_hash = self._hash(prompt)
        d_hash = self._hash(description)
        
        # 1. Try prompt-only cache (description-invariant)
        # Only used for successful negative controls (they stay PASS)
        key_inv = f"inv:{p_hash}"
        cached_inv = self.data.get(key_inv)
        if cached_inv and cached_inv["result"] == "PASS":
            return cached_inv

        # 2. Try description-sensitive cache
        # Used for all positive cases AND failing negative cases (to see if they flip to PASS)
        key_sens = f"sens:{p_hash}:{d_hash}"
        return self.data.get(key_sens)

    def set(self, prompt, description, expect_trigger, result):
        p_hash = self._hash(prompt)
        d_hash = self._hash(description)
        
        # Rule: Successful negative controls are stored description-invariantly
        if expect_trigger == "no" and result == "PASS":
            key = f"inv:{p_hash}"
        else:
            # All positive cases and failing negative cases are description-sensitive
            key = f"sens:{p_hash}:{d_hash}"
            
        self.data[key] = {
            "result": result,
            "timestamp": time.time()
        }
        self._save()

    def clear(self):
        if os.path.exists(self.cache_file):
            os.remove(self.cache_file)
        self.data = {}
