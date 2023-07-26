#!/bin/bash
# shellcheck disable=2001,2154,2016,2028
BASEDIR=/tmp/beet.tmp.$$
mkdir $BASEDIR

beet ls -f '$genre:$path' > ${BASEDIR}/current.csv
if [ -z "$1" ]; then
	cp ${BASEDIR}/current.csv ${BASEDIR}/newsongs.csv
else
	cp "$1" ${BASEDIR}/newsongs.csv
fi
pushd $BASEDIR || exit
IFS=$'\n'
while read -r G; do
	OLD=$(echo "$G" | sed -e 's/:[^:]*$//' -e 's/\//\\\//g')
	NEW=$(echo "$G" | sed -e 's/^.*://' -e 's/\//\\\//g')
	if [ "$OLD" != "$NEW" ]; then
		echo "$OLD -> $NEW"
    {
		echo "s/^${OLD}, \(.*:\)/${NEW}, \1/g"
		echo "s/ ${OLD}, \(.*:\)/ ${NEW}, \1/g"
		echo "s/^${OLD}:/${NEW}:/"
		echo "s/ ${OLD}:/ ${NEW}:/"
  } >> newgenre.sed
	fi
done < ~/Sync/Config/music/genreupdate.csv
sed --in-place -f newgenre.sed newsongs.csv
sed --in-place -f ~/Sync/Config/music/add_genres.sed newsongs.csv
sed --in-place -e 's/^, //' -e 's/, , /, /g' -e 's/, :/:/' newsongs.csv
rm newgenre.sed

# Separate which ones actually changed
diff newsongs.csv current.csv | grep "^<" | sed -e 's/^< //g' >diffsongs.csv
echo Remove dup genres
while read -r S; do
	GENRES=$(echo "$S" | cut -f1 -d:)
	SONG=$(echo "$S" | cut -f2 -d:)
	NEWG=$(echo -n "${GENRES}" | tr , '\n' | awk '{$1=$1;print}' | sort -u | sed -z 's/\n/, /g;s/, $//')
	echo "${NEWG}:${SONG}"
done <diffsongs.csv >tochange.csv

diff tochange.csv current.csv | grep "^<" | sed -e 's/^< //g' >diffsongs.csv
while read -r SONG; do
	G=$(echo "$SONG" | sed -e 's/:\/tank.*$//')
	S=$(echo "$SONG" | sed -e 's/^.*:\/tank/\/tank/')
	echo beet modify -Mwy "path:$S" "genre=$G"
	beet modify -Mwy "path:$S" "genre=$G"
done <diffsongs.csv
rm tochange.csv
rm diffsongs.csv
rm newsongs.csv
rm current.csv
popd || exit
