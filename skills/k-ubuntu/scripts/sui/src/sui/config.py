import os
import yaml
from pathlib import Path
from functools import lru_cache

try:
    from importlib.metadata import version as get_version
except ImportError:

    def get_version(_):
        return "4.0.0"


# --- Source Paths ---
BUNDLED_CONFIG_PATH = Path(__file__).resolve().parent / "config.yaml"
PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent


# --- Dynamic Versioning ---
def _get_project_version() -> str:
    try:
        return get_version("sui")
    except Exception:
        pyproject_path = PROJECT_ROOT / "pyproject.toml"
        if pyproject_path.exists():
            with open(pyproject_path, "r") as f:
                for line in f:
                    if line.strip().startswith("version ="):
                        return line.split("=")[1].strip().strip('"').strip("'")
        return "4.0.0"


VERSION = _get_project_version()


# --- INFRASTRUCTURE HARDENING ---
def ensure_secure_infra():
    os.umask(0o077)
    data_dir = _resolve_data_dir()
    tmp_dir = Path("/tmp/sui")

    if not data_dir.exists():
        data_dir.mkdir(parents=True, mode=0o700)
    else:
        os.chmod(data_dir, 0o700)

    if not tmp_dir.exists():
        tmp_dir.mkdir(parents=True, mode=0o700)
    else:
        os.chmod(tmp_dir, 0o700)

    sensitive_files = [
        data_dir / "config.yaml",
        data_dir / "sui.log",
    ]
    for file_path in sensitive_files:
        if file_path.exists():
            os.chmod(file_path, 0o600)


def _resolve_data_dir() -> Path:
    env_dir = os.environ.get("SUI_DATA")
    if env_dir:
        return Path(os.path.expanduser(env_dir))
    return Path(os.path.expanduser("~/.sui"))


DEFAULT_DATA_DIR = _resolve_data_dir()
LOG_PATH = DEFAULT_DATA_DIR / "sui.log"

# Execute hardening
ensure_secure_infra()


def _resolve_config_path() -> Path:
    explicit = os.environ.get("SUI_CONFIG_PATH")
    if explicit:
        return Path(os.path.expanduser(explicit))
    runtime_config = DEFAULT_DATA_DIR / "config.yaml"
    if runtime_config.exists():
        return runtime_config
    return BUNDLED_CONFIG_PATH


CONFIG_PATH = _resolve_config_path()


def _read_yaml_mapping(path: Path) -> dict:
    if not path.exists():
        return {}
    with open(path, "r", encoding="utf-8") as f:
        try:
            data = yaml.safe_load(f) or {}
        except yaml.YAMLError:
            return {}
    return data if isinstance(data, dict) else {}


@lru_cache(maxsize=1)
def load_config(config_path=CONFIG_PATH, **overrides) -> dict:
    config = _read_yaml_mapping(Path(config_path))
    if config_path != BUNDLED_CONFIG_PATH:
        base = _read_yaml_mapping(BUNDLED_CONFIG_PATH)
        for k, v in base.items():
            if k not in config:
                config[k] = v

    def deep_update(d, u):
        for k, v in u.items():
            if isinstance(v, dict):
                d[k] = deep_update(d.get(k, {}), v)
            else:
                d[k] = v
        return d

    return deep_update(config, overrides)


_config = load_config()
_hitl_config = _config.get("hitl", {})

HITL_HOST = str(_hitl_config.get("host", "127.0.0.1"))
_DEFAULT_HITL_PORT = int(_hitl_config.get("port", 1143))
HITL_MAX_RETRIES = int(_hitl_config.get("max_retries", 5))
REQUIRED_RATIONALE = bool(_hitl_config.get("required_rationale", True))

_hitl_port_override: int | None = None


def set_hitl_port(port: int):
    global _hitl_port_override
    _hitl_port_override = port


def get_hitl_port() -> int:
    return _hitl_port_override or _DEFAULT_HITL_PORT
