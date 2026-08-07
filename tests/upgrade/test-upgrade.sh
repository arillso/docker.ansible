#!/bin/bash
# tests/upgrade/test-upgrade.sh
set -e

IMAGE_NAME=${ANSIBLE_IMAGE:-ansible:latest}

echo "==== Ansible Container Upgrade Test ===="
echo "Using image: $IMAGE_NAME"

# 1. Start base container with a volume to persist Python packages
echo "Starting container..."
TEST_VOLUME="ansible-upgrade-test-vol"

# Create volume if it doesn't exist
docker volume create $TEST_VOLUME || true

# A fresh named volume is owned by root:root, and Docker only adjusts that for
# mountpoints the image already populates. The container runs as a non-root
# user, so hand the volume over before the test writes to it.
docker run --rm -u 0 -v "$TEST_VOLUME:/tmp/packages" "$IMAGE_NAME" \
    chown ansible:ansible /tmp/packages

# Start container with the volume mounted to /tmp/packages
CONTAINER_ID=$(docker run -d -v "$TEST_VOLUME:/tmp/packages" "$IMAGE_NAME" tail -f /dev/null)

# 2. Check if container is running
# `docker ps` truncates IDs to 12 chars, so grepping the full 64-char ID never
# matches; filter server-side instead.
if [ -z "$(docker ps -q --no-trunc --filter "id=$CONTAINER_ID")" ]; then
    echo "ERROR: container $CONTAINER_ID is not running"
    docker logs "$CONTAINER_ID" || true
    exit 1
fi
echo "Container $CONTAINER_ID is running"

# 3. Get initial version information
echo "Collecting initial version information..."
docker exec "$CONTAINER_ID" bash -c "ansible --version | head -1 > /tmp/packages/before.txt"
docker exec "$CONTAINER_ID" bash -c "cat /tmp/packages/before.txt"

# 4. Install a local package that doesn't require root
# `python` on PATH is the pipx shim, which ships no pip and rejects --user
# installs. A venv on the mounted volume is the supported way for the non-root
# user to install a package.
echo "Testing local package installation..."
docker exec "$CONTAINER_ID" bash -c "python -m venv /tmp/packages/venv"
docker exec "$CONTAINER_ID" bash -c "/tmp/packages/venv/bin/pip install cowsay --no-warn-script-location"

# 5. Verify installation worked
echo "Verifying package installation..."
docker exec "$CONTAINER_ID" bash -c "/tmp/packages/venv/bin/python -c 'import cowsay; print(cowsay.cow(\"Upgrade test successful\"))'"

# 6. Check if container still works for Ansible operations
echo "Testing Ansible functionality after package installation..."
docker exec "$CONTAINER_ID" bash -c "ansible localhost -c local -m ping" # DevSkim: ignore DS162092

# 7. Clean up
echo "Cleaning up..."
docker stop "$CONTAINER_ID"
docker rm "$CONTAINER_ID"
docker volume rm "$TEST_VOLUME"

echo "Upgrade test completed successfully!"
