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

parser start {
	extract(ether_hdr);
	return select(ether_hdr.ethertype) {
		0x800: ipv4;
	}
}

parser ipv4 {
	extract(ipv4_hdr);
	return ingress;
}

control ingress {
	if (valid(ipv4_hdr)) {
		apply(ipv4_forwarding_table);
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

action set_egress(port) {
	modify_field(standard_metadata.egress_spec, port);
}

action drop_packet() {
	drop();
}
