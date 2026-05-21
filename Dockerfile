FROM ghcr.io/engineer-man/piston:latest

# 1. Create the data directory Piston expects
RUN mkdir -p /piston

# 2. Bind to Render's dynamic port
ENV PISTON_BIND_ADDRESS=0.0.0.0:10000
EXPOSE 10000

# 3. Disable Kernel Cgroups (This fixes the 500 Error on Render!)
ENV PISTON_DISABLE_CGROUPS=true

# 4. Write the installer script safely
RUN echo "const http = require('http'); const post = (lang, ver) => new Promise(resolve => { const req = http.request({ hostname: '127.0.0.1', port: 10000, path: '/api/v2/packages', method: 'POST', headers: {'Content-Type': 'application/json'} }, res => { res.on('data', d => process.stdout.write(d)); res.on('end', resolve); }); req.write(JSON.stringify({language: lang, version: ver})); req.end(); }); (async () => { console.log('--- Installing Node.js ---'); await post('node', '18.15.0'); console.log('--- Installing Python ---'); await post('python', '3.10.0'); })();" > install_packages.js

# 5. Start the API, wait, install languages, and shut down
RUN node src/index.js & API_PID=$! && \
    sleep 10 && \
    node install_packages.js && \
    kill $API_PID

# 6. Start command to keep the container running live on Render
CMD ["node", "src/index.js"]