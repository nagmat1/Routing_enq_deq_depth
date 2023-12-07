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
