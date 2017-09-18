#!/bin/bash
VM=$1

data=`vboxmanage list vms|grep -i ${VM} |sed 's/"\s/",/g'|sed 's/{//g'|sed 's/}//g'|sed 's/"//g'`
echo $data
