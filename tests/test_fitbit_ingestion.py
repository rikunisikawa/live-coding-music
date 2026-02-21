from __future__ import annotations

import json
from datetime import date
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

from fitbit_music.fitbit_api import FitbitEndpoint
from fitbit_music.raw_storage import RawRecord, RawStorage


class FitbitEndpointTest(unittest.TestCase):
    def test_paths(self):
        target = date(2026, 2, 15)
        self.assertEqual(
            FitbitEndpoint("heart_rate").path(target),
            "/1/user/-/activities/heart/date/2026-02-15/1d.json",
        )
        self.assertEqual(
            FitbitEndpoint("sleep").path(target),
            "/1.2/user/-/sleep/date/2026-02-15.json",
        )
        self.assertEqual(
            FitbitEndpoint("steps").path(target),
            "/1/user/-/activities/steps/date/2026-02-15/1d.json",
        )


class RawStorageTest(unittest.TestCase):
    def test_save_layout(self):
        with TemporaryDirectory() as tmp:
            storage = RawStorage(Path(tmp))
            path = storage.save(
                RawRecord(
                    endpoint="heart_rate",
                    target_date=date(2026, 2, 15),
                    payload={"foo": "bar"},
                )
            )

            self.assertTrue(path.exists())
            self.assertIn("heart_rate/date=2026-02-15", str(path))

            data = json.loads(path.read_text(encoding="utf-8"))
            self.assertEqual(data["meta"]["endpoint"], "heart_rate")
            self.assertEqual(data["meta"]["target_date"], "2026-02-15")
            self.assertEqual(data["payload"]["foo"], "bar")


if __name__ == "__main__":
    unittest.main()
