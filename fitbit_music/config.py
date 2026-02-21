from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class FitbitConfig:
    client_id: str
    client_secret: str
    redirect_uri: str
    access_token: str
    raw_dir: Path


def _env(name: str, default: str = "") -> str:
    return os.getenv(name, default).strip()


def load_config() -> FitbitConfig:
    access_token = _env("FITBIT_ACCESS_TOKEN")
    if not access_token:
        raise ValueError("環境変数 FITBIT_ACCESS_TOKEN が未設定です。")

    raw_dir = Path(_env("FITBIT_RAW_DIR", "data/raw"))
    return FitbitConfig(
        client_id=_env("FITBIT_CLIENT_ID"),
        client_secret=_env("FITBIT_CLIENT_SECRET"),
        redirect_uri=_env("FITBIT_REDIRECT_URI", "http://localhost:8080/callback"),
        access_token=access_token,
        raw_dir=raw_dir,
    )
