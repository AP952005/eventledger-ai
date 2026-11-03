const localtunnel = require('localtunnel');
const fs = require('fs');

(async () => {
  const tunnel = await localtunnel({ port: 8000 });
  
  // URL to give to the user
  console.log("Localtunnel URL: ", tunnel.url);
  fs.writeFileSync('lt_url.txt', tunnel.url);

  tunnel.on('close', () => {
    console.log('Tunnel closed');
  });
})();
