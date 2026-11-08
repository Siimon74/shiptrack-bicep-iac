# Sources and AI tools

## AI tools

**Claude (Anthropic)**, used throughout the case:

- Planning: breaking the brief down into steps and setting priorities within the timebox.
- Code: generated the first version of `main.bicep`, the parameter files, `app/server.js`, the GitHub Actions workflow and `bicepconfig.json`. I then reviewed the code with Claude block by block, to understand what each part does and why.
- Troubleshooting: Git setup (identity, cloning, paths), reading error messages and pipeline annotations.
- Documentation: helped write and structure the README and the files in `docs/`. I reviewed them and checked the test results against my own terminal output.

**Azure Copilot** (in the Azure Portal), used to run the KQL queries that check the logs in Log Analytics.

All deployments and tests were run by me, on my own subscription.

## Documentation

- Microsoft Learn – Bicep documentation and resource reference (`Microsoft.Storage/storageAccounts`, `Microsoft.KeyVault/vaults`, `Microsoft.Web/sites`, `Microsoft.Insights/diagnosticSettings`)
- Microsoft Learn – Use Key Vault references as app settings in App Service
- Microsoft Learn – Azure built-in roles (Key Vault Secrets User)
- Microsoft Cloud Adoption Framework – Resource naming and abbreviation recommendations
- Microsoft Learn – Bicep linter and `bicepconfig.json`
- GitHub Docs – GitHub Actions workflow syntax
- GitHub Docs – Secret scanning and push protection
- GitHub changelog – Deprecation of Node.js 20 on GitHub Actions runners
