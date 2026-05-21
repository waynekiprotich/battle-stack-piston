FROM ghcr.io/engineer-man/piston:latest

# Bind to all interfaces (Render or any host)
ENV PISTON_BIND_ADDRESS=0.0.0.0:10000

# Optional: set isolate directory to writable path (prevents read-only issues)
ENV ISOLATE_DIR=/tmp/isolate

# Expose port (Render will override dynamically anyway)
EXPOSE 10000

# Start command (default Piston entrypoint already exists, but this is explicit)
CMD ["node", "/piston/api/src/index.js"]
