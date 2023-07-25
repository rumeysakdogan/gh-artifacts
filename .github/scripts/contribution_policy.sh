#!/bin/bash

set -eou pipefail

echo "INFO: Checking whether the commit message adheres to the contribution policies."

# Get the commit message of the current HEAD commit
commit_message=$(git log -1 --pretty=format:%s)

# Check if the commit message follows the contribution policies
if [[ ! $commit_message =~ ^(Add|Update|Fix|Remove):[[:space:]] ]]; then
    echo "Error: Commit message should start with either 'Add', 'Update', 'Fix', or 'Remove', in uppercase, followed by a colon and a space."
    echo "Example: 'Add: Implement new feature' or 'Fix: Resolve issue with login form'"
    exit 1
fi

echo "INFO: Commit message adheres to the contribution policies."