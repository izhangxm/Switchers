# This file must be used with "source bin/activate" *from bash*
# you cannot run it directly

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script: \$ source $0" >&2
    exit 33
fi

deactivate () {
    unset -f pydoc >/dev/null 2>&1 || true

    # reset old environment variables
    # ! [ -z ${VAR+_} ] returns true if VAR is declared at all
#    if ! [ -z "${_OLD_VIRTUAL_PATH:+_}" ] ; then
#        PATH="$_OLD_VIRTUAL_PATH"
#        export PATH
#        unset _OLD_VIRTUAL_PATH
#    fi
    if [ -n "$_VENV_PATH" ] ; then
        export PATH=$(/usr/bin/python -c "print(r'$PATH'.replace(r'$_VENV_PATH:',''))")
    fi
    if [ -n "${_OLD_VIRTUAL_PYTHONHOME+_}" ] ; then
        PYTHONHOME="$_OLD_VIRTUAL_PYTHONHOME"
        export PYTHONHOME
        unset _OLD_VIRTUAL_PYTHONHOME
    fi

    # This should detect bash and zsh, which have a hash command that must
    # be called to get it to forget past commands.  Without forgetting
    # past commands the $PATH changes we made may not be respected
    if [ -n "${BASH-}" ] || [ -n "${ZSH_VERSION-}" ] ; then
        hash -r 2>/dev/null
    fi

#    if [ -n "${_OLD_VIRTUAL_PS1+_}" ] ; then
#        PS1="$_OLD_VIRTUAL_PS1"
#        export PS1
#        unset _OLD_VIRTUAL_PS1
#    fi
    if [ -n "$_VENV_PS" ] ; then
        export PS1=$(/usr/bin/python -c "print(r'$PS1'.replace(r'$_VENV_PS',''))")
    fi

    unset VIRTUAL_ENV
    if [ ! "${1-}" = "nondestructive" ] ; then
    # Self destruct!
        unset -f deactivate
    fi
}

# unset irrelevant variables
deactivate nondestructive
if [ -n "${BASH_SOURCE[0]}" ]; then
    cur_dir=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
elif [ -n "$0" ]; then
    cur_dir=$(cd "$(dirname $0)" && pwd)
fi

VIRTUAL_ENV="$(dirname "$cur_dir")"
if ([ "$OSTYPE" = "cygwin" ] || [ "$OSTYPE" = "msys" ]) && $(command -v cygpath &> /dev/null) ; then
    VIRTUAL_ENV=$(cygpath -u "$VIRTUAL_ENV")
fi
export VIRTUAL_ENV

_VENV_PATH="$VIRTUAL_ENV/__BIN_NAME__"
PATH="$_VENV_PATH:$PATH"
export PATH

# unset PYTHONHOME if set
if [ -n "${PYTHONHOME+_}" ] ; then
    _OLD_VIRTUAL_PYTHONHOME="$PYTHONHOME"
    unset PYTHONHOME
fi

if [ -z "${VIRTUAL_ENV_DISABLE_PROMPT-}" ] ; then
    _OLD_VIRTUAL_PS1="${PS1-}"
    if [ "x__VIRTUAL_PROMPT__" != x ] ; then
        _VENV_PS="__VIRTUAL_PROMPT__"
        PS1="$_VENV_PS${PS1-}"
    else
        _VENV_PS="(`basename \"$VIRTUAL_ENV\"`) "
        PS1="$_VENV_PS${PS1-}"
    fi
    export PS1
fi

# Make sure to unalias pydoc if it's already there
alias pydoc 2>/dev/null >/dev/null && unalias pydoc || true

pydoc () {
    python -m pydoc "$@"
}

# This should detect bash and zsh, which have a hash command that must
# be called to get it to forget past commands.  Without forgetting
# past commands the $PATH changes we made may not be respected
if [ -n "${BASH-}" ] || [ -n "${ZSH_VERSION-}" ] ; then
    hash -r 2>/dev/null
fi
