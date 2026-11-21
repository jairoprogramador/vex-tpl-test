// La identidad con la que el pipeline entra a Azure. Sin credencial federada.
param location string
param baseName string
param tags object

resource deploy 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-${baseName}-deploy'
  location: location
  tags: tags
}

output deployIdentityId string = deploy.id
output deployClientId string = deploy.properties.clientId
output deployPrincipalId string = deploy.properties.principalId
