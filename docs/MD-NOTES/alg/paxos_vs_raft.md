[raft算法与paxos算法相比有什么优势，使用场景有什么差异？](https://www.zhihu.com/question/36648084)

Paxos和raft都是一旦一个entries（raft协议叫日志，paxos叫提案，叫法而已）得到多数派的赞成，这个entries就会定下来，不丢失，值不更改，   
最终所有节点都会赞成它。Paxos中称为提案被决定，Raft,ZAB,VR称为日志被提交，这只是说法问题。一个日志一旦被提交(或者决定），就不会丢失，也不可能更改，   
这一点这4个协议都是一致的。Multi-paxos和Raft都用一个数字来标识leader的合法性，multi-paxos中叫proposer-id，Raft叫term，意义是一样的，   
multi-paxos proposer-id最大的Leader提出的决议才是有效的，raft协议中term最大的leader才是合法的   

