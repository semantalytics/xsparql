#!/bin/bash


MKTEMP="mktemp -t tmp.XXXXXXXXXX"
TMPFILE=$($MKTEMP) # global temp. file for answer sets

failed=0
ntests=0

# XSPARQL=xsparqler.py
XSPARQL="python ../src/xsparqler.py"


function test_file () {
    RESULT=`dirname $1`/output/`basename $1`

    $XSPARQL $1 > $TMPFILE 2>/dev/null

    clear
    
    if ! diff -u $RESULT  $TMPFILE
    then
        exec 3<&1
        echo
        read -u 3 -p "Update the rewriting: $1 (y/n)? "
        if [ $REPLY = "y" ]; then
            cp $TMPFILE $RESULT
        fi


    fi
}


function test_files() {
    FILES=$(find . -mindepth 2 -iname \*.xsparql -o -iname \*.sparql -o -iname \*.xquery | egrep -v "(/output/|/tmp/)" );

    for FILE in $FILES
    do
	test_file $FILE
    done
}


# check if there is an argument from the command line
if [ $# -gt 0 ]; then
    for i in $*; do
	test_file $i;
    done
else
    test_files;
fi


# cleanup
rm -f $TMPFILE


exit 0
