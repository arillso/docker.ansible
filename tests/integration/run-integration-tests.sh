#!/bin/bash
set -e

RESULTS_DIR="/results"
mkdir -p "$RESULTS_DIR"
RESULTS_FILE="$RESULTS_DIR/integration-results.txt"

# Function to wait for specified seconds
wait_before_start() {
    local seconds="$1"
    echo "Waiting for $seconds seconds before starting tests..."
    sleep "$seconds"
    echo "Wait completed, starting tests now."
    return 0
}

# Initialize results file
echo "Connectivity Test Results:" >"$RESULTS_FILE"

# Function to check available commands
check_available_commands() {
    echo "Checking container capabilities..."
    AVAILABLE_COMMANDS=()

    for cmd in curl wget redis-cli psql ansible ansible-playbook nc; do
        if command -v "$cmd" &>/dev/null; then
            AVAILABLE_COMMANDS+=("$cmd")
            echo "✅ $cmd available"
        else
            echo "❌ $cmd not available"
        fi
    done

    echo "Available commands: ${AVAILABLE_COMMANDS[*]}"
    return 0
}

# Function to wait for services to be ready
wait_for_services() {
    echo "Waiting for services to be ready..."

    for svc in postgres nginx redis; do
        wait_for_single_service "$svc"
    done

    return 0
}

# Function to wait for a single service
wait_for_single_service() {
    local svc="$1"
    echo "Checking $svc..."
    local timeout=30
    local success=false

    while [ $timeout -gt 0 ]; do
        # Try basic TCP connection
        if (exec 3<>/dev/tcp/"$svc"/80 || exec 3<>/dev/tcp/"$svc"/5432 || exec 3<>/dev/tcp/"$svc"/6379) 2>/dev/null; then
            exec 3<&- # Close the connection
            echo "$svc is ready"
            success=true
            break
        fi

        # Alternative check using ansible command
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

    return 0
}

# Function to record environment information
record_environment_info() {
    echo -e "\n-- Container Environment Information --"
    echo "Container user: $(whoami)"
    echo "Container Python: $(python --version 2>&1)"
    echo "Container Ansible: $(ansible --version 2>&1 | head -1)"
    echo "Container file permissions on /pipx: $(ls -la /pipx 2>&1 || echo 'Cannot access /pipx')"

    return 0
}

# Function to test Redis connection
test_redis_connection() {
    echo "Testing Redis connection..."

    if command -v redis-cli &>/dev/null; then
        if redis-cli -h redis ping &>/dev/null; then
            echo "✅ Redis PING successful" | tee -a "$RESULTS_FILE"
        else
            echo "❌ Redis connection failed" | tee -a "$RESULTS_FILE"
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
" | tee -a "$RESULTS_FILE"
    fi

    return 0
}

# Function to test Nginx connection
test_nginx_connection() {
    echo "Testing Nginx connection..."

    if command -v curl &>/dev/null; then
        if curl -s -I -m 5 http://nginx | head -n 1 | grep -q "200 OK"; then # DevSkim: ignore DS137138
            echo "✅ Nginx responded with 200 OK" | tee -a "$RESULTS_FILE"
        else
            echo "❌ Nginx connection failed" | tee -a "$RESULTS_FILE"
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
" | tee -a "$RESULTS_FILE"
    fi

    return 0
}

# Function to test PostgreSQL connection
test_postgres_connection() {
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
" | tee -a "$RESULTS_FILE"

    return 0
}

# Function to run Ansible local connection test
run_ansible_test() {
    echo -e "\n-- Test 2: Ansible local connection test --"

    # Use preconfigured YAML file from tests directory
    if ansible-playbook -c local /tests/local-test.yml; then
        echo "✅ Ansible local connection test passed" | tee -a "$RESULTS_FILE"
    else
        echo "❌ Ansible local connection test failed" | tee -a "$RESULTS_FILE"
    fi

    return 0
}

# Function to run Python network test
run_python_network_test() {
    echo -e "\n-- Test 3: Networked services test with Python --"

    # Use Python test script from tests directory
    python /tests/network_test.py | tee -a "$RESULTS_FILE"

    return 0
}

# Main function to orchestrate all tests
main() {
    echo "==== Ansible Container Integration Tests ===="

    # Wait before starting tests
    #   wait_before_start 60

    # Phase 1: Environment setup and checks
    check_available_commands
    wait_for_services
    record_environment_info

    # Phase 2: Basic connection tests
    echo -e "\n-- Test 1: Basic connection tests --"
    test_redis_connection
    test_nginx_connection
    test_postgres_connection

    # Phase 3: Integration tests
    run_ansible_test
    run_python_network_test

    # Report results
    echo "==== Integration tests completed! ===="
    cat "$RESULTS_FILE"

    return 0
}

# Execute main function
main
