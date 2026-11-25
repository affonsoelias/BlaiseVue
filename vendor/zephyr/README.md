# Zephyr — Native HTTP/1.1 & WebSocket Engine for BlaiseVue (Aether)

Zephyr is a security-first, zero-GC backend engine written natively in **Aether** (`vendor/zephyr/`) for BlaiseVue full-stack applications.

## Project Structure (Standard Aether Layout)
```text
vendor/zephyr/
├── aether.json              # Aether project manifest (backend, entry, paths.aether -> ["src"])
├── .gitignore
├── README.md
├── src/
│   ├── zephyr.aeth          # Core server, declarative routing & HTTP/1.1 Keep-Alive + WS loop
│   ├── zephyr_http.aeth     # Zero-dependency HTTP/1.1 parser & response serializer
│   ├── zephyr_security.aeth # RateLimiter (IP/Token), path traversal guard, CORS & OWASP headers
│   └── zephyr_ws.aeth       # Pure Aether RFC 3174 SHA-1, RFC 4648 Base64 & RFC 6455 WS frames
├── tests/
│   └── zephyr_test.aeth     # Dual-backend unit test suite (aetherc test --target=all)
└── examples/
    └── zephyr_demo.aeth     # Reference API + WebSocket server (--self-test / --port / --max-conns)
```

## Quick Commands (Inside `vendor/zephyr/`)
- **Run unit test suite on both backends (FPC & GCC C99):**
  ```bash
  aetherc test --target=all
  ```
- **Build production demo server (GCC C99 `-O3 -flto -s`):**
  ```bash
  aetherc build --release
  ```
- **Build development demo server (Free Pascal):**
  ```bash
  aetherc build --target=pascal
  ```
- **BlaiseVue project CLI integration:**
  ```bash
  bv zephyr init
  bv zephyr build [--target=c|pascal] [--release]
  bv zephyr run [--port 8090]
  bv zephyr status
  ```
