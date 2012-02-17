#!/bin/bash
#
#
# Copyright (C) 2011, NUI Galway.
# All rights reserved.
#
# The software in this package is published under the terms of the BSD style license a copy of which has been included
# with this distribution in the bsb_license.txt file and/or available on NUI Galway Server at
# http://xsparql.deri.ie/license/bsd_license.txt
#
# Created: 09 February 2011, Reasoning and Querying Unit (URQ), Digital Enterprise Research Institute (DERI) on behalf of
# NUI Galway.
#


MKTEMP="mktemp -t tmp.XXXXXXXXXX"
TMPFILE=$($MKTEMP)

failed=0
ntests=0


if [ -z $XSPARQLHOME ]; then
    XSPARQLHOME=`pwd`
fi

CLASSPATH="$CLASSPATH:$XSPARQLHOME/cli/target/cli-0.3-SNAPSHOT-bin/libs/*"
OPTS=

XSPARQL="java $OPTS -cp $CLASSPATH org.deri.xsparql.Main $@" 
XSPARQL="java $OPTS -cp $CLASSPATH org.deri.xsparql.Main -dbConfig psql.properties -dbName xsparql $@" 

EXAMPLESDIR=evaluator/src/test/resources/examples/

echo ============ XSPARQL tests start ============


function test_file () {
    RESULT=`dirname $1`/output/`basename $1`

    let ntests++

    if [ $EXEC ]; then
        $XSPARQL $1 -e &> /dev/null
    else
        $XSPARQL $1 > $TMPFILE
    fi

    if [ $? -eq 0 ] #&& cmp -s $TMPFILE $RESULT
    then
	echo PASS: $1
    else
	echo "FAIL: $1"
	let failed++
    fi
}


function test_files() {
    FILES=$(find $EXAMPLESDIR -iname \*.xsparql -o -iname \*.sparql -o -iname \*.xquery | egrep -v "(/output/|/dblp/|/tmp/)" );

    for FILE in $FILES
    do
	test_file $FILE
    done
}


# check if there is an argument from the command line
if [ $# -gt 0 ]; then
    if [ $1 == '-e' ]; then
        EXEC=true;
        test_files
    else
        for i in $*; do
	    test_file $i;
        done
    fi
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

