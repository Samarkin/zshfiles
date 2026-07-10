alias git-graph='git log --graph --oneline --all'

git-summarize() {
    # Color codes
    local GREEN='\033[0;32m'
    local RED='\033[0;31m'
    local YELLOW='\033[0;33m'
    local CYAN='\033[0;36m'
    local BLUE='\033[0;34m'
    local MAGENTA='\033[0;35m'
    local RESET='\033[0m'
    local INDENT='        '
    local dir file line

    for dir in . */(ND); do
        # Remove trailing slash
        dir="${dir%/}"

        # Check if directory contains a git repository
        if [ -d "$dir/.git" ]; then
            # Print directory name with current branch (blue) in brackets
            local branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
            if [ -n "$branch" ]; then
                echo -e "  $dir/    ${BLUE}[${branch}]${RESET}"
            else
                echo "  $dir/"
            fi

            # Summarize upstream tracking status
            local upstream=$(git -C "$dir" rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null)
            if [ -n "$upstream" ]; then
                # Check if upstream is ahead (local branch behind)
                local behind=$(git -C "$dir" rev-list --count HEAD..@{upstream} 2>/dev/null)
                if [ -n "$behind" ] && [ "$behind" -gt 0 ]; then
                    local commit_word="commits"
                    [ "$behind" -eq 1 ] && commit_word="commit"
                    echo -e "${INDENT}${CYAN}local branch is ${behind} ${commit_word} behind ${upstream}${RESET}"
                fi
                # Get unpublished commits (yellow)
                git -C "$dir" log --oneline @{upstream}..HEAD 2>/dev/null | while read -r line; do
                    echo -e "${INDENT}${YELLOW}${line}${RESET}"
                done
            else
                echo -e "${INDENT}${CYAN}no upstream branch configured${RESET}"
            fi

            # Bucket porcelain entries by status (X = index, Y = working tree)
            local -a staged_new=() staged_mod=() staged_del=() staged_ren=() staged_cop=() staged_typ=()
            local -a unstaged_mod=() unstaged_new=() unstaged_del=() unstaged_typ=()
            local -a conflicts=() untracked=()
            local status_output=$(git -C "$dir" status --porcelain -uall 2>/dev/null)

            while IFS= read -r line; do
                [ -z "$line" ] && continue
                local x="${line[1]}"
                local y="${line[2]}"
                local entry="${line[4,-1]}"

                # For renames/copies porcelain prints "orig -> new"; the working-tree
                # entry refers to the new path only.
                local wentry="$entry"
                [[ "$entry" == *" -> "* ]] && wentry="${entry#* -> }"

                case "${x}${y}" in
                    '??') untracked+=("$entry"); continue ;;
                    DD|AA|AU|UD|UA|DU|UU) conflicts+=("$entry"); continue ;;
                esac

                case "$x" in
                    A) staged_new+=("$entry") ;;
                    M) staged_mod+=("$entry") ;;
                    D) staged_del+=("$entry") ;;
                    R) staged_ren+=("$entry") ;;
                    C) staged_cop+=("$entry") ;;
                    T) staged_typ+=("$entry") ;;
                esac

                case "$y" in
                    M) unstaged_mod+=("$wentry") ;;
                    A) unstaged_new+=("$wentry") ;;
                    D) unstaged_del+=("$wentry") ;;
                    T) unstaged_typ+=("$wentry") ;;
                esac
            done <<< "$status_output"

            # Staged changes (green)
            for file in "${staged_new[@]}"; do echo -e "${INDENT}${GREEN}new file:   $file${RESET}"; done
            for file in "${staged_mod[@]}"; do echo -e "${INDENT}${GREEN}modified:   $file${RESET}"; done
            for file in "${staged_del[@]}"; do echo -e "${INDENT}${GREEN}deleted:    $file${RESET}"; done
            for file in "${staged_ren[@]}"; do echo -e "${INDENT}${GREEN}renamed:    $file${RESET}"; done
            for file in "${staged_cop[@]}"; do echo -e "${INDENT}${GREEN}copied:     $file${RESET}"; done
            for file in "${staged_typ[@]}"; do echo -e "${INDENT}${GREEN}typechange: $file${RESET}"; done

            # Working-tree changes (red)
            for file in "${unstaged_new[@]}"; do echo -e "${INDENT}${RED}new file:   $file${RESET}"; done
            for file in "${untracked[@]}"; do echo -e "${INDENT}${RED}new file:   $file${RESET}"; done
            for file in "${unstaged_mod[@]}"; do echo -e "${INDENT}${RED}modified:   $file${RESET}"; done
            for file in "${unstaged_del[@]}"; do echo -e "${INDENT}${RED}deleted:    $file${RESET}"; done
            for file in "${unstaged_typ[@]}"; do echo -e "${INDENT}${RED}typechange: $file${RESET}"; done

            # Conflicts (red)
            for file in "${conflicts[@]}"; do echo -e "${INDENT}${MAGENTA}conflict:   $file${RESET}"; done
        fi
    done
}

git-fetch-all() {
    local dir
    for dir in . */(ND); do
        dir="${dir%/}"
        if [ -d "$dir/.git" ]; then
            echo "  $dir/"
            git -C "$dir" fetch --all --prune 2>&1 | sed "s/^/        /"
        fi
    done
}

git-pull-all() {
    local dir
    for dir in . */(ND); do
        dir="${dir%/}"
        if [ -d "$dir/.git" ]; then
            echo "  $dir/"
            git -C "$dir" pull --rebase 2>&1 | sed "s/^/        /"
        fi
    done
}

alias git-g=git-graph
alias git-s=git-summarize
alias git-f=git-fetch-all
alias git-p=git-pull-all
