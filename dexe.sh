#!/bin/bash
# shellcheck disable=SC2086
# shellcheck disable=SC2294

BORDER_LABEL=" dexe: the exe launcher "

display_help() {
    cat <<EOF
dexe: Execute and Launch CLI Tools 🚀✨

Usage: dexe [optional pass-through args]

dexe --wait-before-exit -- Wait for input before exiting
dexe -h, --help -- Display this help menu

dexe README.md -- Run selected command with README.md
dexe --verbose -- Run selected command with --verbose flag
EOF
}

check_command() {
    if ! command -v "$1" &>/dev/null; then
        echo "Error: The $1 command is not available. Make sure it is installed."
        exit 1
    fi
}

ensure_interactive_shell() {
    if [[ $- != *i* ]]; then
        exec bash -i "$0" "$@"
    fi
}

select_executable() {
    local exe_check="-executable"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        exe_check="-perm +111"
    fi

    IFS=: read -ra DIRS <<<"$PATH"
    exe_list=$(find "${DIRS[@]}" -maxdepth 1 $exe_check -type f -or -type l 2>/dev/null | awk -F/ '{print $NF}')
    alias_list=$(compgen -a)
    function_list=$(compgen -A function)
    all_items=$(sort -u <(echo -e "$exe_list\n$alias_list\n$function_list"))

    echo "$all_items" | fzf --border-label "$BORDER_LABEL" \
        --preview='( {1} --help || command -v {1} ) 2> /dev/null'
}

main() {
    check_command "fzf"
    ensure_interactive_shell "$@"

    case "$1" in
    "-h" | "--help")
        display_help
        exit 0
        ;;
    "--wait-before-exit")
        WAIT_BEFORE_EXIT=1
        shift
        PASSTHROUG_ARGS="$@"
        ;;
    *) PASSTHROUG_ARGS="$@" ;;
    esac

    executable=$(select_executable)
    if [ -n "$executable" ]; then
        eval "$executable" "$PASSTHROUG_ARGS"
    else
        exit 1
    fi

    if [[ -n "$WAIT_BEFORE_EXIT" ]]; then
        read -r -p "Press enter to continue..."
    fi
}

main "$@"
