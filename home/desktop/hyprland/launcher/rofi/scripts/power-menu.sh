# Power menu via rofi

selected=$(echo -e "Lock\nLogout\nSuspend\nReboot\nShutdown" | rofi -dmenu -i -p "Power" -theme-str 'window {width: 200px;} listview {lines: 5;}')

case "$selected" in
    Lock) hyprlock ;;
    Logout) uwsm stop ;;
    Suspend) systemctl suspend ;;
    Reboot) systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac
