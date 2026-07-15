#!/usr/bin/env bash
#
# start_wallpaper.sh
# --------------------
# Phát lại wallpaper vừa được Stop trước đó (đọc từ
# ~/.cache/livewallpaper/last, được apply_wallpaper.sh ghi mỗi lần Apply
# và KHÔNG bị xoá khi Stop). Dùng cho nút "Start Wallpaper" trên panel.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAST_FILE="$HOME/.cache/livewallpaper/last"
RES_FILE="$HOME/.cache/livewallpaper/resolution"

if [ ! -s "$LAST_FILE" ]; then
    echo "Chưa có wallpaper nào được chọn trước đó. Hãy chọn 1 wallpaper từ danh sách." >&2
    exit 1
fi

VIDEO="$(cat "$LAST_FILE")"
RESOLUTION="1080p"
[ -s "$RES_FILE" ] && RESOLUTION="$(cat "$RES_FILE")"

if [ ! -f "$VIDEO" ]; then
    echo "Error: video đã lưu không còn tồn tại: $VIDEO" >&2
    exit 1
fi

exec "$SCRIPT_DIR/apply_wallpaper.sh" "$VIDEO" "$RESOLUTION"
