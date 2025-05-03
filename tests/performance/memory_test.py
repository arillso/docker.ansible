import os
import sys

try:
    import psutil

    process = psutil.Process(os.getpid())
    memory_info = process.memory_info()
    print(f"RSS (Resident Set Size): {memory_info.rss / 1024 / 1024:.2f} MB")
    print(f"VMS (Virtual Memory Size): {memory_info.vms / 1024 / 1024:.2f} MB")
except ImportError:
    print("psutil module not available, trying alternative method")
    try:
        import resource

        rusage = resource.getrusage(resource.RUSAGE_SELF)
        print(f"Maximum Memory Usage: {rusage.ru_maxrss / 1024:.2f} MB")
    except ImportError:
        print("resource module not available")
        print(f"Python executable size: {sys.executable}")
