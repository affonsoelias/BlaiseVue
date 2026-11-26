# Zephyr — Native HTTP/1.1 & WebSocket Engine for BlaiseVue (DelSafe)

Zephyr is a security-first, zero-GC backend engine written natively in **DelSafe** (`vendor/zephyr/`) for BlaiseVue full-stack applications.

## Project Structure (Standard DelSafe Layout)
```text
vendor/zephyr/
├── delsafe.json              # DelSafe project manifest (backend, entry, paths.delsafe -> ["src"])
├── .gitignore
├── README.md
├── src/
│   ├── zephyr.dels          # Core server, declarative routing & HTTP/1.1 Keep-Alive + WS loop
│   ├── zephyr_http.dels     # Zero-dependency HTTP/1.1 parser & response serializer
│   ├── zephyr_security.dels # RateLimiter (IP/Token), path traversal guard, CORS & OWASP headers
│   └── zephyr_ws.dels       # Pure DelSafe RFC 3174 SHA-1, RFC 4648 Base64 & RFC 6455 WS frames
├── tests/
│   └── zephyr_test.dels     # Dual-backend unit test suite (delsafec test --target=all)
└── examples/
    └── zephyr_demo.dels     # Reference API + WebSocket server (--self-test / --port / --max-conns)
```

## Quick Commands (Inside `vendor/zephyr/`)
- **Run unit test suite on both backends (FPC & GCC C99):**
  ```bash
  delsafec test --target=all
  ```
- **Build production demo server (GCC C99 `-O3 -flto -s`):**
  ```bash
  delsafec build --release
  ```
- **Build development demo server (Free Pascal):**
  ```bash
  delsafec build --target=pascal
  ```
- **BlaiseVue project CLI integration:**
  ```bash
  bv zephyr init
  bv zephyr build [--target=c|pascal] [--release]
  bv zephyr run [--port 8090]
  bv zephyr status
  ```
