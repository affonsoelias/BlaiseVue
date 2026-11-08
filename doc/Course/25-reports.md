# 📑 Module 25: Enterprise Reporting with Blaise Reports
**Generate native Vector PDF documents, Excel spreadsheets, thermal receipts, and print layouts in 100% Object Pascal.**

Every enterprise ERP, CRM, and accounting application eventually faces the same unavoidable requirement: generating professional invoices, billing statements, warehouse picking lists, and executive audit summaries.

In typical web projects, exporting a clean PDF is painful—often requiring heavy headless browser dependencies or third-party cloud services.

BlaiseVue solves this with **`@blaise-reports`**: an official enterprise reporting engine written in **100% pure Object Pascal**. It generates native **Vector PDF 1.4** files, **Excel (`.xlsx`)** spreadsheets, and **Thermal POS receipts** directly inside the browser or desktop app with zero external dependencies!

---

## 🏛️ 1. Architecture of BlaiseReports

```text
┌────────────────────────────────────────────────────────────────────────┐
│                   Data Source (TBVDataSet or JSON Array)               │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Bound via Fluent Builder
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                        TBVReport Engine (Pascal)                       │
│  - Branding: Title, Subtitle, Company, LogoText                        │
│  - Structure: Columns (field:Caption:format:align:width)               │
│  - Aggregates: aggSum, aggAverage, aggCount, aggMin, aggMax            │
│  - Pagination: RowsPerPage, Page X of Y footers                        │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Export Pipeline
          ┌─────────────────────────┼─────────────────────────┐
          ▼                         ▼                         ▼
┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
│ Native Vector PDF│      │  Excel (.xlsx)   │      │ Thermal Print POS│
│  Type1 Fonts     │      │ Open XML Package │      │ 80mm / 58mm POS  │
│  Multi-page xref │      │ Typed cell data  │      │ A4 Print Preview │
└──────────────────┘      └──────────────────┘      └──────────────────┘
```

---

## 📦 2. Installing Blaise Reports

To install the reporting package into your project:

```bash
bv lib install reports

# Aliases:
bv lib install blaise-reports
bv lib install @blaise-reports
```

This installs:
- `lib/blaise-reports/BlaiseReports.pas`: The fluent Pascal report builder.
- `<bv-report-viewer>`: An interactive Single File Component with live sheet preview and 1-click export buttons.
- `blaise-reports.css`: Print layouts and thermal receipt styling.

---

## 🚀 3. Creating a Report in Object Pascal

Generating a complete, professional sales invoice or audit report takes only a few lines of fluent Pascal:

```pascal
uses BVDataSet, BlaiseReports;

procedure PrintInvoice(OrdersDS: TBVDataSet);
var
  Report: TBVReport;
begin
  Report := TBVReport.Create(OrdersDS);
  
  Report
    .Title('Commercial Sales Invoice')
    .Subtitle('Fiscal Invoice #INV-2026-089')
    .Company('BlaiseVue Solutions Ltd.')
    .LogoText('BV-ENTERPRISE')
    .Header('Customer: Global Logistics Corp. | Tax ID: 88-192-491')
    .Footer('Thank you for your business! Payment due within 30 days.')
    .ThemeColor('#1e293b')
    .CurrencySymbol('$')
    .RowsPerPage(20)
    .Columns([
      'itemCode:Code:string:center:70',
      'description:Description:string:left:200',
      'qty:Qty:integer:center:50',
      'unitPrice:Unit Price:currency:right:90',
      'lineTotal:Total:currency:right:100'
    ])
    // Summary Aggregates
    .AddSummary('lineTotal', aggSum, 'Grand Total Invoice', 'currency')
    .AddSummary('qty', aggSum, 'Total Units Shipped', 'integer');

  // Trigger instant vector PDF download!
  Report.ExportPDF('Invoice_INV-2026-089.pdf');
end;
```

---

## 📤 4. Supported Export Formats

With the exact same `TBVReport` definition, you can export to any enterprise format:

### 1. Vector PDF 1.4 (`Report.ExportPDF`)
- Produces a valid, native PDF with vector banners and standard Type1 fonts (`/Helvetica` and `/Helvetica-Bold`).
- Automatic multi-page pagination with running page headers and footers (`"Page 1 of 3"`).
- Zebra-striped alternating rows for maximum readability.
- Generates a valid internal cross-reference (`xref`) table.

### 2. Real Excel Spreadsheets (`Report.ExportExcel`)
- Generates a real Office Open XML (`.xlsx`) package.
- Preserves strongly-typed cell formats (Numbers remain numeric cells, not text strings!).
- Formats column headers with theme colors and adds aggregate summary formulas.

### 3. RFC 4180 CSV Streams (`Report.ExportCSV`)
- Fast streaming CSV export with configurable delimiters (`,` or `;`).
- Automatic quote escaping and optional UTF-8 BOM (`\uFEFF`) for direct Excel double-click compatibility.

### 4. Thermal Receipt & POS Layouts (`Report.PrintThermal`)
- Special print layout optimized for **80mm** and **58mm** thermal receipt printers commonly used in point-of-sale terminals.

---

## 🖥️ 5. Embedding the `<bv-report-viewer>` Component

If you want your users to preview the document on screen before downloading, embed the drop-in viewer:

```html
<template>
  <div class="report-container">
    <h2>Billing & Financial Reports</h2>

    <!-- Interactive Report Viewer Component -->
    <bv-report-viewer 
      :report="currentReport"
      :show-pdf-button="true"
      :show-excel-button="true"
      :show-print-button="true">
    </bv-report-viewer>
  </div>
</template>

<script>
uses BVDataSet, BlaiseReports;

var
  currentReport: TBVReport;

mounted:
  procedure;
  begin
    // Initialize report definition
    currentReport := TBVReport.Create(ordersDataSet);
    currentReport
      .Title('Quarterly Financial Summary')
      .Columns([
        'date:Date:string:center:80',
        'account:Account:string:left:160',
        'amount:Amount:currency:right:100'
      ])
      .AddSummary('amount', aggSum, 'Net Balance', 'currency');
  end;
</script>
```

---

## 🏋️ Practical Exercise

1. Install Blaise Reports using `bv lib install reports`.
2. In your view, create a `TBVDataSet` with five order records (columns: `id`, `product`, `quantity`, `price`, `total`).
3. Build a `TBVReport` bound to this dataset with `aggSum` for total revenue.
4. Add a button titled `"📄 Download PDF"` that executes `Report.ExportPDF('Sales_Report.pdf')`.
5. Open the downloaded PDF file in Adobe Acrobat or Google Chrome and verify that the vector typography, borders, and summary rows render cleanly!

---

## 📖 Deeper Technical Reference

- **[BlaiseReports: Native Vector PDF, Excel & Print Engine Manual](../Documentation/51-blaise-reports.md)**: Exhaustive manual detailing binary PDF generation, SpreadsheetML specifications, aggregate calculation algorithms, and thermal printer CSS rules.

---

[⬅️ Module 24: Data Visualization with Blaise Charts](24-charts.md) | [🏠 Course Index](README.md) | [Module 26: Visual Development with Blaise Studio ➡️](26-studio.md)
