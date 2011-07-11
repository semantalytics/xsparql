#!/bin/sh

if [ -z "$M2_HOME" ] ; then
  XSPARQLHOME="."
fi

CLASSPATH="$XSPARQLHOME/libs/*"
OPTS=

java $OPTS -cp "$CLASSPATH" org.deri.xsparql.Main "$@"
