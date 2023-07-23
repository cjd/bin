#!/bin/bash
# shellcheck disable=2034
kubectl scale --replicas=0 statefulset/komga
kubectl wait --for=delete pod/komga-0
sleep 5
SQLITE="sqlite3 /k8s/default/komga-config/database.sqlite"
$SQLITE "select series_id,url,title from series_metadata, series where series.id=series_metadata.series_id;" | while read -r SERIES
do SERIES_ID=$(echo "$SERIES" | cut -f1 -d"|")
URL=$(echo "$SERIES" | cut -f2 -d"|" | sed -e 's/^.*202/202/g' -e 's/%20/ /g' -e 's/\/$//g')
NAME=$(echo "$SERIES" | cut -f3 -d"|")
$SQLITE "UPDATE series_metadata SET title_lock=1, title='${URL}', title_sort='${URL}' WHERE series_id='${SERIES_ID}'"
done
kubectl scale --replicas=1 statefulset/komga
