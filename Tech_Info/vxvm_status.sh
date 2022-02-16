#!/bin/bash
#

disk() {
        /usr/sbin/vxdisk list
        echo
}

volume() {
        /usr/sbin/vxprint -v |grep ^v
        echo
}

plex() {
        /usr/sbin/vxprint -p |grep ^pl
        echo
}

subdisk() {
        /usr/sbin/vxprint -s |grep ^sd
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

str1=$1
if [ ! -z $str1 ]
then
for (( i = ${#str1} -1; i >= 0; i--))
do
        reverse=""
        reverse="$reverse${str1:$i:1}"
        case "$reverse" in
                d)
                        disk
                        ;;
                v)
                        volume
                        ;;
                p)
                        plex
                        ;;
                s)
                        subdisk
                        ;;
                m)
                        dmp
                        ;;
                g)
                        dg
                        ;;

                *)
                        echo -e "  $0 : invalid option --'$reverse' "
                        echo -e "      valid option : volume(v)|DG(g)|disk(d)|plex(p)|subdisk(s)|dmp(m)"
                        echo
                        ;;
        esac
done
else
                        echo -e "  [ERROR] $0 : volume(v)|DG(g)|disk(d)|plex(p)|subdisk(s)|dmp(m)"
fi
