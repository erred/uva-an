https://www.ipspace.net/Data_Center_BGP/
https://www.rfc-editor.org/rfc/rfc7938.txt
https://archive.nanog.org/meetings/nanog55/presentations/Monday/Lapukhov.pdf

Bidirectional Forwarding Detection (BFD)

You can mitigate the configuration scalability issue on your route reflectors
with BGP dynamic neighbor discovery, 'bgp listen' on IOS or 'allow' in Junos.
Note, the IOS command seems to only be available on higher end platforms - e.g. the ASR.

copy startup-config tftp 10.12.0.38 hp-start
copy startup-config tftp://10.12.0.38/cisco-start
