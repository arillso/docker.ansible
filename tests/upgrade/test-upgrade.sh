#!/bin/bash
# tests/upgrade/test-upgrade.sh
set -e

echo "==== Ansible Container Upgrade Test ===="

# 1. Start base container with a volume to persist Python packages
echo "Starting container..."
TEST_VOLUME="ansible-upgrade-test-vol"

# Create volume if it doesn't exist
docker volume create $TEST_VOLUME || true

# Start container with the volume mounted to /tmp/packages
CONTAINER_ID=$(docker run -d -v $TEST_VOLUME:/tmp/packages ansible:latest tail -f /dev/null)

# 2. Check if container is running
echo "Container $CONTAINER_ID is running"
docker ps | grep "$CONTAINER_ID"

# 3. Get initial version information
echo "Collecting initial version information..."
docker exec "$CONTAINER_ID" bash -c "ansible --version | head -1 > /tmp/packages/before.txt"
docker exec "$CONTAINER_ID" bash -c "cat /tmp/packages/before.txt"

# 4. Install a local package that doesn't require root
echo "Testing local package installation..."
docker exec "$CONTAINER_ID" bash -c "cd /tmp/packages && python -m pip install --user cowsay --no-warn-script-location"

# 5. Verify installation worked
echo "Verifying package installation..."
docker exec "$CONTAINER_ID" bash -c "cd /tmp/packages && python -c 'import cowsay; print(cowsay.cow(\"Upgrade test successful\"))'"

# 6. Check if container still works for Ansible operations
echo "Testing Ansible functionality after package installation..."
docker exec "$CONTAINER_ID" bash -c "ansible localhost -c local -m ping" # DevSkim: ignore DS162092

# 7. Clean up
echo "Cleaning up..."
docker stop "$CONTAINER_ID"
docker rm "$CONTAINER_ID"
docker volume rm $TEST_VOLUME

echo "Upgrade test completed successfully!"
