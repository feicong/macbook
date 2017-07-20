#!/bin/sh

currdir=$(pwd)

for f in $(find $currdir -name *.xcodeproj)
do {
    dir=$(dirname $f)
    appname=$(basename $dir)
    appname=${appname%.*}
    echo building $appname...
    cd $dir && xcodebuild 1>/dev/null && cd $currdir
    echo build $appname done.
}
done