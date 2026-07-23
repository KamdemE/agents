from pydantic import BaseModel, ConfigDict
from typing import List


class CommandPayload(BaseModel):
    model_config = ConfigDict(extra="forbid")

    command: List[str]
    cwd: str
    user: str
    host: str
    env: dict[str, str]
