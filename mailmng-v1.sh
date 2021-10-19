#!/bin/bash
#

MAIL_DNS="thisiseng.co.kr thisiseng.local"

mail_start() {
        systemctl start sendmail
        sleep 1
        /usr/sbin/sendmail.sendmail-FMB -C /etc/mail/local.cf -bd -q30m
}

mail_stop() {
        systemctl stop sendmail
        sleep 1
        ps -ef |grep sendmail | grep -v grep | awk '{print "kill -9 "$2}' |sh
}

pop_start() {
        systemctl start dovecot
        sleep 1
}

pop_stop() {
        systemctl stop dovecot
        sleep 1
}

chk_SPAM() {
        echo
        echo "   Sendmail DNSBL Config Info ............................"
        echo "      >> sbl.spamhaus.org DNSBL Config ............................"
        cat /etc/mail/sendmail.cf | grep -A6 "spam list sbl.spamhaus.org"  | awk '{print "\t",$0}'
        echo "      >> spamlist.or.kr DNSBL Config ............................"
        cat /etc/mail/sendmail.cf | grep -A6 "spam list spamlist.or.kr"  | awk '{print "\t",$0}'
        echo
        echo "   Sendmail ClamAV  Config ............................"
        echo "      >> freshclam status ............................"
        systemctl status clamav-freshclam | awk '{print "\t",$0}'
        echo
        ls -l /var/lib/clamav/* | awk '{print "\t",$0}'
        echo
        echo "      >> clamd status ............................"
        systemctl status clamd.service | awk '{print "\t",$0}'
        echo
        echo "      >> clamav-milter status ............................"
        systemctl status clamav-milter | awk '{print "\t",$0}'
        echo
        cat /etc/mail/sendmail.cf |grep -A1 clmilter |  awk '{print "\t",$0}'
}

conf_mail_chk() {
        echo
        echo "   Sendmail >> sendmail.cf Config Info ............................"
        egrep -i "DaemonPortOptions|AuthMechanisms|^DS|^Cw|^Dj|SmtpGreetingMessage|DeliveryMode|QueueDirectory"  /etc/mail/sendmail.cf | awk '{print "\t",$0}'
        echo
        echo "   Sendmail >> local.cf Config Info ............................"
        egrep -i "DaemonPortOptions|AuthMechanisms|^DS|^Cw|^Dj|SmtpGreetingMessage|DeliveryMode|QueueDirectory"  /etc/mail/local.cf | awk '{print "\t",$0}'
	    echo
        echo "   Sendmail >> access file Info ............................"
		cat /etc/mail/access | grep -v "^#" | awk '{print "\t",$0}' 
}

conf_pop_chk() {
        echo
        echo "   Dovecot >> dovecot.conf Config Info ............................"
        cat /etc/dovecot/dovecot.conf  | grep -v ^# | grep -v "^$" | awk '{print "\t",$0}'
        echo
        echo "   Dovecot >> 10-ssl.conf Config Info ............................"
        cat /etc/dovecot/conf.d/10-ssl.conf  | grep -v ^# | grep -v "^$" | awk '{print "\t",$0}'
        echo
        echo "   Dovecot >> 10-auth.conf Config Info ............................"
        cat /etc/dovecot/conf.d/10-auth.conf  | grep -v ^# | grep -v "^$" | awk '{print "\t",$0}'
        echo
        echo "   Dovecot >> 10-mail.conf Config Info ............................"
        cat /etc/dovecot/conf.d/10-mail.conf  | grep -v ^# | grep -v "  #" |grep -v "^$" | awk '{print "\t",$0}'
        echo
        echo "   Dovecot >> 10-logging.conf Config Info ............................"
        cat /etc/dovecot/conf.d/10-logging.conf  | grep -v ^# | grep -v "^$" | awk '{print "\t",$0}'
}

chk_mail() {
        echo "`date` ------------------------------------------"
        echo
        echo "   Sendmail Port 25 Open ............................"
        netstat -nltp | grep :25 | awk '{print "\t",$0}'
        echo "   Sendmail Process Running ............................"
        ps -ef |grep sendmail | grep -v grep | awk '{print "\t",$0}'
		echo
        systemctl -n0 status sendmail | awk '{print "\t",$0}'
        echo "   Saslauthd Process Running ............................"
        ps -ef |grep saslauthd | grep -v grep | awk '{print "\t",$0}'
        # testsaslauthd -u root -p admin12# -s smtp
}

chk_pop() {
        echo
        echo
        echo "   POP3/IMAP Port 110/143 Open ............................"
        netstat -nltp | grep dovecot | awk '{print "\t",$0}'
        echo "   Dovecot Process Running ............................"
        ps -ef |grep -i dovecot | grep -v grep | awk '{print "\t",$0}'
        systemctl -n0 status dovecot | awk '{print "\t",$0}'
        #echo "   Saslauthd Process Running ............................"
        #ps -ef |grep saslauthd | grep -v grep | awk '{print "\t",$0}'
        # testsaslauthd -u root -p admin12# -s smtp
}

chk_dns() {
        echo
        echo
        echo "   DNS Port 53 Open ............................"
        netstat -nltp | grep :53 | awk '{print "\t",$0}'
        echo "   DNS Process Running ............................"
        ps -ef |grep -i named | grep -v grep | awk '{print "\t",$0}'
        echo
        echo "     resolv.conf file ..........."
        cat /etc/resolv.conf | awk '{print "\t",$0}'
        echo
	for DNS in $MAIL_DNS
	do
        	echo "     $DNS query ..........."
        	nslookup -q=mx $DNS > /tmp/dns_query.out
        	cat /tmp/dns_query.out | awk '{print "\t",$0}'
        	cat /tmp/dns_query.out | grep "mail exchanger" | awk '{print "nslookup ",$6}' |sh| awk '{print "\t",$0}'
        	echo
	done
}


chk_log() {
        echo
		echo "/var/log/maillog ................"
		echo
        tail -30f /var/log/maillog &
        read SELT
        ps -ef |grep tail |grep maillog |grep -v grep | awk '{print $2}' | xargs kill -9
}

chk_MQueue() {
        echo
		echo "mailq command ................"
		/usr/bin/mailq
}

chk_MStatus() {
        echo
		echo "mailstats command ................"
		/usr/sbin/mailstats
}

while :
do
  clear
  echo
  echo "`date` -----------------------------"
  cat <<_EOF_
  Mail Management Menu ....... :

	1|mail_start)      Sendmail Start
	2|mail_stop)       Sendmail Stop 
	3|mail_chk)        Sendmail Config Check
	4|mail_proc)       Sendmail Running Check
	5|mail_spam)       Sendmail SPAM Config Check
	6|pop_start)       POP(DoveCot) Start
	7|pop_stop)        POP(DoveCot) Stop
	8|pop_chk)         POP(DoveCot) Config Check
	9|pop_proc)        POP(DoveCot) Running Check
	10|maillog)        Mail Log Check
	11|ALL_chk)        ALL Config Check	
	
	12|DNS_chk)        DNS Query Check
	13|MQueue)         Mail Queue List Check
    14|MailStatus)     Mail Status Check		
	 
	0|exit)            EXIT
	
_EOF_

read -p "  Enter selection [0-12] > " SELT

case "$SELT" in
        0|exit)
		echo
                exit 0
                ;;
        1|mail_start)
                mail_start
                ;;
        2|mail_stop)
                mail_stop
                ;;
        3|conf_mail_chk)
                conf_mail_chk
                ;;
        4|chk_mail)
                chk_mail
                ;;
        5|chk_SPAM)
                chk_SPAM
                ;;
        6|pop_start)
                pop_start
                ;;
        7|pop_stop)
                pop_stop
                ;;
        8|conf_pop_chk)
                conf_pop_chk
                ;;
        9|chk_pop)
                chk_pop
                ;;
		10|chk_log)
                chk_log
                ;;
        11|all)
                chk_mail
                chk_pop
                chk_dns
                ;;
        12|chk_dns)
                chk_dns
                ;;
        13|chk_dns)
                chk_MQueue
                ;;
        14|chk_dns)
                chk_MStatus
                ;;
        *)
           echo
           echo -e "  Error : (${SELT}) selection error ..."
           echo
                ;;
esac
echo
echo " ................... (any key) " ; read SELT
done

# makemap hash /etc/mail/virtusertable < /etc/mail/virtusertable
# makemap hash /etc/mail/access < /etc/mail/access
# makemap hash /etc/mail/genericstable < /etc/mail/genericstable
# newaliase


#USER1="testuser1"
#USER2="testuser2"
#USER3="testuser3"
#
#mail ${USER1}@3stest.co.kr < /tmp/aa
#
#echo 'this is test2.' | mail -s 'sendmail test2' ${USER2}@3stest.co.kr
#
#echo "Test 3 from $(hostname -f)"|mail -s "Test 1 $(hostname -f)" ${USER3}@3stest.co.kr
#echo 'this is test2.' | mail -s 'sendmail test2' testuser1@3stest.co.kr -c hanss00@naver.com

