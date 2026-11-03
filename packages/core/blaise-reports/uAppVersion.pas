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

{$mode objfpc}

interface

const
  APP_NAME    = 'blaise-reports';
  APP_VERSION = '5.0.0';

implementation

end.
