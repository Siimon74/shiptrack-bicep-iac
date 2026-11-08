# Limitations and next steps

## Limitations

- **The pipeline does not deploy.** It only checks the code. Deployments are done by hand from my computer.
- **No private network.** Key Vault and storage are protected by RBAC and HTTPS, but they can be reached from the internet.
- **Everything is in one Bicep file.** It is fine at this size, but it will be harder to read when more resources are added.
- **No production environment.** Only dev and test.
- **After a fresh deployment, the app may not read the secret at first.** The role assignment can take a few minutes to become active. The fix today is manual (a configuration change). See docs/testing.md, test 13.

## Next three steps (in priority order)

1. **Deploy from the pipeline.**
   Today a person must run commands from their computer. That is close to Nordvind's original problem. The pipeline should deploy automatically after a change is approved. GitHub would connect to Azure with a method that does not need a stored password (OIDC). The pipeline could also check at the end that the app reads its secret, and fix it automatically if not.

2. **Use Azure Policy to enforce the rules.**
   Someone can still change a setting by hand in the portal. For example, a policy can require the four tags, or block public blob access. This protects against changes made outside the code.

3. **Put Key Vault and storage in a private network.**
   Add a VNet, connect the web app to it, and make Key Vault and storage reachable only from inside it (private endpoints). This adds a network layer of security on top of RBAC.
