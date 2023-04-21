function update_key_if_exists() {
  local key_name="$1"
  local new_value="$2"
  local input_file="$3"
  key_exists=$(yq "has(\"$key_name\")" "$input_file")
  if [ "$key_exists" = "true" ]; then
    yq -i ".$key_name=\"$new_value\"" "$input_file"
    echo "Key '$key_name' updated"
  else
    echo "Key '$key_name' not found in the file."
  fi
}
