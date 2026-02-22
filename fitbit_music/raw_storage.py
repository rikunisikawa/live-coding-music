from __future__ import annotations

import json
from dataclasses import dataclass
from datetime import date, datetime, timezone
from pathlib import Path


@dataclass(frozen=True)
class RawRecord:
    endpoint: str
    target_date: date
    payload: dict


class RawStorage:
    def __init__(self, base_dir: Path) -> None:
        self._base_dir = Path(base_dir)

    def save(self, record: RawRecord) -> Path:
        now = datetime.now(timezone.utc)
        partition_dir = self._base_dir / record.endpoint / f"date={record.target_date.isoformat()}"
        partition_dir.mkdir(parents=True, exist_ok=True)
        filename = f"fetched_at={now.strftime('%Y%m%dT%H%M%SZ')}.json"
        destination = partition_dir / filename

        data = {
            "meta": {
                "endpoint": record.endpoint,
                "target_date": record.target_date.isoformat(),
                "fetched_at": now.isoformat(),
                "source": "fitbit_web_api",
            },
            "payload": record.payload,
        }
        destination.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
        return destination
