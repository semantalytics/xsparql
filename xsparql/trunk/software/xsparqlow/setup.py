#!/usr/bin/env python

from distutils.core import setup

import sys
if sys.version < '2.4.0':
    print 'Only Python 2.4.0 and higher is supported.'
    sys.exit(1)

try:
    import ply.lex
    import ply.yacc
    if ply.lex.__version__ < '2.3' or ply.yacc.__version__ < '2.3': raise ImportError
except ImportError:
    print '''Could not find Python Lex-Yacc (PLY) 2.3 or higher. Install it using your OS\'
package management system (debian/ubuntu: python-ply, macports: py-ply), or
download it from http://www.dabeaz.com/ply/.'''
    sys.exit(1)


setup(name='xsparqlow',
      version='0.1',
      description='XSPARQL Lowering',
      long_description="""
An XSPARQL Lowering rewriter.
""",
      license='GNU General Public License',
      platforms='Any',
      author='Thomas Krennwallner',
      author_email='tkren@kr.tuwien.ac.at',
      url='http://axel.deri.ie/xsparql/',
      packages=['xsparql', 'xsparql.low'],
      scripts=['xsparqlow.py']
     )
