#!/usr/bin/env python

from distutils.core import setup

import sys
if sys.version < '2.4.0':
    print 'Only Python 2.4.0 and higher is supported.'
    sys.exit(1)

try:
    import ply.lex
    import ply.yacc
except ImportError:
    print '''Could not find PLY (Python Lex-Yacc). Install it using your OS\'
package management system (debian/ubuntu: python-ply, macports:
py-ply), or download it from http://www.dabeaz.com/ply/.'''
    sys.exit(1)


setup(name='xsparqlow',
      version='0.1',
      description='XSPARQL Lowering',
      license='GNU General Public License '
      author='Thomas Krennwallner',
      author_email='tkren@kr.tuwien.ac.at',
      url='http://axel.deri.ie/xsparql/',
      description = 'XSPARQL Lowering Rewriter',
      package_dir={'xsparqlow': ''},
      py_modules=['xsparqlow.grammar', 'xsparqlow.rewriter'],
      scripts=['xsparqlow.py']
     )
