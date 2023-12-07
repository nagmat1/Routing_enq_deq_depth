# Network Configuration for Basic Setup : 

```
sudo ifconfig enp7s0 192.168.1.10/24 
sudo ifconfig enp7s0 192.168.1.1/24 
```

For ARP : 

```
sudo ifconfig enp7s0 hw ether 00:00:00:00:00:01 
sudo ifconfig enp7s0 hw ether 00:00:00:00:00:02 
```

# Delete existing routes : 

```
sudo ip route del 192.168.1.0/24 
sudo ip route del 192.168.2.0/24 
```

# Add new routes : 

```
sudo ip route add 192.168.2.0/24 via 192.168.1.1 
sudo ip route add 192.168.1.0/24 via 192.168.2.1 
```

# ARP2 

```
sudo arp -s 192.168.1.1 00:00:00:00:00:02 
sudo arp -s 192.168.2.1 00:00:00:00:00:03 
```

