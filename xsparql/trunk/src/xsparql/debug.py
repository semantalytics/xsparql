# -*- coding: utf-8 -*-
#
# xsparql -- XSPARQL Rewriter
#
# Copyright (C) 2007, 2008  Thomas Krennwallner  <tkren@kr.tuwien.ac.at>
#               2007, 2008  Waseem Akhtar  <waseem.akhtar@deri.org>
#               2007, 2008  Nuno Lopes  <nuno.lopes@deri.org>
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

show_debug_info = False

def debug(*debug):
    global show_debug_info
    if ( not show_debug_info ):
	return
    i = 1
    for d in debug:
	print >> sys.stderr, i, ":", d #.replace('\n', '\n'+`i`)
	i = i + 1
    print >> sys.stderr, '---'
    return