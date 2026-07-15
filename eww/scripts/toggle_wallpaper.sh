#!/usr/bin/env bash
#
# toggle_wallpaper.sh
# ----------------------
# Dùng cho 1 nút duy nhất trên panel: nếu mpvpaper đang chạy -> Stop,
# nếu không -> Start lại wallpaper vừa dừng trước đó.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if pgrep -x mpvpaper >/dev/null 2>&1; then
    exec "$SCRIPT_DIR/stop_wallpaper.sh"
else
    exec "$SCRIPT_DIR/start_wallpaper.sh"
fi
