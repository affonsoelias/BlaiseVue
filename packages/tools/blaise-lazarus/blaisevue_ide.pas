{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit blaisevue_ide;

{$warn 5023 off : no warning about unused units}
interface

uses
  uBVSynMultiSyn, uBVFileDescriptor, uBVFormatter, uBVAutoComplete, 
  uBVToolsMenu, uBlaiseVueIDEReg, uBVStrings, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uBlaiseVueIDEReg', @uBlaiseVueIDEReg.Register);
end;

initialization
  RegisterPackage('blaisevue_ide', @Register);
end.
