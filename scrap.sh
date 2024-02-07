#!/bin/bash

# Initialize an empty JSON object
json_result="{"

# Loop through each argument passed to the script
for arg in "$@"
do
  # Split the argument into key and value based on the '=' delimiter
  key=$(echo $arg | cut -f1 -d=)
  value=$(echo $arg | cut -f2 -d=)

  # Remove leading '--' from the key
  key=${key//--/}

  # Append the key-value pair to the JSON object
  # Also, add comma before adding a key-value pair if the JSON object is not empty
  if [ ${#json_result} -gt 1 ]; then
    json_result+=", "
  fi
  json_result+="\"$key\": \"$value\""
done

# Close the JSON object
json_result+="}"

# Output the resulting JSON object
echo $json_result
