# Automatically use the global Python venv when no venv is active
function python() {
    if [[ -z "$VIRTUAL_ENV" && -d "$PYTHON_DEFAULT_VENV" ]]; then
        "$PYTHON_DEFAULT_VENV/bin/python3" "$@"
    else
        command python3 "$@"
    fi
}

# Safely leave the current venv, even if VIRTUAL_ENV was inherited
# from a parent process (variable set, but no deactivate function).
function _pro_venv_off() {
    [[ -z "${VIRTUAL_ENV:-}" ]] && return
    if (( $+functions[deactivate] )); then
        deactivate
    else
        # Stale/inherited env: strip its bin dir from PATH and clear vars
        path=("${(@)path:#$VIRTUAL_ENV/bin}")
        unset VIRTUAL_ENV VIRTUAL_ENV_PROMPT
        hash -r
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
        _pro_venv_off
        return
    fi

    # No Python files (excluding irrelevant dirs): deactivate.
    if ! find "$PWD" \
        \( -name '.*' -o -name '__pycache__' -o -name 'node_modules' \
           -o -name '.venv' -o -name 'venv' \) -prune \
        -o -type f -name '*.py' -print -quit 2>/dev/null | grep -q .; then
        _pro_venv_off
        return
    fi

    # Prefer local .venv; otherwise the default.
    local target_venv
    if [[ -d "$PWD/.venv" ]]; then
        target_venv="$PWD/.venv"
    else
        target_venv="$PYTHON_DEFAULT_VENV"
    fi

    if [[ ! -f "$target_venv/bin/activate" ]]; then
        print -u2 "manage_pro_venv: no activate script at $target_venv"
        return 1
    fi

    # Activate unless it's truly active: right VIRTUAL_ENV *and* deactivate defined.
    if [[ "${VIRTUAL_ENV:-}" != "$target_venv" ]] || (( ! $+functions[deactivate] )); then
        _pro_venv_off
        source "$target_venv/bin/activate"
    fi
}
