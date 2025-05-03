#!/bin/bash
set -e

echo "==== Ansible Container Integration Tests ===="
RESULTS_DIR="/results"
mkdir -p $RESULTS_DIR

# Check container capabilities before proceeding
echo "Checking container capabilities..."
AVAILABLE_COMMANDS=()
for cmd in curl wget redis-cli psql ansible ansible-playbook nc; do
    if command -v $cmd &>/dev/null; then
        AVAILABLE_COMMANDS+=("$cmd")
        echo "✅ $cmd available"
    else
        echo "❌ $cmd not available"
    fi
done

echo "Available commands: ${AVAILABLE_COMMANDS[*]}"

# Wait for services using simple tools (no reliance on nc)
echo "Waiting for services to be ready..."
for svc in postgres nginx redis; do
    echo "Checking $svc..."
    timeout=30
    success=false

    while [ $timeout -gt 0 ]; do
        # Try basic TCP connection without using nc
        if (exec 3<>/dev/tcp/$svc/80 || exec 3<>/dev/tcp/$svc/5432 || exec 3<>/dev/tcp/$svc/6379) 2>/dev/null; then
            exec 3<&- # Close the connection
            echo "$svc is ready"
            success=true
            break
        fi

        # Alternative check using ansible command if available
        if command -v ansible &>/dev/null; then
            if ansible localhost -m shell -a "echo > /dev/tcp/$svc/80 || echo > /dev/tcp/$svc/5432 || echo > /dev/tcp/$svc/6379" -c local &>/dev/null; then # DevSkim: ignore DS162092
                echo "$svc is ready (ansible check)"
                success=true
                break
            fi
        fi

        timeout=$((timeout - 1))
        sleep 1
    done

    if [ "$success" = false ]; then
        echo "⚠️ Timeout waiting for $svc, but continuing tests"
    fi
done

# Record test environment
echo -e "\n-- Container Environment Information --"
echo "Container user: $(whoami)"
echo "Container Python: $(python --version 2>&1)"
echo "Container Ansible: $(ansible --version 2>&1 | head -1)"
echo "Container file permissions on /pipx: $(ls -la /pipx 2>&1 || echo 'Cannot access /pipx')"

# Test 1: Simple connection tests
echo -e "\n-- Test 1: Basic connection tests --"
echo "Testing services with basic commands..."

# Record test results
echo -e "\nConnectivity Test Results:" >$RESULTS_DIR/integration-results.txt

# Test Redis if redis-cli is available
if command -v redis-cli &>/dev/null; then
    echo "Testing Redis connection..."
    if redis-cli -h redis ping &>/dev/null; then
        echo "✅ Redis PING successful" | tee -a $RESULTS_DIR/integration-results.txt
    else
        echo "❌ Redis connection failed" | tee -a $RESULTS_DIR/integration-results.txt
    fi
else
    # Try using Python to connect to Redis
    echo "Redis CLI not available, trying Python Redis client..."
    python -c "
import socket
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(('redis', 6379))
    s.send(b'PING\r\n')
    response = s.recv(1024)
    s.close()
    print('✅ Redis connection successful: ' + response.decode().strip())
except Exception as e:
    print('❌ Redis connection failed:', e)
" | tee -a $RESULTS_DIR/integration-results.txt
fi

# Test Nginx if curl is available
if command -v curl &>/dev/null; then
    echo "Testing Nginx connection..."
    if curl -s -I -m 5 http://nginx | head -n 1 | grep -q "200 OK"; then # DevSkim: ignore DS137138
        echo "✅ Nginx responded with 200 OK" | tee -a $RESULTS_DIR/integration-results.txt
    else
        echo "❌ Nginx connection failed" | tee -a $RESULTS_DIR/integration-results.txt
    fi
else
    # Try using Python to connect to Nginx
    echo "curl not available, trying Python HTTP client..."
    python -c "
import socket
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(('nginx', 80))
    s.send(b'GET / HTTP/1.1\r\nHost: nginx\r\n\r\n')
    response = s.recv(1024)
    s.close()
    status_line = response.decode().split('\\n')[0]
    print('✅ Nginx connection successful:', status_line)
except Exception as e:
    print('❌ Nginx connection failed:', e)
" | tee -a $RESULTS_DIR/integration-results.txt
fi

# Test Postgres with Python
echo "Testing PostgreSQL connection with Python..."
python -c "
import socket
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(('postgres', 5432))
    print('✅ PostgreSQL connection successful (TCP connection)')
    s.close()
except Exception as e:
    print('❌ PostgreSQL connection failed:', e)
" | tee -a $RESULTS_DIR/integration-results.txt

# Test 2: Ansible integration test (using local connection)
echo -e "\n-- Test 2: Ansible local connection test --"

# Use preconfigured YAML file from tests directory
if ansible-playbook -c local /tests/local-test.yml; then
    echo "✅ Ansible local connection test passed" | tee -a $RESULTS_DIR/integration-results.txt
else
    echo "❌ Ansible local connection test failed" | tee -a $RESULTS_DIR/integration-results.txt
fi

echo -e "\n-- Test 3: Networked services test with Python --"
# Use Python test script from tests directory
python /tests/network_test.py | tee -a $RESULTS_DIR/integration-results.txt

echo "==== Integration tests completed! ===="
cat $RESULTS_DIR/integration-results.txt
