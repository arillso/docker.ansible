"""Verify release-note version extraction against the actual workflow script."""

from pathlib import Path
import subprocess  # nosec B404 - Runs the repository's workflow script in a test.
import tempfile
import textwrap
import unittest


ROOT = Path(__file__).resolve().parents[2]


def _python_version_script():
    lines = (ROOT / ".github/workflows/merge.yml").read_text().splitlines()
    start = next(
        i for i, line in enumerate(lines)
        if line.strip().startswith("python_version=$(")
    )
    end = next(
        i for i in range(start + 1, len(lines))
        if lines[i].strip().startswith("# Extract mitogen version")
    )
    return textwrap.dedent("\n".join(lines[start:end])).strip()


def _run_extraction(dockerfile):
    with tempfile.TemporaryDirectory() as directory:
        Path(directory, "Dockerfile").write_text(dockerfile)
        script = _python_version_script() + '\nprintf "%s" "$python_version"'
        return subprocess.run(  # nosec B603 - Executes the checked-in workflow script.
            ["bash", "-eo", "pipefail", "-c", script],
            cwd=directory,
            capture_output=True,
            text=True,
            check=False,
        )


class ReleaseNotesTest(unittest.TestCase):
    def test_current_dockerfile_python_version(self):
        result = _run_extraction((ROOT / "Dockerfile").read_text())
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertRegex(result.stdout, r"^[0-9]+\.[0-9]+$")

    def test_supported_python_pin_formats(self):
        cases = (
            ('"python3>=3.14.10-r1" \\\n', "3.14"),
            ("python3=3.15.2-r0\n", "3.15"),
        )
        for pin, expected in cases:
            with self.subTest(pin=pin):
                result = _run_extraction(pin)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout, expected)

    def test_unknown_python_pin_reports_error(self):
        result = _run_extraction("python3~3.15.2-r0\n")
        self.assertEqual(result.returncode, 1)
        self.assertIn("Could not extract Python version", result.stderr)


if __name__ == "__main__":
    unittest.main()
