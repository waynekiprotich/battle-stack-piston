FROM ghcr.io/engineer-man/piston:latest

# Hugging Face Spaces strictly require apps to run on port 7860
ENV PISTON_BIND_ADDRESS=0.0.0.0:7860
EXPOSE 7860

# Install curl so we can talk to the API during the build
RUN apt-get update && apt-get install -y curl

# Start the Piston API in the background, wait for it to boot, 
# use curl to send the package installation requests, and then exit.
RUN \
    # 1. Start API in background and save its Process ID
    node src/index.js & API_PID=$! && \
    # 2. Wait 10 seconds for the server to fully wake up
    sleep 10 && \
    # 3. Tell Piston to install Python 3.10
    curl -s -X POST http://127.0.0.1:7860/api/v2/packages \
         -H "Content-Type: application/json" \
         -d '{"language": "python", "version": "3.10.0"}' && \
    # 4. Tell Piston to install JavaScript (Node 18.0)
    curl -s -X POST http://127.0.0.1:7860/api/v2/packages \
         -H "Content-Type: application/json" \
         -d '{"language": "javascript", "version": "18.0.0"}' && \
    # 5. Kill the background API so Docker can finish saving the image
    kill $API_PID