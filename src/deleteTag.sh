#!/bin/bash

# List all commit hashes in reverse order
commits=$(git rev-list --reverse HEAD)

# Common tag name
base_tag="v1.0.0"

# Counter to differentiate tags
count=1

# Tag each commit with a unique tag
for commit in $commits; do
    tag_name="${base_tag}-commit${count}"
    echo "Tagging commit $commit with tag $tag_name"
    git tag --delete "$tag_name"
    git push origin :refs/tags/"$tag_name" 
    count=$((count + 1))
done


