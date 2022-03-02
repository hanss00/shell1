#!/bin/bash
#

disk() {
	if [ $SELT = "D" ]
	then
        /usr/sbin/vxdisk list ; echo
	elif [ $SELT = "DETAIL_D" ]
		/usr/sbin/vvxdisk -px LIST_DMP -um list ; echo
	fi
}

volume() {
	if [ $SELT = "V" ]
	then
        /usr/sbin/vxprint -v |grep ^v ; echo
	elif [ $SELT = "OPEN_V" ]
		/usr/sbin/vxprint -o alldgs -v -e v_open | grep -v '^$' ; echo
	elif [ $SELT = "MIRROR_V" ]
		# vxprint -o alldgs -htv -e v_nplex=2 -F "%vname %plname %daname %dmname"
		/usr/sbin/vxprint -o alldgs -v -e v_nplex=2 | grep -v '^$'; echo
	fi
}

plex() {
        /usr/sbin/vxprint -o alldgs -pt |grep  -v '^$'
        echo
}

subdisk() {
        /usr/sbin/vxprint -o alldgs -um -st |grep -v ^S |grep  -v '^$'
        echo
}

dmp() {
        /usr/sbin/vxdmpadm listctlr
        echo
}

dg() {
        /usr/sbin/vxdg list
        echo
}

CNT=0
str1=$1
if [ ! -z $str1 ]
then
        WCNT=`echo -n $str1 |wc -c`
        while [ $WCNT -gt $CNT ]
        do
           reverse=`echo ${str1:$CNT:1}`
           case "$reverse" in
                d)
                        SELT="D"; disk
                        ;;
                d)
                        SELT="DETAIL_D"; disk
                        ;;
                v)
                        SELT="V"; volume
                        ;;
				o)
                        SELT="OPEN_V"; volume
                        ;;
				m)
                        SELT="MIRROR_V"; volume
                        ;;
                p)
                        plex
                        ;;
                s)
                        subdisk
                        ;;
                p)
                        dmp
                        ;;
                g)
                        dg
                        ;;

                *)
                        echo -e "  $0 : invalid option --'$reverse' "
                        echo -e "      valid option : volume(v)|DG(g)|disk(d)|plex(p)|subdisk(s)|dmp(p)"
                        echo
                        ;;
           esac
           ((CNT+=1))
        done
else
                        echo -e "  [ERROR] $0 : volume(v)|DG(g)|disk(d)|plex(p)|subdisk(s)|dmp(m)"
fi

