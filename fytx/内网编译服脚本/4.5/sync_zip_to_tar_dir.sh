#!/bin/sh

ver="$1"
tar_dir="/home/sanguo/package_backup/${ver}"
source_dir="/home/sanguo/build_ex/${ver}"
echo "====== tar_dir:${tar_dir}"
echo "====== source_dir:${source_dir}"

if [[ ! -d ${tar_dir}/zip ]]; then
	mkdir -p ${tar_dir}/zip
fi

EXCODE=$?
if [ "$EXCODE" != "0" ]; then
	exit 1
fi

#echo "rm -rf ${tar_dir}/zip/*"
rm -rf ${tar_dir}/zip/*

EXCODE=$?
if [ "$EXCODE" != "0" ]; then
        exit 1
fi

#echo "cp -rf ${source_dir}/zip/* ${tar_dir}/zip/"
cp -rf ${source_dir}/zip/* ${tar_dir}/zip/

EXCODE=$?
if [ "$EXCODE" != "0" ]; then
        exit 1
fi

exit 0
