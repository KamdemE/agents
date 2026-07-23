#!/usr/bin/env python3
import os
import sys
import subprocess
import socket
import threading
import shutil
from pathlib import Path

# --- Configuration ---
DEFAULT_IMAGE = "kpihx/sui:latest"
DEFAULT_DATA_DIR = "/root/.sui" # Inside container
HOST_DATA_DIR = Path.home() / ".sui"

# --- Colors ---
CYAN = "\033[0;36m"
GREEN = "\033[0;32m"
NC = "\033[0m"

def _pick_host_port() -> int:
    env_port = os.environ.get("SUI_PORT")
    if env_port:
        try: return int(env_port)
        except ValueError: pass
    
    default_port = 1143
    with socket.socket(socket.socket.AF_INET, socket.SOCK_STREAM) as s:
        try:
            s.bind(("", default_port))
            return default_port
        except OSError:
            s.bind(("", 0))
            return s.getsockname()[1]

def _build_docker_command(args: list[str], port: int) -> list[str]:
    workspace = Path.cwd()
    cmd = [
        "docker", "run", "--rm", "-i",
        "-e", "PYTHONUNBUFFERED=1",
        "-e", f"SUI_PORT={port}",
        "-e", "HITL_HOST=0.0.0.0",
        "-v", f"{workspace}:/app",
        "-w", "/app",
        "-p", f"127.0.0.1:{port}:{port}",
        "--privileged", # Needed for some elevation tasks if in container
    ]
    
    if sys.stdin.isatty():
        cmd.append("-t")

    HOST_DATA_DIR.mkdir(parents=True, exist_ok=True)
    os.chmod(HOST_DATA_DIR, 0o700)
    cmd.extend(["-v", f"{HOST_DATA_DIR}:{DEFAULT_DATA_DIR}"])

    host_tmp = Path("/tmp/sui")
    host_tmp.mkdir(parents=True, exist_ok=True)
    os.chmod(host_tmp, 0o700)
    cmd.extend(["-v", f"{host_tmp}:/tmp/sui"])

    cmd.append(DEFAULT_IMAGE)
    cmd.extend(args)
    return cmd

def run_shim(args: list[str]):
    port = _pick_host_port()
    cmd = _build_docker_command(args, port)
    
    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1
    )

    def intercept_stdout():
        for line in process.stdout:
            if "HITL_REQUIRED:" in line:
                url = line.split("HITL_REQUIRED:")[1].strip()
                print(f"🚀 [Host] Intercepted SUI HITL request. Opening: {url}")
                try:
                    if shutil.which("xdg-open"):
                        subprocess.run(["xdg-open", url], check=False)
                    elif sys.platform == "darwin":
                        subprocess.run(["open", url], check=False)
                except Exception as e:
                    print(f"⚠️ [Host] Failed to open browser: {e}")
            
            sys.stdout.write(line)
            sys.stdout.flush()

    thread = threading.Thread(target=intercept_stdout, daemon=True)
    thread.start()
    
    sys.exit(process.wait())

if __name__ == "__main__":
    run_shim(sys.argv[1:])
