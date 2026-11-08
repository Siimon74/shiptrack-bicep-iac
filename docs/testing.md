# Test documentation

All tests were done on 8 November 2026, on my own Azure subscription (region `swedencentral`).

## What I tested

| # | Test | How | Result |
|---|---|---|---|
| 1 | `.gitignore` blocks secret files | Created a fake `.env` file and ran `git check-ignore -v .env` | ✅ Blocked by line 2 of `.gitignore`. Fake file deleted after. |
| 2 | The pipeline checks the code | Pushed to GitHub and looked at the Actions tab | ✅ Success in 22 seconds |
| 3 | Pipeline warnings | Read the warnings of the run | ⚠️ Warning about an old Node.js version in `actions/checkout@v4`. Fixed by using `@v5`. |
| 4 | Deploy dev | `az deployment group create` with `dev.bicepparam` | ✅ Succeeded in 49 seconds |
| 5 | The secret is not saved in the deployment history | Read the deployment result | ✅ The secret shows only `SecureString`, with no value |
| 6 | The app reads the secret from Key Vault | Deployed the app and opened the URL | ✅ `Secret loaded from Key Vault (ends with ...1234)` |
| 7 | Deploy test with the same code | `az deployment group create` with `test.bicepparam` | ✅ Succeeded. Same `templateHash` as dev, so the same code was used |
| 8 | Tags on all resources | `az resource list` on `rg-shiptrack-test` | ✅ All 5 resources have the 4 tags |
| 9 | Storage security settings | `az storage account show` on the dev storage account | ✅ `publicBlobAccess: false`, `httpsOnly: true`, `minTls: TLS1_2` |
| 10 | Web app logs arrive in Log Analytics | Opened the app several times, then ran a KQL query on `AppServiceHTTPLogs` (with the help of Azure Copilot in the portal) | ✅ Each visit is logged: `GET /` with status `200` |
| 11 | Key Vault logs who read the secret | KQL query on `AzureDiagnostics` for Key Vault | ✅ `SecretGet` with result `OK` when the app read the secret |
| 12 | Delete dev and rebuild it from scratch | `az group delete`, `az keyvault purge`, then created the resource group, deployed the infrastructure and the app again | ✅ About 5 minutes in total, including typing the commands by hand. Same names as before (same suffix). |
| 13 | App reads the secret after the rebuild | Opened the URL after the rebuild | ⚠️ First `NOT loaded`. See "Problem found" below. Fixed: ✅ `Secret loaded from Key Vault` |

## Problem found during the rebuild (test 13)

After the rebuild, the app showed `Secret NOT loaded`.

1. I checked the status of the Key Vault reference with `az rest` (`.../config/configreferences/appsettings`). Result: `AccessToKeyVaultDenied`.
2. I checked the role assignment: the role `Key Vault Secrets User` exists, and its principal ID is the same as the web app's identity. So the configuration is correct.
3. Cause: the app started and asked for the secret before the new role assignment was active. App Service keeps this result. A restart did not help, because App Service only reads Key Vault references again after a configuration change (or every 24 hours).
4. Fix: I added a temporary app setting (`KV_REFRESH=1`). This forced App Service to read the secret again, and it worked. Then I deleted the temporary setting, so the configuration matches the code again.

## What I did not test

| What | Why |
|---|---|
| The app in the test environment | I deployed only the infrastructure in test, the app only in dev |
| Deleting the test environment | I deleted and rebuilt dev only. Test is still running. |
