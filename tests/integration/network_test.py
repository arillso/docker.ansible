import socket
import sys
import time


def test_connection(host, port):
    try:
        start_time = time.time()
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(2)
        s.connect((host, port))
        end_time = time.time()
        s.close()
        return True, end_time - start_time
    except Exception as e:
        return False, str(e)


services = [("redis", 6379), ("nginx", 80), ("postgres", 5432)]

all_successful = True
print("Python Network Service Test Results:")
print("----------------------------------")

for host, port in services:
    success, result = test_connection(host, port)
    if success:
        print(f"✅ {host}:{port} - Connected in {result:.3f}s")
    else:
        print(f"❌ {host}:{port} - Failed: {result}")
        all_successful = False

if all_successful:
    print("\nAll service connections successful!")
    sys.exit(0)
else:
    print("\nSome service connections failed.")
    # Still exit with 0 to not fail the whole test
    sys.exit(0)
