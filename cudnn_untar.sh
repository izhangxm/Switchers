#!/bin/bash
##############################################################
# File Name: cudnn_untar.sh
# Version: V1.0
# Author: Simon Jang
# Organization: http://www.izhangxm.com
# Created Time : 2020-09-07 19:00:03
# Description:

##############################################################


if [ ! -d "$CUDA_ARCHIVE" ]; then echo "cuda-virtualenv: error: $CUDA_ARCHIVE is not exist!";return 127; fi

CUDNN_TARS=$1

[ ! -d $CUDNN_ARCHIVE ] && mkdir -p $CUDNN_ARCHIVE

cd $CUDNN_TARS || echo $CUDNN_TARS "not exist" && return 127;

cudnns=$(\ls cudnn*.tgz)

for v in ${cudnns[@]};do

    echo "--------------------------------------------------------"
    echo tar name is "$v"
    cudav=$(echo $v| cut -d '-' -f 2)
    cudnnv=$(echo $v | awk -F '.tgz' '{print $1}' | awk -F '-v' '{print $2}' )
    new_cudnn_dir_name="cudnn-$cudnnv-forcuda-$cudav"
    echo new_cudnn_dir_name: "$new_cudnn_dir_name"
    if [ -d $CUDNN_ARCHIVE/$new_cudnn_dir_name ];then
        echo 'exist'
        continue
    fi

    tar -xf $v
    mv "cuda/" "$CUDNN_ARCHIVE/$new_cudnn_dir_name"
    echo "--------------------------------------------------------"
done
