#!/bin/sh
# Discord (Vesktop) in the background, for Rich Presence
# -f because Nix wraps the binary, so the process name isn't plain "vesktop"
pgrep -f vesktop >/dev/null || vesktop --start-minimized &

# Wake the KDE Connect daemon (no window)
kdeconnect-cli --list-devices >/dev/null 2>&1 &
