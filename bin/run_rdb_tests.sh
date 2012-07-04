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



# XSPARQL config
if [ -z $XSPARQLHOME ]; then
    XSPARQLHOME=`pwd`
fi
export JENAROOT=/Users/nl/work/deri/sw/Jena-2.6.4/
RDFCOMP=$JENAROOT/bin/rdfcompare

CLASSPATH="$CLASSPATH:$XSPARQLHOME/cli/target/cli-0.4-SNAPSHOT-bin/libs/*"
OPTS="-Dfile.encoding=UTF-8"



EXAMPLESDIR=rdb2rdf/rdb2rdf-tests/
PSQL="psql"
MYSQL="mysql"


function usage() {
    echo "USAGE: $0 [-mysql|-psql]";
    exit 1;
}


function read_config () {
# read configuration from properties file
    MKTEMP="mktemp -t tmp.XXXXXXXXXX"
    TEMPFILE=$($MKTEMP)
    cat $XSPARQLHOME/$DBCONFIG |\
sed -e 's/"/"/'g|sed -e 's/=\(.*\)/="\1"/g'>$TEMPFILE
    source $TEMPFILE
    rm -f $TEMPFILE

    dbName=rdb2rdf_tests
}


# ============== command line processing

GREP="."
XSPARQLOPTS=""

