#!/bin/sh

FILES=`ls query* 2>/dev/null`

if [ $? -eq 0 ]; then
    tar --remove-files -czf  files-`date +"%Y%m%d"`.tar.gz  $FILES;
fi
