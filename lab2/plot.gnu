#!/usr/bin/gnuplot

reset
set terminal png
set out "lab2-group5-task1.1.1-udp.png"
set style data linespoints
set xlabel "time (seconds)"
set ylabel "Throughput"
set title "Throughput"
set grid
plot "./out1_1_1_udp.csv"  title "udp"

reset
set terminal png
set out "lab2-group5-task1.1.1-tcp.png"
set style data linespoints
set xlabel "time (seconds)"
set ylabel "Throughput"
set title "Throughput"
set grid
plot "./out1_1_1_tcp.csv"  title "tcp"

reset
set terminal png
set out "lab2-group5-task1.1.2.png"
set style data linespoints
set xlabel "time (seconds)"
set ylabel "Throughput"
set title "Throughput"
set grid
plot "./out1_1_2_server2.csv"  title "server2", \
     "./out1_1_2_server3.csv"  title "server3", \
     "./out1_1_2_server4.csv"  title "server4"

reset
set terminal png
set out "lab2-group5-task1.2.png"
set style data linespoints
set xlabel "time (seconds)"
set ylabel "Throughput"
set title "Throughput"
set grid
plot "./out1_2_server2.csv"  title "server2", \
     "./out1_2_server3.csv"  title "server3", \
     "./out1_2_server4.csv"  title "server4"

reset
set terminal png
set out "lab2-group5-task1.3.2.png"
set style data linespoints
set xlabel "time (seconds)"
set ylabel "Throughput"
set title "Throughput"
set grid
plot "./out1_3_2_server2.csv"  title "server2", \
     "./out1_3_2_server3.csv"  title "server3", \
     "./out1_3_2_server4.csv"  title "server4"

reset
set terminal png
set out "lab2-group5-task1.3.3.png"
set style data linespoints
set xlabel "time (seconds)"
set ylabel "Throughput"
set title "Throughput"
set grid
plot "./out1_3_3_server2.csv"  title "server2", \
     "./out1_3_3_server3.csv"  title "server3", \
     "./out1_3_3_server4.csv"  title "server4"

reset
set terminal png
set out "lab2-group5-task2-nopri.png"
set style data linespoints
set xlabel "time (seconds)"
set ylabel "Throughput"
set title "Throughput"
set grid
plot "./out2_server2_nopri.csv"  title "server2", \
     "./out2_server3_nopri.csv"  title "server3"

reset
set terminal png
set out "lab2-group5-task2-pri.png"
set style data linespoints
set xlabel "time (seconds)"
set ylabel "Throughput"
set title "Throughput"
set grid
plot "./out2_server2_pri.csv"  title "server2", \
     "./out2_server3_pri.csv"  title "server3"
