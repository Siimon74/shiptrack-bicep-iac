using '../main.bicep'

param environment = 'test'
param owner = 'infra-team'
param costCenter = 'CC-1001'
param appServiceSkuName = 'B1'
param storageSkuName = 'Standard_ZRS'
param logRetentionDays = 60

// The secret is read from an environment variable at deploy time, never stored in Git
param shipTrackSecret = readEnvironmentVariable('SHIPTRACK_SECRET')
