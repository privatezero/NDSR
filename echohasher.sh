#!/bin/bash
audioHash=$(echoprint-codegen "${1}" 60 180 | jq -r '.[0].code' | echoprint-decode | tr ',' '\n' | sort)
audioHash2=$(echoprint-codegen "${2}" 60 180 | jq -r '.[0].code' | echoprint-decode | tr ',' '\n' | sort)
comm -12 <(echo "${audioHash}") <(echo "${audioHash2}") | wc -l