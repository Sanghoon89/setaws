#!/bin/bash

# This Script is to install Pasckage for Redis.
#                written by Hooni in 2022.08.01

f_install_package () {
    fn_check_package () {
        echo $(rpm -qa |grep -wc $1)
    }

    fn_yum_install () {
        yum install -y $1
    }

    if [ $(fn_check_package $1) -eq 0 ]; then
        fn_yum_install $1
    else
        echo " [$1] Package has been installed. [OK]"
    fi
}

__main__ () {
    f_install_package make
    f_install_package gcc
}
__main__
