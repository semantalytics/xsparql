#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#
# xsparqler -- XSPARQL Rewriter
#
# Copyright (C) 2007  Thomas Krennwallner  <tkren@kr.tuwien.ac.at>
#
# This file is part of xsparql.
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

# our xsparql grammar
import xsparql.grammar


def main(argv=None):
    '''parse stdin and output the possibly rewritten XSPARQL query'''

    if argv is None:
        argv = sys.argv

    s = ' '.join(sys.stdin.readlines())

    output = xsparql.grammar.rewrite(s)

    sys.stdout.write(output)

    return 0


if __name__ == "__main__":
    sys.exit(main())



