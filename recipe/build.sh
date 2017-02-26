#!/bin/bash

# aeon setup.py script is a relic (uses distutils but not setuptools).
# So these do not work (or am I missing something?):
#   As recommended by conda-forge doc: --single-version-externally-managed --record record.txt
#   HAS_GPU=1 pip install --no-deps .
# Therefore we will get the unwanted egg-info file in the package
# Probably we want to manually remove it... see later
HAS_GPU=1 python setup.py install

# Test
# (not easy to do in the test provision of the recipe as, at that time,
# $SRC_DIR does not point anymore to anything valid)
py.test

# Do not really care about loader
#cd $SRC_DIR/loader
#make clean
#make test

# Remove cruft
rm -f ${SP_DIR}/nervana_aeon*.egg-info
rm -Rf ${SP_DIR}/py
rm -Rf ${SP_DIR}/pytest_cov
