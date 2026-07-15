#!/usr/bin/env bash
# Script cài đặt tổng hợp Live Wallpaper Manager + tích hợp Waybar
# Chạy: bash install.sh (từ trong thư mục vừa giải nén, cạnh eww.yuck)
set -e

echo "==> Copy cấu hình Eww vào ~/.config/eww"
mkdir -p ~/.config/eww
cp -r ./* ~/.config/eww/ 2>/dev/null || true
chmod +x ~/.config/eww/scripts/*.sh

echo "==> Tạo thư mục chứa wallpaper (nếu chưa có)"
mkdir -p ~/Pictures/Live\ Wallpaper

echo "==> Cài entry Rofi"
mkdir -p ~/.local/share/applications
cp ~/.config/eww/live-wallpaper-manager.desktop ~/.local/share/applications/ 2>/dev/null || true
update-desktop-database ~/.local/share/applications 2>/dev/null || true

echo "==> Khởi động lại Eww daemon"
eww kill 2>/dev/null || true
sleep 0.3
eww daemon
sleep 0.3
eww open wallpaper-manager

echo ""
echo "✅ Xong. Panel Eww đã mở."
echo "⚠️  Bước Waybar KHÔNG tự động: mở file WAYBAR.md, copy đoạn JSON vào"
echo "    ~/.config/waybar/config và đoạn CSS vào ~/.config/waybar/style.css,"
echo "    rồi chạy:  killall waybar && waybar &"
