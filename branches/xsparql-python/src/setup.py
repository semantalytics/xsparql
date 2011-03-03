#!/usr/bin/env python

try: # first try python's new setuptools
    from setuptools import setup #http://peak.telecommunity.com/DevCenter/PythonEggs
except ImportError: # otw. go with native distutils
    from distutils.core import setup

import sys
if sys.version < '2.3.0':
    print 'Only Python 2.3.0 and higher is supported.'
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


# generate parser at build time, and then use it in the package for distribution
try:
    import glob
    import os
    from stat import ST_MTIME
    if (len(glob.glob('./xsparql/parsetab.py')) == 0 or
	os.stat('./xsparql/parsetab.py')[ST_MTIME] < os.stat('./xsparql/grammar.py')[ST_MTIME]):
	import xsparql.grammar
	xsparql.grammar.generate_parser()
except Exception, e:
    print 'Something went wrong, bailing out:', e
    sys.exit(1)

setup(name='xsparql',
      version='0.1',
      description='XSPARQL Rewriter',
      long_description="""
An XSPARQL rewriter.
""",
      license='GNU Lesser General Public License',
      platforms='Any',
      author='Thomas Krennwallner',
      author_email='tkren@kr.tuwien.ac.at',
      url='http://www.polleres.net/xsparql/',
      packages=['xsparql'],
      scripts=['xsparqler.py'],
      install_requires = ["ply >= 2.3"]
#      include_package_data = True,
#      package_data = {'':['README'], 'examples':['examples']}
     )
