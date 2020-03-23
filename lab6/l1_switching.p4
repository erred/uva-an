parser start {
	return ingress;
} 

control ingress {
	apply(forwarding_table);
}

table forwarding_table {
	reads {
		standard_metadata.ingress_port : exact;
	}
	actions {
		set_egress;
	}
}

action set_egress(port) {
	modify_field(standard_metadata.egress_spec, port);
}
