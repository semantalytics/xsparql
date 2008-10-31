#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#
# xsparql -- XSPARQL Rewriter
#
# Copyright (C) 2007,2008  Thomas Krennwallner  <tkren@kr.tuwien.ac.at>
#               2007,2008  Waseem Akthar  <waseem.akthar@deri.org>
#
# This file is part of xsparql.
#
# xsparql is free software: you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# xsparql is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with xsparql. If not, see
# <http://www.gnu.org/licenses/>.
#
#


import sys

# our xsparql grammar
import xsparql.grammar
import xsparql.lowrewriter


def usage(script):
    return "usage: " + script + " [OPTIONS] queryfile\n"

def main(argv=None):
    '''parse stdin and output the possibly rewritten XSPARQL query'''

    if argv is None:
	argv = sys.argv

    file = ''
    i = 1
    while i < len(argv) :
        if argv[i] == "--endpoint":
            xsparql.lowrewriter.sparql_endpoint = argv[i+1]
            i+= 1
        else:
            file = argv[i]

        i+= 1
    

    if file == '':
        sys.stderr.write(usage(argv[0]))
        sys.exit(1)


    f = open( file, 'r' )

    s = f.readlines()
    s = ' '.join(s)
    f.close()
#    s = ' '.join(sys.stdin.readlines())

    output = xsparql.grammar.rewrite(s)

    sys.stdout.write(output)

    return 0


if __name__ == "__main__":
    sys.exit(main())

