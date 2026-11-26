unit uBVStrings;

{ Texts of the BlaiseVue IDE package shown to the user.

  English is the base. The IDE translates these resourcestrings at start-up from
  languages/ubvstrings.<lang>.po, by the language chosen in
  Tools -> Options -> Environment -> General -> Language (or the system's). }

{$mode objfpc}{$H+}

interface

resourcestring
  // Tools -> BlaiseVue
  rsBVCheckComponent = 'Check Active Component (.bv)';
  rsBVFormatComponent = 'Format Active Component (.bv) (Ctrl+Shift+F)';
  rsBVSyncProject = 'Sync Lazarus Project (.lpi)';
  rsBVListPaths = 'List Compiler Search Paths (bv path)';
  rsBVRunTests = 'Run Test Suite (bv test)';
  rsBVPreview = 'Preview Active Component in the Browser (bv dev)';
  rsBVStopPreview = 'Stop Preview Server (bv dev)';

  // dialogs and the Messages window
  rsBVNoActiveFile = 'No active file in the Lazarus editor.';
  rsBVNotBVFile = 'The active file (%s) is not a BlaiseVue component (.bv).';
  rsBVCheckHeader = '=== [BlaiseVue AST Check] Checking: %s ===';
  rsBVCheckOK = 'Success: the syntax and AST of the component are sound!';
  rsBVCheckFailed = 'Failure: validation errors found in the component.';
  rsBVFormatDone = 'Component formatted: %s';
  rsBVFormatUnchanged = 'The component is already formatted: %s';
  rsBVPathsHeader = '=== [BlaiseVue Path] Units Mapped in the Compiler ===';
  rsBVTestsHeader = '=== [BlaiseVue Test] Running the Test Suite ===';
  rsBVSyncHeader = '=== [BlaiseVue Lazarus] Syncing the Project (.lpi) ===';
  rsBVNoProjectRoot = 'No BlaiseVue project (src/app.bv) was found above %s.';
  rsBVNoRoute = '%s has no route of its own in the router: opening the home page of the app.';
  rsBVDevStarting = '=== [BlaiseVue Dev] Starting "bv dev" in %s (save the .bv to refresh the browser) ===';
  rsBVDevEnded = 'The preview server has ended (code %d).';
  rsBVNoDevServer = 'No preview server is running.';
  rsBVDevStopped = 'Preview server stopped.';

  // File -> New...
  rsBVCategoryDescription = 'Reactive Components (.bv) and SPA Pages for BlaiseVue';
  rsBVComponentName = 'BlaiseVue Component (.bv)';
  rsBVComponentDescription = 'Create a new reactive BlaiseVue Single File Component (.bv) with template, Pascal script, and scoped CSS style.';
  rsBVViewName = 'BlaiseVue Page View (.bv)';
  rsBVViewDescription = 'Create a new routed Page View (.bv) with layout template, page controller, and styles for BlaiseVue SPA router.';

implementation

end.
