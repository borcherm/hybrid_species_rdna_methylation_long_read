#!/bin/bash

OTHER_READS=$1
BASE_DIR=$2
POS=$3
ALT=$4
REF=$5

cd $OTHER_READS
ls *bam | while read FILE
  do
    FILEBASE=$(basename $FILE | cut -d "." -f 1 -)
    NUC=$(samtools mpileup -Q 0 $FILE | grep -w $POS | cut -f 5)
    echo $NUC
    echo $ALT
    echo $REF
    echo $FILEBASE
    REFL=$(echo $REF | tr '[:upper:]' '[:lower:]')
    ALTL=$(echo $ALT | tr '[:upper:]' '[:lower:]')
    if [[ $NUC == $ALT ]]; then
      mv $FILEBASE.bam ../alt
      mv $FILEBASE.bam.bai ../alt
      mv $FILEBASE.fa ../alt
    elif [[ $NUC == $ALTL ]]; then
      mv $FILEBASE.bam ../alt
      mv $FILEBASE.bam.bai ../alt
      mv $FILEBASE.fa ../alt
    elif [[ $NUC == $REF ]]; then
      mv $FILEBASE.bam ../ref
      mv $FILEBASE.bam.bai ../ref
      mv $FILEBASE.fa ../ref
    elif [[ $NUC == $REFL ]]; then
      mv $FILEBASE.bam ../ref
      mv $FILEBASE.bam.bai ../ref
      mv $FILEBASE.fa ../ref
    else
      mv $FILEBASE.bam ../other
      mv $FILEBASE.bam.bai ../other
      mv $FILEBASE.fa ../other
    fi
  done
cd $BASE_DIR
