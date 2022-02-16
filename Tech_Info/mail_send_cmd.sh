#!/bin/bash
#

User=user1
TOUser=user2
CCUser=user3
BCCUser=user4
Mail_DNS="3stest.co.kr"
cp -rp /etc/group /tmp/mail_txt.out

# mail 명령어
mail -v -s "Some File1"   ${User}@${Mail_DNS} < /tmp/mail_txt.out
mail -S smtp="${Mail_DNS}:25" -s 'test message'  -c ${CCUser}@${Mail_DNS} -b ${BCCUser}@${Mail_DNS} ${TOUser}@${Mail_DNS} <<EOF
data
test mail messages
.
EOF
echo test2 | mail -s testing -S smtp="${Mail_DNS}:25" ${User}@${Mail_DNS}


# mailx 명령어
echo "something" | mailx -S smtp="${Mail_DNS}:25" -s "subject" -b ${BCCUser}@${Mail_DNS} -c ${CCUser}@${Mail_DNS}  -r ${User}@${Mail_DNS} ${TOUser}@${Mail_DNS}


# curl 명령어
curl -sv --mail-from "${User}@${Mail_DNS}" --mail-rcpt "${TOUser}@${Mail_DNS}" smtp://${Mail_DNS}:25  --upload-file /tmp/mail_txt.out


# sendmail 명령어
/usr/sbin/sendmail -Am -i -v <<END
To: ${TOUser}@${Mail_DNS}
From: ${User}@${Mail_DNS}
Subject: test!
 
testtest
.
END