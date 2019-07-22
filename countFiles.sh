#!/bin/bash
#
# ls | grep ^....18\- | xargs -I '{}' mv -v '{}' 2018/
# find . -newermt 20180101 -not -newermt 20190101 -maxdepth 1 -type f -name '*.pdf' -exec mv -v {} 2018/ \;
#
find . ! -path . -maxdepth 1 -type d -print0 | while IFS= read -r -d '' i ; do
    echo -n $i": " ; 
    (find "$i" -type f | wc -l) ; 
done