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

CLASSPATH="$CLASSPATH:$XSPARQLHOME/cli/target/cli-0.5-bin/libs/*"
OPTS=

XSPARQL="java $OPTS -cp $CLASSPATH org.deri.xsparql.Main $@" 
XSPARQL="java $OPTS -cp $CLASSPATH org.deri.xsparql.Main -dbConfig mysql.properties -dbName xsparql $@" 

EXAMPLESDIR=evaluator/src/test/resources/examples/

export JENAROOT=/Users/nl/work/deri/sw/Jena-2.6.4/
RDFPARSE="$JENAROOT/bin/rdfcat -out N3 -n3 " 
# RDFPARSE="rapper -i guess -cq -I \"http://ex.org/tt\""

XMLLINT="xmllint --noout"

echo ============ XSPARQL tests start ============

function validate () {

    # try to validate as XML
    echo "<?xml version=\"1.0\" encoding=\"iso-8859-1\"?> " > $TMPFILE.xml
    cat $1 >> $TMPFILE.xml
    # cat $TMPFILE.xml
    $XMLLINT $TMPFILE.xml &> /dev/null
    XML=$?
    # echo "XML: $XML"
    if [ $XML -eq 0 ] ; then
        return 0;
    fi

    rm $TMPFILE.xml
    

    # try to validate as RDF
    sed 's/&gt;/>/g' < $1 >$TMPFILE.2
    sed 's/&lt;/</g' < $TMPFILE.2 >$1.ttl
#    cat $TMPFILE.ttl
    $RDFPARSE $TMPFILE.ttl &> /dev/null
    RDF=$?
    # echo "RDF: $RDF"
    rm $TMPFILE.ttl $TMPFILE.2
    if [ $RDF -eq 0 ] ; then
        return 0;
    fi
    
    return 1;
}


function test_file () {
    RESULT=`dirname $1`/output/`basename $1`

    let ntests++

    if [ $EXEC ]; then
        $XSPARQL $1 -e &> $TMPFILE
    else
        $XSPARQL $1 > $TMPFILE
    fi

    validate $TMPFILE
    VAL=$?

    if [ $? -eq 0 ] && [ $VAL -eq 0 ] #&& cmp -s $TMPFILE $RESULT
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

