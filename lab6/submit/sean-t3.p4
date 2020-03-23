header_type ether_hdr_t {
	fields {
		dst       : 48;
		src       : 48;
		ethertype : 16;
	}
}
header ether_hdr_t ether_hdr;

header_type ipv4_hdr_t {
	fields {
		version   : 4;
		ihl       : 4;
		tos       : 8;
		total_len : 16;
		id        : 16;
		flags     : 3;
		offset    : 13;
		ttl       : 8;
		proto     : 8;
		checksum  : 16;
		src       : 32;
		dst       : 32;
		// Note: IP option fields are not parsed
	}
}
header ipv4_hdr_t ipv4_hdr;

header_type ipv6_hdr_t {
    fields {
        version : 4;
        tc      : 8;
        flow    : 20;
        len     : 16;
        next    : 8;
        limit   : 8;
        src     : 128;
        dst     : 128;
    }
}
header ipv6_hdr_t ipv6_hdr;

header_type tcp_header_t {
    fields {
        srcp    : 16;
        dstp    : 16;
        // no need to parse further
    }
}
header tcp_header_t udp_hdr;

header_type udp_header_t {
    fields {
        srcp    : 16;
        dstp    : 16;
    }
}
header udp_header_t udp_hdr;

parser start {
	extract(ether_hdr);
	return select(ether_hdr.ethertype) {
		0x800: ipv4;
		0x86dd: ipv6;
	}
}

parser ipv4 {
	extract(ipv4_hdr);
    return select(ipv4_hdr.proto) {
        0x6     : tcp;
        0x11    : udp;
    };
}

parser ipv6 {
    extract(ipv6_hdr);
    return select(ipv4_hdr.proto) {
        0x6     : tcp;
        0x11    : udp;
    };
}

parser tcp {
    extract(tcp_hdr);
    return ingress;
}
parser udp {
    extract(udp_hdr);
    return ingress;
}

control ingress {
	if (valid(ipv4_hdr)) {
		apply(ipv4_forwarding_table);
	}
    if (valid(ipv6_hdr)) {
        apply(ipv6_forwarding_table);
    }
}

control egress {
    if(valid(ether_hdr)) {
        apply(ether_multi_drop);
    }
    if(valid(tcp_hdr)) {
        apply(tcp_drop);
    }
    if(valid(udp_hdr)) {
        apply(udp_drop);
    }
}

table ipv4_forwarding_table {
	reads {
	    ipv4_hdr.dst: lpm;
	}
	actions {
		set_egress;
		drop_packet;
	}
}

table ipv6_forwarding_table {
    reads {
        ipv6_hdr.dst: lpm;
    }
    actions {
        set_egress;
        drop_packet;
    }
}

table ether_multi_drop {
    reads {
        ether_hdr.dst: ternary;
    }
    actions {
        drop_packet;
    }
}

table tcp_drop {
    reads {
        tcp_hdr.srcp: exact;
    }
    actions {
        drop_packet;
    }
}
table udp_drop {
    reads {
        udp_hdr.srcp: exact;
    }
    actions {
        drop_packet;
    }
}

action set_egress(port) {
	modify_field(standard_metadata.egress_spec, port);
}

action drop_packet() {
	drop();
}
