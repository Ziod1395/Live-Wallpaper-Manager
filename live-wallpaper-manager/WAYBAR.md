# Tích hợp nút "LW" vào Waybar

Thay vì dùng cửa sổ Eww riêng (`wallpaper-trigger`) nổi trên màn hình,
cách này biến "LW" thành 1 module thật sự nằm TRONG Waybar, cạnh các
icon Bluetooth/Discord khác.

## 1. Thêm module vào `~/.config/waybar/config` (hoặc `config.jsonc`)

Thêm `"custom/livewallpaper"` vào mảng `modules-right` (hoặc `modules-left`
/ `modules-center` tùy vị trí bạn muốn, ví dụ đặt cạnh đồng hồ):

```jsonc
{
    "modules-right": ["custom/livewallpaper", "bluetooth", "custom/discord", "clock"],

    "custom/livewallpaper": {
        "format": "LW",
        "tooltip": true,
        "tooltip-format": "Live Wallpaper Manager",
        "on-click": "bash -c 'eww daemon >/dev/null 2>&1 & sleep 0.3; eww close wallpaper-manager 2>/dev/null; eww open wallpaper-manager'",
        "on-click-right": "~/.config/eww/scripts/stop_wallpaper.sh"
    }
}
```

- Bấm chuột trái: mở panel (tự đóng-mở lại để đảm bảo luôn focus được
  ô tìm kiếm, giống cơ chế nút LW cũ).
- Bấm chuột phải: dừng wallpaper ngay lập tức, không cần mở panel.

## 2. Style trong `~/.config/waybar/style.css`

File `style.css` của bạn đang gom chung style cho các module dạng này:

```css
#custom-power,
#tray,
#bluetooth,
#network,
#battery,
#pulseaudio,
#clock {
    color: @foreground;
    margin: 1px 0;
    padding: 0 10px;
}

#custom-power:hover,
#bluetooth:hover,
#network:hover,
#battery:hover,
#pulseaudio:hover,
#clock:hover {
    background-color: alpha(@select, 0.6);
}
```

Chỉ cần thêm `#custom-livewallpaper` vào **cả 2 nhóm selector trên**
(để nó tự động thừa hưởng margin/padding/hover giống Bluetooth, Network,
Clock...):

```css
#custom-power,
#tray,
#bluetooth,
#network,
#battery,
#pulseaudio,
#custom-livewallpaper,   /* <-- thêm dòng này */
#clock {
    color: @foreground;
    margin: 1px 0;
    padding: 0 10px;
}

#custom-power:hover,
#bluetooth:hover,
#network:hover,
#battery:hover,
#pulseaudio:hover,
#custom-livewallpaper:hover,   /* <-- thêm dòng này */
#clock:hover {
    background-color: alpha(@select, 0.6);
}
```

Rồi thêm màu riêng cho nó (đặt gần đoạn `#bluetooth { color: @yellow; }`
đã có sẵn trong file), dùng `@blue` cho khớp tông màu panel Live
Wallpaper:

```css
#custom-livewallpaper {
    color: @blue;
}
```

> Không cần khai báo lại `border-radius`, `font-family`, `font-weight`
> vì file của bạn đã set chung ở rule `* { ... }` đầu file rồi.

## 3. Reload Waybar

```bash
killall waybar
waybar &
```
(hoặc `pkill -SIGUSR2 waybar` nếu Waybar của bạn hỗ trợ reload bằng
signal, tùy cấu hình autostart bạn đang dùng)

## 4. (Tuỳ chọn) Bỏ icon shortcut Eww cũ

Vì "LW" giờ đã nằm trong Waybar, bạn có thể tắt cửa sổ trigger nổi cũ
(nếu trước đó có bật autostart cho nó):

```bash
eww close wallpaper-trigger 2>/dev/null
```

Và xóa dòng autostart tương ứng trong `~/.config/hypr/hyprland.conf`
nếu có:
```ini
exec-once = eww open wallpaper-trigger
```
