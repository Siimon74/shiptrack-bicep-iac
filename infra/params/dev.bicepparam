using '../main.bicep'

param environment = 'dev'
param owner = 'infra-team'
param costCenter = 'CC-1001'
param appServiceSkuName = 'B1'
param storageSkuName = 'Standard_LRS'
param logRetentionDays = 30

// The secret is read from an environment variable at deploy time, never stored in Git
param shipTrackSecret = readEnvironmentVariable('SHIPTRACK_SECRET')
