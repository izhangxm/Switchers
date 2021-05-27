
CUDA-ENV 是一个用来管理cuda和cudnn版本的一个虚拟环境工具，在兼容的条件下，可以实现任意版本的cuda与cudnn的组合。不论是编译和测试，都十分
方便，其原理是通过建立硬连接和改变环境变量来影响程序的编译和运行，同时不会占用额外的磁盘空间。

2021-05-19 新增GCC版本管理及常用函数功能

### 安装

**需要在root下安装, 目前仅测试了CentOS 7.8**
```bash
su root
curl -L https://izhangxm.coding.net/p/git/d/Switchers/git/raw/master/install.sh | bash
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

### GCC的使用
GCC版本切换器只有激活和反激活的功能，没有创建和删除，前缀为`gcc-`, 使用方法与cuda-env一致


### virtualenv 脚本替换
由于virtualenv反激活时会直接替换相关变量为旧变量，所以为了使virtualenv和cudavirtualenv和gccswitcher兼容，需要将
virtualenv的激活脚本替换为mod之后的版本

```shell
virtual_dir="$(dirname $(pip -V | awk -F ' ' '{print $4}'))/virtualenv/activation/bash"
curl -L https://izhangxm.coding.net/p/git/d/Switchers/git/raw/master/activate.sh >  $virtual_dir/activate.sh
```

### anaconda脚本替换
TODO: 待完成

### License
The project is released under the terms of the GPLv3.
