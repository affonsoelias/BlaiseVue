unit wasm.pas2js.memutils;

{$mode ObjFPC}

interface

uses js, wasienv;

type

  { TWasiMemUtils }
  TMemoryGrowHandler = reference to procedure(aPages : Integer);

  TWasiMemUtils = class(TImportExtension)
  private
    FOnMemoryGrow: TMemoryGrowHandler;
  Protected
    procedure MemoryGrowNotification(aPages : integer); virtual;
  Public
    procedure FillImportObject(aObject: TJSObject); override;
    function ImportName: String; override;
    class function RegisterName : string; override;
    property OnMemoryGrow : TMemoryGrowHandler Read FOnMemoryGrow Write FOnMemoryGrow;
  end;

implementation

{ TWasiMemUtils }

procedure TWasiMemUtils.MemoryGrowNotification(aPages: integer);
begin
  if assigned(OnMemoryGrow) then
    OnMemoryGrow(aPages);
end;

procedure TWasiMemUtils.FillImportObject(aObject: TJSObject);
begin
  aObject['wasm_memory_grow_notification']:=@MemoryGrowNotification;
end;

function TWasiMemUtils.ImportName: String;
begin
  Result:='wasmmem';
end;

class function TWasiMemUtils.RegisterName: string;
begin
  Result:='MemUtils';
end;

initialization
  TWasiMemUtils.Register;
end.

