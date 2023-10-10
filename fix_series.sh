#!/bin/bash
# shellcheck disable=2086
KE="kubectl exec -itq pod/komga-0 -n default -c komga -- "
$KE apt update
$KE apt install sqlite3
SQLITE="sqlite3 /config/database.sqlite"
$KE $SQLITE "select series_id,url,title from series_metadata, series where series.id=series_metadata.series_id;" | while read -r SERIES
do SERIES_ID=$(echo "$SERIES" | cut -f1 -d"|")
NAME=$(echo "$SERIES" | cut -f2 -d"|" | sed -e 's/^.*202/202/g' -e 's/%20/ /g' -e 's/\/$//g')
$KE $SQLITE "UPDATE series_metadata SET title_lock=1, title='${NAME}', title_sort='${NAME}' WHERE series_id='${SERIES_ID}'"
done
