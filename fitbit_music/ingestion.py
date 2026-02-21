from __future__ import annotations

from dataclasses import dataclass
from datetime import date, datetime, timedelta
from typing import Iterable

from fitbit_music.fitbit_api import FitbitApiClient, FitbitEndpoint
from fitbit_music.raw_storage import RawRecord, RawStorage

SUPPORTED_ENDPOINTS = ("heart_rate", "sleep", "steps")


@dataclass(frozen=True)
class IngestionSummary:
    saved_paths: list[str]


class FitbitRawIngestionService:
    def __init__(self, client: FitbitApiClient, storage: RawStorage) -> None:
        self._client = client
        self._storage = storage

    def ingest(self, since: datetime, until: datetime, endpoints: Iterable[str]) -> IngestionSummary:
        if since > until:
            raise ValueError("since は until 以前である必要があります。")

        endpoint_objs = [FitbitEndpoint(name=e) for e in endpoints]
        saved_paths: list[str] = []

        for target_date in _date_range(since.date(), until.date()):
            for endpoint in endpoint_objs:
                payload = self._client.fetch(endpoint=endpoint, target_date=target_date)
                path = self._storage.save(
                    RawRecord(endpoint=endpoint.name, target_date=target_date, payload=payload)
                )
                saved_paths.append(str(path))
        return IngestionSummary(saved_paths=saved_paths)


def parse_iso_datetime(value: str) -> datetime:
    try:
        if len(value) == 10:
            return datetime.fromisoformat(value + "T00:00:00")
        return datetime.fromisoformat(value)
    except ValueError as exc:
        raise ValueError(f"ISO8601形式で指定してください: {value}") from exc


def _date_range(start: date, end: date):
    current = start
    while current <= end:
        yield current
        current = current + timedelta(days=1)
