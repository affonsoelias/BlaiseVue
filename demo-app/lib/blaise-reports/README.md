# BlaiseReports (`packages/blaise-reports`)

**Native Vector PDF, Excel (`.xlsx`), CSV & Thermal/A4 Print Engine in Pure Object Pascal for BlaiseVue 5.0.**

## Features

1. **Declarative Fluent `TBVReport` Builder (`BlaiseReports.pas`)**:
   - Binds directly to `TBVDataSet` or arrays of records.
   - Fluent configuration of titles, headers, footers, company logos, columns, and aggregate summaries (`aggSum`, `aggAverage`, `aggCount`, `aggMin`, `aggMax`).

2. **Multi-Format Export Targets**:
   - **Vector PDF 1.4 (`ExportPDF`)**: Pure vector PDF generation with automatic pagination, running headers/footers, `"Page X of Y"`, zebra-striped tables, and summary bands.
   - **Native Excel Spreadsheet (`ExportExcel`)**: Strongly typed cells (`Currency`, `Number`, `Integer`, `Boolean`, `String`) and custom styles.
   - **RFC 4180 CSV (`ExportCSV`)**: Delimiter-configurable CSV export with UTF-8 BOM for direct Excel compatibility.
   - **Print & Thermal POS Layouts (`PrintPreview`)**: Tailored `@media print` and `@page` rules for A4 Portrait/Landscape, Letter, and Thermal POS (80mm / 58mm) receipt printers.

3. **Reactive `<bv-report-viewer>` Component (`BVReportViewer.bv`)**:
   - Interactive live preview sheet with 1-click export buttons and layout selector.

## Quick Example

```pascal
Report := TBVReport.Create(SalesDataSet);
Report.Title('Q4 Executive Sales Summary')
      .Header('Company: Enterprise Corp | Date: 2026-10-26')
      .Columns(['InvoiceNo', 'Customer', 'SaleDate', 'TotalAmount'])
      .AddSummary('Total Revenue', 'TotalAmount', aggSum)
      .AddSummary('Average Order', 'TotalAmount', aggAverage)
      .ExportPDF('sales_summary.pdf');
```
