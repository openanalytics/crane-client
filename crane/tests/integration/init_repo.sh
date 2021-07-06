#!/bin/sh

mkdir -p repo/test/src/contrib/

R CMD build foo
mv foo_* repo/test/src/contrib/

gzip -k repo/test/src/contrib/PACKAGES
