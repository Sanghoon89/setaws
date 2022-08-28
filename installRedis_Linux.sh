#!/bin/bash

# This Script is to install Redis.
#                written by Hooni in 2022.08.02

VERSION_LIST=("4.0.10" "6.2.7")

# 1. 설치 버전 선텍
f_select_version () {
    echo " ** Version **"
    for ((i=0; i<${#VERSION_LIST[@]}; i++)); do
        echo " $((i+1)). ${VERSION_LIST[$i]}"
    done
    echo -en " - Select NO. [$i] ? "; read NO
    [ $NO ] || NO=$i
    return $NO
}

# 2. 해당 버전 다운로드
f_download_redis () {
    [ -f $DIR/redis-$1.tar.gz ] && 
        echo " File Exists already. [OK]" || {
            cd $DIR
            wget https://download.redis.io/releases/redis-$1.tar.gz
        }
}

f_uncompress_redis () {
    [ -d $TARGET ] &&
        echo " Directory Exists already. [OK]" || {
            cd $DIR
            tar xzvf $DIR/redis-$1.tar.gz
        }
}

# 3. 설치하기 (make install)
f_make_redis () {
    cd $TARGET/src
    make install PREFIX=$TARGET
}

__main__ () {
    f_select_version
    VERSION=${VERSION_LIST[$(($?-1))]}

    DIR=/usr/local
    TARGET=$DIR/redis-$VERSION

    f_download_redis $VERSION
    f_uncompress_redis $VERSION

    f_make_redis

}
__main__