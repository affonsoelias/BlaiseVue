unit uAppVersion;

{
  =============================================================================
  🛡️ BlaiseVue Application Metadata & Version Specification
  =============================================================================
  Auto-generated and synchronized by the BlaiseVue CLI (bv meta / bv license).
  
  OVERVIEW:
  This unit exposes compile-time application constants in pure Object Pascal,
  providing strongly typed access to project metadata defined in package.json:
  • APP_NAME:        Canonical application or library identifier.
  • APP_VERSION:     Semantic Versioning string (SemVer 2.0).
  • APP_AUTHOR:      Registered maintainer or author organization.
  • APP_LICENSE:     SPDX license identifier (e.g. MIT, Apache-2.0, LGPL-3.0).
  • APP_BUILD_DATE:  Build or synchronization timestamp (YYYY-MM-DD).

  USAGE:
  Import "uAppVersion" into any Pascal unit or .bv Single File Component to
  display version numbers, footer credits, about dialogs, or telemetry tags.
  =============================================================================
}

{$mode objfpc}{$H+}

interface

const
  APP_NAME = 'blaise-ui';
  APP_VERSION = '4.4.0';
  APP_AUTHOR = 'BlaiseVue Core Team';
  APP_LICENSE = 'Modified GNU LGPL v2.1 with Static Linking Exception';
  APP_BUILD_DATE = '2026-10-24';

implementation

end.
