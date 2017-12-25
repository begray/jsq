# jsq - JSON stream processor

**Work in progress**

At the moment `jsq` supports very limitted set of filtering operations and cannot really be compared to `jq`.

But it's still quite usable if you want to extract certain parts of structure from large JSON files or JSON streams.

# Motivational example

`jq` can be rather inefficient when dealing with large bodies of JSON

```shell
$ ls -sk sample.json
 879108 sample.json
$ time jq '.[].status."status-details"' sample.json | head -n3
"done at 2017-12-09T00:38:13.860+03:00"
"done at 2017-12-09T00:38:32.736+03:00"
"done at 2017-12-09T00:37:51.380+03:00"
jq '.[].status."status-details"' sample.json  20.44s user 1.85s system 99% cpu 22.508 total
head -n3  0.00s user 0.00s system 0% cpu 22.256 total
$ time jq '.[].status."status-details"' sample.json | tail -n3
"done at 2017-12-09T00:37:59.498+03:00"
"done at 2017-12-09T00:38:27.542+03:00"
"done at 2017-12-09T00:38:11.074+03:00"
jq '.[].status."status-details"' sample.json  22.64s user 2.08s system 99% cpu 24.963 total
tail -n3  0.01s user 0.00s system 0% cpu 24.953 total
➜  jsq time stack exec jsq-exe -- '.[].status.status-details' sample.json | head -n3
"done at 2017-12-09T00:38:13.860+03:00"
"done at 2017-12-09T00:38:32.736+03:00"
"done at 2017-12-09T00:37:51.380+03:00"
stack exec jsq-exe -- '.[].status.status-details' sample.json  1.29s user 0.28s system 117% cpu 1.333 total
head -n3  0.00s user 0.00s system 0% cpu 0.779 total
➜  jsq time stack exec jsq-exe -- '.[].status.status-details' sample.json | tail -n3
"done at 2017-12-09T00:37:59.498+03:00"
"done at 2017-12-09T00:38:27.542+03:00"
"done at 2017-12-09T00:38:11.074+03:00"
stack exec jsq-exe -- '.[].status.status-details' sample.json  7.04s user 1.29s system 122% cpu 6.814 total
tail -n3  0.01s user 0.00s system 0% cpu 6.813 total
```