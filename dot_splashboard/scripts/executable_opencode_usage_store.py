#!/usr/bin/env python3
# Aggregates OpenCode's local session DB into a splashboard basic_read_store
# text payload: $HOME/.splashboard/store/opencode_usage.json
# OpenCode has no subscription/quota concept, so this just reports today's
# token count as a plain number. Run before `splashboard --wait` to refresh it.

import json
import os
import sqlite3
from datetime import datetime, timedelta

DB_PATH = os.path.expanduser("~/.local/share/opencode/opencode.db")
STORE_PATH = os.path.expanduser("~/.splashboard/store/opencode_usage.json")


def main() -> None:
    total = 0
    if os.path.exists(DB_PATH):
        since_ms = int((datetime.now() - timedelta(days=1)).timestamp() * 1000)
        con = sqlite3.connect(DB_PATH)
        cur = con.cursor()
        for table in ("session", "session_v2"):
            try:
                cur.execute(
                    f"""
                    select tokens_input, tokens_output, tokens_reasoning
                    from {table}
                    where time_created >= ?
                    """,
                    (since_ms,),
                )
            except sqlite3.OperationalError:
                continue
            for tokens_input, tokens_output, tokens_reasoning in cur.fetchall():
                total += (tokens_input or 0) + (tokens_output or 0) + (tokens_reasoning or 0)
        con.close()

    payload = {"value": f"{total:,} tok (24h)"}
    os.makedirs(os.path.dirname(STORE_PATH), exist_ok=True)
    with open(STORE_PATH, "w", encoding="utf-8") as f:
        json.dump(payload, f)


if __name__ == "__main__":
    main()
