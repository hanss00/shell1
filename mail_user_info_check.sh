#!/bin/bash
#

U_HOME=""
echo -e "메일 확인 유저 선택: \c"
read User

if [ ! -z ${User} ]
then
        M_USER=`cat /etc/passwd | grep -w ${User}| wc -l`
        U_HOME=`awk -F: -v v="$User" '{if ($1==v) print $6}' /etc/passwd 2>&1 `
        if [ ${M_USER} -eq 0 ]
        then
                echo
                echo -e "\t >> [ERROR] 선택된 유저(${User})는 없는 유저 입니다...!! "
                echo
                exit 1
        elif [ -z ${U_HOME} ]
        then
                echo
                echo -e "\t >> [ERROR] ${User} 의 Home 디렉토리가/etc/passwd에 정의되어 있지않습니다...!! "
                echo
                exit 1
        elif [ ! -d ${U_HOME} ]
        then
                echo
                echo -e "\t >> [ERROR] ${User} 의 Home 디렉토리(${U_HOME})가 존재하지 않습니다...!! "
                echo
                exit 1
        else
                echo "  >>${User} Mail Box List"
                doveadm mailbox list -u ${User} | awk '{print "\t",$0}'
                echo
                echo "  >>${User} Mail Box Status"
                doveadm mailbox list -u ${User} | while read line
                do
                        doveadm mailbox status -u ${User} all "$line" | awk '{print "\t",$0}'
                done
                echo
                echo "  >>${User} Mail Box List Check "
                ls -l /var/spool/mail/$User | awk '{print "\t",$0}'
                echo
                ls -l ${U_HOME}/mail/.imap/ | awk '{print "\t",$0}'
                echo
        fi
else
        echo
        echo -e "\t >> [ERROR] 유저가 선택되지 않았습니다...!!"
        echo
fi
