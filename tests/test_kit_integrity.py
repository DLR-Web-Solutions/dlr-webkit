import os
import subprocess
import sys
import time
import tomllib
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def run(
    command: list[str],
    cwd: Path | None = None,
    env: dict[str, str] | None = None,
    input: str | None = None,
) -> subprocess.CompletedProcess[str]:
    """Run a command with merged environment and return the result."""
    merged_env = os.environ.copy()
    if env:
        merged_env.update(env)

    return subprocess.run(
        command, cwd=cwd, env=merged_env, input=input, text=True, capture_output=True
    )


def test_kit_integrity_required_files_exist() -> None:
    """Test that required agent and context files exist."""
    required_files = [
        ".cursorrules",
        "CLAUDE.md",
        "docs/00-context/project.md",
        "bin/doctor.sh",
        "bin/verify.sh",
        "Dockerfile",
        "docker-compose.yml",
        ".env.example",
    ]

    for rel in required_files:
        file_path = ROOT / rel
        assert file_path.exists(), f"Required file {rel} does not exist"


def test_kit_integrity_pyproject() -> None:
    """pyproject.toml declares the project and the dev tool group."""
    # Load pyproject.toml via tomllib
    with open(ROOT / "pyproject.toml", "rb") as f:
        pkg = tomllib.load(f)

    assert pkg["project"]["name"], "pyproject.toml needs a [project] name"
    assert pkg["project"]["requires-python"].startswith(">=3.12")

    # Check dev dependency groups for pytest in dev dependencies
    dev_deps = []
    if "dependency-groups" in pkg and "dev" in pkg["dependency-groups"]:
        dev_deps = pkg["dependency-groups"]["dev"]

    dev_deps_str = " ".join(dev_deps)
    assert "pytest" in dev_deps_str, "pytest not found in dev dependency group"


def test_kit_integrity_compose() -> None:
    """Test that compose does not default DB password to secret or use version-flag healthcheck."""
    compose_content = (ROOT / "docker-compose.yml").read_text()

    # Remove comments
    without_comments = "\n".join(
        line for line in compose_content.split("\n") if not line.strip().startswith("#")
    )

    # Test that it does not contain secret passwords
    assert "DB_PASSWORD:-secret" not in without_comments
    assert "POSTGRES_PASSWORD:-secret" not in without_comments

    # Test that it doesn't use --version in healthcheck
    assert "--version" not in without_comments

    # Test that it contains /health endpoint reference
    assert "/health" in compose_content

    # Test that it uses DB_PASSWORD:?
    assert "DB_PASSWORD:?" in compose_content


def test_kit_integrity_health_template() -> None:
    """Test that health template responds on /health."""
    # Start the health server
    port = 18765

    proc = subprocess.Popen(
        [sys.executable, str(ROOT / "src" / "server" / "health.py")],
        env={**os.environ, "PORT": str(port)},
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )

    try:
        # Poll for up to ~2s (20 x 0.1s)
        for _ in range(20):
            try:
                response = urllib.request.urlopen(f"http://127.0.0.1:{port}/health")
                assert response.getcode() == 200
                break
            except urllib.error.URLError:
                time.sleep(0.1)
        else:
            raise AssertionError("Health server did not respond on /health within 2 seconds")
    finally:
        proc.terminate()
        proc.wait()
