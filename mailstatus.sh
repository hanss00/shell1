#!/usr/bin/bash
#
# check_mailstats shell (v1.0)

MAILSTATS=`which mailstats 2>/dev/null`;
SendmailCF="/etc/mail/sendmail.cf"
StatusFile=`grep StatusFile ${SendmailCF} |awk -F= '{print $2}'`

echo -e "Monitoring loop count : \c" ; read MCNT
if [ -z "$MCNT" ]; then
        printf "\nUsage: $0 [ Loop count(n) / Infinite loop(0) ]\n"
        echo
        exit
fi

echo
if [ ! -e "$MAILSTATS" ]; then
        printf "CRITICAL - mailstats not found!\n"
        exit
fi

if [ ! -x "$MAILSTATS" ]; then
        printf "CRITICAL - mailstats doesn't have execute permission for current user\n"
        exit
fi

if [ ! -e "$StatusFile" ]; then
        printf "CRITICAL - $StatusFile not found!\n"
        exit
fi

mail_stat(){
                echo "`date` -----------------------------------"
                $MAILSTATS -C  ${SendmailCF} | egrep "Mailer|^ T|^ C"
                sleep 1
}

LCNT=1
if [ ${MCNT} -eq 0 ]
then
        while :
        do
                mail_stat
        done
else
        while [ $MCNT -ge $LCNT ]
        do
                LCNT=$(($LCNT + 1))
                #$MAILSTATS  | egrep "Mailer|T|C|^S"
                mail_stat
        done
        echo
        exit 0
fi

exit 0
