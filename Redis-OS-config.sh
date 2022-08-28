#!/bin/bash

# This Script is to config OS Environment.
#                written by Hooni in 2022.08.01

## Disable THP(Transparent Huge Page)
f_set_disable_THP () {
    fn_disable_kernel_THP () {
        if [ $(cat /sys/kernel/mm/transparent_hugepage/$1 | grep -wc '\[never\]') -eq 0 ]; then
            echo never > /sys/kernel/mm/transparent_hugepage/$1 &&
                echo " * [THP] was successfully set [never] $1."
        else
            echo " $(cat /sys/kernel/mm/transparent_hugepage/$1) - THP $1 [OK]"
        fi
        # Modity /etc/rc.local for Disable THP(Transparent Huge Page)
        if [ $( cat /etc/rc.local |grep -v '^ *#' |grep 'hugepage\/'$1 |grep -c never) -eq 0 ]; then
            echo "echo never > /sys/kernel/mm/transparent_hugepage/$1" >> /etc/rc.local &&
                echo " * [/etc/rc.local] was successfully added THP $1."
        else
            echo " $(cat /sys/kernel/mm/transparent_hugepage/$1) [OK]"
        fi
    }
    fn_disable_kernel_THP enabled
    fn_disable_kernel_THP defrag
}

## Modify sysctl (somaxconn, swap)
f_set_sysctl () {
    fn_modify_sysctl () {
        PARAM_VALUE=$(sysctl -a 2>/dev/null |grep $1)
        if [ $(echo ${PARAM_VALUE} |awk -F= '{print $NF}') -lt $2 ]; then
            sysctl -w $(echo ${PARAM_VALUE} |awk '{print $1}')=$2 |awk '{print " *",$0}'
        else
            echo " $(sysctl -a --ignore 2>/dev/null |grep $1) [OK]"
        fi
        if [ $(sysctl -p |grep -c $1) -eq 0 ]; then
            echo "$(echo ${PARAM_VALUE} |awk '{print $1}') = $2" >> /etc/sysctl.conf &&
                echo " * [$1=$2] was successfully added in /etc/sysctl.conf."
        else
            echo " $(sysctl -p |grep $1) [OK]"
        fi
    }
    fn_modify_sysctl somaxconn 65535
    fn_modify_sysctl swappiness 0
    fn_modify_sysctl overcommit_memory 1
}

# Modify limit (nofile, nproc)
f_set_nproc () {
    for T in "S" "H"; do
        [ $T == "S" ] && TYPE=soft || TYPE=hard
        if [ $(ulimit -u -$T) -lt 131072 ]; then
            echo "*     ${TYPE}    nproc   131072" >> /etc/security/limits.conf &&
                echo " * [nproc=131072] was successfully modify value of soft in limits.conf"
        else
            echo " ${TYPE} nproc = $(ulimit -u -$T) [OK]"
        fi
    done
}

__main__ () {
    f_set_disable_THP
    f_set_sysctl
    f_set_nproc
}
__main__