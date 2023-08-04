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
    start_threshold_line=$(grep -n "NEXT RELEASE CHANGES START THRESHOLD" "Dockerfile" | cut -d ':' -f 1)
    end_threshold_line=$(grep -n "NEXT RELEASE CHANGES END THRESHOLD" "Dockerfile" | cut -d ':' -f 1)
    [ "${start_threshold_line}" -lt "${end_threshold_line}" ] || (echo "Could not find thresholds"; exit 1)
    # start_changed_line=$((start_threshold_line + 6))
    # end_changed_line=$((end_threshold_line - 2))
     insert_start_line=$((start_threshold_line - 2))
    # ${DEBUG} && echo "start_changed_line: $start_changed_line"
    # ${DEBUG} && echo "end_changed_line: $end_changed_line"
     ${DEBUG} && echo "insert_line: $insert_start_line"

    first_changed_line=$(git diff -U0 HEAD~1 -- Dockerfile | grep -m 1 -oP "(?<=\+)(\d+)(?=,?\d* @@)")
    ${DEBUG} && echo "first_changed_line: $first_changed_line"

    total_changed_lines=$(git diff -U0 HEAD~1 -- Dockerfile | grep -m 1 -oP "(?<=,)\d+(?=,?\d*\s+@@)")
    ${DEBUG} && echo "total_changed_lines: $total_changed_lines" 
    last_changed_line=$(( first_changed_line + total_changed_lines - 1 ))
    ${DEBUG} && echo "last_changed_line: $last_changed_line"
    lines_to_insert=$(sed -n "${first_changed_line},${last_changed_line}p" "Dockerfile")
    ${DEBUG} && echo -e "lines_to_insert: \n$lines_to_insert"

    # Save the lines to a temporary file
    echo "$lines_to_insert" > /tmp/temp_lines_to_insert.txt

    # delete new changes placed between thresholds from dockerfile
    sed -i "${first_changed_line},${last_changed_line}d" "Dockerfile"
    ${DEBUG} && echo "New changes placed between thresholds deleted from dockerfile"

    # Append the lines to the input file starting from the specified position
    sed -i "${insert_start_line}r /tmp/temp_lines_to_insert.txt" "Dockerfile"

    # Find the line number above the target lines
    start_threshold_line_after_move=$(grep -n "# NEXT RELEASE CHANGES START THRESHOLD" "Dockerfile" | cut -d ':' -f1)
    ${DEBUG} && echo "start_threshold_line: $start_threshold_line_after_move"

    # If the target lines are found, add a blank line above them
    if [ -n "$start_threshold_line_after_move" ]; then
        line_number_above=$((start_threshold_line_after_move - 1))  # Line number above the target lines -2

        # Add the blank line above the target lines
        sed -i -e "${line_number_above}i\\\\n" "Dockerfile"
        #sed -i "${start_threshold_line_after_move}i\\n" "Dockerfile" did not work
        #sed -i '${start_threshold_line_after_move}N;i\' "Dockerfile" did not work
        #sed -i -e "${start_threshold_line_after_move}i\\\\n" "Dockerfile" # adds double linebreak
        #sed -i -e "${start_threshold_line_after_move}i\&\"" "Dockerfile" did not work
        #sed "${start_threshold_line_after_move}s/$/\n/" did not work
        #sed -i "${start_threshold_line_after_move}a\\" "Dockerfile" did not work

        echo "::group:: print Dockerfile"
        cat Dockerfile
        echo "::endgroup::"
        start_threshold_line_after_move=$(grep -n "# NEXT RELEASE CHANGES START THRESHOLD" "Dockerfile" | cut -d ':' -f1)
        ${DEBUG} && echo "start_threshold_line after adding double linebreak: $start_threshold_line_after_move"
        line_number_above=$((start_threshold_line_after_move - 1))

        sed -i "${line_number_above}d" "Dockerfile"
        start_threshold_line_after_move=$(grep -n "# NEXT RELEASE CHANGES START THRESHOLD" "Dockerfile" | cut -d ':' -f1)
        ${DEBUG} && echo "start_threshold_line after deleting extra linebreak from above start: $start_threshold_line_after_move"
        line_number_below=$((start_threshold_line_after_move + 6))
        sed -i "${line_number_below}d" "Dockerfile"
    else
        echo "Target lines not found in the file."
    fi
    
    # Clean up the temporary file
    rm /tmp/temp_lines_to_insert.txt
fi
exit 0