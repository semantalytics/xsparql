#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#
# xsparqlow -- XSPARQL Lowering Rewriter
#
# Copyright (C) 2007  Thomas Krennwallner  <tkren@kr.tuwien.ac.at>
#
# This file is part of xsparqlow.
#
# xsparqlow is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# xsparqlow is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with xsparqlow.  If not, see <http://www.gnu.org/licenses/>.
#
#


import sys
import re

# our xsparql rewriter
import xsparqlow


def main(argv=None):
    '''parse stdin and output the possibly rewritten XSPARQL query'''

    if argv is None:
        argv = sys.argv

    s = ' '.join(sys.stdin.readlines())

    #
    # search for all the DECLARE NAMESPACE directives and build a list
    # of mappings using re's grouping pattern
    #
    
    re_namespace = re.compile(r'declare\s+namespace\s+(\w+)\s*=\s*\"([^\"]*)\"\s*;',
                              re.IGNORECASE)

    xsparqlow.rewriter.namespaces = re_namespace.findall(s)

    #
    # and now, scan the input for XSPARQL expresssions, and replace
    # them using our rewriting rules; everything else is passed
    # through
    #

    # regexp for FOR and RETURN
    re_for = re.compile(r'\s?FOR\s', re.IGNORECASE)
    re_return = re.compile(r'\sRETURN[ \t\n\{]', re.IGNORECASE)

    # always declare the sparql namespace
    sys.stdout.write('declare namespace sparql = "http://www.w3.org/2005/sparql-results#";\n')

    i = m = n = 0

    while i < len(s):

        # search for FOR
        for_match = re_for.search(s[i:])

        if for_match:

            # set start position of FOR
            m = i + for_match.start()
            # output preceding string
            sys.stdout.write(s[i:m])

            # search for RETURN
            return_match = re_return.search(s[m:])

            if return_match:

                # set start positition of RETURN
                n = m + return_match.start()
                # and now parse our expression
                sys.stdout.write(xsparqlow.grammar.rewrite(s[m:n]))
                # restart with new start position
                i = n

            else:

                # no RETURN found: just output trailing part and quit
                sys.stdout.write(s[m:])
                i = len(s)
 
        else:

            # no FOR found: just output trailing part and quit
            sys.stdout.write(s[i:])
            i = len(s)

    return 0


if __name__ == "__main__":
    sys.exit(main())



