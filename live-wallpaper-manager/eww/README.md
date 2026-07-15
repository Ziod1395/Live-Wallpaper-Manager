# Live Wallpaper Manager (Eww + mpvpaper + Hyprland)

## 1. Cài đặt phụ thuộc (Arch Linux)

```bash
sudo pacman -S eww jq ffmpeg
yay -S mpvpaper   # thường nằm ở AUR
```

## 2. Copy vào đúng vị trí

```bash
mkdir -p ~/Pictures/Live\ Wallpaper
cp -r eww/* ~/.config/eww/
chmod +x ~/.config/eww/scripts/*.sh
```

Bỏ các file video (`.mp4 .webm .mkv .mov`) vào `~/Pictures/Live Wallpaper`.

## 3. Chạy thử

```bash
eww kill              # đảm bảo không có daemon eww cũ nào chạy
eww daemon

# Icon shortcut nhỏ ở góc trên-phải màn hình, bấm vào để mở/đóng panel
eww open wallpaper-trigger

# Hoặc mở thẳng panel chính (không cần qua icon)
eww open wallpaper-manager
```

Đóng panel chính: bấm nút ✕ trên panel, hoặc `eww close wallpaper-manager`.
Đóng hẳn icon shortcut: `eww close wallpaper-trigger`.

> **Lưu ý:** icon shortcut "LW" không dùng chế độ toggle thuần — mỗi lần
> bấm sẽ đóng rồi mở lại panel để ép cấp lại keyboard focus cho ô tìm
> kiếm. Đây là cách khắc phục lỗi thường gặp trên layer-shell (Wayland):
> ô tìm kiếm bị "đơ", không gõ được nữa sau khi bạn chuyển sang cửa sổ
> ứng dụng khác rồi quay lại panel. Nếu gặp tình trạng này, chỉ cần bấm
> lại icon "LW" một lần là gõ được bình thường.

### Tìm được trong Rofi / launcher (như Brave, btop++ trong ảnh)

Copy file `.desktop` vào thư mục ứng dụng của user:

```bash
mkdir -p ~/.local/share/applications
cp live-wallpaper-manager.desktop ~/.local/share/applications/
update-desktop-database ~/.local/share/applications 2>/dev/null
```

Mở Rofi lên, gõ "Live Wallpaper" hoặc "wallpaper" là sẽ thấy nó trong danh
sách, bấm Enter là mở/đóng panel — không cần gõ lệnh `eww open` nữa.

> Nếu Rofi của bạn dùng chế độ `drun` (danh sách ứng dụng, giống ảnh bạn
> gửi) thì nó sẽ hiện ra ngay. Nếu Rofi đang chạy ở chế độ khác (window,
> run, ssh...) hãy đảm bảo bạn mở đúng menu ứng dụng (thường là phím tắt
> mặc định của Hyprland, hoặc lệnh `rofi -show drun`).

### Tìm được trong Rofi / launcher (wofi, dmenu...)

Copy file `.desktop` đi kèm vào thư mục ứng dụng của người dùng:

```bash
mkdir -p ~/.local/share/applications
cp live-wallpaper-manager.desktop ~/.local/share/applications/
update-desktop-database ~/.local/share/applications 2>/dev/null || true
```

Mở Rofi, gõ "Live Wallpaper" là sẽ thấy xuất hiện trong danh sách như các
ứng dụng khác. Bấm Enter sẽ tự khởi động `eww daemon` (nếu chưa chạy) rồi
mở/đóng panel.

### Tự khởi động cùng Hyprland

Thêm vào `~/.config/hypr/hyprland.conf` để icon shortcut luôn xuất hiện
ngay khi mở máy, không cần gõ lệnh:

```ini
exec-once = eww daemon
exec-once = eww open wallpaper-trigger
```

### Cấu hình blur + bo góc trong Hyprland

> ⚠️ Hyprland đã đổi cú pháp `layerrule`/`windowrule` kể từ bản **0.53**.
> Dùng đúng khối tương ứng với bản Hyprland bạn đang chạy — kiểm tra
> bằng lệnh `hyprctl version`.

**Nếu bạn dùng Hyprland >= 0.53 (cú pháp mới):**

```ini
decoration {
    blur {
        enabled = true
        size = 8
        passes = 3
        new_optimizations = true
    }
    rounding = 20
}

# Áp blur cho panel chính + icon shortcut theo namespace
layerrule = blur on, ignore_alpha 1, match:namespace livewallpaper
layerrule = ignore_alpha 1, match:namespace livewallpaper-trigger
```

