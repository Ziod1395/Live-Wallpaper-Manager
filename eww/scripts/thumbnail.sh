#!/usr/bin/env bash
#
# thumbnail.sh <video> <output_thumb.png>
# ----------------------------------------
# Dùng ffmpeg để trích 1 khung hình ở giây thứ 3 của video, resize/crop
# về đúng 400x225 (tỉ lệ 16:9) và lưu thành PNG.

VIDEO="$1"
THUMB="$2"

if [ -z "$VIDEO" ] || [ -z "$THUMB" ]; then
    echo "Usage: thumbnail.sh <video> <output_thumb.png>" >&2
    exit 1
fi

if [ ! -f "$VIDEO" ]; then
    echo "Error: video không tồn tại: $VIDEO" >&2
    exit 1
fi

mkdir -p "$(dirname "$THUMB")"

# -ss trước -i để seek nhanh (input seeking)
# scale+crop đảm bảo luôn ra đúng 400x225 dù video có tỉ lệ khác
ffmpeg -y \
    -ss 00:00:03 \
    -i "$VIDEO" \
    -frames:v 1 \
    -vf "scale=400:225:force_original_aspect_ratio=increase,crop=400:225" \
    -loglevel error \
    "$THUMB"

# Nếu video ngắn hơn 3s (seek lỗi -> không sinh được ảnh), thử lại ở giây 0
if [ ! -s "$THUMB" ]; then
    ffmpeg -y \
        -i "$VIDEO" \
        -frames:v 1 \
        -vf "scale=400:225:force_original_aspect_ratio=increase,crop=400:225" \
        -loglevel error \
        "$THUMB"
fi
