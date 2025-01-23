# finds all images (including containers, initContainers, and ephemeralContainers) 
# removes the leading registry/domain part if it exists (including the slash) 
#  look for one or more characters that are not a slash (^[^/]+) followed by a slash (/), from the start of the string (^).
#   If it matches, it replaces that portion with an empty string ("").
#  
yq e '
  ..
  | select(has("containers") or has("initContainers") or has("ephemeralContainers"))
  | (.containers + .initContainers + .ephemeralContainers)[]?.image
  | sub("^[^/]+/", "")
' multiple-resources.yaml

yq e '
  ..
  | select(has("image"))
  | .image
  | sub("^[^/]+/", "")
' multiple-resources.yaml
