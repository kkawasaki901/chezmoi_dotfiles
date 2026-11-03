#!/usr/bin/env python3
# Computes "quota remaining %" for Claude/Codex/Cursor/Antigravity(agy)/OpenCode Go
# and writes splashboard basic_read_store payloads under
# $HOME/.splashboard/store/<widget_id>.json for the home dashboard's battery gauges.
#
# For each tool, writes:
#   <id>_gauge.json     -> {"value": R/100.0, "label": "<tool> <window>"}  (Ratio shape; gauge_battery prints "label ▕███░▏ R%" inline)
#   <id>_secondary.json -> {"value": "<secondary window text>"}
#
# Sources (read-only, never touches credentials):
#   Claude     -> ~/.config/yasb/claude_usage_cache.json        (yasb's own refresh, "used%")
#   Codex      -> ~/.splashboard/cache/codex_subscription-*.json (splashboard's own fetch, "used%")
#   Cursor     -> ~/.config/yasb/cursor_usage_cache.json        (yasb's own refresh, "used%")
#   Antigravity-> ~/.config/yasb/agy_usage_cache.json           (yasb's own refresh, "remaining fraction" already)
#   OpenCode Go-> $LOCALAPPDATA/yasb-opencode-go/usage.json     (yasb's own refresh, "used%")
#
# Run on a 5-minute schedule (see sync_tool_quotas.ps1 / the scheduled task); this
# script only reads already-fresh caches, it never calls an external API itself.

import json
import os
import re
import glob

STORE_DIR = os.path.expanduser("~/.splashboard/store")
YASB_DIR = os.path.expanduser("~/.config/yasb")
SPLASH_CACHE_DIR = os.path.expanduser("~/.splashboard/cache")
LOCALAPPDATA = os.environ.get("LOCALAPPDATA", os.path.expanduser("~/AppData/Local"))


def write_store(widget_id: str, payload: dict) -> None:
    os.makedirs(STORE_DIR, exist_ok=True)
    with open(os.path.join(STORE_DIR, f"{widget_id}.json"), "w", encoding="utf-8") as f:
        json.dump(payload, f)


# Pad every gauge label to the same width so the battery bar's left edge lands
# in the same column on every row, regardless of how long the tool name is.
LABEL_WIDTH = 15


def write_gauge(widget_id: str, remaining_pct: int, label: str) -> None:
    remaining_pct = max(0, min(100, remaining_pct))
    write_store(f"{widget_id}_gauge", {"value": remaining_pct / 100.0, "label": label.ljust(LABEL_WIDTH)})


def write_secondary(widget_id: str, text: str) -> None:
    write_store(f"{widget_id}_secondary", {"value": text})


def remaining_pct(used: float) -> int:
    return max(0, min(100, round(100.0 - used)))


def codex_window_pct(window_prefix: str) -> "int | None":
    """Read splashboard's own codex_subscription cache for a given window label prefix ("5h" or "7d")."""
    for path in glob.glob(os.path.join(SPLASH_CACHE_DIR, "codex_subscription-*.json")):
        try:
            with open(path, encoding="utf-8") as f:
                data = json.load(f)
            label = data["payload"]["data"]["label"]  # e.g. "5h 97%" or "7d 12%"
            if label.strip().startswith(window_prefix):
                m = re.search(r"(\d+(?:\.\d+)?)\s*%", label)
                return float(m.group(1))
        except Exception:
            continue
    return None


def sync_claude() -> None:
    path = os.path.join(YASB_DIR, "claude_usage_cache.json")
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        five = remaining_pct(data["five_hour"]["utilization"])
        seven = remaining_pct(data["seven_day"]["utilization"])
        write_gauge("claude", five, "Claude 5h")
        write_secondary("claude", f"7d: {seven}%")
    except Exception:
        write_gauge("claude", 0, "Claude 5h")
        write_secondary("claude", "7d: --")


def sync_codex() -> None:
    try:
        five_used = codex_window_pct("5h")
        seven_used = codex_window_pct("7d")
        five = remaining_pct(five_used) if five_used is not None else 0
        seven = remaining_pct(seven_used) if seven_used is not None else None
        write_gauge("codex", five, "Codex 5h")
        write_secondary("codex", f"7d: {seven}%" if seven is not None else "7d: --")
    except Exception:
        write_gauge("codex", 0, "Codex 5h")
        write_secondary("codex", "7d: --")


def sync_cursor() -> None:
    path = os.path.join(YASB_DIR, "cursor_usage_cache.json")
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        total = remaining_pct(float(data["planUsage"]["totalPercentUsed"]))
        auto = remaining_pct(float(data["planUsage"]["autoPercentUsed"]))
        api = remaining_pct(float(data["planUsage"]["apiPercentUsed"]))
        write_gauge("cursor", total, "Cursor Total")
        write_secondary("cursor", f"Auto: {auto}% / API: {api}%")
    except Exception:
        write_gauge("cursor", 0, "Cursor Total")
        write_secondary("cursor", "Auto: -- / API: --")


def sync_agy() -> None:
    path = os.path.join(YASB_DIR, "agy_usage_cache.json")
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        buckets = {}
        for group in data["command"]["data"]["groups"]:
            for b in group["buckets"]:
                buckets[b["id"]] = round(float(b["remaining_fraction"]) * 100)
        gem5h = buckets.get("gemini-5h", 100)
        tp5h = buckets.get("3p-5h", 100)
        gem7d = buckets.get("gemini-weekly", 100)
        tp7d = buckets.get("3p-weekly", 100)
        primary = min(gem5h, tp5h)
        write_gauge("agy", primary, "Antigravity 5h")
        write_secondary("agy", f"7d: Gem {gem7d}% / 3P {tp7d}%")
    except Exception:
        write_gauge("agy", 0, "Antigravity 5h")
        write_secondary("agy", "7d: --")


def sync_opencode_go() -> None:
    path = os.path.join(LOCALAPPDATA, "yasb-opencode-go", "usage.json")
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        weekly = remaining_pct(float(data["usage"]["weekly"]["percent"]))
        monthly = remaining_pct(float(data["usage"]["monthly"]["percent"]))
        write_gauge("opencode", weekly, "OpenCode 7d")
        write_secondary("opencode", f"30d: {monthly}%")
    except Exception:
        write_gauge("opencode", 0, "OpenCode 7d")
        write_secondary("opencode", "30d: --")


if __name__ == "__main__":
    sync_claude()
    sync_codex()
    sync_cursor()
    sync_agy()
    sync_opencode_go()
