import os
import sys
from pathlib import Path
from sui.config import ensure_secure_infra

RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
CYAN = "\033[0;36m"
NC = "\033[0m"

def check_perm(path: Path, expected: str):
    if not path.exists():
        print(f"{YELLOW}SKIP{NC}  {path} (Not found)")
        return True
    current = oct(path.stat().st_mode & 0o777)
    if current == expected:
        print(f"{GREEN}PASS{NC}  {path} ({current})")
        return True
    print(f"{RED}FAIL{NC}  {path} (Expected {expected}, got {current})")
    return False

def audit():
    print(f"{CYAN}--- sui Infrastructure Audit ---{NC}")
    ensure_secure_infra()
    data_dir = Path.home() / ".sui"
    tmp_dir = Path("/tmp/sui")
    all_passed = True
    all_passed &= check_perm(data_dir, "0o700")
    all_passed &= check_perm(tmp_dir, "0o700")
    all_passed &= check_perm(data_dir / "config.yaml", "0o600")
    all_passed &= check_perm(data_dir / "sui.log", "0o600")
    
    test_file = data_dir / ".audit_umask"
    try:
        with open(test_file, "w") as f: f.write("test")
        mode = oct(test_file.stat().st_mode & 0o777)
        if mode == "0o600": print(f"{GREEN}PASS{NC}  Umask Invariant (0o600)")
        else:
            print(f"{RED}FAIL{NC}  Umask Invariant (Got {mode})"); all_passed = False
        os.remove(test_file)
    except Exception as e:
        print(f"{RED}FAIL{NC}  Umask Test failed: {e}"); all_passed = False

    if all_passed:
        print(f"\n{GREEN}✅ AUDIT PASSED{NC}")
        sys.exit(0)
    else:
        print(f"\n{RED}❌ AUDIT FAILED{NC}")
        sys.exit(1)

if __name__ == "__main__":
    audit()
