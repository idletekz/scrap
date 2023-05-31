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
