function update_key_if_exists() {
  local key_path="$1"
  local new_value="$2"
  local input_file="$3"
# This command will return the contents of the input YAML file if the key exists. If the key does not exist, the command will return nothing.
  result=$(yq "select(.$key_path != null)" "$input_file")
  if [ -n "$result" ]; then
    yq -i ".$key_path=\"$new_value\"" "$input_file"
    echo "Key '$key_path' updated"
  else
    echo "Key '$key_path' not found in the file."
  fi
}
