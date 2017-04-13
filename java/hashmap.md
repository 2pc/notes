### HashMap   的实现原理

### HashMap的数据结构

HashMap内部是一个Entry型的数组,  而Entry又是一个链表行的数据结构（这个在解决hash冲突的时候用到）

```
transient Entry[] table;
//注意这个next本省就是个Entry类型，构成了一个链表
Entry(int h, K k, V v, Entry<K,V> n) {
   value = v;
   next = n;
   key = k;
   hash = h;
}
```

#### HashMap 的put方法

```
复制代码
public V put(K key, V value) {
    //当key为null，调用putForNullKey方法，保存null与table第一个位置中，这是HashMap允许为null的原因
    if (key == null)
        return putForNullKey(value);
    //计算key的hash值
    int hash = hash(key.hashCode());                  
    //计算key hash 值在 table 数组中的位置
    int i = indexFor(hash, table.length);         
    //从i出开始迭代 e,找到 key 保存的位置
    for (Entry<K, V> e = table[i]; e != null; e = e.next) {
        Object k;
        //判断该条链上是否有hash值相同的(key相同)
        //若存在相同，则直接覆盖value，返回旧value
        if (e.hash == hash && ((k = e.key) == key || key.equals(k))) {
            V oldValue = e.value;    //旧值 = 新值
            e.value = value;
            e.recordAccess(this);
            return oldValue;     //返回旧值
        }
    }
    //修改次数增加1
    modCount++;
    //将key、value添加至i位置处
    addEntry(hash, key, value, i);
    return null;
}

void  addEntry(int hash, K key, V value, int bucketIndex) {
     Entry<K,V> e = table[bucketIndex];
     //Entry链表解决hash冲突问题，注意这里的e为原来在改位置的值，如果有会放入链表尾部，新元素则到头部
     table[bucketIndex] = new Entry<K,V>(hash, key, value, e);
     if (size++ >= threshold)
         resize(2 * table.length);
 }
```
HashMap的get方法
```
public V get(Object key) {
    // 若为null，调用getForNullKey方法返回相对应的value
    if (key == null) return getForNullKey();
    // 根据该key的hashCode值计算它的hash码  
    int hash = hash(key.hashCode());
    // 取出 table 数组中指定索引处的值
    for (Entry < K, V > e = table[indexFor(hash, table.length)]; e != null; e = e.next) {
        Object k;
        //若搜索的hash,key与查找的hash,key相同，则返回相对应的value
        if (e.hash == hash && ((k = e.key) == key || key.equals(k))) return e.value;
    }
    return null;
}
```
