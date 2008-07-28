#!/bin/bash

MKTEMP="mktemp -t tmp.XXXXXXXXXX"
TMPFILE=$($MKTEMP) # global temp. file for answer sets

failed=0
ntests=0

XSPARQL=xsparqler.py

echo ============ XSPARQL tests start ============


for t in $(find . -name '*.test' -type f)
do
    while read QUERY
    do
	RESULT=`dirname $QUERY`/output/`basename $QUERY`

	let ntests++

	if [ ! -f $QUERY ] || [ ! -f $RESULT ]; then
	    test ! -f $QUERY && echo WARN: Could not find query file $QUERY
	    test ! -f $RESULT && echo WARN: Could not find result file $RESULT
	    continue
	fi

	$XSPARQL  <  $QUERY > $TMPFILE

#	if [ $? -eq 0 ] && cmp -s $TMPFILE $RESULT
	if [ $? -eq 0 ] && diff -q --ignore-all-space $TMPFILE $RESULT &> /dev/null
	then
	    echo PASS: $QUERY
	else
	    echo "FAIL: $QUERY"
	    let failed++
	fi

    done < `basename $t` # redirect test file to the while loop
done

# cleanup
rm -f $TMPFILE

echo ========== XSPARQL tests completed ==========

echo Tested $ntests queries
echo $failed failed

echo ============= XSPARQL tests end =============

exit $failed
