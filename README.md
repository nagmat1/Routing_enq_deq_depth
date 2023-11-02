# Routing_enq_deq_depth

Routing enqueue and dequeue depth on fabric testbed platform. 

# Architecture 

We are using server from WASH and UCSD for server1 and server2. 
Our server at DALL is functioning as a bmv2 programmable switch with 2 Basic NICs. These three sites are connected by physical connections as shown in figure below : 

![Screenshot from 2023-11-02 10-13-26](https://github.com/nagmat1/Routing_enq_deq_depth/assets/51871069/4c91d231-6d49-49e2-857f-6b52574afb82)


# Limiting the rate to build up the queue : 

Limiting the rate by : 

```
sudo tc qdisc add dev enp7s0 root netem rate 1Gbit delay 100ms
```

will limit the traffic, but we can't see the queue build up. 

In order to the see the queue build up, limit the rate by  : 

```
sudo tc qdisc add dev enp7s0 root handle 1:0 netem delay 1ms
sudo tc qdisc add dev enp7s0 parent 1:1 handle 10: tbf rate 1gbit buffer 160000 limit 300000
```

Then we started to see the queue build up as shown below: 

![Screenshot from 2023-10-23 14-35-54](https://github.com/nagmat1/Routing_enq_deq_depth/assets/51871069/ec4be6cb-f206-429a-b687-743d4fd15e22)

# Average Enq_qdepth and deqqdepth for 2 cases with congestion 

In our experiment we make a congestion and analyze the enq_qdepth and deq_qdepth while the switch is congested. 

After each 0.05 seconds we send the probing packets. Every time when the switch receives the probing packets it resets the ```sum``` value and and ```packet_count``` value on Registers and patches the existing values onto the packet header as shown in figure below.   

![temp](https://github.com/nagmat1/Routing_enq_deq_depth/assets/51871069/c3ee42c4-296a-47d1-b0ba-3f544764020c)
