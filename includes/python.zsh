# Automatically use the global Python venv when no venv is active
function python() {
    if [[ -z "$VIRTUAL_ENV" && -d "$PYTHON_DEFAULT_VENV" ]]; then
        "$PYTHON_DEFAULT_VENV/bin/python3" "$@"
    else
        command python3 "$@"
    fi
}

# - Outside $PRO_PROJECT_ROOT: deactivate any currently active virtual environment.
# - Inside $PRO_PROJECT_ROOT, but no .py files anywhere under the current directory: deactivate any currently active virtual environment.
# - Inside $PRO_PROJECT_ROOT, with at least one .py file (including subdirectories):
#   - If $PWD/.venv exists, activate it.
#   - Otherwise, activate $PYTHON_DEFAULT_VENV.
function manage_pro_venv() {
    # Outside the project root: deactivate any active environment.
    if [[ "$PWD" != "$PRO_PROJECT_ROOT" && "$PWD" != "$PRO_PROJECT_ROOT"/* ]]; then
        if [[ -n "${VIRTUAL_ENV:-}" ]]; then
            deactivate
        fi
        return
    fi

    # Check for Python files recursively, excluding irrelevant directories.
    if ! find "$PWD" \
        \( -name '.*' -o -name '__pycache__' -o -name 'node_modules' \
           -o -name '.venv' -o -name 'venv' \) -prune \
        -o -type f -name '*.py' -print -quit 2>/dev/null | grep -q .; then
        if [[ -n "${VIRTUAL_ENV:-}" ]]; then
            deactivate
        fi
        return
    fi

    # Prefer the local .venv if present; otherwise use PYTHON_DEFAULT_VENV.
    local target_venv
    if [[ -d "$PWD/.venv" ]]; then
        target_venv="$PWD/.venv"
    else
        target_venv="$PYTHON_DEFAULT_VENV"
    fi

    # Activate the target environment only if it isn't already active.
    if [[ "${VIRTUAL_ENV:-}" != "$target_venv" ]]; then
        if (( $+functions[deactivate] )); then
            deactivate
        fi
        source "$target_venv/bin/activate"
    fi
}
