#!/bin/sh

#sudo apt-get install -y moreutils git-buildpackage
GIT_PATH=$1
DEB_PATH=`pwd`
CL_PATH="$DEB_PATH/debian/changelog"
cd "$GIT_PATH"
prevtag="2016.1"
pkgname=`cat "$DEB_PATH/debian/control" | grep '^Package: ' | sed 's/^Package: //'`
git tag -l 2*.* | sort -V | while read tag; do
    (echo "$pkgname (${tag#v}) unstable; urgency=low\n"; git log --pretty=format:'  * (%an) %s' $prevtag..$tag; git log --pretty='format:%n%n -- Chris Debenham <chris@adebenham.com>  %aD%n%n' $tag^..$tag) | cat - "$CL_PATH" | sponge "$CL_PATH"
        prevtag=$tag
done

sed -i 's/UNRELEASED/unstable/' "$CL_PATH"
