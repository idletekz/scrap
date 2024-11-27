az rest --method GET \
  --url "https://graph.microsoft.com/v1.0/servicePrincipals/$spnID/transitiveMemberOf" \
  --headers '{"Content-Type":"application/json"}'

az rest --method GET \
  --url "https://graph.microsoft.com/v1.0/directoryRoles/$roleID" \
  --headers '{"Content-Type": "application/json"}'

az rest --method GET \
  --url "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions/$roleTemplateID" \
  --headers '{"Content-Type": "application/json"}' 
