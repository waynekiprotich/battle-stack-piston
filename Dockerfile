FROM ghcr.io/engineer-man/piston:latest

# Render dynamically assigns a port, so we leave it open
ENV PISTON_BIND_ADDRESS=0.0.0.0:10000
EXPOSE 10000

# Pre-install JavaScript and Python
RUN node /piston/api/src/installer install python 3.10.0 || true
RUN node /piston/api/src/installer install javascript 18.0.0 || true