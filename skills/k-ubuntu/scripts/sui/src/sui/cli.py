import typer
import asyncio
import os
import platform
import sys
from typing import List, Optional
from .api import Elevator
from .models import CommandPayload
from .logger import logger
from .config import VERSION

app = typer.Typer(
    help="Sovereign Unified Interface — Agnostic privileged command gateway"
)


@app.command()
def do(
    commands: List[str] = typer.Argument(
        ..., help="The command to execute with privileges"
    ),
    reason: str = typer.Option("", "--reason", "-r", help="Rationale for this action"),
    port: Optional[int] = typer.Option(None, "--port", "-p", help="HITL port override"),
):
    """
    Execute a command with elevated privileges.
    """
    if port:
        from .config import set_hitl_port

        set_hitl_port(port)

    elevator = Elevator()
    payload = CommandPayload(
        command=commands,
        cwd=os.getcwd(),
        user=os.getlogin()
        if platform.system() != "Windows"
        else os.environ.get("USERNAME", "user"),
        host=platform.node(),
        env={},
    )

    async def _run():
        try:
            exit_code = await elevator.execute(payload, rationale=reason)
            sys.exit(exit_code)
        except Exception as e:
            logger.error(str(e))
            sys.exit(1)

    asyncio.run(_run())


@app.command()
def version():
    """Show version information."""
    typer.echo(f"sui v{VERSION}")


if __name__ == "__main__":
    app()
