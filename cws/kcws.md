注意绝对路径
```
python kcws/train/process_anno_file.py /data/kcws/2014 chars_for_w2v.txt
bazel build third_party/word2vec:word2vec
./bazel-bin/third_party/word2vec/word2vec -train /data/kcws/chars_for_vec.txt -output /data/kcws/kcws/models/vec.txt -size 50 -sample 1e-4 -negative 5 -hs 1 -binary 0 -iter 5
```
