#!/bin/bash
#

User=user1
#
echo test2 | mail -s testing -S smtp="3stest.co.kr:25" ${User}@3stest.co.kr
