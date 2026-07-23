import os
import subprocess
import platform
import logging
from typing import List
from .models import CommandPayload
from .hitl import require_approval
from .exceptions import SuiError

logger = logging.getLogger("sui")


class Elevator:
    """Sovereign Command Elevation Engine."""

    def __init__(self):
        self.os_type = platform.system().lower()

    def _is_shell_required(self, cmd: List[str]) -> bool:
        if len(cmd) != 1:
            return False
        import re

        # Detect shell metacharacters or spaces
        return bool(re.search(r"[^a-zA-Z0-9._/+-]", cmd[0]))

    def get_elevated_command(self, cmd: List[str]) -> List[str]:
        # Logic to wrap command
        is_shell = self._is_shell_required(cmd)

        if self.os_type == "linux" or self.os_type == "darwin":
            if is_shell:
                return ["sudo", "bash", "-c", cmd[0]]
            return ["sudo"] + cmd

        if self.os_type == "windows":
            import shutil

            if is_shell:
                # Wrap in powershell
                shell_cmd = ["powershell.exe", "-Command", cmd[0]]
                if shutil.which("gsudo"):
                    return ["gsudo"] + shell_cmd
                return shell_cmd  # Fallback to native PS (might need -Verb RunAs)

            if shutil.which("gsudo"):
                return ["gsudo"] + cmd
            return ["powershell.exe", "-Command", f"Start-Process -Verb RunAs {cmd[0]}"]

        return cmd

    @require_approval()
    async def execute(self, payload: CommandPayload, rationale: str = "") -> int:
        """
        Execute an elevated command.
        Requires Human-in-the-Loop approval via the Sui Web Gateway.
        """
        final_cmd = self.get_elevated_command(payload.command)
        logger.info(f"Elevating: {' '.join(final_cmd)}")

        try:
            # Execute in the original environment/cwd if possible
            result = subprocess.run(
                final_cmd,
                cwd=payload.cwd,
                env={**os.environ, **payload.env},
                check=False,
            )
            return result.returncode
        except Exception as e:
            logger.error(f"Execution failed: {e}")
            raise SuiError(f"Elevation failed: {e}")
