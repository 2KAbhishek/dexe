#!/bin/bash

BORDER_LABEL=" exer: select executable "

display_help() {
    cat <<EOF
exer: Execute and Launch CLI Tools 🚀✨

Usage: exer
EOF
}

check_command() {
    if ! command -v "$1" &>/dev/null; then
        echo "Error: The $1 command is not available. Make sure it is installed."
        exit 1
    fi
}

select_executable() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        for dir in $(echo "$PATH" | tr ":" "\n"); do
            find -L "$dir" -maxdepth 1 -type f -perm +111 2>/dev/null
        done | awk -F/ '{print $NF}' | sort -u | fzf --border-label "$BORDER_LABEL"
    else
        for dir in $(echo "$PATH" | tr ":" "\n"); do
            find -L "$dir" -maxdepth 1 -mindepth 1 -executable 2>/dev/null
        done | awk -F/ '{print $NF}' | sort -u | fzf --border-label "$BORDER_LABEL"
    fi
}

main() {
    check_command "fzf"
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help
        exit 0
    fi

    executable=$(select_executable)
    if [ -n "$executable" ]; then
        "$executable"
    else
        exit 1
    fi
    read -r -p "Press any key to continue..."
}

main "$@"
