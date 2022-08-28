#!/bin/bash

f_sshd_config () {
    fn_set_ssh_port () {
        if [ $(grep -cw "^ *Port *${1}" ${FILE}) -eq 0 ]; then
            if [ $(grep -cw "^ *# *Port *${1}" ${FILE}) -eq 1 ]; then
                sed -i '/^ *# *Port *'${1}'/ s/^ *# *Port *'${1}'/Port '${1}'/' ${FILE} &&
                    echo " * [Port ${1}] was successfully uncommented in ${FILE}."
            else
                LINE=$(grep -nw Port ${FILE} |tail -1 |awk -F: '{print $1}')
                [ $LINE ] || LINE=$(cat ${FILE} |wc -l)
                ((LINE += 1))
                sed -i ''$LINE' i \
Port '${1}'' ${FILE} &&
                sed -i ''$LINE's/^ *//' ${FILE} &&
                echo " * [Port ${1}] was successfully added in ${FILE}."
            fi
        else
            echo " [Port ${1}] has been set in ${FILE}. [OK] "
        fi
    }
    fn_set_ssh_param () {
        PARAM=$1
        [ $2 ] && VALUE=$2 || VALUE="yes"
        [ ${VALUE} = "yes" ] && NVALUE=no || NVALUE=yes
        if [ $(grep -cw "^ *${PARAM} *${VALUE}" ${FILE}) -eq 0 ]; then
            if [ $(grep -cw "^ *# *${PARAM} *${VALUE}" ${FILE}) -gt 0 ]; then
                sed -i '/^ *# *'${PARAM}' *'${VALUE}'/ s/^ *# *'${PARAM}' *'${VALUE}'/'${PARAM}' '${VALUE}'/' ${FILE} &&
                    echo " * [${PARAM} ${VALUE}] was successfully uncommented in ${FILE}."
                [ $(grep -cw "^ *${PARAM} *${NVALUE}" ${FILE}) -gt 0 ] &&
                    sed -i 's/^ *'${PARAM}' *'${NVALUE}'/# '${PARAM}' '${NVALUE}'/g' ${FILE} &&
                        echo " * [${PARAM} ${NVALUE}] was successfully commented in ${FILE}."
            elif [ $(grep -cw "${PARAM} *${NVALUE}" ${FILE}) -gt 0 ]; then
                sed -i '/^ *# *'${PARAM}'/ s/^ *# *'${PARAM}'/'${PARAM}'/' ${FILE}
                sed -i '/^ *'${PARAM}' *'${NVALUE}'/ s/^ *'${PARAM}' *'${NVALUE}'/'${PARAM}' '${VALUE}'/' ${FILE} &&
                    echo " * [${PARAM} ${VALUE}] was successfully changed value in ${FILE}."
            else
                echo "${PARAM} yes" >> ${FILE} &&
                echo " * [${PARAM} ${VALUE}] was successfully added in ${FILE}."
            fi
        else
            echo " [${PARAM} ${VALUE}] has been set in ${FILE}. [OK] "
        fi
    }
    fn_mv_authorized () {
        FILE=/root/.ssh/authorized_keys
        if [ -f ${FILE} ]; then
            mv ${FILE} ${FILE}.old &&
                echo " * [authorized_keys] File was successfully renamed."
        else
            echo " [authorized_keys] File is not existed. [OK]"
        fi
    }
    BAKFILE=${FILE}.$(date +"%Y%m%d.%H%M")
    cp -rp ${FILE} ${BAKFILE}
    fn_set_ssh_port  22
    fn_set_ssh_port  3000
    fn_set_ssh_param PermitRootLogin
    fn_set_ssh_param PasswordAuthentication
    
    cmp -s ${FILE} ${BAKFILE}
    [ $? -eq 0 ] && rm -f ${BAKFILE}
    fn_mv_authorized
    systemctl restart sshd
}

f_set_enforce () {
    if [ $(getenforce) == "Enforcing" ]; then
        setenforce 0 &&
        echo " * [Enforce] was successfully changed status (Enforcing -> $(getenforce))."
    else
        echo " [Enforce] has been set $(getenforce). [OK]"
    fi

    SELINUX=$(grep -w ^SELINUX ${FILE} |awk -F= '{print $2}')
    if  [ ${SELINUX} == "disabled" ]; then
        echo " [SELINUX=disabled] has been set in ${FILE}. [OK]"
    else
        sed -i 's/^SELINUX='${SELINUX}'/SELINUX=disabled/' ${FILE} &&
            echo " * [SELINUX] was successfully changed (${SELINUX} -> disabled) in ${FILE}."
    fi
}

FILE=/etc/selinux/config
f_set_enforce
FILE=/etc/ssh/sshd_config
f_sshd_config
