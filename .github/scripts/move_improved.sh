#!/bin/bash

set -euo pipefail
DEBUG=false

if test "$1" == "--debug";then
    DEBUG=true
    shift
fi

changed_files=$(git diff --name-only HEAD~1)
if [[ ${changed_files} =~ "Dockerfile" ]]; then
    ${DEBUG} && echo "DEBUG: Dockerfile has been changed."
    start_threshold_line=$(grep -n "NEXT RELEASE CHANGES START THRESHOLD" "$input_file" | cut -d ':' -f 1)
    end_threshold_line=$(grep -n "NEXT RELEASE CHANGES END THRESHOLD" "$input_file" | cut -d ':' -f 1)
    [ "${start_threshold_line}" -lt "${end_threshold_line}" ] || (echo "Could not find thresholds"; exit 1)
    lines_to_move_begin=$((start_threshold_line + 6))
    lines_to_move_end=$((end_threshold_line - 2))
    line_to_start_append=$((start_threshold_line - 2))
    ${DEBUG} && echo "lines_to_move_begin: $lines_to_move_begin"
    ${DEBUG} && echo "lines_to_move_end: $lines_to_move_end"
    ${DEBUG} && echo "line_to_start_append: $line_to_start_append"

    first_changed_line=$(git diff -U0 HEAD~1 -- Dockerfile | grep -m 1 -oP "(?<=\+)(\d+)(?=,?\d* @@)")
    ${DEBUG} && echo "first_changed_line: $first_changed_line"

    total_changed_lines=$(git diff -U0 HEAD~1 -- Dockerfile | grep -m 1 -oP "(?<=,)\d+(?=,?\d*\s+@@)")
    ${DEBUG} && echo "total_changed_lines: $total_changed_lines" 
    last_changed_line=$(( first_changed_line + total_changed_lines - 1 ))
    ${DEBUG} && echo "last_changed_line: $last_changed_line"
    lines_to_move=$(sed -n "${first_changed_line},${last_changed_line}p" "$input_file")
    ${DEBUG} && echo -e "lines_to_move: \n$lines_to_move"

    # Save the lines to a temporary file
    echo "$lines_to_move" > $GITHUB_WORKSPACE/tmp/temp_lines_to_move.txt

    # delete new changes placed between thresholds from dockerfile
    sed -i "${first_changed_line},${last_changed_line}d" "$input_file"
    ${DEBUG} && echo "New changes placed between thresholds deleted from dockerfile"

    # Append the lines to the input file starting from the specified position
    sed -i "${line_to_start_append}r ${{ GITHUB_WORKSPACE }}/tmp/temp_lines_to_move.txt" "$input_file"

    # Find the line number above the target lines
    line_number_above=$(grep -n "# NEXT RELEASE CHANGES START THRESHOLD" "$input_file" | cut -d ':' -f1)

    # If the target lines are found, add a blank line above them
    if [ -n "$line_number_above" ]; then
        line_number_above=$((line_number_above - 1))  # Line number above the target lines

        # Add the blank line above the target lines
        sed -i -e "${line_number_above}i\\\\n" "$input_file"
        #sed "${line_number_above}s/$/\n/"
    else
        echo "Target lines not found in the file."
    fi

    # Clean up the temporary file
    rm $GITHUB_WORKSPACE/tmp/temp_lines_to_move.txt
fi
exit 0