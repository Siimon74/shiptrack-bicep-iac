// =============================================================================
// ShipTrack infrastructure - Nordvind Logistik A/S
// Deploys one environment (dev or test) into the current resource group.
// Differences between environments are handled in params/*.bicepparam files.
// =============================================================================

// ---------- Parameters ----------

@description('Environment name. Used in resource names and the Environment tag.')
@allowed([
  'dev'
  'test'
])
param environment string

@description('Azure region. Defaults to the region of the resource group.')
param location string = resourceGroup().location

@description('Team or person responsible for the resources (Owner tag).')
param owner string

@description('Cost center for billing (CostCenter tag).')
param costCenter string

@description('App Service plan SKU. Low-cost tier.')
param appServiceSkuName string

@description('Storage redundancy SKU.')
param storageSkuName string

@description('Log Analytics retention in days.')
param logRetentionDays int

@description('Demo secret stored in Key Vault. Passed at deploy time, never committed.')
@secure()
param shipTrackSecret string

// ---------- Naming and tags ----------

// Naming convention (based on Microsoft CAF): <type>-<app>-<env>-<suffix>
// The suffix makes globally unique names (web app, Key Vault, storage)
// and is stable for a given resource group.
var appName = 'shiptrack'
var suffix = take(uniqueString(resourceGroup().id), 5)

var names = {
  logAnalytics: 'log-${appName}-${environment}-${suffix}'
  storage: 'st${appName}${environment}${suffix}' // storage: lowercase + digits only, max 24
  keyVault: 'kv-${appName}-${environment}-${suffix}' // max 24 characters
  appServicePlan: 'asp-${appName}-${environment}-${suffix}'
  webApp: 'app-${appName}-${environment}-${suffix}'
}

var tags = {
  Environment: environment
  Owner: owner
  Application: 'ShipTrack'
  CostCenter: costCenter
}

// Built-in role "Key Vault Secrets User": read secret values only (least privilege)
var keyVaultSecretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'

// ---------- Monitoring ----------

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: names.logAnalytics
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: logRetentionDays
  }
}

// ---------- Storage ----------

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: names.storage
  location: location
  tags: tags
  sku: {
    name: storageSkuName
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false // security review finding: public blob access
    supportsHttpsTrafficOnly: true // HTTPS only
    minimumTlsVersion: 'TLS1_2' // TLS 1.2 minimum
  }
}

// ---------- Secrets ----------

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: names.keyVault
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true // Azure RBAC instead of access policies
    softDeleteRetentionInDays: 7
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'ShipTrackDbConnection'
  properties: {
    value: shipTrackSecret
  }
}

// ---------- Web hosting ----------

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: names.appServicePlan
  location: location
  tags: tags
  kind: 'linux'
  sku: {
    name: appServiceSkuName
  }
  properties: {
    reserved: true // required for Linux
  }
}

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: names.webApp
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned' // managed identity: no password to store
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'NODE|22-lts'
      appCommandLine: 'node server.js'
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      appSettings: [
        {
          // Key Vault reference: App Service fetches the value with its managed identity
          name: 'SHIPTRACK_SECRET'
          value: '@Microsoft.KeyVault(SecretUri=${secret.properties.secretUri})'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'false'
        }
      ]
    }
  }
}

// Give the web app's identity read access to secrets in this Key Vault only
resource kvRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, webApp.id, keyVaultSecretsUserRoleId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUserRoleId)
    principalId: webApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// ---------- Diagnostic settings (logs to Log Analytics) ----------

resource webAppDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-to-log-analytics'
  scope: webApp
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
      }
      {
        category: 'AppServicePlatformLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource keyVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-to-log-analytics'
  scope: keyVault
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        categoryGroup: 'audit' // who read or changed secrets
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// ---------- Outputs (no secrets) ----------

output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output webAppName string = webApp.name
output keyVaultName string = keyVault.name
output storageAccountName string = storage.name
