#!/bin/bash

input_file="input_file.txt"

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
echo "lines_to_move_begin: $lines_to_move_begin"
lines_to_move_end=$((end_threshold_line - 2))
echo "lines_to_move_end: $lines_to_move_end"

line_to_start_append=$((start_threshold_line - 2))
echo "line_to_start_append: $line_to_start_append"
# Move the lines within the defined range above the start threshold block
lines_to_move=$(sed -n "${lines_to_move_begin},${lines_to_move_end}p" "$input_file")
echo -e "lines_to_move: \n$lines_to_move"


