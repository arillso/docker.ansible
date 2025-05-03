import time
from typing import Dict, Optional

# Dictionary to store the results of import attempts
modules = ["ansible", "jmespath", "netaddr", "docker", "yaml", "json", "lxml"]
results: Dict[str, Optional[float]] = {}

# Test each module
for module in modules:
    start = time.time()
    try:
        __import__(module)
        end = time.time()
        results[module] = end - start
    except ImportError:
        # Use None to indicate module is not available
        results[module] = None

# Display results
for module, duration in results.items():
    if duration is not None:
        print(f"{module}: {duration:.6f} seconds")
    else:
        print(f"{module}: not available")
