alias git-graph='git log --graph --oneline --all'

git-summarize() {
    # Color codes
    local GREEN='\033[0;32m'
    local RED='\033[0;31m'
    local YELLOW='\033[0;33m'
    local CYAN='\033[0;36m'
    local BLUE='\033[0;34m'
    local RESET='\033[0m'
    local INDENT='        '

    for dir in . */(N); do
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

            # Get staged new files (green)
            git -C "$dir" diff --cached --name-only --diff-filter=A 2>/dev/null | while read -r file; do
                echo -e "${INDENT}${GREEN}new file:   $file${RESET}"
            done

            # Get staged modified files (green)
            git -C "$dir" diff --cached --name-only --diff-filter=M 2>/dev/null | while read -r file; do
                echo -e "${INDENT}${GREEN}modified:   $file${RESET}"
            done

            # Get unstaged modified files (red)
            git -C "$dir" diff --name-only --diff-filter=M 2>/dev/null | while read -r file; do
                echo -e "${INDENT}${RED}modified:   $file${RESET}"
            done

            # Get untracked files (red)
            git -C "$dir" ls-files --others --exclude-standard 2>/dev/null | while read -r file; do
                echo -e "${INDENT}${RED}new file:   $file${RESET}"
            done
        fi
    done
}

git-fetch-all() {
    for dir in . */(N); do
        dir="${dir%/}"
        if [ -d "$dir/.git" ]; then
            echo "  $dir/"
            git -C "$dir" fetch --all --prune 2>&1 | sed "s/^/        /"
        fi
    done
}

git-pull-all() {
    for dir in . */(N); do
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
