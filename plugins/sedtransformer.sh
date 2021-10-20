#!/bin/bash

if ! [ -x "$(command -v yq)" ]; then
  echo "Error: please install yq."
  exit 1
fi

 # read the `kind: ResourceList` from stdin
resourceList=$(cat)
items=$(echo "$resourceList" | yq e '.items' - )
replacements=$(echo "$resourceList" | yq e '.functionConfig.spec.replacements' - )

for i in `seq 0 $(expr $(echo "$items" | yq e ". | length" - ) - 1)`; do
    item=$(echo "$items" | yq e ".[$i]" - )
    for key in $(echo "$replacements" | yq e ". | keys" - | yq e ".[]" - ); do
        item=$(echo "$item" | sed -e "s/@@$key@@/"$(echo "$replacements" | yq e ".$key" - )"/g")
    done
    echo "$item"
    echo "---"
done