# check if there is an argument from the command line
if [ $# -gt 0 ]; then
    if [ $1 == '-mysql' ]; then
        DBCONFIG=mysql.properties
        read_config 
        DB="$MYSQL -u $dbUser"
        if [ "${dbPasswd-x}" != "x" ] ; then
            DB="$DB -p$dbPasswd"
        fi
        DEFAULTDB=mysql
        XSPARQLOPTS="-mysql"
    fi
    if [ $1 == '-psql' ]; then
        DBCONFIG=psql.properties
        read_config
        DB="$PSQL -U $dbUser"
        DEFAULTDB=postgres
        XSPARQLOPTS="-psql"
    fi

    shift 1

    if [ -n $1 ]; then
        GREP="$1"
        shift 1
    fi
else
    usage
fi


XSPARQL="java $OPTS -cp $CLASSPATH org.deri.xsparql.Main "
XSPARQLRDB="$XSPARQL -dbConfig $XSPARQLHOME/$DBCONFIG $XSPARQLOPTS" 
#XSPARQL="java $OPTS -cp $CLASSPATH org.deri.xsparql.Main $1 -dbUser $dbUser -dbPassword $@" 


MKTEMP="mktemp -t tmp.XXXXXXXXXX"
TMPFILE=$($MKTEMP)

failed=0
ntests=0


function compare_quad() {
    MAP=$1

    cat $TMPFILE | sed 's/@prefix .*//g' | sed 's/@base .*//g' | \
        sed 's/^ //g' | \
        sed 's/rdf:type/\<http:\/\/www.w3.org\/1999\/02\/22-rdf-syntax-ns#type\>/g' | \
        sort -b | \
        sed '/^$/d' > $TMPFILE.1
    mv $TMPFILE.1 $TMPFILE

    cat $MAP      | sed 's/@prefix .*//g' | sed 's/@base .*//g' | sed 's/^ //g' | sort -b | sed '/^$/d' > $TMPFILE.2
#    | sed 's/.$//g'

    dos2unix $TMPFILE.2 &>/dev/null

    diff -Bbwq $TMPFILE $TMPFILE.2 &> /dev/null
    RES=$?

    rm -f $TMPFILE.1 $TMPFILE.2

    return $RES;
}



function compare_result() {

    # function arguments
    RES=$1
    MAP=$2/$3

    QUAD_STRING=""

    # compare the datasets
    # echo $RDFCOMP $TMPFILE $MAP N3 N3 
    $RDFCOMP $TMPFILE $MAP N3 N3 &> /dev/null
    COMP=$?

    # negative test: no result expected
    if [ -z $3 ] ; then
        if [ $COMP -ne 0 ]  &> /dev/null
        then 
	    echo -e " PASS (negative test)"
        else
	    echo -e " FAIL (negative test)"
	    let failed++
        fi
    else
        # positive
        QUAD=1
        if [ $COMP -eq 255 ]; 
        then
            QUAD_STRING=" (NQUAD)"
	    compare_quad $MAP
            QUAD=$?
        fi

        if [ $RES -eq 0 ] && ([ $COMP -eq 0 ] || [ $QUAD -eq 0 ])  &> /dev/null
        then
	    echo -e " PASS$QUAD_STRING"
        else
            
            # if [ $COMP -eq 255 ]; 
            # then
	    #     echo -e " NQUAD"
            # else
	        echo -e " FAIL$QUAD_STRING"
	        let failed++
            # fi
            
            echo -e ">>>> $MAP"
            cat $MAP
            echo "<<<<"
            echo ">>>> XSPARQL"
            cat $TMPFILE
            echo -e "<<<<\n\n\n"
            
        fi

    fi
}


function test_r2rml() {
    
    $XSPARQL <<EOF > $TMPFILE
prefix rdb2rdftest: <http://purl.org/NET/rdb2rdf-test#> 
prefix dcterms: <http://purl.org/dc/elements/1.1/> 

let \$res := <res>{
for * from <file:$1>
where { \$a a rdb2rdftest:R2RML;	
            dcterms:identifier \$id; 
            rdb2rdftest:mappingDocument \$map .
        optional { \$a rdb2rdftest:output \$output }
}
order by \$map
return <row><output>{fn:concat("""", \$output, """")}</output><ident>{fn:concat("""", \$id, """")}</ident><map>{fn:concat("""", \$map, """")}</map></row>
}</res>
return 
 fn:concat("local OUTPUTS=(",fn:string-join(\$res//output, " "), ")&#xA;
local IDENTS=(", fn:string-join(\$res//ident, " "), ")&#xA;
local MAPS=(", fn:string-join(\$res//map, " "),")&#xA;")
EOF
    source $TMPFILE

    SIZE=${#MAPS[@]}
    for (( i=0; i<$SIZE; i++ )); do
        local MAP=${MAPS[$i]};
        local IDENT=${IDENTS[$i]};
        local OUTPUT=${OUTPUTS[$i]};

        echo -ne "        $IDENT: `dirname $1`/$MAP .... "
        let ntests++
#        $XSPARQLRDB -dbName $dbName  evaluator/src/main/resources/rdb2rdf/r2rml.xsparql r2rml_mapping=file:`dirname $1`/$MAP > $TMPFILE 
#        echo $XSPARQLRDB -dbName $dbName -r2rml `dirname $1`/$MAP 
        $XSPARQLRDB -dbName $dbName -r2rml `dirname $1`/$MAP > $TMPFILE 2>/dev/null
        RES=$?
        
        sed 's/&gt;/>/g' < $TMPFILE >$TMPFILE.2
        sed 's/&lt;/</g' < $TMPFILE.2 >$TMPFILE
        rm $TMPFILE.2

        # copy file to the final directory
        if [ $OUTPUT ] ; then
            cat $TMPFILE | sed 's/@prefix .*//g' | sed 's/^ //g' > `dirname $1`/${OUTPUT/.nq/}-XSPARQL.nq
        # cp $TMPFILE `dirname $1`/${OUTPUT/.nq/}-XSPARQL.nq
        fi

        compare_result $RES `dirname $1` $OUTPUT

    done


}


function test_direct_mapping() {
    
    # check direct mapping
    $XSPARQL <<EOF > $TMPFILE
prefix rdb2rdftest: <http://purl.org/NET/rdb2rdf-test#> 
prefix dcterms: <http://purl.org/dc/elements/1.1/> 

for * from <file:$1>
where {\$a a rdb2rdftest:DirectMapping;	rdb2rdftest:output \$output; dcterms:identifier \$id}
return fn:concat("local OUTPUT=""",fn:data(\$output), """&#xA;local IDENT=""", \$id,"""&#xA;")
EOF
    source $TMPFILE

    if [ -z "$IDENT" ]; then
        return 0;
    fi

    echo -en "        $IDENT ... "
    let ntests++
#    $XSPARQLRDB -dbName $dbName evaluator/src/main/resources/rdb2rdf/dm.xsparql baseURI=""  > $TMPFILE
    $XSPARQLRDB -dbName $dbName -dm "http://example.com/base/" > $TMPFILE 2>/dev/null
    RES=$?

    sed 's/&gt;/>/g' < $TMPFILE >$TMPFILE.2
    sed 's/&lt;/</g' < $TMPFILE.2 >$TMPFILE
    rm $TMPFILE.2

    # copy file to the final directory
    if [ $OUTPUT ] ; then
        cat $TMPFILE | sed 's/@prefix .*//g'| sed 's/^ //g'  > `dirname $1`/directGraph-XSPARQL.ttl
    # cp $TMPFILE `dirname $1`/directGraph-XSPARQL.ttl
    fi

    compare_result $RES `dirname $1` $OUTPUT
  
}



function test_file () {
    # create the database
    $DB $DEFAULTDB <<EOF &> /dev/null
DROP DATABASE IF EXISTS $dbName ;
CREATE DATABASE $dbName;
EOF

    # read SQL script file
    SQL=$($XSPARQL <<EOF 
prefix rdb2rdftest: <http://purl.org/NET/rdb2rdf-test#> 

for * from <file:$1>
where {\$a rdb2rdftest:sqlScriptFile \$c}
return fn:data(\$c)
EOF
)
    if [ -z "$SQL" ]; then
        return 0;
    fi
    
    if [ -a `dirname $1`/"${SQL/.sql/-$DEFAULTDB.sql}" ]; then
        # echo "$DB $dbName < `dirname $1`/${SQL/.sql/-$DEFAULTDB.sql}"
        $DB $dbName < `dirname $1`/"${SQL/.sql/-$DEFAULTDB.sql}" &> /dev/null
    else
    # create database contents from SQL script file
        $DB $dbName < `dirname $1`/$SQL &> /dev/null
    fi

    echo "  => Direct Mapping"
    test_direct_mapping $1

    echo "  => R2RML"
    test_r2rml $1

    
    # delete the database
    $DB $DEFAULTDB <<EOF &> /dev/null
DROP DATABASE $dbName;
EOF
}


function test_files() {
#    FILES=$(find $EXAMPLESDIR -iname manifest.ttl );
    # D016 - BINARY data
    # D017 - i18n characters
    # FILES=$(find $EXAMPLESDIR -iname manifest.ttl | grep -e  "$GREP" | egrep -v "(D016|D017)"  );
    FILES=$(find $EXAMPLESDIR -iname manifest.ttl | grep  "$GREP" );
    for FILE in $FILES
    do
	echo -e "\n===> Manifest: $FILE"
	test_file $FILE
    done
}


# test manifest files
test_files


# cleanup
rm -f $TMPFILE

echo ========== XSPARQL tests completed ==========

echo Tested $ntests queries
echo $failed failed

echo =============================================
#echo ============= XSPARQL tests end =============

exit $failed

