### 基于数组

默认大小为10

```
public ArrayList() {
    this(10);
}
```
### 扩容（（平均）算法复杂度）

### 源码分析

add 方法
>
*. 判断容量是不是够，不够需要扩容
*. 容量够了之后，直接添加元素至elementData最后，size增1
``` 
public boolean add(E e) {
    ensureCapacityInternal(size + 1);  // Increments modCount!!
    elementData[size++] = e;
    return true;
}
```
当前minCapacity(size+1)比当前数组elementData长度大了，需要grow

```
private void ensureCapacityInternal(int minCapacity) {
    modCount++;
    // overflow-conscious code
    if (minCapacity - elementData.length > 0)
        grow(minCapacity);
}
```
grow策略
>
*. 先按数组elementData长度的1.5倍，在比较minCapacity与newCapacity，取较大者
*. 如果newCapacity比MAX_ARRAY_SIZE大了，最多能扩容到Integer.MAX_VALUE（有些VM可能不支持）
```
private void grow(int minCapacity) {
    // overflow-conscious code
    int oldCapacity = elementData.length;
    int newCapacity = oldCapacity + (oldCapacity >> 1);
    if (newCapacity - minCapacity < 0)
        newCapacity = minCapacity;
    if (newCapacity - MAX_ARRAY_SIZE > 0)
        newCapacity = hugeCapacity(minCapacity);
    // minCapacity is usually close to size, so this is a win:
    elementData = Arrays.copyOf(elementData, newCapacity);
}

private static int hugeCapacity(int minCapacity) {
    if (minCapacity < 0) // overflow
        throw new OutOfMemoryError();
    return (minCapacity > MAX_ARRAY_SIZE) ?
        Integer.MAX_VALUE :
        MAX_ARRAY_SIZE;
}
/**
 * The maximum size of array to allocate.
 * Some VMs reserve some header words in an array.
 * Attempts to allocate larger arrays may result in
 * OutOfMemoryError: Requested array size exceeds VM limit
 */
private static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;
```
