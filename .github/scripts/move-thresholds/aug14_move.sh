#!/bin/bash

set -euo pipefail

DEBUG=false

if [[ $# -eq 1 && "$1" == "--debug" ]]; then
    DEBUG=true
    shift
fi

beg_start_threshold_line=$(grep -n "NEXT RELEASE CHANGES START THRESHOLD BEGIN" "Dockerfile" | cut -d ':' -f 1)
finish_start_threshold_line=$(grep -n "NEXT RELEASE CHANGES START THRESHOLD FINISH" "Dockerfile" | cut -d ':' -f 1)
beg_end_threshold_line=$(grep -n "NEXT RELEASE CHANGES END THRESHOLD BEGIN" "Dockerfile" | cut -d ':' -f 1)
finish_end_threshold_line=$(grep -n "NEXT RELEASE CHANGES END THRESHOLD FINISH" "Dockerfile" | cut -d ':' -f 1)

lines_to_insert=$(sed -n "${beg_start_threshold_line},${finish_start_threshold_line}p" "Dockerfile")
echo "lines_to_insert:\n${lines_to_insert}"

#delete new changes placed between thresholds from dockerfile
sed -i "${beg_start_threshold_line},$((finish_start_threshold_line+1))d" "Dockerfile"
${DEBUG} && echo "Start threshold moved above End threshold"

beg_end_threshold_line=$(grep -n "NEXT RELEASE CHANGES END THRESHOLD BEGIN" "Dockerfile" | cut -d ':' -f 1)
target_insertion_line=$((beg_end_threshold_line -1))

sed -i "${target_insertion_line}r /dev/stdin" "Dockerfile" << EOF
$lines_to_insert

EOF
