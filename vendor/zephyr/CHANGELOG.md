# Changelog

All notable changes to **Zephyr** (`vendor/zephyr`) will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Created [ROADMAP.md](ROADMAP.md) defining the `v0.1.0` -> `v1.0.0` evolution plan combining Horse-style routing/DX ergonomics with full mORMot 2 enterprise capabilities (ORM/Multi-DB, Interface SOA/RPC, RBAC/JWT/Crypto, Caching/Jobs/DDD, `TSynLog`-style observability, and clustering).
- Added [CHANGELOG.md](CHANGELOG.md) to track Zephyr backend releases.

## [0.1.0] - 2026-11-28

### Added
- Core HTTP/1.1 Keep-Alive server and declarative route registration (`src/zephyr.dels`: `AddGet`, `AddPost`, `AddPut`, `AddDelete`, `AddPatch`, `AddWs`, `SetStaticDir`, `DetectMimeType`, and JSON/HTTP status response helpers).
- Zero-dependency HTTP/1.1 request parser and response serializer (`src/zephyr_http.dels`).
- Security subsystem (`src/zephyr_security.dels`): IP/token `RateLimiter`, path traversal protection, CORS headers, and OWASP security headers.
- Pure DelSafe RFC 6455 WebSocket implementation (`src/zephyr_ws.dels`) including RFC 3174 SHA-1, RFC 4648 Base64, handshake accept-key calculation, and text frame encode/decode.
- Reference server application (`examples/zephyr_demo.dels`) showcasing `[derive(JSON, Equals)]`, `contract require/ensure`, and built-in `--self-test`.
- Dual-backend unit test suite (`tests/zephyr_test.dels` via `delsafec test --target=all` for Free Pascal and GCC C99) and standard `delsafe.json` manifest (`v0.1.0`).
- BlaiseVue CLI workflow integration (`bv zephyr init`, `bv zephyr build`, `bv zephyr run`, `bv zephyr status`).
