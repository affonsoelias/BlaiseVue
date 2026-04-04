program basic;

{$MODE OBJFPC}
{$MODESWITCH EXTERNALCLASS}

uses
  Web,
  jsPDF;

var
  doc: TjsPDF;
  opt: string;
  edSelExample: TJSHTMLSelectElement;
  btDownload: TJSHTMLButtonElement;
  ebPreview: TJSHTMLEmbedElement;
  ImgData:string = 'data:image/png;base64,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';

procedure edSelExampleChange;
begin
  doc := TjsPDF.new;
  opt := edSelExample.value;
  case opt of
    'hello': doc.text('Hello world. I love TjsPDF! :-)', 10, 10);
    'font':
    begin
      doc.text('This is the default font.', 20, 20);

      doc.setFont('courier');
      doc.setFontStyle('normal');
      doc.text('This is courier normal.', 20, 30);

      doc.setFont('times');
      doc.setFontStyle('italic');
      doc.text('This is times italic.', 20, 40);

      doc.setFont('helvetica');
      doc.setFontStyle('bold');
      doc.text('This is helvetica bold.', 20, 50);

      doc.setFont('courier');
      doc.setFontStyle('bolditalic');
      doc.text('This is courier bolditalic.', 20, 60);

      doc.setFont('times');
      doc.setFontStyle('normal');
      doc.text('This is centred text.', 105, 80, nil, nil, 'center');
      doc.text('And a little bit more underneath it.', 105, 90, nil, nil, 'center');
      doc.text('This is right aligned text', 200, 100, nil, nil, 'right');
      doc.text('And some more', 200, 110, nil, nil, 'right');
      doc.text('Back to left',20, 120);

      doc.text('10 degrees rotated', 20, 140, nil, 10);
      doc.text('-10 degrees rotated', 20, 160, nil, -10);
    end;
    'two_page':
    begin
      doc.text('Hello world!', 20, 20);
      doc.text('This is client-side Javascript, pumping out a PDF.', 20, 30);
      doc.addPage('l', 'a6');
      doc.text('Do you like that?', 20, 20);
    end;
    'circles':
    begin
      doc.ellipse(40, 20, 10, 5);

      doc.setFillColor(0,0,255);
      doc.ellipse(80, 20, 10, 5, 'F');

      doc.setLineWidth(1);
      doc.setDrawColor(0);
      doc.setFillColor(255,0,0);
      doc.circle(120, 20, 5, 'FD');
    end;
    'lines':
    begin
      doc.line(20, 20, 60, 20); // horizontal line

      doc.setLineWidth(0.5);
      doc.line(20, 25, 60, 25);

      doc.setLineWidth(1);
      doc.line(20, 30, 60, 30);

      doc.setLineWidth(1.5);
      doc.line(20, 35, 60, 35);

      doc.setDrawColor(255,0,0); // draw red lines

      doc.setLineWidth(0.1);
      doc.line(100, 20, 100, 60); // vertical line

      doc.setLineWidth(0.5);
      doc.line(105, 20, 105, 60);

      doc.setLineWidth(1);
      doc.line(110, 20, 110, 60);

      doc.setLineWidth(1.5);
      doc.line(115, 20, 115, 60);
    end;
    'rectangles':
    begin
      // Empty square
      doc.rect(20, 20, 10, 10);

      // Filled square
      doc.rect(40, 20, 10, 10, 'F');

      // Empty red square
      doc.setDrawColor(255,0,0);
      doc.rect(60, 20, 10, 10);

      // Filled square with red borders
      doc.setDrawColor(255,0,0);
      doc.rect(80, 20, 10, 10, 'FD');

      // Filled red square
      doc.setDrawColor(0);
      doc.setFillColor(255,0,0);
      doc.rect(100, 20, 10, 10, 'F');

       // Filled red square with black borders
      doc.setDrawColor(0);
      doc.setFillColor(255,0,0);
      doc.rect(120, 20, 10, 10, 'FD');

      // Black square with rounded corners
      doc.setDrawColor(0);
      doc.setFillColor(255, 255, 255);
      doc.roundedRect(140, 20, 10, 10, 3, 3, 'FD');
    end;
    'triangles':
    begin
      doc.triangle(60, 100, 60, 120, 80, 110, 'FD');

      doc.setLineWidth(1);
      doc.setDrawColor(255,0,0);
      doc.setFillColor(0,0,255);
      doc.triangle(100, 100, 110, 100, 120, 130, 'FD');
    end;
    'image':
    begin
      doc.addImage(ImgData,'PNG',20,20);
      doc.text('This Cool!', 20, 40);
    end;
  end;
  ebPreview.src := doc.output_('datauristring');
  btDownload.disabled := opt = '';
end;

procedure btDownloadClick;
begin
  doc.save(opt + '.pdf');
end;

begin
  edSelExample := TJSHTMLSelectElement(document.getElementById('edSelExample'));
  edSelExample.addEventListener('change', @edSelExampleChange);
  btDownload := TJSHTMLButtonElement(document.getElementById('btDownload'));
  btDownload.addEventListener('click', @btDownloadClick);
  ebPreview := TJSHTMLEmbedElement(document.getElementById('ebPreview'));
end.
