#!/bin/sh
set -e

for i in $@
do
	sudo ip link add name veth${i} type veth peer name port${i}
	sudo ip link set veth${i} addrgenmode none
	sudo ip link set port${i} addrgenmode none
	sudo ip link set dev veth${i} up
	sudo ip link set dev port${i} up
done

