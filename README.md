# Routing_enq_deq_depth
Routing enqueue dequeue depth fabric program

# Limiting the rate to build up the queue : 

Limiting the rate by : 

```
sudo tc qdisc add dev enp7s0 root netem rate 1Gbit delay 100ms
```

will limit the traffic, but we can't see the queue build up. 

In order to the see the queue build up, limit the rate by  : 

```
sudo tc qdisc change dev enp7s0 root handle 1:0 netem delay 1ms
sudo tc qdisc add dev enp7s0 parent 1:1 handle 10: tbf rate 1gbit buffer 160000 limit 300000
```

Then we started to see the queue build up as shown below: 

![Screenshot from 2023-10-23 14-35-54](https://github.com/nagmat1/Routing_enq_deq_depth/assets/51871069/ec4be6cb-f206-429a-b687-743d4fd15e22)
