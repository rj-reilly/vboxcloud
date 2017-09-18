#!/bin/bash
VM=$1
until [[ $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
  do
    IP=`VBoxManage guestproperty enumerate ${VM}|grep /VirtualBox/GuestInfo/Net/0/V4/IP |awk '{print $4}'|sed s/\,//g`
    sleep 1
done
echo "ready"
