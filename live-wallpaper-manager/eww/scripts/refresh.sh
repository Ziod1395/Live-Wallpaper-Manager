#!/usr/bin/env bash
#
# refresh.sh
# -----------
# Quét lại toàn bộ thư mục Wallpapers, sinh thumbnail còn thiếu
# (thông qua wallpaper_list.sh, script này tự gọi thumbnail.sh khi cần),
# sau đó ép Eww cập nhật lại biến "wallpapers" ngay lập tức thay vì
# đợi đến chu kỳ defpoll tiếp theo.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Dọn thumbnail rác (video đã bị xoá khỏi thư mục Wallpapers)
WALL_DIR="$HOME/Pictures/Live Wallpaper"
THUMB_DIR="$HOME/.cache/livewallpaper/thumbs"
mkdir -p "$THUMB_DIR"

# Danh sách hash hợp lệ hiện tại (theo file video đang tồn tại)
shopt -s nullglob nocaseglob
valid_hashes=()
for f in "$WALL_DIR"/*.mp4 "$WALL_DIR"/*.webm "$WALL_DIR"/*.mkv "$WALL_DIR"/*.mov; do
    [ -f "$f" ] || continue
    valid_hashes+=("$(echo -n "$f" | md5sum | cut -d' ' -f1)")
done
shopt -u nocaseglob nullglob

for t in "$THUMB_DIR"/*.png; do
    [ -f "$t" ] || continue
    base="$(basename "$t" .png)"
    keep=false
    for h in "${valid_hashes[@]}"; do
        [ "$h" = "$base" ] && keep=true && break
    done
    $keep || rm -f "$t"
done

# Quét lại + sinh JSON mới (đồng thời tự sinh thumbnail còn thiếu)
json="$("$SCRIPT_DIR/wallpaper_list.sh")"

# Đẩy dữ liệu mới vào biến "wallpapers" của Eww ngay lập tức
if command -v eww >/dev/null 2>&1; then
    eww update wallpapers="$json" 2>/dev/null
fi

echo "Đã refresh danh sách wallpaper."
