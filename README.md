# jsq - JSON stream processor

**Work in progress**

Think about `jsq` as `jq`, but with focus on processing large JSON files and streams.

At the moment it supports very limitted set of filtering operations and cannot really be compared to `jq`, but still quite usable if you want to extract certain parts of structure from large JSON files or streams.

# Installation

Checkout repository and use `stack` to build it.

```shell
$ stack build
$ stack test
$ stack install
```

# Features

## Filtering

`jq`-like selection

```
$ curl -s http://www.json-generator.com/api/json/get/cgjIJCdlua\?indent\=2 | jsq '.[].friends.[0]'
{"name":"Tia Pearson","id":0}
{"name":"Horton Mccoy","id":0}
{"name":"Jimmie Santiago","id":0}
{"name":"Montoya Powell","id":0}
{"name":"Bray Delacruz","id":0}
```

## Folding 

Fold document at a certain level for a brief overview of its contents

```
$ curl -s http://www.json-generator.com/api/json/get/cgjIJCdlua\?indent\=2 | jsq -d1 '.'
["{...}","{...}","{...}","{...}","{...}"]
```

## YAML output

Prefer reading YAML, not JSON? Not a problem!

```
curl -s http://www.json-generator.com/api/json/get/cgjIJCdlua\?indent\=2 | jsq -y '.[].friends.[0]'
name: Tia Pearson
id: 0

name: Horton Mccoy
id: 0

name: Jimmie Santiago
id: 0

name: Montoya Powell
id: 0

name: Bray Delacruz
id: 0
```

# Why another `jq`? Motivating example.

`jq` can be rather inefficient when dealing with large bodies of JSON

```shell
# input json file ~850MB

$ ls -sk sample.json
 879108 sample.json

# using jq and head/tail to extract first/last status-details

$ time jq '.[].status."status-details"' sample.json | head -n1
"done at 2017-12-09T00:38:13.860+03:00"
jq '.[].status."status-details"' sample.json  20.44s user 1.85s system 99% cpu 22.508 total
head -n1  0.00s user 0.00s system 0% cpu 22.256 total

$ time jq '.[].status."status-details"' sample.json | tail -n1
"done at 2017-12-09T00:37:59.498+03:00"
jq '.[].status."status-details"' sample.json  22.64s user 2.08s system 99% cpu 24.963 total
tail -n1  0.01s user 0.00s system 0% cpu 24.953 total

# same task with jsq

$ time jsq '.[].status.status-details' sample.json | head -n1
"done at 2017-12-09T00:38:13.860+03:00"
jsq '.[].status.status-details' sample.json  1.29s user 0.28s system 117% cpu 1.333 total
head -n1  0.00s user 0.00s system 0% cpu 0.779 total

$ time jsq '.[].status.status-details' sample.json | tail -n1
"done at 2017-12-09T00:37:59.498+03:00"
jsq '.[].status.status-details' sample.json  7.04s user 1.29s system 122% cpu 6.814 total
tail -n1  0.01s user 0.00s system 0% cpu 6.813 total
```
