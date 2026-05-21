FROM ghcr.io/engineer-man/piston:latest

# 1. Create the data directory Piston expects so it doesn't crash on boot
RUN mkdir -p /piston

# 2. Bind to Render's dynamic port
ENV PISTON_BIND_ADDRESS=0.0.0.0:10000
EXPOSE 10000

# 3. Write the installer script safely (Updated with correct JS version)
RUN echo "const http = require('http'); const post = (lang, ver) => new Promise(resolve => { const req = http.request({ hostname: '127.0.0.1', port: 10000, path: '/api/v2/packages', method: 'POST', headers: {'Content-Type': 'application/json'} }, res => { res.on('data', d => process.stdout.write(d)); res.on('end', resolve); }); req.write(JSON.stringify({language: lang, version: ver})); req.end(); }); (async () => { console.log('--- Installing JavaScript ---'); await post('javascript', '18.15.0'); console.log('--- Installing Python ---'); await post('python', '3.10.0'); })();" > install_packages.js
# 4. Start the API in the background, wait 10 seconds for it to boot, run the installer, then shut down
RUN node src/index.js & API_PID=$! && \
    sleep 10 && \
    node install_packages.js && \
    kill $API_PID

# 5. Start command to keep the container running live on Render
CMD ["node", "src/index.js"]