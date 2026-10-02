#!/bin/sh

FILE="$1"
IMAGE="$5"

case "$FILE" in

    # Images
    *.jpg|*.jpeg|*.png|*.gif|*.webp|*.bmp|*.tiff|*.tif)
        kitty +kitten icat \
            --clear \
            --transfer-mode=file \
            "$FILE"
        exit 0
        ;;

    # Videos
    *.mp4|*.mkv|*.webm|*.avi|*.mov|*.flv|*.wmv|*.m4v)
        if [ -n "$IMAGE" ]; then
            ffmpegthumbnailer \
                -i "$FILE" \
                -o "$IMAGE" \
                -s 0 \
                -q 8 \
                2>/dev/null
        fi
        exit 0
        ;;

    # Text / code
    *.txt|*.md|*.nix|*.py|*.lua|*.c|*.cpp|*.h|*.hpp|*.rs|*.go|*.js|*.ts|*.sh)
        bat --style=numbers --color=always "$FILE"
        exit 0
        ;;

esac

exit 0
