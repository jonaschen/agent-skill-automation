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
        
        # Rule: Key includes description for positive cases (they might flip)
        # For negative cases, they are unlikely to flip if description improves
        if expect_trigger == "yes":
            key = f"pos:{p_hash}:{d_hash}"
        else:
            # Negative cases are cached based on prompt only (description-invariant)
            key = f"neg:{p_hash}"
            
        return self.data.get(key)

    def set(self, prompt, description, expect_trigger, result):
        p_hash = self._hash(prompt)
        d_hash = self._hash(description)
        
        if expect_trigger == "yes":
            key = f"pos:{p_hash}:{d_hash}"
        else:
            key = f"neg:{p_hash}"
            
        self.data[key] = {
            "result": result,
            "timestamp": time.time()
        }
        self._save()

    def clear(self):
        if os.path.exists(self.cache_file):
            os.remove(self.cache_file)
        self.data = {}
