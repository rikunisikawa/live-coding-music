from __future__ import annotations

import argparse

from fitbit_music.config import load_config
from fitbit_music.fitbit_api import FitbitApiClient
from fitbit_music.ingestion import SUPPORTED_ENDPOINTS, FitbitRawIngestionService, parse_iso_datetime
from fitbit_music.raw_storage import RawStorage


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="fitbit-music")
    subparsers = parser.add_subparsers(dest="command", required=True)

    ingest = subparsers.add_parser("ingest", help="Fitbit APIからRawデータを取得")
    ingest.add_argument("--since", required=True, help="ISO8601日時または日付 (例: 2026-02-15)")
    ingest.add_argument("--until", required=True, help="ISO8601日時または日付 (例: 2026-02-15)")
    ingest.add_argument(
        "--endpoints",
        nargs="+",
        default=list(SUPPORTED_ENDPOINTS),
        help="取得対象endpoint (heart_rate sleep steps)",
    )

    return parser


def _run_ingest(args: argparse.Namespace) -> int:
    config = load_config()

    invalid = sorted(set(args.endpoints) - set(SUPPORTED_ENDPOINTS))
    if invalid:
        raise ValueError(f"未対応endpointが指定されました: {', '.join(invalid)}")

    since = parse_iso_datetime(args.since)
    until = parse_iso_datetime(args.until)

    service = FitbitRawIngestionService(
        client=FitbitApiClient(access_token=config.access_token),
        storage=RawStorage(config.raw_dir),
    )
    summary = service.ingest(since=since, until=until, endpoints=args.endpoints)

    print(f"取得完了: {len(summary.saved_paths)} ファイル保存")
    for path in summary.saved_paths:
        print(path)
    return 0


def main() -> int:
    parser = _build_parser()
    args = parser.parse_args()

    if args.command == "ingest":
        return _run_ingest(args)
    raise ValueError(f"未対応コマンドです: {args.command}")


if __name__ == "__main__":
    raise SystemExit(main())
