#!/usr/bin/env bash
#
# apply_wallpaper.sh <duong_dan_video> [do_phan_giai]
# -------------------------------------------------------
# Dừng mpvpaper đang chạy (nếu có) rồi phát live wallpaper mới bằng mpvpaper.
# Lưu lại đường dẫn video hiện tại vào ~/.cache/livewallpaper/current
# để giao diện Eww hiển thị "Current: ...".
#
# Tham số 2 [do_phan_giai] (tuỳ chọn): original | 1080p | 720p | 480p
# Mặc định "original" (giữ nguyên độ phân giải gốc, không scale).

VIDEO="$1"
RESOLUTION="${2:-1080p}"
CACHE_DIR="$HOME/.cache/livewallpaper"
CURRENT_FILE="$CACHE_DIR/current"
LAST_FILE="$CACHE_DIR/last"
RES_FILE="$CACHE_DIR/resolution"

# Có thể chỉnh lại tên màn hình cho đúng máy bạn (xem bằng: hyprctl monitors)
MONITOR="${MONITOR:-eDP-1}"

mkdir -p "$CACHE_DIR"

if [ -z "$VIDEO" ]; then
    echo "Error: chưa truyền đường dẫn video" >&2
    exit 1
fi

if [ ! -f "$VIDEO" ]; then
    echo "Error: video không tồn tại: $VIDEO" >&2
    exit 1
fi

# Cố gắng tự lấy monitor đang focus qua hyprctl, fallback về $MONITOR nếu lỗi
if command -v hyprctl >/dev/null 2>&1; then
    detected="$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused==true) | .name' 2>/dev/null)"
    [ -n "$detected" ] && MONITOR="$detected"
fi

# ---------------------------------------------------------------------------
# Chuyển tên độ phân giải sang bộ lọc scale của mpv. Dùng chiều cao cố định
# (chiều rộng "-2" để mpv tự tính theo đúng tỉ lệ khung hình gốc, luôn là
# số chẵn theo yêu cầu của nhiều codec).
# Lưu ý: chọn 4K trên video gốc có độ phân giải thấp hơn sẽ chỉ là upscale
# (phóng to), không tăng thêm chi tiết thật, có thể còn tốn tài nguyên hơn
# phát ở độ phân giải gốc — chọn 4K khi video nguồn đã sẵn 4K trở lên.
# ---------------------------------------------------------------------------
SCALE_FILTER=""
case "$RESOLUTION" in
    480p)  SCALE_FILTER="vf=scale=-2:480" ;;
    720p)  SCALE_FILTER="vf=scale=-2:720" ;;
    1080p) SCALE_FILTER="vf=scale=-2:1080" ;;
    2k|2K)  SCALE_FILTER="vf=scale=-2:1440" ;;
    4k|4K) SCALE_FILTER="vf=scale=-2:2160" ;;
    original|*) SCALE_FILTER="" ;;
esac

MPV_OPTS="loop no-audio hwdec=no"
[ -n "$SCALE_FILTER" ] && MPV_OPTS="$MPV_OPTS $SCALE_FILTER"

# ---------------------------------------------------------------------------
# Hàm launch_mpvpaper: thử phát mpvpaper bằng hyprctl dispatch exec trước
# (để chính Hyprland làm cha tiến trình, tránh bị dọn theo session/cgroup),
# fallback sang setsid nếu hyprctl không khởi động được. Trả về "true"/"false"
# tuỳ mpvpaper có thực sự lên hình hay không (poll pgrep tối đa 1.5s).
# ---------------------------------------------------------------------------
launch_mpvpaper() {
    if command -v hyprctl >/dev/null 2>&1 && [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        esc_monitor="$(printf '%q' "$MONITOR")"
        esc_video="$(printf '%q' "$VIDEO")"
        hyprctl dispatch exec "mpvpaper -f -o \"$MPV_OPTS\" $esc_monitor $esc_video" >/dev/null 2>&1
    else
        setsid mpvpaper -f -o "$MPV_OPTS" "$MONITOR" "$VIDEO" \
            > /dev/null 2>&1 < /dev/null &
        disown
    fi

    for _ in $(seq 1 15); do
        if pgrep -x mpvpaper >/dev/null 2>&1; then
            echo true
            return
        fi
        sleep 0.1
    done
    echo false
}

# ---------------------------------------------------------------------------
# Kill mọi tiến trình mpvpaper cũ đang chạy. Phải CHỜ XÁC NHẬN nó đã chết
# hẳn (poll bằng pgrep) rồi mới được mở cái mới — nếu chỉ sleep một khoảng
# cố định, tiến trình cũ có thể chưa kịp giải phóng layer-shell surface
# trên compositor, khiến lần launch đầu tiên bị compositor "từ chối" âm
# thầm.
# ---------------------------------------------------------------------------
if pgrep -x mpvpaper >/dev/null 2>&1; then
    pkill -x mpvpaper 2>/dev/null
    pkill -f "mpvpaper" 2>/dev/null

    for _ in $(seq 1 20); do
        pgrep -x mpvpaper >/dev/null 2>&1 || break
        sleep 0.1
    done

    if pgrep -x mpvpaper >/dev/null 2>&1; then
        pkill -9 -x mpvpaper 2>/dev/null
        pkill -9 -f "mpvpaper" 2>/dev/null
        sleep 0.5
    fi

    sleep 0.6
fi

# ---------------------------------------------------------------------------
# THỬ LAUNCH TỰ ĐỘNG TỐI ĐA 3 LẦN, không bắt người dùng phải tự bấm lại
# nút Apply.
# ---------------------------------------------------------------------------
started=false
for attempt in 1 2 3; do
    result="$(launch_mpvpaper)"
    if [ "$result" = "true" ]; then
        started=true
        break
    fi
    pkill -9 -x mpvpaper 2>/dev/null
    sleep $(( attempt * 1 ))
done

if [ "$started" = false ]; then
    echo "Cảnh báo: mpvpaper đã thoát ngay sau khi khởi động dù đã thử 3 lần (monitor: $MONITOR, resolution: $RESOLUTION)." >&2
    echo "Chạy tay để xem log lỗi: mpvpaper -v -o \"$MPV_OPTS\" $MONITOR \"$VIDEO\"" >&2
    exit 1
fi

# Lưu wallpaper hiện tại + độ phân giải đã chọn, để hiển thị trên UI và để
# nút "Start Wallpaper" phát lại đúng video VÀ đúng độ phân giải sau khi
# đã Stop (file "last"/"resolution" KHÔNG bị xoá khi Stop, khác "current").
echo "$VIDEO" > "$CURRENT_FILE"
echo "$VIDEO" > "$LAST_FILE"
echo "$RESOLUTION" > "$RES_FILE"

echo "Đã áp dụng wallpaper: $VIDEO (monitor: $MONITOR, độ phân giải: $RESOLUTION)"
