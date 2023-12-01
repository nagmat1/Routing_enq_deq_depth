/* -*- P4_16 program for findind min,max and average enq_qdepth  -*- */
#include <core.p4>
#include <v1model.p4>

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<48> macAddr_t;
const bit<16> TYPE_IPV4 = 0x800;
typedef bit<9>  egressSpec_t;
typedef bit<32> ip4Addr_t;


header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<6>    dscp;
    bit<2>    ecn;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

header metadata_t {
    bit<32> count; 
    bit<32> swid;
    bit<32> sum;
    bit<32> counter;
}

struct metadata {
    /* empty */
}

struct headers {
    ethernet_t   ethernet;
    ipv4_t       ipv4;
    metadata_t my_meta;
}

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

      state start {

        transition parse_ethernet;

    }

    state parse_ethernet {

        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType){
            TYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol){
            default: accept;
        }
    }

}

/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {

    action drop() {
        mark_to_drop(standard_metadata);
    }

     action forward(macAddr_t dstAddr, egressSpec_t port) {
        //set the src mac address as the previous dst
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;

       //set the destination mac address that we got from the match in the table
        hdr.ethernet.dstAddr = dstAddr;

        //set the output port that we also get from the table
        standard_metadata.egress_spec = port;

        //decrease ttl by 1
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            forward;
            drop;
        }
        size = 1024;
        default_action = drop;
    }

    apply {
        if(hdr.ipv4.isValid()) {
            ipv4_lpm.apply();
        }
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
        register<bit<32>>(512) input_port_pkt_count;
	bit<32> jemi;
	bit<32> counter1;

	action add_swtrace(bit<32> swid) {
		
		hdr.my_meta.setValid();

		hdr.my_meta.count = 1;
		hdr.my_meta.swid = swid; 
	
		input_port_pkt_count.read(jemi, (bit<32>) 0);
           	hdr.my_meta.sum = jemi;
           	jemi = 0;
          	input_port_pkt_count.write((bit<32>) 0, jemi);
		
		input_port_pkt_count.read(counter1, (bit<32>) 1);
	        hdr.my_meta.counter = (bit<32>) counter1;
       	    	counter1= 0;
        	input_port_pkt_count.write((bit<32>) 1, counter1);
	}		

	table swtrace {
        actions = {
            add_swtrace;
            NoAction;
        }
        default_action = NoAction();        
	} 

	apply {

        //Find sum
        input_port_pkt_count.read(jemi, (bit<32>) 0);
        jemi = jemi + (bit<32>) standard_metadata.enq_qdepth;
        input_port_pkt_count.write((bit<32>) 0, jemi);

        //Counter
        input_port_pkt_count.read(counter1, (bit<32>) 1);
        counter1 = counter1 + 1;
        input_port_pkt_count.write((bit<32>) 1, counter1);

        //Find minimum
        //bit<32> jmin;
        //input_port_pkt_count.read(jmin, (bit<32>) 2);
        //if (((bit<32>)standard_metadata.enq_qdepth < (bit<32>)jmin))     {
        //jmin = (bit<32>)standard_metadata.enq_qdepth;
        //input_port_pkt_count.write((bit<32>) 2, jmin);
        //}
        //input_port_pkt_count.write((bit<32>) 2, jmin);

        //Find maximum
        //bit<32> jmax;
        //input_port_pkt_count.read(jmax, (bit<32>) 3);
        //if (((bit<32>)standard_metadata.enq_qdepth > (bit<32>)jmax))     {
        //jmax = (bit<32>)standard_metadata.enq_qdepth;
        //}
        //input_port_pkt_count.write((bit<32>) 3, jmax);

 if ((hdr.ipv4.protocol != 0x01) && (hdr.ipv4.protocol != 0x6) && (hdr.ipv4.protocol!= 0x11))
    {
	   swtrace.apply();
           //input_port_pkt_count.read(jmin, (bit<32>) 2);
           //hdr.my_meta.enq_qdepth = (bit<32>) standard_metadata.enq_qdepth;
           //jmin = 100;
           //input_port_pkt_count.write((bit<32>) 2, jmin);

           //input_port_pkt_count.read(jmax, (bit<32>) 3);
           //hdr.my_meta.deq_timedelta = (bit<32>) standard_metadata.deq_timedelta;
           //jmax = 0;
           //input_port_pkt_count.write((bit<32>) 3, jmax);

      }
 }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers  hdr, inout metadata meta) {
    apply {
        update_checksum(
            hdr.ipv4.isValid(),
            { hdr.ipv4.version,
              hdr.ipv4.ihl,
              hdr.ipv4.dscp,
              hdr.ipv4.ecn,
              hdr.ipv4.totalLen,
              hdr.ipv4.identification,
              hdr.ipv4.flags,
              hdr.ipv4.fragOffset,
              hdr.ipv4.ttl,
              hdr.ipv4.protocol,
              hdr.ipv4.srcAddr,
              hdr.ipv4.dstAddr },
              hdr.ipv4.hdrChecksum,
              HashAlgorithm.csum16);
    }
}

/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
                // parsed headers have to be added again into the packet
                packet.emit(hdr.ethernet);
                packet.emit(hdr.ipv4);
                packet.emit(hdr.my_meta);
        }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/
V1Switch(
        MyParser(),
        MyVerifyChecksum(),
        MyIngress(),
        MyEgress(),
        MyComputeChecksum(),
        MyDeparser()
) main;


