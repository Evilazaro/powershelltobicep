#!/bin/bash

# List all commit hashes in reverse order
commits=$(git rev-list --reverse HEAD)

# Common tag name
base_tag="v1.0.0"

# Counter to differentiate tags
count=1

# Tag each commit with a unique tag
for commit in $commits; do
    tag_name="${base_tag}${count}"
    echo "Tagging commit $commit with tag $tag_name"
    git tag "$tag_name" "$commit"
    count=$((count + 1))
done

# Push all tags to the remote repository
git push --tags
