header_type ether_hdr_t {
	fields {
		dst       : 48;
		src       : 48;
		ethertype : 16;
	}
}
header ether_hdr_t ether_hdr;

parser start {
	extract(ether_hdr);
	return ingress;
}

control ingress {
	apply(forwarding_table);
}

table forwarding_table {
	reads {
		ether_hdr.dst : exact;
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
