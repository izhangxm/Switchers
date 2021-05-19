#!/bin/bash
##############################################################
# File Name: cudavirtualenv.sh
# Version: V1.0
# Author: Simon Jang
# Organization: http://www.izhangxm.com
# Created Time : 2020-09-07 19:00:03
# Description:
# This is a cuda version switcher developed by ustb-lab, which can
# switch your shell environment to any version of cuda and cudnn quickly.

##############################################################

function _cudaswitcher_initlize {
    if [ ! -d "$CUDA_ARCHIVE" ]; then echo "cuda-virtualenv: error: $CUDA_ARCHIVE is not exist!"; unset cuda-workon;unset cuda-deactive;return 127; fi
    if [ ! -d "$CUDNN_ARCHIVE" ]; then echo "cuda-virtualenv: error: $CUDNN_ARCHIVE is not exist!";unset cuda-workon;unset cuda-deactive;return 127; fi
    export CUDA_USER_ENV_HOME=$CUDA_ENV_HOME/$USER
    if [ ! -d "$CUDA_USER_ENV_HOME" ]; then mkdir -p "$CUDA_USER_ENV_HOME"; echo "cuda-virtualenv created CUDA_ENV_HOME $CUDA_USER_ENV_HOME"; fi
    return 0
}
_cudaswitcher_initlize
if [ ! "$?" -eq "0" ]; then echo "some errors are occured."; return 127; fi

# cuda-workon command help info
function _help {
    echo "USAGE:"
    echo "cudawork_on <envname>"
    return 0
}

# cuda-mkvirtualenv command help info
function _mkenv_help {
    echo "USAGE:"
    echo "cudamkenv <options>"
    echo "    -X|--cudav <xxx>  : cuda version"
    echo "    -M|--cudnnv <xxx> : cudnn version"
    echo "    -E|--envname <xxx> : envname"
    echo "    -h|--help         : help info"
    return 0
}


# create a cuda-virtualenv with a name
function cuda-mkvirtualenv {

    ARGS=`getopt -a -o X:M:E:h -l cudnnv:,cudav:,envname:,help -- "$@"`

    [ $? -ne 0 ] || [ $# == 0 ]&& _mkenv_help && return 0
    eval set -- "${ARGS}"

    local CUDAV CUDNNV ENVNAME

    while [ $# -gt 0 ]; do

        case "$1" in
            -h|--help)
                _mkenv_help
                shift
                ;;
            -X|--cudav)
                CUDAV=$2
                shift
                ;;
            -M|--cudnnv)
                CUDNNV=$2
                shift
                ;;
            -E|--envname)
                ENVNAME=$2
                shift
                ;;
            --)
                shift
                break
                ;;
        esac
    shift
    done


    if [ -z "$CUDAV" ]; then
        echo 'cuda-virtualenv: error: the argument cudav is required'
        _mkenv_help
        return 127
    fi

    if [ -z "$CUDNNV" ]; then
        echo 'cuda-virtualenv: error: the argument cudnnv is required'
        _mkenv_help
        return 127
    fi

    if [ -z "$ENVNAME" ]; then
        echo 'cuda-virtualenv: error: the argument envname is required'
        _mkenv_help
        return 127
    fi

    if [ ! -d "$CUDA_ARCHIVE/cuda-$CUDAV" ]; then
        echo "cuda-virtualenv: error: $CUDA_ARCHIVE/cuda-$CUDAV is not exist."
        return 127
    fi

    if [ ! -d "$CUDNN_ARCHIVE/cudnn-$CUDNNV-forcuda-$CUDAV" ]; then
        echo "cuda-virtualenv: error: $CUDNN_ARCHIVE/cuda-$CUDNNV-forcuda-$CUDAV is not exist."
        return 127
    fi


