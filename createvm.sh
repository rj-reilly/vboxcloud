#!/bin/bash
#set -x
VM=$1
SIZE=$2
echo "Creating vm ${VM}"

VBoxManage clonemedium disk /vms/image_build/centos7/output-virtualbox-iso/centos7-base-0.1.0-disk001.vmdk  /vms/${VM}/${VM}.vdi --format VDI
VBoxManage createvm --name "${VM}" --register
VBoxManage modifyvm "${VM}" --memory 2048 
VBoxManage modifyvm "${VM}" --cpus 2
VBoxManage modifyvm "${VM}" --ioapic on 
VBoxManage modifyvm "${VM}" --nic1 bridged --bridgeadapter1 eno1 --nictype1 virtio --cableconnected1 on 
VBoxManage modifyvm "${VM}" --macaddress1 auto
VBoxManage modifyvm "${VM}" --ostype RedHat_64

VBoxManage storagectl ${VM} --name "SATA Controller" --add sata

VBoxManage storageattach "${VM}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium /vms/${VM}/${VM}.vdi

#add app disk
VBoxManage createhd --filename /vms/${VM}/${VM}-app.vdi --size ${SIZE}
VBoxManage storageattach ${VM} --storagectl "SATA Controller" --port 1 --device 0 --type hdd --medium /vms/${VM}/${VM}-app.vdi

echo "Create complete, starting vm"
VBoxHeadless --startvm "${VM}" > /dev/null &

until [[ $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
  do 
    IP=`VBoxManage guestproperty enumerate ${VM}|grep /VirtualBox/GuestInfo/Net/0/V4/IP |awk '{print $4}'|sed s/\,//g`
    printf .
    sleep 1
done
echo 


echo "${VM} is now at ${IP}"

echo "Customizing OS"

echo "Rebooting host NOW !"
VBoxManage controlvm ${VM} keyboardputscancode 1d 38 53 b8 9d
sleep 7

until echo ${VM} | ssh -oStrictHostKeyChecking=no root@${IP} "hostnamectl set-hostname ${VM}"
do 
 sleep 1
 printf .
done

echo

echo "${VM} is now available at ${IP}"
echo "boot strapping"
cd /home/rreilly/chef-repo/
knife bootstrap -N ${VM} ${IP} -r init::default,chef-client::default -e dev 
knife vault update keys rreilly -A rjreilly  -S "*base*"
knife node ${VM} run_list  add base::default 
knife ssh ${VM} chef-client
echo done
