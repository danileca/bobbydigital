#!/bin/bash
  set -e

  # Start Chromium with explicit IPv4 binding
  # Fixes IPv4/IPv6 mismatch where OpenClaw connects to 127.0.0.1 but chromium binds to [::1]
  echo "[entrypoint] Starting Chromium..."
  /usr/bin/chromium \
      --headless=new \
      --no-sandbox \
      --disable-gpu \
      --disable-dev-shm-usage \
      --remote-debugging-address=127.0.0.1 \
      --remote-debugging-port=18800 \
      --user-data-dir=/data/.chromium \
      &

  # Wait for CDP to be ready
  for i in {1..20}; do
      if curl -s http://127.0.0.1:18800/json/version > /dev/null 2>&1; then
          echo "[entrypoint] Chromium ready"
          break
      fi
      sleep 0.5
  done

  # Start the server
  exec "$@"
