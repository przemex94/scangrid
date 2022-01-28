#!/bin/bash
#scangrid.sh - A simple nmap scan wrapper.

username=$(whoami | cut -c -6)
datestring=$(date +"%d-%m-%Y_%T")
script="$0"
initials="$1"
projectname="$2"
function="$3"
targetlist="$4"

# Put executed command to logit.log
echo $datestring "executed by:" $username "$0" "$@" >> logit.log


#FUNCTIONS
#Buffer with corpkey vs initials array
username_buffer(){
    if [[ ${#initials} -ge 5 ]] ; then echo "Error: Bad initials. Too long!!!" ; break
    elif [[ ${#initials} -le 3 ]] ; then echo "Error: Bad initials. Too short!!!" ; break
    #elif [ `expr "$initials" : ".*[!@#\$%^\&*()_+].*"` -gt 0 ]; then echo "This str contain sspecial symbol" ; break
    else
        break
    fi
}

#Mini tcp scan run
mini_tcp_scan_run() {
    echo testnamebuffer
}
#Tcp scan run
tcp_scan_run() {
    username_buffer
    if [ -d "/home/domain/$username/$projectname" ]; then
        :
    else
        mkdir /home/domain/$username/$projectname
    fi
    screen -S $projectname -dm bash -c "nmap -p- -A -oA /home/domain/$username/$projectname/nmaptcp --stats-every 1s --script=all --version-all --osscan-guess --unprivileged -Pn -T4 -vvv --reason -iL $targetlist | tee log.log" 
    exit 1
}
#Udp scan run
udp_scan_run() {
    username_buffer
    if [ -d "/home/domain/$username/$projectname" ]; then
        :
    else
        mkdir /home/domain/$username/$projectname
    fi
    screen -S $projectname -dm_ sh -c "nmap -p- -A -oA /home/domain/$username/$projectname/nmapudp --stats-every 1s --script=all --version-all --osscan-guess --privileged -Pn -T4 -vvv --reason -sU -iL $targetlist | tee sudolog.log"
    exit 1
}
#List of person scan
list() {
    username_buffer
    list=`ps -aux | grep $username | grep 'nmap' | grep -v grep | grep -v './mykmyk' | grep -v 'SCREEN'`
    echo "$initials $list"
    exit 1
}
#Scan finder
find() {
    username_buffer
    finder=`ps -aux | grep nmap | grep $username | grep $projectname | grep -v grep | grep -v 'SCREEN' | grep -v './mykmyk' | grep -v tee`
    echo "$finder"
    exit 1
}
#Scan results
results() {
    username_buffer
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

#Loop loop / whoop whoop!
while :
do
case $1 in
    -h | --help |?)
        display_help
        ;;
    -* | --*)
        display_help
        ;;
    esac
case $2 in
    -l | --list)
        list
        ;;
    -* | --*)
        display_help
        shift 2
        ;;
    esac
case $3 in
    -m | --mtcp)
        mini_tcp_scan_run
        shift 2
        ;;
    -t | --tcp)
        tcp_scan_run
        shift 2
        ;;
    -u | --udp)
        udp_scan_run
        shift 2
        ;;
    -f | --find)
        find
        shift 2
        ;;
    -r | --results)
        results
        shift 2
        ;;
        --)
        display_help
        exit 0
        ;;
    -* | --*) 
        display_help
        exit 0
        ;;
    *)  break
        ;;
    esac
done
