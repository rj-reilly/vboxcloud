#!/bin/bash
VM=${1}
printf "Shutting down ${VM} ..."
uuid=`vboxmanage list vms |grep ${VM} |awk '{print $2}'|sed 's/{//g'|sed 's/}//g'`
echo "found ${uuid}"
VBoxManage controlvm ${uuid} poweroff
printf "done"
printf "Destroying vm..."
VBoxManage unregistervm "${uuid}" --delete
rm -rf /vms/${VM}
printf "done"
