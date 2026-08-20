from __future__ import annotations

import json
from pathlib import Path

from pydantic import BaseModel, Field


class Settings(BaseModel):
    camera_index: int = 0
    host: str = "0.0.0.0"
    port: int = 8080
    recordings_dir: str = "recordings"
    segment_minutes: int = Field(default=5, ge=1)
    retention_days: int = Field(default=7, ge=1)
    fps: int = Field(default=15, ge=1)
    width: int = Field(default=1280, ge=160)
    height: int = Field(default=720, ge=120)
    jpeg_quality: int = Field(default=80, ge=20, le=95)


def load_settings(path: str = "config.json") -> Settings:
    config_path = Path(path)
    if not config_path.exists():
        example_path = Path("config.example.json")
        if example_path.exists():
            return Settings.model_validate_json(example_path.read_text(encoding="utf-8"))
        return Settings()

    return Settings.model_validate(json.loads(config_path.read_text(encoding="utf-8")))
