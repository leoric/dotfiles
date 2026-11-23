# Convert .webp to .png using dwebp
png() {
    dwebp "$1" -o "$(basename "$1" .webp).png"
}

# Identifies read-only files before deletion.
# Deletes writable files automatically.
# If there are multiple read-only files, displays their paths and asks for confirmation once.
# Deletes read-only files only if you confirm.
# Leaves read-only files untouched if you decline.
rmr() {
    emulate -L zsh
    setopt local_options null_glob

    if (( $# == 0 )); then
        print -u2 "Usage: rmr <file-or-directory> [...]"
        return 2
    fi

    local -a ro_files all_files
    local f answer

    # Scan only; delete nothing yet.
    while IFS= read -r -d '' f; do
        all_files+=("$f")
        [[ ! -L "$f" && ! -w "$f" ]] && ro_files+=("$f")
    done < <(command find "$@" ! -type d -print0 2>/dev/null)

    # 0 or 1 read-only files: standard rm behavior (its own prompt).
    if (( ${#ro_files} <= 1 )); then
        command rm -r -- "$@"
        return
    fi

    # Several read-only files: ask once.
    print
    print "Read-only files found (${#ro_files}):"
    printf '  %s\n' "${ro_files[@]}"

    printf "\nDelete all read-only files? [y/N] "
    read -r answer

    if [[ "$answer" == [yY] ]]; then
        command chmod -R -- u+w "$@" &&
            command rm -rf -- "$@"
    else
        # Delete only the writable files, keep read-only ones.
        for f in "${all_files[@]}"; do
            [[ -L "$f" || -w "$f" ]] && command rm -f -- "$f"
        done
        command find "$@" -depth -type d -empty -delete 2>/dev/null
        print "Read-only files preserved."
    fi
}

up() {
  local count=${1:-1}
  for ((i = 1; i <= count; i++)); do
    cd ..
  done
}

un () {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1        ;;
            *.tar.gz)    tar xzf $1     ;;
            *.tar.xz)    tar xJf $1     ;;
            *.bz2)       bunzip2 $1       ;;
            *.rar)       unrar x $1     ;;
            *.gz)        gunzip $1     ;;
            *.tar)       tar xf $1        ;;
            *.tbz2)      tar xjf $1      ;;
            *.tgz)       tar xzf $1       ;;
            *.zip)       unzip $1     ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1    ;;
            *)           echo "epic fail with '$1'..." ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

pk () {
    if [ $1 ] ; then
        case $1 in
            tbz)   	tar cjvf $2.tar.bz2 $2      ;;
            tgz)   	tar czvf $2.tar.gz  $2   	;;
            txz)   	tar cJvf $2.tar.xz  $2   	;;
            tar)  	tar cpvf $2.tar  $2       ;;
			bz2)	bzip $2 ;;
            gz)		gzip -c -9 -n $2 > $2.gz ;;
			zip)   	zip -r $2.zip $2   ;;
            7z)    	7z a $2.7z $2    ;;
            *)     	echo "'$1' cannot be packed via pk()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Interactive Git commit history browser using fzf.
# Displays a colored commit graph with relative timestamps.
# Press Ctrl-S to toggle sorting and Enter (Ctrl-M) to view
# the selected commit's full diff in less.
# Checks for a Git repository and fzf before running.
glf() {
    # Check whether we're inside a Git repository
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        print -P "Not inside a Git repository."
        return 1
    fi

    # Check whether fzf is installed
    if ! command -v fzf &>/dev/null; then
        print -P "fzf is not installed. Install it first."
        return 1
    fi

    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(green)%cr%C(reset)" "$@" |
        fzf --ansi --no-sort --reverse --tiebreak=index \
            --bind=ctrl-s:toggle-sort \
            --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
                FZF-EOF"
}

