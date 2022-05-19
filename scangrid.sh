#!/bin/bash#####
#scangrid.sh - A simple nmap scan wrapper.

username=$(whoami | cut -c -6)
year=$(date +"%Y")
datestring=$(date +"%d-%m-%Y_%T")
script="$0"
initials="$1"
projectname="$2"
function="$3"
targetlist="$4"

#Functions

#Initials input buffer
initials_buffer(){
    if [[ ${#initials} -ge 5 ]] ; then echo "Error: Bad initials. Too long!!!" ; break
    elif [[ ${#initials} -le 3 ]] ; then echo "Error: Bad initials. Too short!!!" ; break
    elif [[ $projectname == *['!'@'#'\$%^\&*()_+]* ]] ; break
    else
        :
    fi
}

#Projectname input buffer
projectname_buffer(){
    if [[ $projectname == *['!'@'#'\$%^\&*()_+]* ]] ; break
    else
        :
    fi
}

# Put executed command to /srv/scangrid/$date/
logit_buffer() {
initials_buffer
projectname_buffer
    if [ -d "/srv/scangrid/logit.log"]; then
        :
    else
        if [ -d "/srv/scangrid"]; then
            :
        else
            mkdir -p /srv/scangrid
        fi
        touch /srv/scangrid/logit.log
    fi
echo $datestring "executed by:" $initials $username "$0" "$@" >> /srv/scangrid/logit.log
}

#Mini tcp scan run
mini_tcp_scan_run() {
    logit_buffer
    initials_buffer
    projectname_buffer
    id=`ls /srv/scangrid/ | sort | tail -1`
    if [ -d "/srv/scangrid/minitcp/$id"]; then
        id=$((++id))
    else
        mkdir -p /srv/scangrid/minitcp/$id
    fi
    screen -S $projectname+_minitcp -dm bash -c "getitfromipport tee /srv/scangrid/minitcp/$id"
    exit 1
}   

#Tcp scan run
tcp_scan_run() { 
    logit_buffer
    initials_buffer
    projectname_buffer
    id=`ls /srv/scangrid/ | sort | tail -1`
    if [ -d "/srv/scangrid/minitcp/$id"]; then
        id=$((++id))
    else
        mkdir -p /srv/scangrid/tcp/$id
    fi
    screen -S $projectname+_tcp -dm bash -c "nmap -p- -A -oA /srv/scangrid/tcp/$id --stats-every 1s --script=all --version-all --osscan-guess --unprivileged -Pn -T4 -vvv --reason | tee tcplog.log" 
    exit 1
}

#Udp scan run
udp_scan_run() {
    logit_buffer
    initials_buffer
    projectname_buffer
    id=`ls /srv/scangrid/ | sort | tail -1`
    if [ -d "/srv/scangrid/minitcp/$id"]; then
        id=$((++id))
    else
        mkdir -p /srv/scangrid/udp/$id
    fi
    screen -S $projectname -dm sh -c "sudo nmap -p- -A -oA /srv/scangrid/udp/$id --stats-every 1s --script=all --version-all --osscan-guess --privileged -Pn -T4 -vvv --reason -sU | tee udplog.log"
    exit 1
}

#List of person scan
list_func() {
    logit_buffer
    initials_buffer
    projectname_buffer
    templst=`ps -aux | grep $username | grep 'nmap' | grep -v grep | grep -v './mykmyk' | grep -v 'SCREEN'`
    echo "$initials $templst"
    exit 1
}

#Scan finder
find_func() {
    initials_buffer
    projectname_buffer
    finder=`ps -aux | grep nmap | grep $username | grep $projectname | grep -v grep | grep -v 'SCREEN' | grep -v './mykmyk' | grep -v tee`
    echo "$finder"
    exit 1
}

#Scan results
results_func() {
    initials_buffer
    projectname_buffer
    echo $testname && tail -2 log.log | grep -v grep | grep "Timing: About" | xargs -n 1 | grep %
    exit 1
}

#Help Banner
display_help() {
    echo -e "\n"
    echo "  ==============================|$0|===================================="
    echo "  ||                                                                           ||"
    echo "  || START SCAN:                                                               ||"
    echo "  || Usage: $0 <initials> <projectname> [-s] <path_to_target_file>    ||"
    echo "  ||                                                                           ||"
    echo "  || START SUDOSCAN:                                                           ||"
    echo "  || Usage: $0 <initials> <projectname> [-ss] <path_to_target_file>   ||"
    echo "  ||                                                                           ||"
    echo "  || SCAN FIND:                                                                ||"
    echo "  || Usage: $0 <initials> <projectname> [-f]                          ||"
    echo "  ||                                                                           ||"
    echo "  || SCAN RESULTS IN PERCENT:                                                  ||"
    echo "  || Usage: $0 <initials> <projectname> [-r]                          ||"
    echo "  ||                                                                           ||"
    echo "  || SCAN LIST:                                                                ||"
    echo "  || Usage: $0 <initials> [-l]                                        ||"
    echo "  ||                                                                           ||"
    echo "  ==============================================================================="
    echo -e "\n"
    exit 0
}

#Loop loop whoop whoop! 
while :
do
case $1 in
    -h | --help |?)
        logit_buffer
        display_help
        ;;
    -* | --*)
        logit_buffer
        display_help
        ;;
    *)  logit_buffer
        break
        ;;
esac
case $2 in
    -l | --list)
        logit_buffer
        list_funct
        ;;
    -* | --*)
        logit_buffer
        display_help
        exit 0
        ;;
    *)  logit_buffer
        display_help
        break
        ;;        
esac
case $3 in
    -m | --mtcp)
        initials_buffer
        logit_buffer
        username_buffer
        projectname_buffer
        mini_tcp_scan_run
        exit 0
        ;;
    -t | --tcp)
        initials_buffer
        logit_buffer
        username_buffer
        projectname_buffer
        tcp_scan_run
        exit 0
        ;;
    -u | --udp)
        initials_buffer
        logit_buffer
        username_buffer
        projectname_buffer
        udp_scan_run
        exit 0
        ;;
    -f | --find)
        initials_buffer
        logit_buffer
        username_buffer
        projectname_buffer
        find
        exit 0
        ;;
    -r | --results)
        initials_buffer
        logit_buffer
        username_buffer
        projectname_buffer
        results
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
    *)  logit_buffer
        display_help
        break
        ;;
esac
done
