#!/bin/bash
SYNC_DIR=~/Sync/Music-For-Car
rm -rf "${SYNC_DIR}"
curl -X 'GET' -H 'accept: application/json' -H 'Authorization: Mediabrowser Token="4e3113b18856438aa4c776a7149161fc"' 'https://media.adebenham.com/Playlists/6d6d31149355af0a06a684207a1779f2/Items?EnableImages=false&UserId=a518e04f58724d04a36c2e599ce625e2&Fields=Path' > /tmp/playlist.json
for ROW in $( jq -r '.Items[] | {Name: .Name, Path: .Path} | @base64' < /tmp/playlist.json )
do DATA=$(echo "$ROW" | base64 --decode)
  FILE="$(echo "$DATA" | jq '.Path' | sed -e 's/^\"//' -e 's/\"$//')"
  SONG="$(echo "$DATA" | jq '.Name' | sed -e 's/^\"//' -e 's/\"$//' -e 's/[:;\?“”]/_/g')"
  DIR=$(dirname "$FILE" | sed -e 's/^.*export\/Music\///' -e 's/\// - /g')
  SRC="$(echo "$FILE" | sed -e 's/\/export\//\/tank\//g')"
  mkdir -p "${SYNC_DIR}/${DIR}" 2>/dev/null
  ln -s "$SRC" "${SYNC_DIR}/${DIR}/${SONG}.mp3" 2>/dev/null
done

echo rsync -rLvP --delete-after --size-only ~/Sync/Music-For-Car/ /mnt/
