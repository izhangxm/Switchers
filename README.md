
CUDA-ENV 是一个用来管理cuda和cudnn版本的一个虚拟环境工具，在兼容的条件下，可以实现任意版本的cuda与cudnn的组合。不论是编译和测试，都十分
方便，其原理是通过建立硬连接和改变环境变量来影响程序的编译和运行，同时不会占用额外的磁盘空间。

### 安装

**需要在root下安装, 目前仅测试了CentOS 7.8**
```bash
su root

cp /bin/cp /bin/cudaenvcp
cp /bin/chown /bin/cudaenvchw
chmod u+s /bin/cudaenvcp
chmod u+s /bin/cudaenvchw

wget cudavirtualenv.sh -O /usr/local/bin/cudavirtualenv.sh

cat >> ~/.bashrc <<"EOF"
export CUDA_ARCHIVE=/usr/local/cuda-archive
export CUDNN_ARCHIVE=/usr/local/cudnn-archive
export CUDA_ENVHOME="$HOME/.cudaenv"
. /usr/local/bin/cudavirtualenv.sh
EOF

.  ~/.bashrc
```

**目录结构**
```bash
多版本的CUDA目录
cd $CUDA_ARCHIVE
tree -L 1 ./
./
├── cuda-10.0
├── cuda-10.1
├── cuda-10.2
├── cuda-11.1
├── cuda-11.2
├── cuda-8.0
└── cuda-9.0
└── cuda-9.2

cd $CUDNN_ARCHIVE
tree -L 1 ./
./
├── cudnn-7.0.5-forcuda-8.0
├── cudnn-7.6.2.24-forcuda-10.0
├── cudnn-7.6.2.24-forcuda-10.1
├── cudnn-7.6.2.24-forcuda-9.2
├── cudnn-7.6.3.30-forcuda-10.0
├── cudnn-7.6.3.30-forcuda-10.1
├── cudnn-7.6.3.30-forcuda-9.0
├── cudnn-7.6.3.30-forcuda-9.2
├── cudnn-7.6.4.38-forcuda-10.0
├── cudnn-7.6.4.38-forcuda-10.1
├── cudnn-7.6.4.38-forcuda-9.2
├── cudnn-7.6.5.32-forcuda-10.0
├── cudnn-7.6.5.32-forcuda-10.1
├── cudnn-7.6.5.32-forcuda-10.2
├── cudnn-7.6.5.32-forcuda-9.0
├── cudnn-7.6.5.32-forcuda-9.2
├── cudnn-8.0.1.13-forcuda-10.2
├── cudnn-8.0.1.13-forcuda-11.0
├── cudnn-8.0.2.39-forcuda-10.1
├── cudnn-8.0.2.39-forcuda-10.2
├── cudnn-8.0.2.39-forcuda-11.0
├── cudnn-8.0-forcuda-10.1
├── cudnn-9.0-forcuda-10.1
├── cudnn-9.0-forcuda-11.1
└── cudnn-9.0-forcuda-11.2
```

### 使用
使用方法与命名方法与python的`virtualenv-wrapper`基本一致

**创建一个cuda虚拟环境**
```bash
[zhangxinming@150 ~]$ cuda-mkvirtualenv --cudav 11.0 --cudnnv 8.0.2.39 --envname mmrun-tf-2
mkdir /home/zhangxinming/.cudaenv/mmrun-tf-2 ...
cuda-virtualenv: copy files from cuda ...
cuda-virtualenv: copy files from cudnn ...
cuda-virtualenv: change owners...
cuda-virtualenv: done.
[NVIDIA:mmrun-tf-2][zhangxinming@150 ~]$ 

```

**切换cuda虚拟环境**
```bash
# 不论在不在虚拟环境中 均可切换
[zhangxinming@150 ~]$ cuda-workon cuda-11
[NVIDIA:cuda-11][zhangxinming@150 ~]$
```

**删除虚拟环境**
```bash
[NVIDIA:cuda-11][zhangxinming@150 ~]$ cuda-rmvirtualenv cuda-11
[zhangxinming@150 ~]$

```

**切换到虚拟环境目录**
```bash
[NVIDIA:cuda-11][zhangxinming@150 cuda-11]$ cuda-cdvirtualenv 222 
[NVIDIA:cuda-11][zhangxinming@150 222]$ cuda-cdvirtualenv 
```

**虚拟环境信息**
```bash
[NVIDIA:cuda-11][zhangxinming@150 222]$ cuda-envinfo 
CUDA-11.0, CUDNN-8.0.2.39
[NVIDIA:cuda-11][zhangxinming@150 222]$ cuda-envinfo cuda-11 
CUDA-11.0, CUDNN-8.0.2.39
[NVIDIA:cuda-11][zhangxinming@150 222]$ 

```

### License
The project is released under the terms of the GPLv3.
