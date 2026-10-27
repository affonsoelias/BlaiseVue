program reportsview_view_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uBVReportViewer, uReportsView;

var
  Wrapper: TWrapper;

begin
  Register_uBVReportViewer;
  Register_uReportsView;

  Describe('View: ReportsView (v5.0 BlaiseReports Showcase)', procedure
    begin
      It('should initialize ReportsView and render <bv-report-viewer> and PDF/Excel/CSV export controls', procedure
        var
          Html: string;
        begin
          Wrapper := Mount('reports-view-page');
          Expect(Wrapper.Element <> nil).ToBe(True);
          Expect(Wrapper.Find('.reports-view-page')).ToBeDefined;
          Expect(Wrapper.Find('.bv-report-viewer-root')).ToBeDefined;

          Html := Wrapper.HTML;
          Expect(Pos('BlaiseReports', Html) > 0).ToBe(True);
          Expect(Pos('Acme Cloud Corp', Html) > 0).ToBe(True);
          Expect(Pos('%PDF-1.4', Html) > 0).ToBe(True);
        end);
    end);
end.
