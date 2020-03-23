## CoS marking

layer 2 802.1P/Q tagging

- vlan necessary

- https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst3750/software/release/12-2_35_se/configuration/guide/scg/swqos.html#wp1058769
- https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst3750/software/release/12-2_35_se/configuration/guide/scg/swqos.html#wp1021247
- https://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus5000/sw/configuration/guide/cli/CLIConfigurationGuide/AccessTrunk.html#55125
- https://www.cisco.com/c/en/us/support/docs/switches/catalyst-3750-series-switches/91862-cat3750-qos-config.html#concept21
- http://www.ciscopress.com/articles/article.asp?p=170743&seqNum=3
- https://wiki.archlinux.org/index.php/VLAN

### switch

```
# enable qos
enable
configure terminal
mls qos

# trust server cos
interface GigabitEthernet2/0/4
switchport trunk encapsulation dot1q
switchport mode trunk
mls qos trust cos

config t
vlan 2
mtu 9000
exit
interface vlan 2
ip address 10.0.2.193 255.255.255.0

# set cos on port
interface GigabitEthernet2/0/3
switchport mode access
mls qos cos 6

show mls qos interface
copy running-config startup-config
```

### server

```
ip link add link eno2 name eno2.1 type vlan id 2
ip link set eno2.1 address 34:17:eb:f0:dc:e5
ip addr add 10.0.2.194/24 dev eno2.1
ip link set dev eno2.1 up
```

## SRR

https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst3750/software/release/12-2_35_se/configuration/guide/scg/swqos.html#wp1250091

```
# show current
show mls qos interface interface-id queueing

# output queue
# udo
mls qos srr-queue output cos-map queue 1 2
# tcp
mls qos srr-queue output cos-map queue 2 3

nterface interface-id
queue-set qset-id

interface interface-id
# shape applies 1/n bandwidth to queue, 0 = shared
srr-queue bandwidth shape 8 2 0 0
# shared compares ratios
srr-queue bandwidth share 25 25 25 25

show mls qos interface interface-id queueing
copy running-config startup-config

srr-queue bandwidth shape 0 0 0 0
srr-queue bandwidth shape 15 75 5 5
```

## DSCP

```
CS2 = tos 0x20
CS5 = tos 0xA0
```
