#!/bin/bash
#

SLEEPTIME=$2

ndt_service="ndt_db ndt_cmon ndt_cauth ndt_ccom ndt_cstor ndt_cbatch ndt_clog ndt_hcom ndt_hstor ndt_hmon ndt_webcb  ndt_websmtp ndt_webadmin ndt_webuser ndt_webapi ndt_webinsa"

ndt_proc="db_agent c_mon c_com c_stor c_batch c_auth c_log h_com h_stor h_mon web_cb web_smtp web_user web_api web_admin web_insa"

if [ -z $SLEEPTIME ]
then
        SLEEPTIME=1
fi

#if [ -n "$SLEEPTIME" ] && [ "$SLEEPTIME" -eq "$SLEEPTIME" ] 2>/dev/null; then
[ -n "$SLEEPTIME" ] && [ "$SLEEPTIME" -eq "$SLEEPTIME" ] 2>/dev/null
if [ $? -ne 0 ]; then
        echo -e "[ERROR] loop count not number ...!!"
        exit 2
fi

ps_exec1() {
         ps -C ${PROC_LIST} -o pid,pcpu,pmem,cmd,etime |grep -v ELAPSED
}

ndt_proc_chk() {
        echo "Total CPU & Memory usage ..."
        top -n 1 | egrep "Mem|Cpu" | awk '{print "\t",$0}'
        echo
        echo -e "Service \t    PID %CPU %MEM CMD                            ELAPSED"
        echo -e "---------------------------------------------------------------------------"
        for PROC_LIST in $ndt_proc
        do
                HEADER=${PROC_LIST^^}
                echo -en "${HEADER} : \t"
                if [ -n "`ps -C $PROC_LIST | grep -v PID`" ]
                then
                        ps_exec1
                else
                        echo -e "[ERROR] /opt/cdt/bin/$PROC_LIST process not found ...!! "
                fi
        done
        echo
}

ndt_service_chk() {
        echo
        for SERVICE in $ndt_service
        do
                HEADER=${SERVICE^^}
                echo -n "=> `echo ${HEADER} | cut -c 5-` status : "
                systemctl status ${SERVICE}  | grep Active | awk '{print "\t",$0}'
        done
}

ps_exec() {
         ps -C ${PROC_LIST} -o pid,pcpu,pmem,size,vsize,etime,cmd
}

ndt_req_proc_chk() {
        echo
        ndt_reg_proc="CEPH MariaDB MongoDB RabbitMQ REDIS"
        for PROC in $ndt_reg_proc
        do
                if [ $PROC = "CEPH" ]; then
                        echo "1. CEPH Process Check"
                        PROC_LIST="ceph-mon,ceph-osd" ; ps_exec
                elif [ $PROC = "MariaDB" ]; then
                        echo "2. MariaDB Process Check"
                        PROC_LIST="mysqld" ; ps_exec
                elif [ $PROC = "MongoDB" ]; then
                        echo "3. MongoDB Process Check"
                        PROC_LIST="mongod,mongos" ; ps_exec
                elif [ $PROC = "RabbitMQ" ]; then
                        echo "4. RabbitMQ Process Check"
                        PROC_LIST="beam.smp,epmd,inet_gethost" ; ps_exec
                elif [ $PROC = "REDIS" ]; then
                        echo "5. REDIS Process Check"
                        PROC_LIST="redis-server" ; ps_exec
                fi
                                echo
        done
}

ndt_license() {
        PID_FILE="/usr/local/networkbridge/var/nepyx_license.pid"
        PID=`cat $PID_FILE`
        License_PROC=`ps -ef |grep $PID |grep -v grep |wc -l`

        if [ $License_PROC -ne 2 ]
        then
                echo -e " >> [ERROR] VDI License Process not running"
                echo -e "\t rm -rf $PID_FILE "
                echo -e "\t /usr/local/networkbridge/etc/nepyxd.sh stop"
                echo -e "\t /usr/local/networkbridge/etc/nepyxd.sh start"
        else
                echo -e " >> VDI License Process running"
                ps -C nepyx_license -o pid,tty,time,cmd | awk '{print "\t",$0}'
        fi
}

case "$1" in
        vdi_service|s)
                echo ;ndt_service_chk
                echo
                ;;
        vdi_service_loop|sl)
                while :
                do
                        echo "`date` -------------------------------------"
                        ndt_service_chk
                        echo
                        sleep $SLEEPTIME
                done
                ;;
        vdi_proc|p)
                echo ;ndt_proc_chk
                echo
                ;;
        vdi_proc_loop|pl)
                while :
                do
                        echo "`date` -------------------------------------"
                        echo ; ndt_proc_chk
                        echo;echo
                        sleep $SLEEPTIME
                done
                ;;
        regproc|r)
                ndt_req_proc_chk
                echo
                ;;
        license|l)
                echo; ndt_license
                echo
                ;;
        *)
                ndt_service_chk
                echo
                echo "[ERROR] Usage: $0 {vdi_service(s,sl)|vdi_proc(p,pl)|reg_proc(r)|vdi_license(l)"
                echo
                exit 2
                ;;
esac

exit 0
