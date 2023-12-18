echo "table_add MyIngress.ipv4_lpm MyIngress.forward 192.168.1.0/24 => 00:00:00:00:00:03 0" | simple_switch_CLI
echo "table_add MyIngress.ipv4_lpm MyIngress.forward 192.168.2.0/24 => 00:00:00:00:00:06 1" | simple_switch_CLI
echo "table_add MyEgress.swtrace MyEgress.add_swtrace => 200" | simple_switch_CLI
