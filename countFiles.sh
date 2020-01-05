#!/bin/bash
#
# ls | grep ^....19\- | xargs -I '{}' mv -v '{}' 2019/
# find . -newermt 20190101 -not -newermt 20200101 -maxdepth 1 -type f \( -name '*.xml' -o -name '*.pdf' \) -exec mv -v {} 2019/ \;
#
find . ! -path . -maxdepth 1 -type d -print0 | while IFS= read -r -d '' i ; do
    echo -n $i": " ; 
    (find "$i" -type f | wc -l) ; 
done
