spark repartition &coalesce

```
def repartition(numPartitions: Int)(implicit ord: Ordering[T] = null): RDD[T] = withScope {
  coalesce(numPartitions, shuffle = true)
}
```

[Prefer repartition to coalesce in Spark](https://reports.telemetry.mozilla.org/post/projects/avoid_coalesce.kp)   
[Spark - repartition() vs coalesce()-stackoverflow](https://stackoverflow.com/questions/31610971/spark-repartition-vs-coalesce)
