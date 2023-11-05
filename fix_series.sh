#!/bin/bash
# shellcheck disable=2086
KE="kubectl exec -itq pod/komga-0 -n default -c komga -- "
if [ "$1" != "skip" ]; then
	$KE apt update
	$KE apt install sqlite3
fi
SQLITE="sqlite3 /config/database.sqlite"
rm /tmp/fix_comic.sh 2>/dev/null
$KE $SQLITE "select series_id,url,title from series_metadata, series where series.id=series_metadata.series_id;" | while read -r SERIES; do
	echo $SERIES
	SERIES_ID=$(echo "$SERIES" | cut -f1 -d"|")
	NAME=$(echo "$SERIES" | cut -f2 -d"|" | sed -e 's/^.*202/202/g' -e 's/%20/ /g' -e 's/\/$//g')
	CMD="UPDATE series_metadata SET title_lock=1, title='${NAME}', title_sort='${NAME}' WHERE series_id='${SERIES_ID}'"
	echo $KE $SQLITE \"$CMD\" >>/tmp/fix_comic.sh
done
sh /tmp/fix_comic.sh
