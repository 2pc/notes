python3

```
/usr/local/python3/bin/esrally list tracks
/usr/local/python3/bin/esrally --target-hosts=172.28.3.169:9200 --challenge=append-no-conflicts  --pipeline=benchmark-only 
```


```
------------------------------------------------------

|   Lap |                         Metric |              Operation |    Value |   Unit |
|------:|-------------------------------:|-----------------------:|---------:|-------:|
|   All |                  Indexing time |                        |  18.4233 |    min |
|   All |                     Merge time |                        |  8.45383 |    min |
|   All |                   Refresh time |                        |   1.5959 |    min |
|   All |                     Flush time |                        |   0.0937 |    min |
|   All |            Merge throttle time |                        |  1.28283 |    min |
|   All |             Total Young Gen GC |                        |  105.426 |      s |
|   All |               Total Old Gen GC |                        |    6.087 |      s |
|   All |         Heap used for segments |                        |   35.902 |     MB |
|   All |       Heap used for doc values |                        | 0.376518 |     MB |
|   All |            Heap used for terms |                        |  32.3862 |     MB |
|   All |            Heap used for norms |                        |  0.37085 |     MB |
|   All |           Heap used for points |                        | 0.497391 |     MB |
|   All |    Heap used for stored fields |                        |  2.27103 |     MB |
|   All |                  Segment count |                        |      386 |        |
|   All |                 Min Throughput |           index-append |  61862.3 | docs/s |
|   All |              Median Throughput |           index-append |  62272.4 | docs/s |
|   All |                 Max Throughput |           index-append |  62547.7 | docs/s |
|   All |        50th percentile latency |           index-append |  591.556 |     ms |
|   All |        90th percentile latency |           index-append |   792.14 |     ms |
|   All |        99th percentile latency |           index-append |  1008.76 |     ms |
|   All |       100th percentile latency |           index-append |  1159.34 |     ms |
|   All |   50th percentile service time |           index-append |  591.556 |     ms |
|   All |   90th percentile service time |           index-append |   792.14 |     ms |
|   All |   99th percentile service time |           index-append |  1008.76 |     ms |
|   All |  100th percentile service time |           index-append |  1159.34 |     ms |
|   All |                     error rate |           index-append |        0 |      % |
|   All |                 Min Throughput |            force-merge | 0.451521 |  ops/s |
|   All |              Median Throughput |            force-merge | 0.451521 |  ops/s |
|   All |                 Max Throughput |            force-merge | 0.451521 |  ops/s |
|   All |       100th percentile latency |            force-merge |  2214.73 |     ms |
|   All |  100th percentile service time |            force-merge |  2214.73 |     ms |
|   All |                     error rate |            force-merge |        0 |      % |
|   All |                 Min Throughput |            index-stats |  99.8537 |  ops/s |
|   All |              Median Throughput |            index-stats |  100.042 |  ops/s |
|   All |                 Max Throughput |            index-stats |  100.079 |  ops/s |
|   All |        50th percentile latency |            index-stats |  5.46182 |     ms |
|   All |        90th percentile latency |            index-stats |  5.81822 |     ms |
|   All |        99th percentile latency |            index-stats |  13.5812 |     ms |
|   All |      99.9th percentile latency |            index-stats |    31.53 |     ms |
|   All |       100th percentile latency |            index-stats |  35.5274 |     ms |
|   All |   50th percentile service time |            index-stats |  5.38569 |     ms |
|   All |   90th percentile service time |            index-stats |  5.73539 |     ms |
|   All |   99th percentile service time |            index-stats |  7.35532 |     ms |
|   All | 99.9th percentile service time |            index-stats |  19.8843 |     ms |
|   All |  100th percentile service time |            index-stats |  33.2946 |     ms |
|   All |                     error rate |            index-stats |        0 |      % |
|   All |                 Min Throughput |             node-stats |  99.7234 |  ops/s |
|   All |              Median Throughput |             node-stats |   100.08 |  ops/s |
|   All |                 Max Throughput |             node-stats |  100.506 |  ops/s |
|   All |        50th percentile latency |             node-stats |  4.99755 |     ms |
|   All |        90th percentile latency |             node-stats |  6.18105 |     ms |
|   All |        99th percentile latency |             node-stats |  19.1822 |     ms |
|   All |      99.9th percentile latency |             node-stats |  40.7044 |     ms |
|   All |       100th percentile latency |             node-stats |  43.4248 |     ms |
|   All |   50th percentile service time |             node-stats |  4.92518 |     ms |
|   All |   90th percentile service time |             node-stats |  5.89061 |     ms |
|   All |   99th percentile service time |             node-stats |  12.7114 |     ms |
|   All | 99.9th percentile service time |             node-stats |    23.81 |     ms |
|   All |  100th percentile service time |             node-stats |  29.5221 |     ms |
|   All |                     error rate |             node-stats |        0 |      % |
|   All |                 Min Throughput |                default |  49.7138 |  ops/s |
|   All |              Median Throughput |                default |  49.8357 |  ops/s |
|   All |                 Max Throughput |                default |  49.9989 |  ops/s |
|   All |        50th percentile latency |                default |   78.694 |     ms |
|   All |        90th percentile latency |                default |  109.321 |     ms |
|   All |        99th percentile latency |                default |  130.211 |     ms |
|   All |      99.9th percentile latency |                default |  132.313 |     ms |
|   All |       100th percentile latency |                default |   133.01 |     ms |
|   All |   50th percentile service time |                default |  19.5179 |     ms |
|   All |   90th percentile service time |                default |  22.9952 |     ms |
|   All |   99th percentile service time |                default |  29.5767 |     ms |
|   All | 99.9th percentile service time |                default |  33.6133 |     ms |
|   All |  100th percentile service time |                default |  34.0087 |     ms |
|   All |                     error rate |                default |        0 |      % |
|   All |                 Min Throughput |                   term |    200.1 |  ops/s |
|   All |              Median Throughput |                   term |  200.146 |  ops/s |
|   All |                 Max Throughput |                   term |  200.247 |  ops/s |
|   All |        50th percentile latency |                   term |  1.35143 |     ms |
|   All |        90th percentile latency |                   term |  1.48689 |     ms |
|   All |        99th percentile latency |                   term |  7.12223 |     ms |
|   All |      99.9th percentile latency |                   term |  12.4479 |     ms |
|   All |       100th percentile latency |                   term |  14.2566 |     ms |
|   All |   50th percentile service time |                   term |  1.28271 |     ms |
|   All |   90th percentile service time |                   term |  1.41036 |     ms |
|   All |   99th percentile service time |                   term |  2.19197 |     ms |
|   All | 99.9th percentile service time |                   term |  9.44819 |     ms |
|   All |  100th percentile service time |                   term |  14.1846 |     ms |
|   All |                     error rate |                   term |        0 |      % |
|   All |                 Min Throughput |                 phrase |  200.079 |  ops/s |
|   All |              Median Throughput |                 phrase |  200.103 |  ops/s |
|   All |                 Max Throughput |                 phrase |   200.18 |  ops/s |
|   All |        50th percentile latency |                 phrase |   2.2103 |     ms |
|   All |        90th percentile latency |                 phrase |   2.4706 |     ms |
|   All |        99th percentile latency |                 phrase |   11.616 |     ms |
|   All |      99.9th percentile latency |                 phrase |  15.6662 |     ms |
|   All |       100th percentile latency |                 phrase |  18.5554 |     ms |
|   All |   50th percentile service time |                 phrase |  2.13811 |     ms |
|   All |   90th percentile service time |                 phrase |  2.37983 |     ms |
|   All |   99th percentile service time |                 phrase |  6.02854 |     ms |
|   All | 99.9th percentile service time |                 phrase |   15.007 |     ms |
|   All |  100th percentile service time |                 phrase |  18.4917 |     ms |
|   All |                     error rate |                 phrase |        0 |      % |
|   All |                 Min Throughput |   country_agg_uncached |  4.99828 |  ops/s |
|   All |              Median Throughput |   country_agg_uncached |  5.00039 |  ops/s |
|   All |                 Max Throughput |   country_agg_uncached |  5.00094 |  ops/s |
|   All |        50th percentile latency |   country_agg_uncached |  182.581 |     ms |
|   All |        90th percentile latency |   country_agg_uncached |  188.497 |     ms |
|   All |        99th percentile latency |   country_agg_uncached |  216.159 |     ms |
|   All |      99.9th percentile latency |   country_agg_uncached |  265.591 |     ms |
|   All |       100th percentile latency |   country_agg_uncached |  283.101 |     ms |
|   All |   50th percentile service time |   country_agg_uncached |  182.469 |     ms |
|   All |   90th percentile service time |   country_agg_uncached |  187.274 |     ms |
|   All |   99th percentile service time |   country_agg_uncached |   204.71 |     ms |
|   All | 99.9th percentile service time |   country_agg_uncached |  235.395 |     ms |
|   All |  100th percentile service time |   country_agg_uncached |  283.018 |     ms |
|   All |                     error rate |   country_agg_uncached |        0 |      % |
|   All |                 Min Throughput |     country_agg_cached |   100.06 |  ops/s |
|   All |              Median Throughput |     country_agg_cached |  100.088 |  ops/s |
|   All |                 Max Throughput |     country_agg_cached |  100.141 |  ops/s |
|   All |        50th percentile latency |     country_agg_cached |  1.60566 |     ms |
|   All |        90th percentile latency |     country_agg_cached |   1.7477 |     ms |
|   All |        99th percentile latency |     country_agg_cached |   2.2176 |     ms |
|   All |      99.9th percentile latency |     country_agg_cached |  9.30915 |     ms |
|   All |       100th percentile latency |     country_agg_cached |  16.4332 |     ms |
|   All |   50th percentile service time |     country_agg_cached |  1.52987 |     ms |
|   All |   90th percentile service time |     country_agg_cached |  1.67116 |     ms |
|   All |   99th percentile service time |     country_agg_cached |   2.1434 |     ms |
|   All | 99.9th percentile service time |     country_agg_cached |  7.93241 |     ms |
|   All |  100th percentile service time |     country_agg_cached |  16.3647 |     ms |
|   All |                     error rate |     country_agg_cached |        0 |      % |
|   All |                 Min Throughput |                 scroll |  50.8261 |  ops/s |
|   All |              Median Throughput |                 scroll |  51.0866 |  ops/s |
|   All |                 Max Throughput |                 scroll |  51.1761 |  ops/s |
|   All |        50th percentile latency |                 scroll |   202331 |     ms |
|   All |        90th percentile latency |                 scroll |   293105 |     ms |
|   All |        99th percentile latency |                 scroll |   313990 |     ms |
|   All |       100th percentile latency |                 scroll |   316299 |     ms |
|   All |   50th percentile service time |                 scroll |  489.875 |     ms |
|   All |   90th percentile service time |                 scroll |  503.467 |     ms |
|   All |   99th percentile service time |                 scroll |  604.492 |     ms |
|   All |  100th percentile service time |                 scroll |  671.093 |     ms |
|   All |                     error rate |                 scroll |        0 |      % |
|   All |                 Min Throughput |             expression |  1.50274 |  ops/s |
|   All |              Median Throughput |             expression |  1.51578 |  ops/s |
|   All |                 Max Throughput |             expression |  1.52315 |  ops/s |
|   All |        50th percentile latency |             expression |  47835.8 |     ms |
|   All |        90th percentile latency |             expression |  61424.2 |     ms |
|   All |        99th percentile latency |             expression |  63231.4 |     ms |
|   All |       100th percentile latency |             expression |  63428.9 |     ms |
|   All |   50th percentile service time |             expression |  601.142 |     ms |
|   All |   90th percentile service time |             expression |  803.793 |     ms |
|   All |   99th percentile service time |             expression |   855.46 |     ms |
|   All |  100th percentile service time |             expression |  864.696 |     ms |
|   All |                     error rate |             expression |        0 |      % |
|   All |                 Min Throughput |        painless_static |  1.52618 |  ops/s |
|   All |              Median Throughput |        painless_static |  1.53092 |  ops/s |
|   All |                 Max Throughput |        painless_static |  1.53463 |  ops/s |
|   All |        50th percentile latency |        painless_static |  46295.4 |     ms |
|   All |        90th percentile latency |        painless_static |  59289.4 |     ms |
|   All |        99th percentile latency |        painless_static |  62228.7 |     ms |
|   All |       100th percentile latency |        painless_static |    62592 |     ms |
|   All |   50th percentile service time |        painless_static |   654.26 |     ms |
|   All |   90th percentile service time |        painless_static |   677.31 |     ms |
|   All |   99th percentile service time |        painless_static |  688.594 |     ms |
|   All |  100th percentile service time |        painless_static |  692.648 |     ms |
|   All |                     error rate |        painless_static |        0 |      % |
|   All |                 Min Throughput |       painless_dynamic |  1.58312 |  ops/s |
|   All |              Median Throughput |       painless_dynamic |  1.58976 |  ops/s |
|   All |                 Max Throughput |       painless_dynamic |  1.59402 |  ops/s |
|   All |        50th percentile latency |       painless_dynamic |  39157.3 |     ms |
|   All |        90th percentile latency |       painless_dynamic |  49429.6 |     ms |
|   All |        99th percentile latency |       painless_dynamic |  51808.9 |     ms |
|   All |       100th percentile latency |       painless_dynamic |  52032.1 |     ms |
|   All |   50th percentile service time |       painless_dynamic |   614.86 |     ms |
|   All |   90th percentile service time |       painless_dynamic |   659.55 |     ms |
|   All |   99th percentile service time |       painless_dynamic |  667.928 |     ms |
|   All |  100th percentile service time |       painless_dynamic |  671.404 |     ms |
|   All |                     error rate |       painless_dynamic |        0 |      % |
|   All |                 Min Throughput |            large_terms |          |  ops/s |
|   All |              Median Throughput |            large_terms |          |  ops/s |
|   All |                 Max Throughput |            large_terms |          |  ops/s |
|   All |        50th percentile latency |            large_terms |   303402 |     ms |
|   All |        90th percentile latency |            large_terms |   382914 |     ms |
|   All |        99th percentile latency |            large_terms |   400940 |     ms |
|   All |       100th percentile latency |            large_terms |   403041 |     ms |
|   All |   50th percentile service time |            large_terms |  1491.91 |     ms |
|   All |   90th percentile service time |            large_terms |  1620.02 |     ms |
|   All |   99th percentile service time |            large_terms |  1715.96 |     ms |
|   All |  100th percentile service time |            large_terms |  1850.31 |     ms |
|   All |                     error rate |            large_terms |      100 |      % |
|   All |                 Min Throughput |   large_filtered_terms |  1.05604 |  ops/s |
|   All |              Median Throughput |   large_filtered_terms |  1.05881 |  ops/s |
|   All |                 Max Throughput |   large_filtered_terms |  1.06254 |  ops/s |
|   All |        50th percentile latency |   large_filtered_terms |   134066 |     ms |
|   All |        90th percentile latency |   large_filtered_terms |   169674 |     ms |
|   All |        99th percentile latency |   large_filtered_terms |   177395 |     ms |
|   All |       100th percentile latency |   large_filtered_terms |   178306 |     ms |
|   All |   50th percentile service time |   large_filtered_terms |  933.624 |     ms |
|   All |   90th percentile service time |   large_filtered_terms |   1051.8 |     ms |
|   All |   99th percentile service time |   large_filtered_terms |  1095.05 |     ms |
|   All |  100th percentile service time |   large_filtered_terms |  1102.69 |     ms |
|   All |                     error rate |   large_filtered_terms |        0 |      % |
|   All |                 Min Throughput | large_prohibited_terms |  1.10261 |  ops/s |
|   All |              Median Throughput | large_prohibited_terms |  1.10642 |  ops/s |
|   All |                 Max Throughput | large_prohibited_terms |  1.10927 |  ops/s |
|   All |        50th percentile latency | large_prohibited_terms |   122288 |     ms |
|   All |        90th percentile latency | large_prohibited_terms |   153311 |     ms |
|   All |        99th percentile latency | large_prohibited_terms |   160411 |     ms |
|   All |       100th percentile latency | large_prohibited_terms |   161308 |     ms |
|   All |   50th percentile service time | large_prohibited_terms |  891.075 |     ms |
|   All |   90th percentile service time | large_prohibited_terms |  1007.45 |     ms |
|   All |   99th percentile service time | large_prohibited_terms |  1037.46 |     ms |
|   All |  100th percentile service time | large_prohibited_terms |  1058.17 |     ms |
|   All |                     error rate | large_prohibited_terms |        0 |      % |

```
