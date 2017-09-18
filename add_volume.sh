#!/bin/bash
VM=$1
APP=$2
SIZE=$3

VBoxManage createhd --filename /vms/${VM}/${VM}-${APP}.vdi --size ${SIZE}
sleep 5
VBoxManage storagectl ${VM} --name "sata00" --add sata  --controller IntelAHCI
sleep 5
VBoxManage storageattach ${VM} --storagectl "sata00" --port 0  --device 0 --type hdd --medium /vms/${VM}/${VM}-${APP}.vdi
~
