#!/usr/bin/env bash
#
# wallpaper_list.sh
# ------------------
# Quét toàn bộ file video (*.mp4 *.webm *.mkv *.mov) trong ~/Videos/Wallpapers
# và in ra một mảng JSON để Eww (defpoll) đọc trực tiếp.
#
# Mỗi phần tử JSON có dạng:
# { "name": "TenKhongDuoi", "path": "/duong/dan/day/du.mp4", "thumb": "/duong/dan/thumb.png" }
#
# Nếu thumbnail chưa tồn tại, script sẽ tự gọi thumbnail.sh để sinh ra.
# Không hardcode bất kỳ tên file nào — toàn bộ được quét động.

set -o pipefail

WALL_DIR="$HOME/Pictures/Live Wallpaper"
THUMB_DIR="$HOME/.cache/livewallpaper/thumbs"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$WALL_DIR" "$THUMB_DIR"

# Nếu chưa có wallpaper nào -> trả về mảng rỗng hợp lệ
shopt -s nullglob nocaseglob
files=("$WALL_DIR"/*.mp4 "$WALL_DIR"/*.webm "$WALL_DIR"/*.mkv "$WALL_DIR"/*.mov)
shopt -u nocaseglob nullglob

if [ "${#files[@]}" -eq 0 ]; then
    echo "[]"
    exit 0
fi

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

for f in "${files[@]}"; do
    [ -f "$f" ] || continue

    name="$(basename "$f")"
    name_noext="${name%.*}"

    # Thumbnail được đặt tên theo hash đường dẫn để tránh trùng khi 2 file
    # cùng tên nhưng khác thư mục con (an toàn hơn dùng tên gốc).
    hash="$(echo -n "$f" | md5sum | cut -d' ' -f1)"
    thumb="$THUMB_DIR/${hash}.png"

    # Tự sinh thumbnail nếu chưa có
    if [ ! -s "$thumb" ]; then
        "$SCRIPT_DIR/thumbnail.sh" "$f" "$thumb" >/dev/null 2>&1
    fi

    jq -n \
        --arg name "$name_noext" \
        --arg path "$f" \
        --arg thumb "$thumb" \
        '{name: $name, path: $path, thumb: $thumb}' >> "$tmp_file"
done

# Gộp toàn bộ object đơn lẻ thành 1 mảng JSON duy nhất
jq -s '.' "$tmp_file"
