
1. getLeafCollector()得到一个Collector

```
@Override
public LeafBucketCollector getLeafCollector(LeafReaderContext ctx,
        final LeafBucketCollector sub) throws IOException {

    globalOrds = valuesSource.globalOrdinalsValues(ctx);

    if (acceptedGlobalOrdinals == null && includeExclude != null) {
        acceptedGlobalOrdinals = includeExclude.acceptedGlobalOrdinals(globalOrds);
    }

    if (acceptedGlobalOrdinals != null) {
        globalOrds = new FilteredOrdinals(globalOrds, acceptedGlobalOrdinals);
    }

    return newCollector(globalOrds, sub);
}
```
1. DocValues是否在单个文件中
2. 单个文件中直接获取ord，多个则需要计算ord得到globalOrd
```
protected LeafBucketCollector newCollector(final RandomAccessOrds ords, final LeafBucketCollector sub) {
    grow(ords.getValueCount());
    final SortedDocValues singleValues = DocValues.unwrapSingleton(ords);
    if (singleValues != null) {
        return new LeafBucketCollectorBase(sub, ords) {
            @Override
            public void collect(int doc, long bucket) throws IOException {
                assert bucket == 0;
                final int ord = singleValues.getOrd(doc);
                if (ord >= 0) {
                    collectExistingBucket(sub, doc, ord);
                }
            }
        };
    } else {
        return new LeafBucketCollectorBase(sub, ords) {
            @Override
            public void collect(int doc, long bucket) throws IOException {
                assert bucket == 0;
                ords.setDocument(doc);
                final int numOrds = ords.cardinality();
                for (int i = 0; i < numOrds; i++) {
                    final long globalOrd = ords.ordAt(i);
                    collectExistingBucket(sub, doc, globalOrd);
                }
            }
        };
    }
}
```

计算top N

```
public InternalAggregation buildAggregation(long owningBucketOrdinal) throws IOException {
    if (globalOrds == null) { // no context in this reader
        return buildEmptyAggregation();
    }

    final int size;
    if (bucketCountThresholds.getMinDocCount() == 0) {
        // if minDocCount == 0 then we can end up with more buckets then maxBucketOrd() returns
        size = (int) Math.min(globalOrds.getValueCount(), bucketCountThresholds.getShardSize());
    } else {
        size = (int) Math.min(maxBucketOrd(), bucketCountThresholds.getShardSize());
    }
    long otherDocCount = 0;
    BucketPriorityQueue<OrdBucket> ordered = new BucketPriorityQueue<>(size, order.comparator(this));
    OrdBucket spare = new OrdBucket(-1, 0, null, showTermDocCountError, 0);
    for (long globalTermOrd = 0; globalTermOrd < globalOrds.getValueCount(); ++globalTermOrd) {
        if (includeExclude != null && !acceptedGlobalOrdinals.get(globalTermOrd)) {
            continue;
        }
        final long bucketOrd = getBucketOrd(globalTermOrd);
        final int bucketDocCount = bucketOrd < 0 ? 0 : bucketDocCount(bucketOrd);
        if (bucketCountThresholds.getMinDocCount() > 0 && bucketDocCount == 0) {
            continue;
        }
        otherDocCount += bucketDocCount;
        spare.globalOrd = globalTermOrd;
        spare.bucketOrd = bucketOrd;
        spare.docCount = bucketDocCount;
        if (bucketCountThresholds.getShardMinDocCount() <= spare.docCount) {
            spare = ordered.insertWithOverflow(spare);
            if (spare == null) {
                spare = new OrdBucket(-1, 0, null, showTermDocCountError, 0);
            }
        }
    }

    // Get the top buckets
    final StringTerms.Bucket[] list = new StringTerms.Bucket[ordered.size()];
    long survivingBucketOrds[] = new long[ordered.size()];
    for (int i = ordered.size() - 1; i >= 0; --i) {
        final OrdBucket bucket = (OrdBucket) ordered.pop();
        survivingBucketOrds[i] = bucket.bucketOrd;
        BytesRef scratch = new BytesRef();
        copy(globalOrds.lookupOrd(bucket.globalOrd), scratch);
        list[i] = new StringTerms.Bucket(scratch, bucket.docCount, null, showTermDocCountError, 0, format);
        list[i].bucketOrd = bucket.bucketOrd;
        otherDocCount -= list[i].docCount;
    }
    //replay any deferred collections
    runDeferredCollections(survivingBucketOrds);

    //Now build the aggs
    for (int i = 0; i < list.length; i++) {
        StringTerms.Bucket bucket = list[i];
        bucket.aggregations = bucket.docCount == 0 ? bucketEmptyAggregations() : bucketAggregations(bucket.bucketOrd);
        bucket.docCountError = 0;
    }

    return new StringTerms(name, order, bucketCountThresholds.getRequiredSize(), bucketCountThresholds.getMinDocCount(),
            pipelineAggregators(), metaData(), format, bucketCountThresholds.getShardSize(), showTermDocCountError,
            otherDocCount, Arrays.asList(list), 0);
}
```
