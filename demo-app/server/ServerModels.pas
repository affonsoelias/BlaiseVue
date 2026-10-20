unit ServerModels;

{
  ServerModels - Shared Data Transfer Objects (DTO) & Records
  -----------------------------------------------------------
  Definitions of data contracts shared across the mORMot 2
  backend services and serialized as JSON for the BlaiseVue
  reactive frontend.
}

{$I mormot.defines.inc}

interface

uses
  sysutils,
  mormot.core.base;

type
  { Shared Item Record }
  TBlaiseItem = record
    ID: Integer;
    Title: RawUtf8;
    Category: RawUtf8;
    Done: Boolean;
    CreatedAt: RawUtf8;
  end;
  TBlaiseItemDynArray = array of TBlaiseItem;

  { Server Status DTO }
  { User & Authentication Records }
  TAuthUser = record
    ID: Integer;
    Name: RawUtf8;
    Email: RawUtf8;
    Role: RawUtf8;
    CreatedAt: RawUtf8;
  end;
  TAuthUserDynArray = array of TAuthUser;

  TUserWithPassword = record
    User: TAuthUser;
    PasswordHash: RawUtf8;
  end;
  TUserWithPasswordDynArray = array of TUserWithPassword;

  TServerStatus = record
    Status: RawUtf8;
    Framework: RawUtf8;
    Engine: RawUtf8;
    Version: RawUtf8;
    Port: Integer;
    UptimeSeconds: Int64;
    RequestsServed: Int64;
    ActiveWebSockets: Integer;
    ItemsCount: Integer;
  end;

  { Shared Product Record }
  TProduct = record
    ID: Integer;
    Name: RawUtf8;
    Price: Double;
    Stock: Integer;
    Category: RawUtf8;
    CreatedAt: RawUtf8;
  end;
  TProductDynArray = array of TProduct;

  { Shared Customer Record }
  TCustomer = record
    ID: Integer;
    Name: RawUtf8;
    Email: RawUtf8;
    Phone: RawUtf8;
    Active: Boolean;
    CreatedAt: RawUtf8;
  end;
  TCustomerDynArray = array of TCustomer;

implementation

end.
