[]()


### Split-brain(脑裂)问题

可依据有资格参加选举的节点数，设置法定票数属性的值，来避免爆裂的发生

```
discovery.zen.minimum_master_nodes = int(# of master eligible nodes/2)+1
```
