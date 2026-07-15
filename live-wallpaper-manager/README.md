# Live Wallpaper Manager

Trình quản lý live wallpaper cho **Hyprland**, giao diện dựng bằng
**Eww**, phát video nền bằng **mpvpaper**, theme **Catppuccin Mocha**
lấy cảm hứng từ Windows 11 (Mica/Fluent).

![theme](https://img.shields.io/badge/theme-Catppuccin%20Mocha-b4befe)
![wm](https://img.shields.io/badge/WM-Hyprland-33ccff)
![license](https://img.shields.io/badge/license-MIT-green)

## Tính năng

- Tự động quét toàn bộ video (`.mp4 .webm .mkv .mov`) trong thư mục
  wallpaper — không hardcode danh sách.
- Tự sinh thumbnail bằng `ffmpeg` nếu chưa có, cache tại
  `~/.cache/livewallpaper/thumbs`.
- Click 1 nút là đổi wallpaper ngay (`pkill` + `mpvpaper` qua
  `hyprctl dispatch exec` để tiến trình không bị dọn theo session,
  tự động thử lại nếu lần đầu bị compositor từ chối).
- Thanh tìm kiếm lọc theo tên video real-time.
- Hiển thị wallpaper đang dùng.
- Bộ chọn độ phân giải phát wallpaper: **480p / 720p / 1080p / 2K / 4K**
  (dùng bộ lọc `scale` của mpv để giảm tải CPU/GPU khi cần).
- Nút toggle **Start/Stop Wallpaper** động — tự đổi nhãn theo trạng
  thái, bấm Start sẽ phát lại đúng video + độ phân giải vừa dừng.
- Nút Refresh.
- Icon shortcut "LW" (dùng độc lập hoặc gắn vào Waybar).
- Entry `.desktop` để tìm được qua Rofi/launcher.
- Bo góc 20px + blur nền qua Hyprland layer rules.

## Cài đặt

### Phụ thuộc

```bash
sudo pacman -S eww jq ffmpeg
yay -S mpvpaper
```

### Cài nhanh

```bash
git clone https://github.com/<your-username>/live-wallpaper-manager.git
cd live-wallpaper-manager
bash install.sh
```

Script sẽ copy cấu hình vào `~/.config/eww`, tạo thư mục
`~/Pictures/Live Wallpaper`, cài entry Rofi, và mở panel lần đầu.

Bỏ file video (`.mp4 .webm .mkv .mov`) vào `~/Pictures/Live Wallpaper`
rồi bấm **Refresh** trên panel.

### Cấu hình Hyprland (blur + bo góc + autostart)

Xem chi tiết đầy đủ trong [`eww/README.md`](eww/README.md) — bao gồm
cả cú pháp `layerrule` cho Hyprland cũ **và** mới (≥ 0.53, đã đổi cú
pháp sang dạng `blur on, match:namespace ...`).

### Tích hợp vào Waybar (tuỳ chọn)

Xem [`WAYBAR.md`](WAYBAR.md) để thêm icon "LW" trực tiếp vào thanh
Waybar thay vì dùng cửa sổ Eww nổi riêng.

## Cấu trúc project

```
live-wallpaper-manager/
├── install.sh              # script cài đặt nhanh
├── WAYBAR.md                # hướng dẫn tích hợp Waybar
├── LICENSE
└── eww/
    ├── eww.yuck              # giao diện (Eww/yuck)
    ├── eww.scss              # theme Catppuccin Mocha + Windows 11
    ├── live-wallpaper-manager.desktop
    ├── README.md              # hướng dẫn cài đặt & cấu hình chi tiết
    └── scripts/
        ├── wallpaper_list.sh   # quét thư mục -> JSON
        ├── apply_wallpaper.sh  # đổi wallpaper qua mpvpaper
        ├── stop_wallpaper.sh   # dừng wallpaper
        ├── start_wallpaper.sh  # phát lại wallpaper vừa dừng
        ├── toggle_wallpaper.sh # gộp Start/Stop cho 1 nút duy nhất
        ├── refresh.sh          # quét lại + sinh thumbnail thiếu
        └── thumbnail.sh        # sinh thumbnail bằng ffmpeg
```

## Thư mục mặc định

| Việc gì | Ở đâu |
|---|---|
| Video wallpaper | `~/Pictures/Live Wallpaper` |
| Thumbnail cache | `~/.cache/livewallpaper/thumbs` |
| Wallpaper hiện tại | `~/.cache/livewallpaper/current` |
| Wallpaper để "Start" lại | `~/.cache/livewallpaper/last` |
| Độ phân giải đã chọn | `~/.cache/livewallpaper/resolution` |

## Gỡ cài đặt

```bash
eww kill
pkill -9 -f mpvpaper
rm -rf ~/.config/eww ~/.cache/livewallpaper
rm -f ~/.local/share/applications/live-wallpaper-manager.desktop
```
(không xóa `~/Pictures/Live Wallpaper` nếu muốn giữ lại video)

## License

MIT — xem [LICENSE](LICENSE).
