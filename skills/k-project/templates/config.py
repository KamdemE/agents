# src/<package>/config.py
"""
Config management — override hierarchy:
  1. Built-in defaults  (config.yaml alongside this file)
  2. User config file   (override_path or CONFIG_PATH env var)
  3. Inline kwargs
"""
import copy
import os
import yaml
from functools import lru_cache
from pathlib import Path
from typing import Any, Dict, Optional
from dotenv import load_dotenv

_SENTINEL = object()
_DEFAULT_CONFIG = Path(__file__).parent / "config.yaml"


@lru_cache(maxsize=8)
def _load_yaml(path: Path) -> Dict[str, Any]:
    """Load a YAML file from disk, cached by absolute path."""
    if not path.exists():
        raise FileNotFoundError(f"Config not found: {path}")
    with open(path, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f)
    if not isinstance(data, dict):
        raise TypeError(f"Config at {path} must be a YAML mapping.")
    return data


def _deep_merge(base: Dict[str, Any], overlay: Dict[str, Any]) -> Dict[str, Any]:
    """Recursively merge overlay into base in-place. overlay wins."""
    for k, v in overlay.items():
        if isinstance(v, dict) and isinstance(base.get(k), dict):
            _deep_merge(base[k], v)
        else:
            base[k] = v
    return base


class ConfigManager:
    """
    Central config store. Supports file + inline overrides, nested access, type coercion.

    Usage::
        cm = ConfigManager()                          # defaults only
        cm = ConfigManager("~/my_config.yaml")        # + override file
        cm = ConfigManager(debug=True, model="x")     # + inline kwargs
        cm = ConfigManager("~/my.yaml", debug=True)   # both
    """

    def __init__(self, override_path: Optional[str] = None, **kwargs: Any) -> None:
        load_dotenv()
        data = copy.deepcopy(_load_yaml(_DEFAULT_CONFIG))

        env_path = os.environ.get("CONFIG_PATH")
        path_str = override_path or env_path
        if path_str:
            path = Path(path_str).expanduser()
            if path.exists():
                _deep_merge(data, copy.deepcopy(_load_yaml(path)))

        for k, v in kwargs.items():
            data[k] = v

        self._data = data

    def get(self, key: str, default: Any = None) -> Any:
        return self._data.get(key, default)

    def get_nested(self, *keys: str, default: Any = None) -> Any:
        """Navigate nested keys safely. Returns default if any key is missing."""
        node: Any = self._data
        for k in keys:
            if not isinstance(node, dict):
                return default
            node = node.get(k, _SENTINEL)
            if node is _SENTINEL:
                return default
        return node

    def set(self, key: str, value: Any) -> None:
        """Set a key with type coercion to match the existing type when possible."""
        existing = self._data.get(key)
        if existing is not None and not isinstance(value, type(existing)):
            try:
                value = type(existing)(value)
            except (ValueError, TypeError):
                pass
        self._data[key] = value

    @property
    def debug(self) -> bool:
        return bool(self._data.get("debug", False))

    def reload(self, override_path: Optional[str] = None, **kwargs: Any) -> None:
        """Clear caches and reinitialize."""
        _load_yaml.cache_clear()
        self.__init__(override_path, **kwargs)