vibe_advance() {
    # Emulate standard zsh behavior and isolate options
    emulate -L zsh

    local VERSION_TYPE="minor"
    local MANUAL_VERSION=""
    local NEW_VERSION=""

    # 1. Smart argument processing
    if [[ -n "$1" && "$1" == *.** ]]; then
        MANUAL_VERSION="$1"
    else
        while (( $# > 0 )); do
            case "$1" in
                -v|--version)
                    if [[ -n "$2" && "$2" != -* ]]; then
                        MANUAL_VERSION="$2"
                        shift 2
                    else
                        echo "Error: Flag $1 requires a version argument (e.g., 1.2.3)"
                        return 1
                    fi
                    ;;
                1|major) VERSION_TYPE="major"; shift ;;
                2|minor) VERSION_TYPE="minor"; shift ;;
                3|patch) VERSION_TYPE="patch"; shift ;;
                *)
                    echo "Error: Unknown argument '$1'"
                    echo "Usage: vibe_advance [major|minor|patch | 1|2|3] [X.X.X]"
                    return 1
                    ;;
            esac
        done
    fi

    # 2. If a manual version is provided, validate and pad it
    if [[ -n "$MANUAL_VERSION" ]]; then
        if [[ ! "$MANUAL_VERSION" =~ ^[0-9]+(\.[0-9]+){0,2}$ ]]; then
            echo "Error: Version '$MANUAL_VERSION' must contain only digits separated by dots (e.g., 1, 1.4, or 1.4.0)"
            return 1
        fi

        local -a m_parts
        m_parts=(${(s:.:)MANUAL_VERSION})

        local m_major=${m_parts[1]:-0}
        local m_minor=${m_parts[2]:-0}
        local m_patch=${m_parts[3]:-0}

        MANUAL_VERSION="${m_major}.${m_minor}.${m_patch}"

        if git show-ref --verify --quiet "refs/tags/v$MANUAL_VERSION" \
           || git show-ref --verify --quiet "refs/tags/$MANUAL_VERSION" \
           || git log --all --format='%s' | grep -Fxq -- "$MANUAL_VERSION"; then
            echo "Error: Version $MANUAL_VERSION already exists in Git history (as a tag or commit subject)!"
            return 1
        fi

        NEW_VERSION="$MANUAL_VERSION"
    fi

    # 3. Stage everything
    git add -A

    # 4. Extract commit message from CHANGELOG.txt diff safely
    # This filters out the header diff lines (+++ b/ or --- a/) entirely
    local COMMIT_MSG
    COMMIT_MSG=$(git diff --staged CHANGELOG.txt | sed -n '/^+++/d; /^+/s/^+//p')

    if [[ -z "$COMMIT_MSG" ]]; then
        echo "Error: No new changes found in CHANGELOG.txt to generate a commit message."
        return 1
    fi

    # 5. If auto-incrementing, calculate the new version
    if [[ -z "$MANUAL_VERSION" ]]; then
        local LATEST_TAG
        # Sort tags by semantic version natively using git, fallback to v0.0.0 if empty
        LATEST_TAG=$(git tag --list 'v*' --sort=-v:refname | head -n 1 2>/dev/null)
        if [[ -z "$LATEST_TAG" ]]; then
            LATEST_TAG="v0.0.0"
        fi
        local CURRENT_VERSION=${LATEST_TAG#v}

        local -a parts
        parts=(${(s:.:)CURRENT_VERSION})
        local major=${parts[1]:-0}
        local minor=${parts[2]:-0}
        local patch=${parts[3]:-0}

        case "$VERSION_TYPE" in
            major) (( major++ )); minor=0; patch=0 ;;
            minor) (( minor++ )); patch=0 ;;
            patch) (( patch++ )) ;;
        esac

        NEW_VERSION="${major}.${minor}.${patch}"
        echo "Auto-incrementing version: $CURRENT_VERSION -> $NEW_VERSION"
    else
        echo "Using manual version: $NEW_VERSION"
    fi

    # 6. Commit changes and create a tag safely
    echo "Commit message:\n$COMMIT_MSG"
    echo "---"

    if ! git commit -m "$NEW_VERSION" -m "$COMMIT_MSG"; then
        echo "Error: Git commit failed."
        return 1
    fi

    if ! git tag -a "v$NEW_VERSION" -m "Release $NEW_VERSION"; then
        echo "Error: Tagging failed. Rollback commit..."
        git reset --soft HEAD~1
        return 1
    fi

    echo "Successfully committed and tagged as v$NEW_VERSION"
}

brew() {
    if [[ "$1" == "isntall" ]]; then
        shift
        command brew install "$@"
    else
        command brew "$@"
    fi
}

is_supported_os() {
  [[ "$OSTYPE" == linux* || "$OSTYPE" == darwin* ]] &&
    ! { [[ "$OSTYPE" == linux* ]] && grep -qi microsoft /proc/version 2>/dev/null; }
}
