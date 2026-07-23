import pytest
from unittest.mock import patch
from sui.hitl import HITLResponse


@pytest.fixture(autouse=True)
def mock_hitl_approval():
    """Automatically mock HITL approval for all tests."""
    with patch("sui.hitl.request_approval") as mock:
        mock.return_value = HITLResponse(status="APPROVED")
        yield mock


@pytest.fixture(autouse=True, scope="session")
def isolate_infra(tmp_path_factory):
    """Ensure tests never touch the real ~/.sui directory."""
    tmp_dir = tmp_path_factory.mktemp("sui_isolate")
    with (
        patch("sui.config.DEFAULT_DATA_DIR", tmp_dir),
        patch("sui.config.CONFIG_PATH", tmp_dir / "config.yaml"),
        patch("sui.config.LOG_PATH", tmp_dir / "sui.log"),
    ):
        yield tmp_dir
