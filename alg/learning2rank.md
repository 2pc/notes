

对于文档i与j，设打分函数为F(X)（X=w1v1+w2v2+w3v3+...+wnvn）,则F(Xi)-F(Xj)越大，i排在j前面的概率越高,即F(Xi)-F(Xj)表示文档i排在j前面的概率

但是概率的范围应该是[0,1]之间，参考逻辑斯蒂回归的归一化函数归一化得

$$
P_ij=\frac e^{F(x_i)-F(x_j)} {1+e^{F(x_i)-F(x_j)}
$$

[Learning to Rank using Gradient Descent](https://zhuanlan.zhihu.com/p/20711017) 

[交叉熵代价函数(损失函数)及其求导推导](http://blog.csdn.net/jasonzzj/article/details/52017438)

>
. logistic回归（是非问题）中，y(i)取0或者1；   
. softmax回归（多分类问题）中，y(i)取1,2…k中的一个表示类别标号的一个数（假设共有k类）。

[再理解RankNet算法](http://blog.csdn.net/puqutogether/article/details/43667375)
[排序学习实践---ranknet方法](https://yq.aliyun.com/articles/18)
[学习排序Learning to Rank之RankNet](http://blog.csdn.net/OrthocenterChocolate/article/details/43203891)
