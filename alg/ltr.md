#### 

#### 前提ranknet  F(x) =Si-Sj  逻辑回归变换

#### 交叉熵损失函数

1. [交叉熵代价函数（作用及公式推导）](http://blog.csdn.net/u014313009/article/details/51043064)
2. [交叉熵代价函数(损失函数)及其求导推导](http://blog.csdn.net/jasonzzj/article/details/52017438)

#### 

1. [Learning To Rank之LambdaMART的前世今生](http://blog.csdn.net/huagong_adu/article/details/40710305)
2. [再理解RankNet算法](http://blog.csdn.net/puqutogether/article/details/43667375)

#### LambdaMART求解步骤 
1. 依据公式NDCG, 求解λ, 求解λ的一阶导数w
2. 拟合第一步的λ，依据MSE
3. 依据拟牛顿法计算叶子结点的值
4. 更新模型
