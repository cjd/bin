#!/bin/bash
if [ -z "$1" ]; then echo "usage: myocr.sh <pdf filename>";exit;fi

INFILE="$1"
TMPDIR=/tmp/scandoc-$$
mkdir $TMPDIR
cp "$INFILE" $TMPDIR
pushd $TMPDIR
pdfimages -j "$INFILE" out
for F in out-*; do
    #convert "$F" -threshold 50% threshold-$F.pbm
    tesseract --tessdata-dir /usr/share/tesseract-ocr/tessdata -l eng $F $F pdf
    #tesseract -l eng threshold-$F.pbm $F pdf
    #grep -v "^<?xml" $F.hocr | hocr2pdf -r 300 -i $F -s -o $F.pdf
done

#gs -dCompatibilityLevel=1.4 -dNOPAUSE -dQUIET -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=searchable.pdf out-*.pdf 
pdfjoin --a4paper --fitpaper 'false' out-*pdf
mv out*joined.pdf searchable.pdf
DATE="`echo $INFILE | cut -f1 -d_ | sed -e 's/-/:/g'` 00:00:00"
TITLE=`echo $INFILE | sed -e 's/^[0-9-]*_//g' -e 's/_/ /g' -e 's/.pdf$//g'`
exiftool -CreateDate="$DATE" -ModifyDate="$DATE" -Title="$TITLE" -overwrite_original searchable.pdf
popd
cp "$INFILE" "original-$INFILE"
cp "$TMPDIR/searchable.pdf" "$INFILE"
echo $TMPDIR
