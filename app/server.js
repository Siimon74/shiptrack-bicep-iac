// Placeholder ShipTrack app: shows whether the secret was loaded from Key Vault.
// The secret value is masked on purpose: never display a full secret.
const http = require('http');

const port = process.env.PORT || 8080;

http.createServer((req, res) => {
  const secret = process.env.SHIPTRACK_SECRET || '';
  const loaded = secret !== '' && !secret.startsWith('@Microsoft.KeyVault');

  const message = loaded
    ? `ShipTrack is running. Secret loaded from Key Vault (ends with ...${secret.slice(-4)}).`
    : 'ShipTrack is running. Secret NOT loaded from Key Vault.';

  console.log(`Request ${req.url} - secret loaded: ${loaded}`);
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end(message);
}).listen(port);