**Nếu bạn dùng Hyprland < 0.53 (cú pháp cũ):**

```ini
decoration {
    blur {
        enabled = true
        size = 8
        passes = 3
        new_optimizations = true
    }
    rounding = 20
}

layerrule = blur, livewallpaper
layerrule = ignorezero, livewallpaper
layerrule = ignorezero, livewallpaper-trigger
```

Sau khi sửa file, áp dụng ngay không cần khởi động lại máy:
```bash
hyprctl reload
```

Nếu vẫn còn lỗi "Config error ... invalid field ... missing a value" ở
dòng nào đó, đó là do đúng bản Hyprland của bạn khác giả định ở trên —
chạy `hyprctl version` rồi gửi mình kết quả để xác nhận đúng cú pháp.

## 4. Cấu hình Hyprland (blur nền + bo góc thật sự)

GTK/Eww không tự vẽ được backdrop-blur — phần "blur nền" phải do
Hyprland xử lý ở tầng compositor thông qua layer rule, dựa vào
`:namespace "livewallpaper"` đã khai báo trong `eww.yuck`.

👉 Xem chi tiết đầy đủ (kèm cả cú pháp cũ/mới tùy phiên bản Hyprland)
ở mục **"Cấu hình blur + bo góc trong Hyprland"** phía trên (mục 3).

> Ghi chú: `mpvpaper` tự vẽ layer riêng ở dưới cùng (background layer)
> nên nó sẽ không bị Eww che khuất về mặt hiệu năng khi bạn đóng panel.

## 5. Đổi tên monitor nếu cần

Mặc định `apply_wallpaper.sh` dùng `eDP-1` (màn hình laptop) và tự
động dò monitor đang focus qua `hyprctl monitors -j`. Nếu muốn ép
cứng 1 màn hình cụ thể:

```bash
MONITOR=DP-1 ~/.config/eww/scripts/apply_wallpaper.sh "/path/to/video.mp4"
```

## 5b. Chọn độ phân giải phát wallpaper

Panel có sẵn bộ nút **480p / 720p / 1080p / 2K / 4K** ngay dưới thanh
tìm kiếm (mặc định 1080p). Chọn độ phân giải thấp hơn sẽ giảm tải
CPU/GPU khi phát (dùng bộ lọc `scale` của mpv), đổi lại hình hơi mờ
hơn bản gốc. Lựa chọn này áp dụng cho lần Apply tiếp theo, và được
nhớ lại để nút "Start Wallpaper" phát đúng độ phân giải đã chọn
trước đó.

> Lưu ý: chọn 2K/4K trên video nguồn có độ phân giải thấp hơn sẽ chỉ
> là phóng to (upscale), không tăng thêm chi tiết thật và có thể còn
> tốn tài nguyên hơn — chỉ chọn khi video gốc đã sẵn độ phân giải đó
> trở lên.

Cũng có thể gọi tay từ terminal:
```bash
~/.config/eww/scripts/apply_wallpaper.sh "/path/to/video.mp4" 720p
```
Tham số thứ 2 là tuỳ chọn, nhận các giá trị: `480p`, `720p`, `1080p`
(mặc định), `2k`, `4k`.

## 6. Cấu trúc thư mục

```
~/.config/eww/
├── eww.yuck
├── eww.scss
└── scripts/
    ├── wallpaper_list.sh     # quét thư mục -> JSON
    ├── apply_wallpaper.sh    # pkill + chạy mpvpaper
    ├── stop_wallpaper.sh     # pkill mpvpaper
    ├── refresh.sh            # quét lại + sinh thumbnail thiếu
    └── thumbnail.sh          # ffmpeg tạo thumbnail 400x225

~/.cache/livewallpaper/
├── current                   # đường dẫn video đang áp dụng
└── thumbs/                   # thumbnail .png đã sinh (cache theo hash path)
```

## 7. Lưu ý / giới hạn đã biết

- Ô tìm kiếm lọc theo tên file (không phân biệt hoa/thường) bằng hàm
  `jq()` dựng sẵn trong Eww simplexpr — cần Eww bản build có hỗ trợ jq
  (bản chính thức trên AUR `eww` / `eww-git` đều có).
- Tên file wallpaper không nên chứa dấu nháy đơn (`'`) vì đường dẫn
  được truyền vào script bằng cách bọc trong `'...'`.
- Thumbnail được đặt tên theo mã băm MD5 của đường dẫn video để tránh
  đụng độ khi có nhiều file trùng tên ở thư mục con khác nhau.
