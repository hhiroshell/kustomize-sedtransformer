#!/bin/bash

if ! [ -x "$(command -v yq)" ]; then
  echo "Error: please install yq."
  exit 1
fi

resourceList=$(cat) # read the `kind: ResourceList` from stdin
spec=$(echo "$resourceList" | yq e '.functionConfig.spec' - )

i=0
while true; do
    resource="$(echo "$resourceList" | yq e ".items[$i]" - )"
    if [[ "$resource" == "null" ]]; then
        break
    fi
    IFS=$'\n'
    for rep in $(echo "$spec"); do
        key=$(echo "$rep" | cut -f 1 -d ":")
        val=$(echo "$resourceList" | yq e ".functionConfig.spec.$key" - )
        resource=$(echo "$resource" | sed -e "s/@@$key@@/"$val"/g")
    done
    echo "$resource"
    echo "---"
    let i++
done
