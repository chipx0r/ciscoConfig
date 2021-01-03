#!/bin/bash
#
# ls | grep ^....20\- | xargs -I '{}' mv -v '{}' 2020/
# find . -newermt 20200101 -not -newermt 20210101 -maxdepth 1 -type f \( -name '*.xml' -o -name '*.pdf' \) -exec mv -v {} 2020/ \;
#
find . ! -path . -maxdepth 1 -type d -print0 | while IFS= read -r -d '' i ; do
    echo -n $i": " ; 
    (find "$i" -type f | wc -l) ; 
done
