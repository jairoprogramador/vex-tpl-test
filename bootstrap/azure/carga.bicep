// La identidad de despliegue solo puede leer el grupo de carga.
param deployPrincipalId string

var reader = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'

resource deployReadsWorkload 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, deployPrincipalId, reader)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', reader)
    principalId: deployPrincipalId
    principalType: 'ServicePrincipal'
  }
}
