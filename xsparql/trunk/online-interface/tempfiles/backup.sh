#!/bin/sh

if [ -a query* ]; then
    tar --remove-files -czf  files-`date +"%Y%m%d"`.tar.gz  query*;
fi
