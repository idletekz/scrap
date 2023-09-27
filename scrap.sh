indent_content() {
    local indent="        "  # 8 spaces for indentation
    local content="$1"

    # Indent each line by adding the indent string at the beginning
    local indented_content=$(echo "$content" | sed "s/^/$indent/")

    echo "$indented_content"
}

# Example usage
content=$(cat <<-EOF
echo "running below scripts"
i=0;
while true;
do
  echo "\$i: \$(date)";
  i=\$((i+1));
  sleep 1;
done
EOF
)

# Indent the content using the indent_content function
indented_content=$(indent_content "$content")

# Print the indented content
echo "$indented_content"


import yaml

def text_to_yaml(filename):
    # Read the content from the text file
    with open(filename, 'r') as f:
        lines = f.readlines()

    # Extract key-value pairs from the content
    data_list = []
    for line in lines:
        key, value = line.split(',')
        data_list.append({"id": key.strip(), "value": value.strip()})

    # Convert the list of key-value pairs to a YAML formatted string
    yaml_string = yaml.dump(data_list, default_flow_style=False)
    
    return yaml_string

# Example usage
filename = 'sample.txt'
print(text_to_yaml(filename))
