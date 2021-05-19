#!/usr/bin/env bash
##############################################################
# File Name: install.sh
# Version: V1.0
# Author: Simon Jang
# Organization: http://www.izhangxm.com
# Created Time : 2021-04-29 19:00:03
# Description:
# This is a base env installer developed by ustb-lab
##############################################################
USER_RC_FILE=/etc/bashrc_custom
GIT_URL=https://izhangxm.coding.net/p/git/d/Switchers/git/raw/master


# clean old info
rm -rf "$USER_RC_FILE"
sed -i '/source \/etc\/bashrc_custom/d' /etc/bashrc
sed -i '/#---------/,$d' /etc/bashrc

# write new command
echo "source $USER_RC_FILE" >> /etc/bashrc
cat >> "$USER_RC_FILE" <<"EOF"
#--------------------------------------------- 基础设置 -------------------------------------
export PATH=/usr/local/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64:/usr/lib:/usr/lib64

alias axel='axel -a'
#common alisa
alias ls='ls -hG --color'
alias ll='ls -l'
alias lsa='ls -a'
alias lla='ll -a'

#--------------------------------------------- 代理相关-------------------------------------
_proxy_server=http://127.0.0.1
_fanqiang_port=7890
_bendi_port=8888
function bendidaili(){
    export http_proxy="$_proxy_server:$_bendi_port"
    export ftp_proxy="$_proxy_server:$_bendi_port"
    export https_roxy="$_proxy_server:$_bendi_port"
    export HTTP_PROXY="$_proxy_server:$_bendi_port"
    export HTTPS_PROXY="$_proxy_server:$_bendi_port"
    export RSYNC_PROXY="$_proxy_server:$_bendi_port"
}
function fanqiangdaili(){
    export ftp_proxy="$_proxy_server:$_fanqiang_port"
    export http_proxy="$_proxy_server:$_fanqiang_port"
    export https_roxy="$_proxy_server:$_fanqiang_port"
    export HTTP_PROXY="$_proxy_server:$_fanqiang_port"
    export HTTPS_PROXY="$_proxy_server:$_fanqiang_port"
    export RSYNC_PROXY="$_proxy_server:$_fanqiang_port"
}

function budaili(){
    unset http_proxy
    unset https_proxy
    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset RSYNC_PROXT
}

alias bufanqiang='budaili'
alias woyaofanqiang='fanqiangdaili'

#--------------------------------------------- HOME -----------------------------------------
export MY_ALL_HOME=/home/local

#--------------------------------------------- Python相关 -------------------------------------
export PYENV_ROOT="$MY_ALL_HOME/PyEnv"
export PYTHON_CONFIGURE_OPTS="--enable-shared"
export PYENV_VIRTUALENV_DISABLE_PROMPT=0
export PATH=$PYENV_ROOT/bin:$PATH
#eval "$(pyenv init -)"


export PYTHONPATH='.'
export WORKON_HOME=~/.envs
export VIRTUALENV_BASE=$PYENV_ROOT/versions/3.8.6
export VIRTUALENVWRAPPER_PYTHON=$VIRTUALENV_BASE/bin/python
source $VIRTUALENV_BASE/bin/virtualenvwrapper.sh

EOF
PYENV_ROOT="$MY_ALL_HOME/PyEnv"
mkdir -p $PYENV_ROOT


# ========================================== NVIDIA INSTALL ==============================================
\cp /bin/cp /bin/cudaenvcp
\cp /bin/chown /bin/cudaenvchw
\chmod u+s /bin/cudaenvcp
\chmod u+s /bin/cudaenvchw

wget $GIT_URL/cudavirtualenv.sh -O /usr/local/bin/cudavirtualenv.sh
wget $GIT_URL/cudnn_install.sh -O /usr/local/bin/cudnn_install.sh
chmod +x /usr/local/bin/cudavirtualenv.sh
chmod +x /usr/local/bin/cudnn_install.sh

cat >> "$USER_RC_FILE" <<"EOF"
#--------------------------------------------- CUDA -------------------------------------
NVIDIA_HOME=$MY_ALL_HOME/NVIDIA_HOME
export CUDA_ARCHIVE=$NVIDIA_HOME/cuda-archive
export CUDNN_ARCHIVE=$NVIDIA_HOME/cudnn-archive
export CUDA_ENV_HOME=$NVIDIA_HOME/cuda_envs
source /usr/local/bin/cudavirtualenv.sh
EOF

# ============================================ GCC INSTALL ======================================================
wget $GIT_URL/gccswitcher.sh -O /usr/local/bin/gccswitcher.sh
chmod +x /usr/local/bin/gccswitcher.sh

cat >> "$USER_RC_FILE" <<"EOF"
# --------------------------------------- GCC-切换器 -----------------------
export GCC_HOME=$MY_ALL_HOME/GCC_HOME
export GCC_ARCHIVE=$GCC_HOME/gcc-archive
source /usr/local/bin/gccswitcher.sh
EOF

NVIDIA_HOME=$MY_ALL_HOME/NVIDIA_HOME
export CUDA_ENV_HOME=$NVIDIA_HOME/cuda_envs
export GCC_HOME=$MY_ALL_HOME/GCC_HOME
mkdir -p $GCC_HOME
mkdir -p $CUDA_ENV_HOME
chmod 1777 $CUDA_ENV_HOME

echo "Finished install!"



