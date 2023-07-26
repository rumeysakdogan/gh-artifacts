#!/bin/bash

echo "INFO: Checking whether the commit message and PR title adhere to the contribution policies."

# Get the commit message of the current HEAD commit
commit_message=$(git log -1 --pretty=format:%s)

echo $commit_message
# Check if the commit message or PR title follows the contribution policies
if [[ ! $commit_message =~ ^(Add|Update|Fix|Remove):[[:space:]]+ ]]; then
    echo "Error: Commit message and PR title should start with either 'Add', 'Update', 'Fix', or 'Remove', in uppercase, followed by a colon and a space."
    echo "Example: 'Add: Implement new feature' or 'Fix: Resolve issue with login form'"
    exit 1
fi

echo "INFO: Commit message and PR title adhere to the contribution policies."