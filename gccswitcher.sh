#!/bin/bash
##############################################################
# File Name: cudavirtualenv.sh
# Version: V1.0
# Author: Simon Jang
# Organization: http://www.izhangxm.com
# Created Time : 2020-09-07 19:00:03
# Description:
# This is a cuda version switcher developed by ustb-lab, which can
# switch your shell environment to any version of cuda and cudnn quikly.

##############################################################
if [ "$GCC_ARCHIVE" = "" ]; then export GCC_ARCHIVE=/usr/local; fi

function _gccswitcher_initlize {

    if [ ! -d "$GCC_ARCHIVE" ]; then echo "gcc-switcher: error: $GCC_ARCHIVE is not exist!"; unset cuda-workon;unset cuda-deactive;return 127; fi
    return 0
}
_gccswitcher_initlize
if [ ! "$?" -eq "0" ]; then echo "some errors are occured."; return 127; fi


# cuda-workon command help info
function _help {
    echo "USAGE:"
    echo "gcc-workon <envname>"
    return 0
}

# this command could switch your environments to an existed gcc-switcher
function gcc-workon {
    if [ "$#" -lt 1 ];then
        echo "Please specify a gcc version you want to change to"
        return 127
    fi

    if [ "$_gcc_switcher_worked_on" == true ]; then
        gcc-deactive
        gcc-workon "$@"
        return 0
    fi

    if [ "$_gcc_switcher_worked_on" == "" ]; then export _gcc_switcher_worked_on=false; fi

    local _workon_env_name="$1"

    if [ ! -d "$GCC_ARCHIVE/$_workon_env_name" ]; then
        echo "Error: $GCC_ARCHIVE/$_workon_env_name is not exist."
        return 127
    fi

    _gcc_PATH="$GCC_ARCHIVE/$_workon_env_name/bin"
    export PATH="${_gcc_PATH}:$PATH"

    _gcc_LD_PATH="$GCC_ARCHIVE/$_workon_env_name/lib64:$GCC_ARCHIVE/$_workon_env_name/lib"
    export LD_LIBRARY_PATH="$_gcc_LD_PATH:$LD_LIBRARY_PATH"

    _gcc_PS_PATH="\[\033[35m\][$_workon_env_name]\[\033[0m\]"
    export PS1="${_gcc_PS_PATH}$PS1"

    export _gcc_switcher_worked_on=true
    export _gcc_active_env_name=$_workon_env_name
    return 0
}

# recover your environment to when you changed
function gcc-deactive {
    if [ "$_gcc_switcher_worked_on" == false ]; then
        echo "gcc-switcher: error: no gcc active, or actived gcc is missing"
        return 127
    fi
    export PATH=$(echo $PATH | sed "s#${_gcc_PATH}:##")
    export LD_LIBRARY_PATH=$(echo $LD_LIBRARY_PATH | sed "s#${_gcc_LD_PATH}:##")
    export PS1=$(python -c "print(r'$PS1'.replace(r'$_gcc_PS_PATH',''))")
    export _gcc_switcher_worked_on=false
    unset _gcc_active_env_name
}

function _gcc_version_complete_func {
    local cur prev opts
    COMPREPLY=()

    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [ ${#COMP_WORDS[@]} -eq 2 ]; then
        opts="$(/bin/ls -l $GCC_ARCHIVE 2>/dev/null | grep "^d" | grep "gcc-" | awk '{print $9}' | tr '\n' " ")"
    else
        opts=""
    fi
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}
complete -F _gcc_version_complete_func gcc-workon

