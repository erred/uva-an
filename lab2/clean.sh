#!/bin/sh

awk 'NR % 11 == 0' task1_1_1_tcp.csv | awk -F ',' '{ print $1 " " $9 }' > out_task1_1_1_tcp.csv
awk 'NR % 11 == 0' task1_1_1_udp.csv | awk -F ',' '{ print $1 " " $9 }' > out_task1_1_1_udp.csv
