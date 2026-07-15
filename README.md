# Live Wallpaper Manager

A modern **Live Wallpaper Manager** for **Hyprland**, built with **Eww** and powered by **mpvpaper**. It features a **Catppuccin Mocha** theme inspired by the Windows 11 Fluent (Mica) design language.

![theme](https://img.shields.io/badge/theme-Catppuccin%20Mocha-b4befe)
![wm](https://img.shields.io/badge/WM-Hyprland-33ccff)
![license](https://img.shields.io/badge/license-MIT-green)

---

## 🎥 Demo

▶️ **Watch the full demo on TikTok**

https://www.tiktok.com/@ziodenms/video/7662639226181225746

---

## ✨ Features

- Automatically scans all supported video files (`.mp4`, `.webm`, `.mkv`, `.mov`) inside the wallpaper directory — no hardcoded list required.
- Automatically generates thumbnails using **ffmpeg** and stores them in `~/.cache/livewallpaper/thumbs`.
- Change wallpapers instantly with a single click using **mpvpaper** (`pkill` + `hyprctl dispatch exec`). Automatically retries if the compositor rejects the first launch.
- Real-time wallpaper search.
- Displays the currently active wallpaper.
- Built-in wallpaper playback resolution selector:
  - **480p**
  - **720p**
  - **1080p**
  - **2K**
  - **4K**
- Uses mpv's `scale` filter to reduce CPU/GPU usage when lower resolutions are selected.
- Dynamic **Start / Stop Wallpaper** button.
  - Automatically changes its label depending on the current state.
  - Pressing **Start** resumes the last wallpaper with the previously selected resolution.
- Refresh button for rescanning wallpapers.
- "LW" shortcut icon (can be used standalone or integrated into Waybar).
- Desktop launcher (`.desktop`) for Rofi, Wofi, or other application launchers.
- Rounded 20px corners with Hyprland blur support via layer rules.

---

# 🚀 Installation

## Dependencies

```bash
sudo pacman -S eww jq ffmpeg
yay -S mpvpaper
```

## Quick Installation

```bash
cd ~/Downloads

git clone https://github.com/Ziod1395/Live-Wallpaper-Manager.git

cd Live-Wallpaper-Manager

mkdir -p "$HOME/Pictures/Live Wallpaper"

bash install.sh
```

The installer will automatically:

- Copy the configuration to `~/.config/eww`
- Create the default wallpaper directory:

```
~/Pictures/Live Wallpaper
```

- Install the desktop launcher
- Launch the wallpaper manager for the first time

Copy your video wallpapers (`.mp4`, `.webm`, `.mkv`, `.mov`) into:

```
~/Pictures/Live Wallpaper
```

Then click **Refresh** inside the manager.

---

## ▶️ Launch

Start the manager manually:

```bash
eww kill
eww daemon
eww open wallpaper-manager
eww open wallpaper-trigger
```

If Eww is already running and you've modified the configuration:

```bash
eww reload
```

---

## ⚙️ Hyprland Configuration

For complete Hyprland setup (blur, rounded corners, autostart, and layer rules), see:

**[`eww/README.md`](eww/README.md)**

The guide includes configuration examples for both:

- Older Hyprland versions
- Hyprland **0.53+** (`blur on, match:namespace ...` syntax)

---

## 🖥 Waybar Integration (Optional)

See **[`WAYBAR.md`](WAYBAR.md)** for instructions on adding the **LW** launcher directly to Waybar.

---

# 📁 Project Structure

```text
live-wallpaper-manager/
├── install.sh                    # Installation script
├── WAYBAR.md                     # Waybar integration guide
├── LICENSE
└── eww/
    ├── eww.yuck                  # Eww UI
    ├── eww.scss                  # Catppuccin Mocha theme
    ├── live-wallpaper-manager.desktop
    ├── README.md                 # Detailed setup guide
    └── scripts/
        ├── wallpaper_list.sh     # Scan wallpapers -> JSON
        ├── apply_wallpaper.sh    # Apply wallpaper
        ├── stop_wallpaper.sh     # Stop wallpaper
        ├── start_wallpaper.sh    # Resume previous wallpaper
        ├── toggle_wallpaper.sh   # Start / Stop toggle
        ├── refresh.sh            # Refresh wallpapers
        └── thumbnail.sh          # Generate thumbnails
```

---

# 📂 Default Directories

| Item | Location |
|------|----------|
| Video wallpapers | `~/Pictures/Live Wallpaper` |
| Thumbnail cache | `~/.cache/livewallpaper/thumbs` |
| Current wallpaper | `~/.cache/livewallpaper/current` |
| Last wallpaper | `~/.cache/livewallpaper/last` |
| Selected resolution | `~/.cache/livewallpaper/resolution` |

---

# 🗑 Uninstall

```bash
eww kill

pkill -9 -f mpvpaper

rm -rf ~/.config/eww

rm -rf ~/.cache/livewallpaper

rm -f ~/.local/share/applications/live-wallpaper-manager.desktop
```

> **Note:** Your videos inside `~/Pictures/Live Wallpaper` will **not** be removed.

---

# 📄 License

MIT License

Copyright (c) 2026 Ziod1395

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
