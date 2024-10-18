#!/bin/bash

PROJECT_DIR=code
REPORT_FILE=rapport.pdf
PROJECT_FILE=src_tb/min_max_top_tb.sv
ARCHIVE=rendu.tar.gz

if [ ! -d "$PROJECT_DIR" ]
then
    echo "Could not find $PROJECT_DIR directory in $(pwd)" >&2
    exit 1
fi

if [ ! -f "$REPORT_FILE" ]
then
    echo "Could not find $REPORT_FILE directory in $(pwd)" >&2
    exit 1
fi

if [ ! -f "$PROJECT_DIR/$PROJECT_FILE" ]
then
    echo "Could not find project file : $PROJECT_FILE in $(realpath $PROJECT_DIR)" >&2
    exit 1
fi

echo "The following files are archived in $ARCHIVE : "
tar --exclude='rendu.tar.gz' --exclude='comp' -czvf $ARCHIVE $PROJECT_DIR $REPORT_FILE
