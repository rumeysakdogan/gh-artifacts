#!/bin/bash

set -euo pipefail
DEBUG=false

if test "$1" == "--debug";then
    DEBUG=true
    shift
fi

# changed_files=$(git diff --name-only HEAD~1)
# if [[ ${changed_files} =~ "Dockerfile" ]]; then
${DEBUG} && echo "DEBUG: Dockerfile has been changed."
start_threshold_line=$(grep -n "NEXT RELEASE CHANGES START THRESHOLD" "Dockerfile" | cut -d ':' -f 1)
end_threshold_line=$(grep -n "NEXT RELEASE CHANGES END THRESHOLD" "Dockerfile" | cut -d ':' -f 1)
[ "${start_threshold_line}" -lt "${end_threshold_line}" ] || (echo "Could not find thresholds"; exit 1)
    # start_changed_line=$((start_threshold_line + 6))
    # end_changed_line=$((end_threshold_line - 2))
insert_start_line=$((end_threshold_line - 2))
    # ${DEBUG} && echo "start_changed_line: $start_changed_line"
    # ${DEBUG} && echo "end_changed_line: $end_changed_line"
${DEBUG} && echo "insert_line: $insert_start_line"

start_threshold_line_beginning=$((start_threshold_line - 1))
${DEBUG} && echo "start_threshold_line_beginning: $start_threshold_line_beginning"
start_threshold_line_ending=$((start_threshold_line + 5))
${DEBUG} && echo "start_threshold_line_ending: $start_threshold_line_ending"
lines_to_insert=$(sed -n "${start_threshold_line_beginning},${start_threshold_line_ending}p" "Dockerfile")
${DEBUG} && echo -e "lines_to_insert: \n$lines_to_insert"
# Save the lines to a temporary file
echo "$lines_to_insert" > /tmp/temp_lines_to_insert.txt

#delete new changes placed between thresholds from dockerfile
sed -i "${start_threshold_line_beginning},${start_threshold_line_ending}d" "Dockerfile"
${DEBUG} && echo "Start threshold moved above End threshold"


end_threshold_line=$(grep -n "NEXT RELEASE CHANGES END THRESHOLD" "Dockerfile" | cut -d ':' -f 1)
[ "${start_threshold_line}" -lt "${end_threshold_line}" ] || (echo "Could not find thresholds"; exit 1)
    # start_changed_line=$((start_threshold_line + 6))
    # end_changed_line=$((end_threshold_line - 2))
insert_start_line=$((end_threshold_line - 2))
# Append the lines to the input file starting from the specified position
sed -i "${insert_start_line}r /tmp/temp_lines_to_insert.txt" "Dockerfile"

end_threshold_line=$(grep -n "NEXT RELEASE CHANGES END THRESHOLD" "Dockerfile" | cut -d ':' -f 1)
linebreak_line=$((end_threshold_line - 1))
sed -i -e "${linebreak_line}i\\\\n" "Dockerfile"
# Remove extra linebreak 
end_threshold_line_after=$(grep -n "NEXT RELEASE CHANGES END THRESHOLD" "Dockerfile" | cut -d ':' -f 1)
linebreak_line_to_remove=$((end_threshold_line - 2))
sed -i "${linebreak_line_to_remove}d" "Dockerfile"


# Clean up the temporary file
rm /tmp/temp_lines_to_insert.txt
# fi
# exit 0