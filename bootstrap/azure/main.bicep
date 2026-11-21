// Bootstrap mínimo de la plantilla de pruebas (contrato azure/v1): lo justo
// para comprobar la conexión y el canje del token, sin nada que cueste.
// La credencial federada no va aquí: la crea vex después.
targetScope = 'subscription'

@description('Id del proyecto en vex (uuid).')
param projectId string

@description('Nombre corto del proyecto calculado por vex.')
param projectSlug string

@description('Ambiente al que pertenece esta conexión.')
param environment string

@description('Región de los grupos de recursos.')
param location string

var baseName = 'vex-${projectSlug}-${environment}'
var tags = {
  'vex:managed': 'true'
  'vex:project': projectId
  'vex:environment': environment
}

resource identityGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${baseName}-id'
  location: location
  tags: tags
}

resource workloadGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${baseName}'
  location: location
  tags: tags
}

module identities 'identidades.bicep' = {
  name: 'vex-bootstrap-identidades'
  scope: identityGroup
  params: {
    location: location
    baseName: baseName
    tags: tags
  }
}

module workload 'carga.bicep' = {
  name: 'vex-bootstrap-carga'
  scope: workloadGroup
  params: {
    deployPrincipalId: identities.outputs.deployPrincipalId
  }
}

output deployIdentityId string = identities.outputs.deployIdentityId
output deployClientId string = identities.outputs.deployClientId
output deployPrincipalId string = identities.outputs.deployPrincipalId
output resourceGroup string = workloadGroup.name
output identityResourceGroup string = identityGroup.name
