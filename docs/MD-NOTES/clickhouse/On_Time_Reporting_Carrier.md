Downloading data:
```
for s in `seq 1987 2018`
do
for m in `seq 1 12`
do
wget https://transtats.bts.gov/PREZIP/On_Time_Reporting_Carrier_On_Time_Performance_1987_present_${s}_${m}.zip
done
done
```
Loading data:
```
time for i in *.zip; do echo $i; unzip -cq $i '*.csv' | sed 's/\.00//g' | clickhouse-client --host=127.0.0.1   --query="INSERT INTO ontime FORMAT CSVWithNames"; done
real    52m38.307s
user    40m0.454s
sys     4m42.302s
```
Q

```
1.hadoopdev.com :) select count(*) from ontime;

SELECT count(*)
FROM ontime 

┌───count()─┐
│ 176442058 │
└───────────┘

1 rows in set. Elapsed: 0.119 sec. Processed 176.44 million rows, 176.44 MB (1.49 billion rows/s., 1.49 GB/s.) 

1.hadoopdev.com :) select count(*) from ontime;

SELECT count(*)
FROM ontime 

┌───count()─┐
│ 185133752 │
└───────────┘

1 rows in set. Elapsed: 0.799 sec. Processed 185.13 million rows, 185.13 MB (231.65 million rows/s., 231.65 MB/s.) 

1.hadoopdev.com :) select count(*) from ontime;

SELECT count(*)
FROM ontime 

┌───count()─┐
│ 185133752 │
└───────────┘

1 rows in set. Elapsed: 0.089 sec. Processed 185.13 million rows, 185.13 MB (2.08 billion rows/s., 2.08 GB/s.) 

1.hadoopdev.com :) select count(*) from ontime;

SELECT count(*)
FROM ontime 

┌───count()─┐
│ 185133752 │
└───────────┘

1 rows in set. Elapsed: 0.116 sec. Processed 185.13 million rows, 185.13 MB (1.60 billion rows/s., 1.60 GB/s.) 

1.hadoopdev.com :) select count(*) from ontime;

SELECT count(*)
FROM ontime 

┌───count()─┐
│ 185133752 │
└───────────┘

1 rows in set. Elapsed: 0.102 sec. Processed 185.13 million rows, 185.13 MB (1.81 billion rows/s., 1.81 GB/s.) 

1.hadoopdev.com :) 
```
Q0

```
1.hadoopdev.com :) select avg(c1) from (select Year, Month, count(*) as c1 from ontime group by Year, Month);

SELECT avg(c1)
FROM 
(
    SELECT 
        Year, 
        Month, 
        count(*) AS c1
    FROM ontime 
    GROUP BY 
        Year, 
        Month
) 

;↙ Progress: 5.98 million rows, 17.95 MB (2.22 million rows/s., 6.67 MB/s.) █████                                                                                                                                                          3%
 ┌────────────avg(c1)─┐
│ 493690.00533333333 │
└────────────────────┘

1 rows in set. Elapsed: 8.345 sec. Processed 185.13 million rows, 555.40 MB (22.18 million rows/s., 66.55 MB/s.) 

1.hadoopdev.com :) ;

Empty query

1.hadoopdev.com :) select avg(c1) from (select Year, Month, count(*) as c1 from ontime group by Year, Month);

SELECT avg(c1)
FROM 
(
    SELECT 
        Year, 
        Month, 
        count(*) AS c1
    FROM ontime 
    GROUP BY 
        Year, 
        Month
) 

┌────────────avg(c1)─┐
│ 493690.00533333333 │
└────────────────────┘

1 rows in set. Elapsed: 1.168 sec. Processed 185.13 million rows, 555.40 MB (158.48 million rows/s., 475.44 MB/s.) 
```
