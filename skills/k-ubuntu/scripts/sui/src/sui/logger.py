import logging
import sys
from logging.handlers import RotatingFileHandler
from .config import LOG_PATH


def setup_logger(name: str = "sui", level: int = logging.INFO):
    logger = logging.getLogger(name)
    logger.setLevel(level)

    if logger.handlers:
        return logger

    formatter = logging.Formatter(
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    )

    # Console Handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)

    # File Handler
    try:
        file_handler = RotatingFileHandler(
            LOG_PATH, maxBytes=10 * 1024 * 1024, backupCount=5
        )
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
    except Exception:
        pass

    return logger


logger = setup_logger()
