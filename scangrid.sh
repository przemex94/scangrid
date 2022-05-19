#!/bin/bash######E#####
#scangrid.sh - A simple nmap scan wrapper.
#written by przemex94
username=$(whoami | cut -c -6)
year=$(date +"%Y")
datestring=$(date +"%d-%m-%Y_%T")
scangrid=`basename "$0"`
options=$@
initials=$1
projectname=$2
targetlist=$4
mkdir -p /opt/scangrid/tcp
#mkdir -p /opt/scangrid/minitcp
mkdir -p /opt/scangrid/udp
mkdir -p /opt/scangrid/results

#FUNCTIONS

#Show logit
show_logit(){
    cat /opt/scangrid/logit.log
    exit 0
}

#Initials input buffer
initials_buffer(){ 
    if [[ ${#initials} -ge 5 ]] ; then echo "Error: Bad initials. Too long!!!" ; exit 0
    elif [[ ${#initials} -le 3 ]] ; then echo "Error: Bad initials. Too short!!!" ; exit 0
    elif [[ $initials = *['!'@'#'\$%^\&*()_+]* ]] ; then echo "Hey!! No special chars!!"; exit 0
    fi
}

#Projectname input buffer
projectname_buffer(){ 
    if [[ $2 == *['!'@'#'\$%^\&*()_+]* ]] ; then echo "Hey!! No special chars!!"
    fi
}

# Put executed command to /opt/scangrid/$date/ 
logit_buffer() { 
    if [ -e "/opt/scangrid/logit.log" ] ; then
        touch /opt/scangrid/logit.log
    fi
    echo "$datestring" "executed by:" $username $scangrid $options >> /opt/scangrid/logit.log
}

#Mini tcp scan run
#mini_tcp_scan_run() { 
#    scantype=$minitcp
#    mkdir -p /opt/scangrid/minitcp/0
#    id=`ls /opt/scangrid/minitcp/ | sort -n | uniq | tail -1`
#    id=$((++id))
#    mkdir -p /opt/scangrid/minitcp/$id
#    screen -S $2+_minitcp -dm bash -c "nc -zvnw 2 $targetlist 2>&1 | tee /opt/scangrid/results/$scantype_$projectname.log"
#    exit 1
#}   

#Tcp scan run
tcp_scan_run() { 
    echo "TCP SCAN STARTED!"
    scantype="tcp"
    mkdir -p /opt/scangrid/tcp/
    screen -S $scantype_$projectname -dm sh -c "nmap -p- -oA /opt/scangrid/tcp/$scantype_$projectname --stats-every 1s -sC -sV $targetlist | tee /opt/scangrid/results/$scantype_$projectname.log" 
    exit 0
}

#Udp scan run
udp_scan_run() { 
    echo "UDP SCAN STARTED!"
    scantype="udp"
    mkdir -p /opt/scangrid/udp/
    screen -S $scantype_$projectname -dm sh -c "nmap -p- -oA /opt/scangrid/udp/$scantype_$projectname --stats-every 1s -sC -sV -sU $targetlist | tee /opt/scangrid/results/$scantype_$projectname.log"
    exit 0
}

#List of all scans function
list_func() {
    templst=`ps -aux | grep 'nmap' | grep -v grep | grep -v 'SCREEN' | grep -v tee`
    echo "$templst"
    exit 0
}

#Scan finder
find_func() {
    finder=`ps -aux | grep nmap | grep $username | grep $projectname | grep -v grep | grep -v 'SCREEN' | grep -v tee`
    echo $finder
    exit 0
}

#Scan results
results_func() {
    echo $2 && tail -2 /opt/scangrid/results/$scantype_$projectname.log | tail -2 | grep -v grep | grep "Timing: About" | xargs -n 1 | grep %
    exit 0
}

show_scan_udp_xml() {
    cat /opt/scangrid/udp/$projectname.xml
    exit 0
}

show_scan_tcp_xml() {
    cat /opt/scangrid/tcp/$projectname.xml
    exit 0
}

show_scan_udp_normal() {
    cat /opt/scangrid/udp/$projectname.nmap
    exit 0
}

show_scan_tcp_normal() {
    cat /opt/scangrid/tcp/$projectname.nmap
    exit 0
}

#Help Banner
display_help() {
    echo -e "\n"
    echo "   ==============================|$scangrid|======================================="
    echo "  ||                                                                                ||"
    echo "  ||                                                                                ||"
    echo "  || START TCP SCAN:                                                                ||"
    echo "  || Usage: $scangrid <initials> <projectname> [-t | --tcp ] ''target or targets''||"
    echo "  ||                                                                                ||"
    echo "  || START UDP SCAN:                                                                ||"
    echo "  || Usage: $scangrid <initials> <projectname> [-u | --udp] ''target or targets'' ||"
    echo "  ||                                                                                ||"
    echo "  || SCAN FIND:                                                                     ||"
    echo "  || Usage: $scangrid <initials> <projectname> [-f]                               ||"
    echo "  ||                                                                                ||"
    echo "  || SCAN RESULTS IN PERCENT:                                                       ||"
    echo "  || Usage: $scangrid <initials> <projectname> [-r]                               ||"
    echo "  ||                                                                                ||"
    echo "  || SCAN LIST:                                                                     ||"
    echo "  || Usage: $scangrid <initials> [-l --la --listall]                              ||"
    echo "  ||                                                                                ||"
    echo "  || SHOW REPORT:                                                                   ||"
    echo "  || Usage: $scangrid <initials> <projectname> --rux (for udp xml)                ||"
    echo "  ||                                             --run (for udp normal)             |"
    echo "  ||                                             --rtx (for tcp xml)                ||"
    echo "  ||                                             --rtn (for tcp normal)             ||"
    echo "  ||                                                                                ||"
    echo "  || WHO? WHEARE? HOW?:                                                             ||"
    echo "  ||        $scangrid [-s --show-logit]                                           ||"
    echo "  ||                                                                                ||"
    echo "   =================================================================================="
    echo -e "\n"
    exit 0
}

#Loop loop whoop whoop 
case $1 in
   -h | --help |?)
       logit_buffer
       display_help
       exit 0
       ;;
   -s | --show-logit)
       logit_buffer
       show_logit
       exit 0
       ;;
   -* | --*)
       logit_buffer
       display_help
       exit 0
       ;;
esac
case $2 in
   -f | --find)
       logit_buffer
       projectname_buffer
       find_func
       exit 0
       ;;
    -l | --la | --listall)
       logit_buffer
       list_func
       exit 0
       ;;
   -* | --*)
       logit_buffer
       display_help
       exit 0
       ;;
esac
case $3 in
   -m | --mtcp)
       initials_buffer
       logit_buffer
       projectname_buffer
       mini_tcp_scan_run
       exit 0
       ;;
   -t | --tcp)
       initials_buffer
       logit_buffer
       projectname_buffer
       tcp_scan_run
       exit 0
       ;;
   -u | --udp)
       initials_buffer
       logit_buffer
       projectname_buffer
       udp_scan_run
       exit 0
       ;;
   -r | --results)
       logit_buffer
       initials_buffer
       projectname_buffer
       results_func
       exit 0
       ;;
   --rux)
       logit_buffer
       show_scan_udp_xml
       exit 0
       ;;
   --rtx)
       logit_buffer
       show_scan_tcp_xml
       exit 0
       ;;
   --run)
       logit_buffer
       show_scan_udp_normal
       exit 0
       ;;
   --rtn)
       logit_buffer
       show_scan_tcp_normal
       exit 0
       ;;
  --)
       logit_buffer
       display_help
       exit 0
       ;;
  -* | --*)
       logit_buffer
       display_help
       exit 0
       ;;
esac
find /opt/scangrid/ -type d -exec chmod 750 {} \;
find /opt/scangrid/ -type f -exec chmod 640 {} \;
env -i
