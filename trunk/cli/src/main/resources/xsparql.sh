#!/bin/sh
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

THISSCRIPT=`dirname $0`

if [ -z "$XSPARQLHOME" ] ; then
  XSPARQLHOME=$THISSCRIPT/..
fi

CLASSPATH="$XSPARQLHOME/libs/*"
OPTS=

java $OPTS -cp "$CLASSPATH" org.deri.xsparql.Main "$@"
