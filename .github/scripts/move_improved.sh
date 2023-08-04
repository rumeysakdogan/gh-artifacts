#!/bin/bash

set -euo pipefail
DEBUG=false

if test "$1" == "--debug";then
    DEBUG=true
    shift
fi

input_file="Dockerfile"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
  echo "Input file not found: $input_file"
  exit 1
fi

# Find the line numbers of the start and end threshold blocks using grep
start_threshold_line=$(grep -n "NEXT RELEASE CHANGES START THRESHOLD" "$input_file" | cut -d ':' -f 1)
end_threshold_line=$(grep -n "NEXT RELEASE CHANGES END THRESHOLD" "$input_file" | cut -d ':' -f 1)

# Check if the start and end threshold blocks are found
if [ -z "$start_threshold_line" ] || [ -z "$end_threshold_line" ]; then
  echo "Start or end threshold block not found in the input file."
  exit 1
fi

# Define the range for lines to move (5 lines before start threshold to 1 line before end threshold)
lines_to_move_begin=$((start_threshold_line + 6))
${DEBUG} && echo "lines_to_move_begin: $lines_to_move_begin"
lines_to_move_end=$((end_threshold_line - 2))
${DEBUG} && echo "lines_to_move_end: $lines_to_move_end"

line_to_start_append=$((start_threshold_line - 2))
${DEBUG} && echo "line_to_start_append: $line_to_start_append"



first_changed_line=$(git diff -U0 HEAD~1 -- Dockerfile | grep -m 1 -oP "(?<=\+)(\d+)(?=,?\d* @@)")
${DEBUG} && echo "first_changed_line: $first_changed_line"
# last_changed_line=$(git diff -U0 HEAD~1 -- Dockerfile | tac | grep -m 1 -oP "(?<=\+)(\d+)(?=,?\d* @@)")
# last_changed_line=$(git diff -U0 HEAD~1 -- Dockerfile | tac | grep -m 1 -oP "(?<=-)(\d+)(?=,?\d* @@)" | head -n 1)
# ${DEBUG} && echo "last_changed_line: $last_changed_line"

total_changed_lines=$(git diff -U0 HEAD~1 -- Dockerfile | grep -m 1 -oP "(?<=,)\d+(?=,?\d*\s+@@)")
${DEBUG} && echo "total_changed_lines: $total_changed_lines" 
last_changed_line=$(( first_changed_line + total_changed_lines - 1 ))
${DEBUG} && echo "last_changed_line: $last_changed_line"

# Move the lines within the defined range above the start threshold block
# lines_to_move=$(sed -n "${lines_to_move_begin},${lines_to_move_end}p" "$input_file")
# ${DEBUG} && echo -e "lines_to_move: \n$lines_to_move"
# Move the lines within the defined range above the start threshold block
lines_to_move=$(sed -n "${first_changed_line},${last_changed_line}p" "$input_file")
${DEBUG} && echo -e "lines_to_move: \n$lines_to_move"

# Save the lines to a temporary file
echo "$lines_to_move" > "${{ GITHUB_WORKSPACE }}/tmp/temp_lines_to_move.txt"

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

cat Dockerfile

# Clean up the temporary file
rm /tmp/temp_lines_to_move.txt







