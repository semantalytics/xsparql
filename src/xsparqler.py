#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#
# xsparql -- XSPARQL Rewriter
#
# Copyright (C) 2007-2009  Nuno Lopes  <nuno.lopes@deri.org>
#                          Thomas Krennwallner  <tkren@kr.tuwien.ac.at>
#                          Waseem Akthar  <waseem.akthar@deri.org>
#                          Axel Polleres  <axel.polleres@deri.org>
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
import getopt

# our xsparql grammar
import xsparql.grammar
import xsparql.lowrewriter

def parse_params(argv):
    try:
        opts, args = getopt.gnu_getopt(argv[1:], 'hde:', ['help', 'debug', 'endpoint='])
    except getopt.GetoptError, err:
        sys.stderr.write(str(err) + "\n" + usage(argv[0]))
        sys.exit(2)

    # defaults
    xsparql.lowrewriter.sparql_endpoint = 'http://localhost:2020/sparql?query='

    for opt, arg in opts:
        if opt in ('-h','--help'):
            print usage(argv[0])
            sys.exit()
        elif opt in ('-e','--endpoint'):
            xsparql.lowrewriter.sparql_endpoint = arg + '?query='
        elif opt in ('-d','--debug'):
            xsparql.grammar.debugInfo = True
        else:
            assert False, "unhandled option"

    try:
        file = args[0]
    except Exception, err:
        sys.stderr.write("The queryfile must be specified\n" + usage(argv[0]))
        sys.exit(2)

    return file


# read the specified file, check if it exists! or from stdin
def read_query(file):

    if file == '-':
        s = ' '.join(sys.stdin.readlines())
    else:
        try:
            f = open( file, 'r' )
        except IOError:
            sys.stderr.write('Error: query file not found!\n')
            sys.exit(1)

        s = f.readlines()
        s = ' '.join(s)
        f.close()

    return s


def usage(script):
    return "Usage: " + script + " [OPTIONS] queryfile\n"

def main(argv=None):
    '''parse stdin and output the possibly rewritten XSPARQL query'''

    if argv is None:
	argv = sys.argv

    file = parse_params(argv)

    query = read_query(file)

    output = xsparql.grammar.rewrite(query)

    sys.stdout.write(output)

    return 0


if __name__ == "__main__":
    sys.exit(main())

