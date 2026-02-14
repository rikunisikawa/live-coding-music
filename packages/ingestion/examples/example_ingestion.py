from packages.ingestion.src.base_ingestion import BaseIngestion


class ExampleIngestion(BaseIngestion):
    def extract(self):
        return [
            {"event_id": 1, "event_type": "click", "updated_at": "2026-02-14"},
            {"event_id": 2, "event_type": "view", "updated_at": "2026-02-14"},
        ]

    def transform(self, records):
        return records

    def load(self, records):
        for record in records:
            print(f"load: {record}")


if __name__ == "__main__":
    ExampleIngestion().run()
