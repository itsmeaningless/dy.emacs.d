#!/bin/bash -e


olddir=`pwd`


do_one=1


for i in `find ./ -name .git`; 
do
    do_one=2
    cd `dirname $i`
    mv .git xx.gitxx
    cd $olddir
done


if [ $do_one -eq 1 ]; then 

for i in `find ./ -name xx.gitxx`; 
do
    cd `dirname $i`
    mv xx.gitxx .git
    cd $olddir
done

fi
