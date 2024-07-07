#!/bin/bash
# shellcheck disable=SC2086

BORDER_LABEL=" dexe: the exe launcher "

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
    exe_check="-executable"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        exe_check="-perm +111"
    fi

    IFS=: read -ra DIRS <<<"$PATH"
    find "${DIRS[@]}" -maxdepth 1 $exe_check -type f -or -type l 2>/dev/null |
        awk -F/ '{print $NF}' | sort -u | fzf --border-label "$BORDER_LABEL" --preview "{} --help"
}

main() {
    check_command "fzf"
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help
        exit 0
    fi

    executable=$(select_executable)
    if [ -n "$executable" ]; then
        "$executable" "$@"
    else
        exit 1
    fi
    read -r -p "Press any key to continue..."
}

main "$@"
