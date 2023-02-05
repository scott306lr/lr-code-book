#!/bin/bash

insert=false
delete=false
usage=$(printf "Usage: %s: [-I|-D] [-m 'tcp'|'udp'] [-p port]\n" $0)

# read opts
while getopts 'IDp:m:' opt
do
	case "${opt}" in
		I) insert=true;;
		D) delete=true;;
		m) mode=${OPTARG};;
		p) port=${OPTARG};;
		?) echo $usage
           exit 2;;
	esac
done

# insert/delete check
if [ $insert = $delete ] ; then
	if [ $insert = true ] ; then
		echo "Insert and delete arg cannot appear together!"
	else
		echo "Requires arg: -I or -D."
		echo $usage
	fi
	exit 1
fi

# mode check
if [ -z $mode ] ; then
	echo "Requires arg: -m"
	echo $usage
	exit 1
elif [ $mode != tcp ] && [ $mode != udp ] ; then
	echo "mode incorrect: '$mode', requires 'tcp' or 'udp'"
	exit 1
fi

# port check
re='^[0-9]+$'
if [ -z $port ] ; then
	echo "requires arg: -p"
	exit 1
elif ! [[ $port =~ $re ]] ; then
	echo "Port input invalid!"
	exit 1
fi

# root check
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Execute command
if [ $insert = true ] ; then
	iptables -t nat -I PREROUTING -p ${mode} --dport ${port} -j DNAT --to 127.0.0.1:${port}
	echo "Created portforward ${mode} rule on port ${port}!"
elif [ $delete = true ] ; then
	echo "iptables -t nat -D PREROUTING -p ${mode} --dport ${port} -j DNAT --to 127.0.0.1:${port}"
	iptables -t nat -D PREROUTING -p ${mode} --dport ${port} -j DNAT --to 127.0.0.1:${port}
	
	if [ $? -eq 0 ]; then
		echo
		echo "Deleted portforward ${mode} rule on port ${port}!"
	else
		echo
		echo "Deletion failed. Perhaps rule doesn't exist?"
	fi
fi

exit 0
