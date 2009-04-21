#!/bin/bash


MKTEMP="mktemp -t tmp.XXXXXXXXXX"
TMPFILE=$($MKTEMP) # global temp. file for answer sets

failed=0
ntests=0

# XSPARQL=xsparqler.py
XSPARQL="python ../src/xsparqler.py"

echo ============ XSPARQL tests start ============


function test_file () {
    RESULT=`dirname $1`/output/`basename $1`

    let ntests++

    if [ ! -f $1 ] || [ ! -f $RESULT ]; then
	test ! -f $1 && echo WARN: Could not find query file $1
	test ! -f $RESULT && echo WARN: Could not find result file $RESULT
	continue
    fi

    $XSPARQL $1 > $TMPFILE

    if [ $? -eq 0 ] && cmp -s $TMPFILE $RESULT
    then
	echo PASS: $1
    else
	echo "FAIL: $1"
	let failed++
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

echo ========== XSPARQL tests completed ==========

echo Tested $ntests queries
echo $failed failed

echo ============= XSPARQL tests end =============

exit $failed
