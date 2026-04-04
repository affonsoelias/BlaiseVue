program demoreadfileinput;

uses
  Web,JS;

const
  DownloadFileName = 'result.txt';
var
  GInput: TJSHTMLInputElement;
  Goutput: TJSHTMLAnchorElement;
  LReader: TJSFileReader;
  LFile: TJSHTMLFile;
  LFileContent: String;
begin
  GInput := TJSHTMLInputElement(Document.GetElementByID('input'));
  Goutput := TJSHTMLAnchorElement(Document.GetElementByID('output'));

  GInput.OnChange := function (AFileInputChangeEvent: TEventListenerEvent): Boolean
  begin
    LFile := GInput.Files[0];

    LReader := TJSFileReader.New;
    LReader.OnLoad := function (AFileLoadEvent: TEventListenerEvent): Boolean
    begin
      LFileContent := String(TJSFileReader(AFileLoadEvent.Target).Result);
      // begin edit
      LFileContent := '<pre>' + LineEnding + LFileContent + LineEnding + '</pre>';
      // end edit

      // need a way to assign back modified LFileContent to LFile or create a new TJS(HTMLFile|Blob) with LFileContent as its content
      // the Web API standard provides the way as a constructor parameter, but is missing from the declaration

      LFile := TJSHTMLFile.New(TJSString.New(LFileContent), DownloadFileName);
      Goutput.HRef := TJSURL.createObjectURL(LFile);
      Goutput.Download := DownloadFileName;
      Goutput.Click;
      TJSURL.revokeObjectURL(Goutput.HRef);
    end;
    LReader.ReadAsText(LFile);
  end;
end.

