#!/bin/bash

echo "INFO: Checking whether the commit message and PR title adhere to the contribution policies."

# Get the commit message of the current HEAD commit
commit_message=$(git log -1 --pretty=format:%s)

# Get the PR title from the environment variable (GITHUB_HEAD_REF)
# This assumes you are using the `pull_request` event, where GITHUB_HEAD_REF holds the PR branch name
pr_title=$PR_TITLE

# Check if the commit message or PR title follows the contribution policies
if [[ ! $commit_message =~ ^(Add|Update|Fix|Remove):[[:space:]] || ! $pr_title =~ ^(Add|Update|Fix|Remove):[[:space:]] ]]; then
    echo "Your PR_TITLE: $pr_title"
    echo "Error: Commit message and PR title should start with either 'Add', 'Update', 'Fix', or 'Remove', in uppercase, followed by a colon and a space."
    echo "Example: 'Add: Implement new feature' or 'Fix: Resolve issue with login form'"
    exit 1   
fi

echo "INFO: Commit message and PR title adhere to the contribution policies."