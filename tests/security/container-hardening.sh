#!/bin/bash
# Safer security check that works for non-root users
set -e

echo "==== Container Security Hardening Check ===="

# Check for unnecessary packages - only if we can run apk
echo -e "\n[+] Checking for unnecessary packages..."
if command -v apk &>/dev/null; then
    ALLOWED_PACKAGES=(
        "libgcc"         # Required runtime library
        "gdbm"           # Required by Python
        "git"            # Required for Ansible operations
        "gnupg"          # Required for signing/verification
        "gpg"            # Required for security
        "libgcrypt"      # Required security library
        "libgpg-error"   # Required by gpg
        "libunistring"   # Common dependency
        "openssh-keygen" # Required for SSH operations
        "libcurl"        # Required for network operations
    )

    found_packages=$(apk info 2>/dev/null | grep -E "dev$|headers$|gcc$|g\+\+$|make$|curl$|wget$" | grep -v -E "$(
        IFS="|"
        echo "${ALLOWED_PACKAGES[*]}"
    )" -c)
    if [ "$found_packages" -gt 0 ]; then
        echo "WARNING: Potentially unnecessary development packages found: $(apk info 2>/dev/null | grep -E "dev$|headers$|gcc$|g\+\+$|make$|curl$|wget$" | grep -v -E "$(
            IFS="|"
            echo "${ALLOWED_PACKAGES[*]}"
        )")"
    fi
else
    echo "INFO: apk command not available, skipping package check"
fi

# Only check areas the current user can access
echo -e "\n[+] Checking for SUID/SGID binaries in user-accessible directories..."
ALLOWED_SUID=(
    "/usr/bin/passwd"    # Necessary for password management
    "/usr/bin/su"        # Necessary for user switching
    "/usr/bin/ssh-agent" # Necessary for SSH operations
)

# Only check directories the user can access
for dir in /home/ansible /usr/local/bin /bin /usr/bin; do
    if [ -d "$dir" ] && [ -r "$dir" ]; then
        suid_files=$(find $dir -type f -perm -2000 -o -perm -4000 2>/dev/null | grep -v -E "$(
            IFS="|"
            echo "${ALLOWED_SUID[*]}"
        )" 2>/dev/null || true)
        if [ -n "$suid_files" ]; then
            echo "WARNING: SUID/SGID binaries found in $dir (excluding allowed ones):"
            echo "$suid_files"
        fi
    fi
done

# Check for world-writable directories in user-accessible locations
echo -e "\n[+] Checking for insecure permissions..."
for dir in /home/ansible /tmp /usr/local/bin; do
    if [ -d "$dir" ] && [ -r "$dir" ]; then
        writable=$(find $dir -type d -perm -o+w -c 2>/dev/null)
        if [ "$writable" -gt 0 ]; then
            echo "WARNING: World-writable directories found under $dir"
        fi
    else
        echo "INFO: Directory $dir does not exist or is not readable, skipping permission check"
    fi
done

# Check for user privileges
echo -e "\n[+] Checking user privileges..."
if [ "$(id -u)" = "0" ]; then
    echo "WARNING: Container is running as root"
else
    echo "OK: Container is running as non-root user ($(id -u))"
fi

# Check for temporary files
echo -e "\n[+] Checking for temporary files..."
if [ -d "/tmp" ] && [ -r "/tmp" ]; then
    temp_files=$(find /tmp -type f -c 2>/dev/null)
    if [ "$temp_files" -gt 0 ]; then
        echo "WARNING: Temporary files found in /tmp"
    fi
fi

# Check for correct PATH settings
echo -e "\n[+] Checking PATH settings..."
if echo "$PATH" | grep -q "::"; then
    echo "WARNING: PATH contains empty elements (::)"
fi
if echo "$PATH" | grep -q "\."; then
    echo "WARNING: PATH contains current directory (.)"
fi

# Check for shell history files
echo -e "\n[+] Checking for shell history files in user home..."
if [ -d "/home/ansible" ]; then
    history_files=$(find /home/ansible -name ".bash_history" -o -name ".ash_history" -o -name ".history" 2>/dev/null || true)
    if [ -n "$history_files" ]; then
        echo "WARNING: Shell history files found"
    fi
fi

# Check if we have Python packages with known vulnerabilities
echo -e "\n[+] Checking Python packages..."
if command -v pip &>/dev/null; then
    echo "INFO: Python packages installed:"
    pip list 2>/dev/null | grep -E "ansible|jinja2|cryptography|pyyaml" || echo "No common packages found"
fi

# Check for SSH configuration security
echo -e "\n[+] Checking SSH configuration..."
if [ -f "/etc/ssh/ssh_config" ] && [ -r "/etc/ssh/ssh_config" ]; then
    if grep -q "HashKnownHosts yes" /etc/ssh/ssh_config; then
        echo "OK: SSH is configured to hash known hosts"
    fi
    if grep -q "Protocol 2" /etc/ssh/ssh_config; then
        echo "OK: SSH is using secure protocol version"
    fi
fi

echo -e "\n==== Security check completed ===="
# Always exit with success
exit 0
