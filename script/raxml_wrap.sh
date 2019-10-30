#!/bin/bash
DIR=$1
TREE=$2
PARTITIONS=$3
INFILES=$(ls "$DIR"/*.phy.gz)
for INFILE in $INFILES; do
  raxml_wrap.pl -m "$INFILE" -t "$TREE" -p "$PARTITIONS"
  rm $PARTITIONS.reduced
done