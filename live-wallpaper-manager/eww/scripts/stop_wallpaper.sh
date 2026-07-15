#!/usr/bin/env bash
#
# stop_wallpaper.sh
# ------------------
# Dừng toàn bộ tiến trình mpvpaper và xoá wallpaper hiện tại trong cache
# để UI hiển thị "Current: Không có".

CURRENT_FILE="$HOME/.cache/livewallpaper/current"

pkill -x mpvpaper 2>/dev/null
pkill -f "mpvpaper" 2>/dev/null
sleep 0.4

if pgrep -x mpvpaper >/dev/null 2>&1; then
    pkill -9 -x mpvpaper 2>/dev/null
    pkill -9 -f "mpvpaper" 2>/dev/null
fi

rm -f "$CURRENT_FILE"

# Ép Hyprland vẽ lại (repaint) toàn màn hình sau khi mpvpaper đã bị kill.
# Nếu không làm bước này, khung hình cuối cùng của video có thể vẫn còn
# "đóng băng" trên màn hình dù tiến trình đã chết hẳn (quirk thường gặp
# của layer-shell trên Wayland: xóa surface không tự động trigger repaint
# vùng đó). Cách khắc phục: chuyển qua workspace kế rồi quay lại ngay lập
# tức để buộc Hyprland vẽ lại toàn bộ khung hình — quá nhanh để mắt người
# nhận ra, nhưng đủ để xóa sạch khung hình cũ.
if command -v hyprctl >/dev/null 2>&1 && [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    hyprctl dispatch workspace e+1 >/dev/null 2>&1
    hyprctl dispatch workspace e-1 >/dev/null 2>&1
fi

echo "Đã dừng live wallpaper."
