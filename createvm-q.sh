#!/bin/bash
#set -x
VM=$1
SIZE=$2

VBoxManage clonemedium disk /vms/image_build/centos7/output-virtualbox-iso/centos7-base-0.1.0-disk001.vmdk  /vms/${VM}/${VM}.vdi --format VDI > /dev/null 2>&1
VBoxManage createvm --name "${VM}" --register > /dev/null 2>&1
VBoxManage modifyvm "${VM}" --memory 2048  > /dev/null 2>&1
VBoxManage modifyvm "${VM}" --cpus 2 > /dev/null 2>&1
VBoxManage modifyvm "${VM}" --ioapic on  > /dev/null 2>&1
VBoxManage modifyvm "${VM}" --nic1 bridged --bridgeadapter1 eno1 --nictype1 virtio --cableconnected1 on  > /dev/null 2>&1
VBoxManage modifyvm "${VM}" --macaddress1 auto > /dev/null 2>&1
VBoxManage modifyvm "${VM}" --ostype RedHat_64 > /dev/null 2>&1

VBoxManage storagectl ${VM} --name "SATA Controller" --add sata > /dev/null 2>&1

VBoxManage storageattach "${VM}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium /vms/${VM}/${VM}.vdi > /dev/null 2>&1

#add app disk
VBoxManage createhd --filename /vms/${VM}/${VM}-app.vdi --size ${SIZE} > /dev/null 2>&1
VBoxManage storageattach ${VM} --storagectl "SATA Controller" --port 1 --device 0 --type hdd --medium /vms/${VM}/${VM}-app.vdi > /dev/null 2>&1

VBoxHeadless --startvm "${VM}" > /dev/null 2>&1 &

until [[ $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
  do 
    IP=`VBoxManage guestproperty enumerate ${VM}|grep /VirtualBox/GuestInfo/Net/0/V4/IP |awk '{print $4}'|sed s/\,//g`
    sleep 1
done



echo ${VM} | ssh -oStrictHostKeyChecking=no root@${IP} "hostnamectl set-hostname ${VM}" > /dev/null 2>&1

VBoxManage controlvm ${VM} keyboardputscancode 1d 38 53 b8 9d > /dev/null 2>&1
sleep 7
until nc -vzw 2 ${IP} 22 > /dev/null 2>&1 
do 
 sleep 1
done
uuid=`vboxmanage list vms |grep "#{server_id}" |awk '{print $2}'|sed 's/{//g'|sed 's/}//g'`
echo $uuid