#    local new_cuda_env_home="$CUDA_USER_ENV_HOME/cuda-$CUDAV-$CUDNNV"
    local new_cuda_env_home="$CUDA_USER_ENV_HOME/$ENVNAME"
    if [ ! -d "$new_cuda_env_home" ]; then

        echo "mkdir $new_cuda_env_home ..."
        mkdir -p $new_cuda_env_home

        echo "cuda-virtualenv: copy files from cuda ..."
        /bin/cudaenvcp -larf $CUDA_ARCHIVE/cuda-$CUDAV/* $new_cuda_env_home/ 2>/dev/null

        echo "cuda-virtualenv: copy files from cudnn ..."
        /bin/cudaenvcp -lrf $CUDNN_ARCHIVE/cudnn-$CUDNNV-forcuda-$CUDAV/lib64/* $new_cuda_env_home/lib64/ 2>/dev/null
        /bin/cudaenvcp -lrf $CUDNN_ARCHIVE/cudnn-$CUDNNV-forcuda-$CUDAV/include/* $new_cuda_env_home/include/ 2>/dev/null

        echo "CUDA-$CUDAV, CUDNN-$CUDNNV" > $new_cuda_env_home/info

        echo "cuda-virtualenv: change owners..."
        /bin/cudaenvchw "$USER:$USER" -R $new_cuda_env_home/

        echo "cuda-virtualenv: done."
    else
        echo "cuda-virtualenv: error: cuda-virtualenv $ENVNAME existed."
        return 127
    fi

    cuda-workon "$ENVNAME"
    return 0
}


# this command could switch your environments to an existed cuda-virtualenv
function cuda-workon {
    if [ "$#" -lt 1 ];then
        echo "Please specify an environment name you want to change to"
        return 127
    fi

    if [ "$_cuda_switcher_worked_on" == true ]; then
        cuda-deactive
        cuda-workon "$@"
        return 0
    fi

    if [ "$_cuda_switcher_worked_on" == "" ]; then export _cuda_switcher_worked_on=false; fi

    local _workon_env_name="$1"

    if [ ! -d "$CUDA_USER_ENV_HOME/$_workon_env_name" ]; then
        echo "Error: $CUDA_USER_ENV_HOME/$_workon_env_name is not exist."
        return 127
    fi

    _cuda_PATH="$CUDA_USER_ENV_HOME/$_workon_env_name/bin"
    export PATH="$_cuda_PATH:$PATH"

    _cuda_LD_PATH="$CUDA_USER_ENV_HOME/$_workon_env_name/lib64"
    export LD_LIBRARY_PATH="$_cuda_LD_PATH:$LD_LIBRARY_PATH"


    _cuda_PS_PATH="\[\033[32m\][NVIDIA:$_workon_env_name]\[\033[0m\]"
    export PS1="${_cuda_PS_PATH}$PS1"

    export CUDA_HOME="$CUDA_USER_ENV_HOME/$_workon_env_name"

    export _cuda_switcher_worked_on=true
    export _cuda_active_env_name=$_workon_env_name
    return 0
}

# recover your environment to when you changed
function cuda-deactive {
    if [ "$_cuda_switcher_worked_on" == false ]; then
        echo "cuda-virtualenv: error: no cuda virtualenv active, or active virtualenv is missing"
        return 127
    fi

    export PATH=$(echo $PATH | sed "s#${_cuda_PATH}:##")
    export LD_LIBRARY_PATH=$(echo $LD_LIBRARY_PATH | sed "s#${_cuda_LD_PATH}:##")
    export PS1=$(python -c "print(r'$PS1'.replace(r'$_cuda_PS_PATH',''))")

    unset CUDA_HOME

    export _cuda_switcher_worked_on=false
    unset _cuda_active_env_name
}

# delete an cuda-virtualenv existed
function cuda-rmvirtualenv {

    if [ $# -lt 1 ];then
        echo "cuda-virtualenv: Please specify an environment you want to delete"
        return 127
    fi

    if [ ! -d $CUDA_USER_ENV_HOME/$1 ]; then
        echo "cuda-virtualenv: error: $CUDA_USER_ENV_HOME/$1 is not exsit, please check the input."
        return 127
    fi

    echo "Removing $1..."

    /bin/cudaenvchw "$USER:$USER" -R $CUDA_USER_ENV_HOME/$1/
    /bin/rm -rf "$CUDA_USER_ENV_HOME/$1/"

    if [ "$_cuda_switcher_worked_on" == true ]; then
        cuda-deactive "$_cuda_active_env_name"
    fi

    return 0
}

# change the current directory to the working cuda-virtualenv or a specify one.
function cuda-cdvirtualenv {

    if [ $# -ge 1 ];then
        if [ ! -d $CUDA_USER_ENV_HOME/$1 ]; then
            echo "cuda-virtualenv: error: $CUDA_USER_ENV_HOME/$1 is not exsit, please check the input."
            return 127
        fi
        cd $CUDA_USER_ENV_HOME/$1/
        return 0
    fi

    if [ "$_cuda_switcher_worked_on" == true ]; then
        if [ ! -d "$CUDA_USER_ENV_HOME/$_cuda_active_env_name" ]; then
            echo "cuda-virtualenv: error: $CUDA_USER_ENV_HOME/$_cuda_active_env_name is not exist, or active virtualenv is missing"
            return 127
        fi
        cd $CUDA_USER_ENV_HOME/$_cuda_active_env_name/
    else
        echo "cuda-virtualenv: Please specify an environment you want to check"
        return 127
    fi
    return 0
}

# print the working cuda-virtualenv info or a specify one.
function cuda-envinfo {
    if [ $# -ge 1 ];then
        if [ ! -d $CUDA_USER_ENV_HOME/$1 ]; then
            echo "cuda-virtualenv: error: $CUDA_USER_ENV_HOME/$1 is not exsit, please check the input."
            return 127
        fi
        cat $CUDA_USER_ENV_HOME/$1/info
        return 0
    fi

    if [ "$_cuda_switcher_worked_on" == true ]; then
        if [ ! -d "$CUDA_USER_ENV_HOME/$_cuda_active_env_name" ]; then
            echo "cuda-virtualenv: error: $CUDA_USER_ENV_HOME/$_cuda_active_env_name is not exist, or active virtualenv is missing"
            return 127
        fi
        cat $CUDA_USER_ENV_HOME/$_cuda_active_env_name/info
    else
        echo "cuda-virtualenv: Please specify an environment you want to check"
        return 127
    fi

    return 0
}


# auto complete the command line for cuda-mkvirtualenv
_cudamkenv_complete_func()
{
    local cur prev opts
    COMPREPLY=()

    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts=''

    if [[ ${prev} == '--cudav' ]] ; then
        local _cudnnv=''
        for i in "${!COMP_WORDS[@]}"; do
            if [ "${COMP_WORDS[$i]}" == "--cudnnv" ]  && [ ${#COMP_WORDS[@]} -gt $[ $i + 1 ] ]; then
                _cudnnv=${COMP_WORDS[ $[ $i + 1 ] ]}
            fi
        done

        if [ -n "$_cudnnv" ]; then
            local _cudav_valid_stage1=$(\ls -lh $CUDNN_ARCHIVE 2>/dev/null | grep "^d" | awk '{print $9}' | grep "cudnn-$_cudnnv-" | cut -d '-' -f 4)
            for _cav in "${_cudav_valid_stage1[@]}"; do
                if [ -d "$CUDA_ARCHIVE/cuda-$_cav" ];then
                    opts="$opts $_cav"
                fi
            done
        else
            opts="$(\ls -lh $CUDA_ARCHIVE 2>/dev/null | grep "^d" | awk '{print $9}' | grep 'cuda-.*' | cut -d '-' -f 2 | tr '\n' " ")"
        fi

    elif [[ ${prev} == '--cudnnv' ]] ; then
        local _cudav=''

        for i in "${!COMP_WORDS[@]}"; do
            if [ "${COMP_WORDS[$i]}" == "--cudav" ]  && [ ${#COMP_WORDS[@]} -gt $[ $i + 1 ] ]; then
                _cudav=${COMP_WORDS[ $[ $i + 1 ] ]}
            fi
        done

        if [ -n "$_cudav" ]; then
            opts="$(\ls -lh $CUDNN_ARCHIVE 2>/dev/null | grep "^d" | awk '{print $9}' | grep "cudnn-.*-forcuda-$_cudav" | cut -d '-' -f 2 | tr '\n' " ")"
        else
            opts="$(\ls -lh $CUDNN_ARCHIVE 2>/dev/null  | grep "^d" | awk '{print $9}' | grep 'cudnn-.*' | cut -d '-' -f 2 | tr '\n' " ")"
        fi
    elif [[ ${prev} == '--envname' ]] ; then
        opts=''
    elif [[ ${cur} == --* ]] || [[ ${cur} == '' ]] ; then
        opts="--cudav --cudnnv --envname --help"
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    fi
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}
complete -F _cudamkenv_complete_func cuda-mkvirtualenv


# auto complete the command line for cuda-workon, cuda-rmvirtualenv, cuda-cdvirtualenv, cuda-envinfo
function _cuda_version_complete_func {
    local cur prev opts
    COMPREPLY=()

    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [ ${#COMP_WORDS[@]} -eq 2 ]; then
        opts="$(\ls -lh $CUDA_USER_ENV_HOME 2>/dev/null | grep "^d" | awk '{print $9}' | tr '\n' " ")"
    else
        opts=""
    fi
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}

complete -F _cuda_version_complete_func cuda-workon
complete -F _cuda_version_complete_func cuda-rmvirtualenv
complete -F _cuda_version_complete_func cuda-cdvirtualenv
complete -F _cuda_version_complete_func cuda-envinfo

