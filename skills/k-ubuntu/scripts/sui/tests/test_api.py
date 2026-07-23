import pytest
from sui.api import Elevator
from sui.models import CommandPayload


@pytest.mark.asyncio
async def test_elevator_linux():
    elevator = Elevator()
    # Mocking platform for test
    elevator.os_type = "linux"

    payload = CommandPayload(
        command=["ls", "-la"], cwd="/tmp", user="test", host="test", env={}
    )

    # The command should be prefixed with sudo
    cmd = elevator.get_elevated_command(payload.command)
    assert cmd == ["sudo", "ls", "-la"]


@pytest.mark.asyncio
async def test_elevator_shell_wrap():
    elevator = Elevator()
    elevator.os_type = "linux"

    payload = CommandPayload(
        command=["ls -la /root"], cwd="/tmp", user="test", host="test", env={}
    )

    # Should detect shell string and wrap
    cmd = elevator.get_elevated_command(payload.command)
    assert cmd == ["sudo", "bash", "-c", "ls -la /root"]
