#!/bin/sh
set -e

for i in $@
do
	sudo ip link del veth${i}
done


