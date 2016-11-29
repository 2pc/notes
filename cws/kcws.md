注意绝对路径
```
python kcws/train/process_anno_file.py /data/kcws/2014 chars_for_w2v.txt   
```
使用word2vec 训练 chars_for_w2v (注意-binary 0),得到字嵌入结果vec.txt
```
bazel build third_party/word2vec:word2vec
./bazel-bin/third_party/word2vec/word2vec -train /data/kcws/chars_for_vec.txt -output /data/kcws/kcws/models/vec.txt -size 50 -sample 1e-4 -negative 5 -hs 1 -binary 0 -iter 5
```   
产生训练数据与测试数据
```
bazel build kcws/train:generate_training
./bazel-bin/kcws/train/generate_training /data/kcws/kcws/models/vec.txt /data/kcws/2014  all.txt
python kcws/train/filter_sentence.py /data/kcws/all.txt 
```
安装好tensorflow,切换到kcws代码目录，运行
```
python kcws/train/train_cws_lstm.py --word2vec_path /data/kcws/kcws/models/vec.txt --train_data_path /data/kcws/train.txt  --test_data_path /data/kcws/test.txt  --max_sentence_len 80 --learning_rate 0.001
```
