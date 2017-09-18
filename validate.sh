#!/bin/bash
hosts=( "$@" )
for vm in ${hosts[@]}
  do
    cvm=`/usr/local/bin/exists.sh ${vm} | awk -F, '{print $1}'`
    cid=`/usr/local/bin/exists.sh ${vm} | awk -F, '{print $2}'`
    if [[ ${cvm} != ${vm} ]]
    then
	echo "no vm"
	   /usr/local/bin/createvm.sh ${vm} 20 
    else
	    echo "${VM} Exists "
    fi
done

