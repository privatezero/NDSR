#!/bin/bash
#depends on chromaprint

INPUT1=$(fpcalc -raw "$1" | tail -n1 | cut -d'=' -f2 | tr , '\n' | sort)
INPUT2=$(fpcalc -raw "$2" | tail -n1 | cut -d'=' -f2 | tr , '\n' | sort)



HASH_SHARED=$(comm -12 <(echo "$INPUT1") <(echo "$INPUT2") | wc -l)
HASH_TOTAL=$(echo "$INPUT1" | wc -l)
echo "$HASH_TOTAL"
echo "$HASH_SHARED"

echo "File hashes have "$HASH_SHARED" similarities out of "$HASH_TOTAL" checked values."
