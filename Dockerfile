FROM ghcr.io/engineer-man/piston:latest

# Render dynamically assigns a port, so we bind to all interfaces on 10000
ENV PISTON_BIND_ADDRESS=0.0.0.0:10000
EXPOSE 10000

# 1. Create a native Node.js script to install the packages (bypassing dead Linux servers)
# Notice we changed the port in the script to 10000 to match Render's setup
RUN echo "const http = require('http'); \
const post = (lang, ver) => new Promise(resolve => { \
  const req = http.request({ \
    hostname: '127.0.0.1', port: 10000, path: '/api/v2/packages', method: 'POST', \
    headers: {'Content-Type': 'application/json'} \
  }, res => { \
    res.on('data', d => process.stdout.write(d)); \
    res.on('end', resolve); \
  }); \
  req.write(JSON.stringify({language: lang, version: ver})); \
  req.end(); \
}); \
(async () => { \
  console.log('\n--- Installing JavaScript ---'); await post('javascript', '18.0.0'); \
  console.log('\n--- Installing Python ---'); await post('python', '3.10.0'); \
})();" > install_packages.js

# 2. Start the API in the background, wait 5 seconds, run our JS installer, then shut down
RUN node src/index.js & API_PID=$! && \
    sleep 5 && \
    node install_packages.js && \
    kill $API_PID

# Start command to keep the container running on Render
CMD ["node", "src/index.js"]