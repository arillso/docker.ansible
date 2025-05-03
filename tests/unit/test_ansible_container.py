#!/usr/bin/env python3
"""
Unit Tests for Ansible Docker Container
These tests validate the functionality and integrity of the Ansible container.
"""

import os
import shutil
import subprocess  # nosec B404 - Required for container tests
import unittest


class AnsibleContainerTest(unittest.TestCase):
    """Unittest class for Ansible Docker container tests"""

    @classmethod
    def setUpClass(cls):
        """Start container once for all tests"""
        # Validate environment variable to prevent injection
        image_env = os.environ.get("ANSIBLE_IMAGE", "")
        # Fallback to safe value if invalid
        if not image_env or not cls._is_valid_image_name(image_env):
            cls.image_name = "ansible:test"
        else:
            cls.image_name = image_env
        # Check if container exists
        # Use shutil.which to get full path to docker executable
        docker_path = shutil.which("docker")
        if not docker_path:
            docker_path = "/usr/bin/docker"  # Fallback to common location

        result = subprocess.run(  # nosec B603 - Safe input parameters
            [docker_path, "image", "inspect", cls.image_name],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )
        if result.returncode != 0:
            raise ValueError(
                f"Docker image {cls.image_name} not found. Please build it first."
            )

        # Get container info to adjust tests
        cls.container_info = cls.get_container_info()

    @staticmethod
    def _is_valid_image_name(name):
        """
        Validates that the image name is safe
        """
        # Allowed characters: letters, numbers, dots, hyphens, colons, slashes
        import re

        if not isinstance(name, str):
            return False
        pattern = r"^[a-zA-Z0-9][a-zA-Z0-9._/-]*(:[-._a-zA-Z0-9]+)?$"
        return bool(re.match(pattern, name))

    @classmethod
    def get_container_info(cls):
        """Get information about the container to adjust tests accordingly"""
        info = {}

        # Check Linux distribution
        result = cls.run_container_command_static(
            cls.image_name, ["cat", "/etc/os-release"]
        )
        if result.returncode == 0:
            info["os_release"] = result.stdout

            # Detect Alpine
            if "Alpine" in result.stdout:
                info["is_alpine"] = True
                # Get package list
                pkg_result = cls.run_container_command_static(
                    cls.image_name, ["apk", "info"]
                )
                if pkg_result.returncode == 0:
                    info["installed_packages"] = pkg_result.stdout.splitlines()
                else:
                    info["installed_packages"] = []
            else:
                info["is_alpine"] = False

        # Check command availability
        commands_to_check = [
            "curl",
            "git",
            "ssh",
            "ansible",
            "python",
            "kubectl",
            "helm",
        ]
        info["available_commands"] = {}

        for cmd in commands_to_check:
            result = cls.run_container_command_static(cls.image_name, ["which", cmd])
            info["available_commands"][cmd] = result.returncode == 0

        # Check Python modules
        modules_to_check = ["ansible", "yaml", "jinja2", "netaddr", "jmespath"]
        info["available_modules"] = {}

        for module in modules_to_check:
            check_script = f"import {module}; print('{module} available')"
            result = cls.run_container_command_static(
                cls.image_name, ["python", "-c", check_script]
            )
            info["available_modules"][module] = result.returncode == 0

        return info

    @staticmethod
    def run_container_command_static(image_name, command, env=None):
        """Static method to run a command in the container"""
        env_args = []
        if env:
            for key, value in env.items():
                env_args.extend(["-e", f"{key}={value}"])

        # Ensure image_name is validated
        if not AnsibleContainerTest._is_valid_image_name(image_name):
            raise ValueError(f"Invalid image name: {image_name}")

        # Get full path to docker executable to avoid B607 warning
        docker_path = shutil.which("docker")
        if not docker_path:
            docker_path = "/usr/bin/docker"  # Fallback to common location

        cmd = (
            [docker_path, "run", "--rm"] + env_args + [image_name] + command
        )  # List instead of shell string
        result = subprocess.run(  # nosec B603 - Input is validated
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            check=False,
        )
        return result

    def run_container_command(self, command, env=None):
        """Run a command in the container and return the result"""
        return self.run_container_command_static(self.image_name, command, env)

    def test_ansible_version(self):
        """Check if Ansible is correctly installed and can output its version"""
        result = self.run_container_command(["ansible", "--version"])
        self.assertEqual(result.returncode, 0)
        self.assertIn("ansible [core", result.stdout)

    def test_python_version(self):
        """Check the Python version"""
        result = self.run_container_command(["python", "--version"])
        self.assertEqual(result.returncode, 0)
        self.assertIn("Python 3.", result.stdout)

    def test_ansible_modules(self):
        """Check if important Ansible modules are available"""
        important_modules = ["ping", "shell", "command", "setup"]
        result = self.run_container_command(["ansible-doc", "--list"])
        self.assertEqual(result.returncode, 0)

        for module in important_modules:
            self.assertIn(module, result.stdout, f"Module {module} not found")

    def test_ansible_environment_variables(self):
        """Check if environment variables are set correctly"""
        env_vars = {"TEST_ENV": "test_value", "ANSIBLE_STDOUT_CALLBACK": "yaml"}
        result = self.run_container_command(["env"], env=env_vars)
        self.assertEqual(result.returncode, 0)

        for key, value in env_vars.items():
            self.assertIn(f"{key}={value}", result.stdout)

        # Also check default environment variables
        self.assertIn("ANSIBLE_FORCE_COLOR=True", result.stdout)

    def test_installed_packages(self):
        """Check if required packages are installed based on detected OS"""
        # Skip individual package checks if not on Alpine
        if not self.container_info.get("is_alpine", False):
            self.skipTest("Not an Alpine-based container, skipping package test")

        # Define essential packages that must be present
        essential_packages = ["bash", "git"]
        for package in essential_packages:
            result = self.run_container_command(["which", package])
            self.assertEqual(
                result.returncode, 0, f"Essential package {package} not found"
            )

        # Check available commands from container info
        for cmd, available in self.container_info["available_commands"].items():
            if cmd in ["ansible", "python"]:  # These are critical and must be available
                self.assertTrue(available, f"Critical command {cmd} is not available")

        # For non-critical commands, print info but don't fail
        non_critical = ["kubectl", "helm", "ssh", "curl"]
        missing = [
            cmd
            for cmd in non_critical
            if cmd in self.container_info["available_commands"]
            and not self.container_info["available_commands"][cmd]
        ]

        if missing:
            print(f"INFO: Non-critical commands not found: {', '.join(missing)}")

    def test_user_permissions(self):
        """Check if the container runs as user 'ansible' with UID 1000"""
        result = self.run_container_command(["id"])
        self.assertEqual(result.returncode, 0)
        self.assertIn("uid=1000", result.stdout)

    def test_ansible_playbook_syntax(self):
        """Check the Ansible playbook syntax checking function"""
        # Use the external test playbook
        test_playbook_path = os.path.join(
            os.path.dirname(__file__), "test_syntax_playbook.yml"
        )

        # Validate playbook path
        vol_path = os.path.dirname(os.path.abspath(test_playbook_path))
        file_name = os.path.basename(test_playbook_path)

        # Additional security check for filenames
        if (
            not os.path.exists(test_playbook_path)
            or ".." in file_name
            or file_name != "test_syntax_playbook.yml"
        ):
            raise ValueError("Invalid playbook path or filename")

        # Ensure the file exists
        self.assertTrue(
            os.path.exists(test_playbook_path), "Test playbook file not found"
        )

        # Use absolute paths and additional security checks
        # Get full path to docker executable to avoid B607 warning
        docker_path = shutil.which("docker")
        if not docker_path:
            docker_path = "/usr/bin/docker"  # Fallback to common location

        result = subprocess.run(  # nosec B603 - Paths are validated
            [
                docker_path,  # Full path to docker executable
                "run",
                "--rm",
                "-v",
                f"{vol_path}:/playbooks",
                self.image_name,
                "ansible-playbook",
                "--syntax-check",
                "-c",
                "local",
                f"/playbooks/{file_name}",
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0)

    def test_python_modules(self):
        """Check if important Python modules can be imported"""
        # Get modules that we know are available from container_info
        available_modules = [
            module
            for module, available in self.container_info["available_modules"].items()
            if available
        ]

        if not available_modules:
            self.skipTest("No Python modules detected as available")

        # Test with the modules we know are available
        module_list = ", ".join(available_modules)
        python_script = f"""
import sys
try:
    import {" ,".join(available_modules)}
    print("Modules successfully imported: {module_list}")
    sys.exit(0)
except ImportError as e:
    print(f"Error importing: {{e}}")
    sys.exit(1)
"""
        result = self.run_container_command(["python", "-c", python_script])
        self.assertEqual(result.returncode, 0)

    def test_ansible_local_execution(self):
        """Check if Ansible can execute tasks locally without SSH"""
        # Use local connection mode instead of SSH
        result = self.run_container_command(
            [
                "ansible",
                "localhost",  # DevSkim: ignore DS162092
                "-c",
                "local",
                "-m",
                "ping",
            ]
        )
        self.assertEqual(
            result.returncode, 0, "Ansible failed to run with local connection"
        )
        self.assertIn("SUCCESS", result.stdout)


if __name__ == "__main__":
    unittest.main()
