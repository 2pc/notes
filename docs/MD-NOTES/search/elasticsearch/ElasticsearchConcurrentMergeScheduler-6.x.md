### segment合并

ES由ElasticsearchConcurrentMergeScheduler来负责调度merge任务
控制merge的参数


MergePolicyConfig

>
1. index.merge.policy.floor_segment 默认 2MB，小于这个大小的 segment，优先被归并。
2. index.merge.policy.max_merge_at_once 默认一次最多归并 10 个 segment
3. index.merge.policy.max_merge_at_once_explicit 默认 forcemerge 时一次最多归并 30 个 segment。
4. index.merge.policy.max_merged_segment 默认 5 GB，大于这个大小的 segment，不用参与归并。forcemerge 除外。


MergeSchedulerConfig

[ELK stack 中文指南](https://kibana.logstash.es/content/elasticsearch/principle/indexing-performance.html)
