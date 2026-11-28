# Changelog

All notable changes to **BlaiseVue** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Automated GitHub Pages deployment workflow (`.github/workflows/pages.yml`) publishing the live `demo-app` showcase and component docs.
- Automatically generate a starter `CHANGELOG.md` (`v0.1.0`) during `bv create`, plus `demo-app/CHANGELOG.md`.
- Added Zephyr backend evolution roadmap (`vendor/zephyr/ROADMAP.md`, `v0.1.0` -> `v1.0.0`) and `vendor/zephyr/CHANGELOG.md`.
- Multiplatform GitHub Actions CI workflow (`.github/workflows/ci.yml`) building `bv` and running CLI smoke + SDK unit test suites across Windows, Linux, and macOS.
- Zero-dependency CLI and native RFC 6455 WebSocket integration smoke suite (`tests/cli/cli_smoke.mjs`).
- Unit test suite for `BVDevTools` (`tests/core/devtools.test.pas`).

### Changed
- Decoupled `BlaiseReports` helper wrappers from `BVPascalDX` and replaced unconditional all-unit imports in `BlaiseVue`, `BVCompiler`, and generated `uApp`/`u<Component>` units with automatic feature detection in `bv` (reducing clean starter release bundle size from `495.9 KB` / `120.5 KB` gzip / `34` modules to `168.5 KB` / `30.9 KB` gzip / `15` modules).
- Removed tracked `node_modules/` directory from the Git repository index.
- Separated framework version (`window.__BV_FRAMEWORK_VERSION__`) from application version (`window.__BV_APP_VERSION__`), adding an `App Version` row to the floating `BVDevTools` overlay and defaulting newly created projects to `0.1.0`.
- Standardized CLI Capacitor recommendations to `bv capacitor` while retaining `bv mobile` as an alias.

### Fixed
- Skipped optional DelSafe test fixtures in `bv test --sdk` when `delsafec` is not installed so pure-Pascal SDK suites pass in clean CI environments.
- Used `textContent` in the `BVDevTools` event timeline logger for consistent browser and `jsdom` compatibility.
- Fixed horizontal clipping on `BVDataGrid` (`Data` page) and CRUD tables in mobile and Capacitor viewports.
- Automatically injected the active CLI framework version into `BVDevTools`, `BVCompiler`, and clean starter projects created with `bv create <name>`.

## [0.1.1] - 2026-11-28

### Added
- Native zero-dependency RFC 6455 WebSocket servers in `bin/dev-server.js` and `bin/studio-server.js` (no external `npm install ws` required).
- Automatic compile-time and release versioning (`BV_BUILD_VERSION`) across CLI banners, `package.json`, and `studio-server.js`.
- On-demand Vitest installation during `bv test` so `bv create` finishes instantaneously without blocking on `npm install`.
- Smart GitHub Actions `check` gate to skip scheduled `nightly` builds when `main` has no new commits since the last nightly build.

### Fixed
- Fixed mobile Capacitor clipping on `BVInputGroup`, `I18nLabView`, `ProductView`, `CustomerView`, and generated `dist/docs/index.html`.
- Aligned `README.md` with prebuilt releases, zero-npm workflows, and the `v0.1.x` series.

## [0.1.0] - 2026-11-27

### Added
- Automated cross-platform prebuilt binary releases (Windows, Linux, macOS) via GitHub Actions with SHA-256 checksums.
- One-line installers (`scripts/install.ps1` and `scripts/install.sh`) and atomic CLI self-update commands (`bv self-update`, `bv channel`, `bv rollback`, `bv framework`).
- On-demand downloads for `demo-app` (`bv create --demo`) and Synopse mORMot 2 integration.
- Greek (`el`) i18n locale showcase and Zero-ASM demo view refinements.

[Unreleased]: https://github.com/affonsoelias/BlaiseVue/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/affonsoelias/BlaiseVue/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/affonsoelias/BlaiseVue/releases/tag/v0.1.0
