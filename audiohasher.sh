#!/bin/bash
#depends on chromaprint (available via brew install chromaprint)

#generate hashes from inputs
INPUT1=$(fpcalc -raw "$1" | tail -n1 | cut -d'=' -f2 | tr , '\n' | sort)
INPUT2=$(fpcalc -raw "$2" | tail -n1 | cut -d'=' -f2 | tr , '\n' | sort)

#count total hashes and unique hashes
HASH_SHARED=$(comm -12 <(echo "$INPUT1") <(echo "$INPUT2") | wc -l)
HASH_TOTAL1=$(echo "$INPUT1" | wc -l)
HASH_TOTAL2=$(echo "$INPUT1" | wc -l)

#report results
echo "$(basename "$1") Number of Hashes: $HASH_TOTAL1"
echo "$(basename "$2") Number of Hashes: $HASH_TOTAL2"
echo "Number of Common Hashes: $HASH_SHARED"

