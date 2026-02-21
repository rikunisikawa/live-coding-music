from __future__ import annotations

import json
from dataclasses import dataclass
from datetime import date
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


@dataclass(frozen=True)
class FitbitEndpoint:
    name: str

    def path(self, target_date: date) -> str:
        value = target_date.isoformat()
        if self.name == "heart_rate":
            return f"/1/user/-/activities/heart/date/{value}/1d.json"
        if self.name == "sleep":
            return f"/1.2/user/-/sleep/date/{value}.json"
        if self.name == "steps":
            return f"/1/user/-/activities/steps/date/{value}/1d.json"
        raise ValueError(f"未対応endpoint: {self.name}")


class FitbitApiClient:
    def __init__(self, access_token: str, base_url: str = "https://api.fitbit.com") -> None:
        if not access_token:
            raise ValueError("access_token が必要です。")
        self._access_token = access_token
        self._base_url = base_url.rstrip("/")

    def fetch(self, endpoint: FitbitEndpoint, target_date: date) -> dict:
        url = f"{self._base_url}{endpoint.path(target_date)}"
        request = Request(
            url=url,
            method="GET",
            headers={
                "Authorization": f"Bearer {self._access_token}",
                "Accept": "application/json",
            },
        )
        try:
            with urlopen(request, timeout=30) as response:
                body = response.read().decode("utf-8")
                return json.loads(body)
        except HTTPError as exc:
            body = exc.read().decode("utf-8", errors="ignore")
            raise RuntimeError(
                f"Fitbit API error endpoint={endpoint.name} date={target_date.isoformat()} status={exc.code} body={body}"
            ) from exc
        except URLError as exc:
            raise RuntimeError(
                f"Fitbit API connection error endpoint={endpoint.name} date={target_date.isoformat()} reason={exc.reason}"
            ) from exc
