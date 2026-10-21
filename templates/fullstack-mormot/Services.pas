unit Services;

{
  Services - Shared Service Contracts & DTOs (mORMot 2 SOA)
  ---------------------------------------------------------
  Shared between the native mORMot 2 backend server and the
  BlaiseVue frontend client for 100% end-to-end compile-time
  type safety.
}

{$mode objfpc}

interface

uses
  SysUtils
  {$IFNDEF PAS2JS}
  , mormot.core.base
  {$ENDIF}
  ;

{$IFDEF PAS2JS}
type
  RawUtf8 = string;
{$ENDIF}

type
  { Customer Data Transfer Object }
  TCustomer = record
    ID: Integer;
    Name: RawUtf8;
    Email: RawUtf8;
    Phone: RawUtf8;
    Active: Boolean;
    CreatedAt: RawUtf8;
  end;
  TCustomerDynArray = array of TCustomer;

  { Product Data Transfer Object }
  TProduct = record
    ID: Integer;
    Name: RawUtf8;
    Price: Double;
    Stock: Integer;
    Category: RawUtf8;
    CreatedAt: RawUtf8;
  end;
  TProductDynArray = array of TProduct;

  { System Info DTO }
  TSystemInfo = record
    Status: RawUtf8;
    Framework: RawUtf8;
    Engine: RawUtf8;
    Version: RawUtf8;
    UptimeSeconds: Int64;
    ItemsCount: Integer;
  end;

  { Service Interfaces inheriting from IInvokable }
  ICustomerService = interface(IInvokable)
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function GetAll: TCustomerDynArray;
    function GetById(Id: Integer): TCustomer;
    function Save(const Customer: TCustomer): TCustomer;
    function Delete(Id: Integer): Boolean;
  end;

  IProductService = interface(IInvokable)
    ['{B2C3D4E5-F6A7-8901-BCDE-F12345678901}']
    function GetAll: TProductDynArray;
    function GetById(Id: Integer): TProduct;
    function Save(const Product: TProduct): TProduct;
    function Delete(Id: Integer): Boolean;
  end;

  ISystemService = interface(IInvokable)
    ['{C3D4E5F6-A7B8-9012-CDEF-123456789012}']
    function GetStatus: string;
    function Ping(const Msg: string): string;
    function Echo(const Text: string): string;
  end;

implementation

end.
