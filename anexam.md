# AN Exam

Sean Liao

Student Number 12622370

## Q1 Evolution of congestion control algorithms

TCP Tahoe was one of the first congestion control algorithms for TCP.
It was designed to be independent of wall clock time and used RTTs
to pace the connection. It was designed to respond primarily to congestion through
packet loss events.

Later came TCP New Reno, which improved on Tahoe/Reno by observing
that emptying the transmit window every time a packet was lost was poor for performance.
This was especially useful for filling large/multiple gaps.
Up to now, these algorithms were designed for general use,
filling gaps resulting from packet loss.

TCP Cubic was instead designed for high latency high bandwidth networks.
Its cubic growth during recovery and probing allow for much faster recovery,
making it more suitable for lossy networks, such as wireless.
Additionally it is more fair to streams of different latencies as it is not clocked by RTT,
instead by congestion events, allowing it to be used in more places.

TCP BBR also isn't clocked by RTTs and instead tries to measure RTT and build a model of the network,
useful for wired networks with Gigbit speeds and buffer bloat as the primary limit,
as opposed to packet loss. Used at YouTube, it apparently has better performance,
but its fairness is debated.

\newpage

## Q2 Flow control settings

### optimal receive window

- S-A: RTT = (20+50+30+10) = 110ms, Speed=1Gbps, BDP = 0.11s x 1Gbps = 110Mbps, RWND = 110Mbps x 0.11 = 12.1Mb
- S-B: RTT = (20+50+5) = 75ms, Speed=1Gbps, BDP = 0.075s x 1Gbps = 75Mbps, RWND = 75Mbps 0.075s = x 5.625Mb
- S-C: RTT = (20+10) = 30ms, Speed=10Gbps, BDP = 0.03s x 10Gbps = 300Mbps = 300Mbps x 0.03s = 9Mb

### throughput at window = 1MB

1MB = 8Mb

- S-A: 8 \* 110 / 12.1 = 72.73Mbps
- S-B: 8 \* 75 / 6.625 = 90.57Mbps
- S-C: 8 \* 300 / 9 = 266.67Mbps

\newpage

## Q3 Policing and shaping

| packet # | size Kb | Arrival Time | Policing Departure Time | Shaping Departure Time |
| -------- | ------- | ------------ | ----------------------- | ---------------------- |
| 1        | 8 Kbit  | T = 0        | 0+20 = 20ms             | 0+20 = 20ms            |
| 2        | 4 Kbit  | T = 25ms     | 25+10 = 35ms            | 25+10 = 35ms           |
| 3        | 8 Kbit  | T = 50ms     | 50+20 = 70ms            | 50+20 = 70ms           |
| 4        | 4 Kbit  | T = 75ms     | 75+10 = 85ms            | 75+10 = 85ms           |

- 8Kb/400Kbps = 0.02
- 4Kb/400Kbps = 0.01

| time | bucket | calc             |
| ---- | ------ | ---------------- |
| 0    | 8      |                  |
| 20   | 8      | 8-8 + 400 x 0.02 |
| 25   | 8      |                  |
| 26   | 8      | 8-4 + 400 x 0.01 |
| 35   | 8      |

...

\newpage

## Q4 Security of TCP

### 4.1

We can check if the sender is adhering to slow start by looking at
the number of inflight packets at any given time,
since it should sharply decrease and follow the slow start curve.

Greedy connections can be identified by either not following the slow start curve
or by using a more aggressive algorithm/curve.

### 4.2

A very simple attack is to stall the progress of a TCP stream by continuously duplicating a single ACK,
This appears to the sender as a packet loss event and it will keep trying to resend the same packet, stopping forward progression of the connection.
This may also cause the sender to send more data than it received (ACK packet size is smaller), fast recovery sends more packets.

```
Sender      Attacker      Receiver
| DATA a ---------------------> |
| DATA b ---------------------> |
| DATA c ---------------------> |
| DATA d ---------------------> |
| DATA e ---------------------> |
| DATA f ---------------------> |
|               <-------- ACK f |
| <--------- ACK a              |
| <--------- ACK a              |
| <--------- ACK a              |
| DATA b ---------------------> | thinks there is packet loss
| DATA c ---------------------> | resend
| DATA d ---------------------> |
| DATA e ---------------------> |
| DATA f ---------------------> |

```

\newpage

## Q5 Network design and CoS

### 5.1

```
                7x Dell R740
                PoP

     KPN                          SURFnet
      |                              |
      | 10Gbps                       | 10Gbps
      |                              |
Juniper SRX1500               Juniper SRX1500
      |       145.100.100.0/26       |
      |-----------------------------------------
      |                    |                    |
Juniper EX2300       Juniper EX2300        Juniper EX2300
145.100.101.0/24    145.100.101.0/24      145.100.100.128/25
      |                    |                    |
6x Raspberry Pi 4    4x Dell R740          1x Dell R740
Office Automation    Kubernetes Cluster       VPNs
```

- Junipers only: single OS to manage, easier
- Router per purpose: physical separation, not logical routing nightmares
- Simple(?) network: all junipers in backbone, each EX2300 gets own area for servers
- Raspberry Pi for automation: automation usually doesn't need too much computing power
- Dell R740s for everything else: only other compute unit
- Network could easily be just a single EX2300...

### 5.2

relies on default cos-queue mapping

```txt
interface GigabitEthernet 1/0/1
  srr-queue bandwidth share 30 5 5 70

interface Vlan 13
  mls qos cos 4

interface Vlan 42
  mls qos cos 1
```

\newpage

## Q6 Source-based forwarding

### MPLS

1. Setup MPLS network
2. Specify path in terms of labels
3. Wrap packet in stack of labels
4. Send packet into MPLS network, popping of one label per router

### IPv6 Segment Routing

1. Setup IPv6 network
2. Specify path in terms of IPv6 addresses
3. Attach Segment Routing Header to packet with list of addresses
4. Send packet into IPv6 network

\newpage

## Q7 Dynamic MPLS paths

### Protocols

- LDP: Label Distribution Protocol
  - Single purpose
  - Extensible
  - No traffic engineering
- RSVP-TE: Resource ReserVation Protocol Traffic Engineering
  - More explicit configuration
  - Allows explicit routing (not shortest path)
- MP-BGP: Multi Protocol BGP
  - No need for other protocol
  - Used across AS

### Choice

- LDP for easy setup / simple usecases
- RSVP-TE for needing traffic engineering/resource reservation
- MP-BGP for communicating across ASes, using existing BGP infrastructure

\newpage

## Q8 Netflix in Corona times

Video is a high bandwidth application,
needing a constant, high bandwidth to stream video on demand.
Bandwidth can be reduced in multiple ways:

- reducing quality (number of pixels)
- reducing bitrate (higher compression, lower quality, ...)

Some of these services are limiting the maximum quality for all users,
putting a cap on the bandwidth needed per customer.
Others are changing the default,
so most users who don't care as much will use less bandwidth,
for those that care or have the need, higher quality/bandwidth is still available.
