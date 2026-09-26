#!/bin/sh

case "$1" in
    *.txt|*.md|*.nix|*.py|*.lua|*.c|*.cpp|*.h|*.hpp|*.rs|*.go|*.js|*.ts|*.sh)
        bat --style=numbers --color=always "$1"
        exit 0
        ;;
esac

exit 0
