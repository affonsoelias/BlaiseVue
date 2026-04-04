{
    This file is part of the Pas2JS run time library.
    Copyright (c) 2018 by Mattias Gaertner

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$IFNDEF FPC_DOTTEDUNITS}
unit RTTI;
{$ENDIF}

{$mode objfpc}
{$ModeSwitch advancedrecords}

interface

uses
{$IFDEF FPC_DOTTEDUNITS}
  JSApi.JS, System.RTLConsts, System.Types, System.SysUtils, System.TypInfo;
{$ELSE}
  JS, RTLConsts, Types, SysUtils, TypInfo;
{$ENDIF}

resourcestring
  SErrInvokeInvalidCodeAddr = 'CodeAddress is not a function';
  SErrTypeIsNotEnumerated  = 'Type %s is not an enumerated type';
  SErrDimensionOutOfRange = 'Dimension %d out of range [0..%d]';

type
  ERtti = Class(Exception);
  { TValue }

  TValue = record
  private
    FTypeInfo: TTypeInfo;
    FData: JSValue;
    FReferenceVariableData: Boolean;
    function GetData: JSValue;
    function GetIsEmpty: boolean;
    function GetTypeKind: TTypeKind;

    procedure SetData(const Value: JSValue);
  public
    class function Empty: TValue; static;
    generic class function From<T>(const Value: T): TValue; static;
    class function FromArray(TypeInfo: TTypeInfo; const Values: specialize TArray<TValue>): TValue; static;
    class function FromJSValue(v: JSValue): TValue; static;
    class function FromOrdinal(ATypeInfo: TTypeInfo; AValue: JSValue): TValue; static;
    class function FromVarRec(const aValue: TVarRec): TValue; static;

    class procedure Make(const ABuffer: JSValue; const ATypeInfo: PTypeInfo; var Result: TValue); overload; static;
    generic class procedure Make<T>(const Value: T; var Result: TValue); overload; static;

    function AsBoolean: boolean;
    function AsClass: TClass;
    function AsExtended: Extended;
    function AsDouble: Double;
    function AsDateTime: TDateTime;
    function AsInteger: Integer;
    function AsInterface: IInterface;
    function AsJSValue: JSValue;
    function AsNativeInt: NativeInt;
    function AsNativeUInt: NativeUInt;
    function AsObject: TObject;
    function AsOrdinal: NativeInt;
    function AsString: string;
    function AsWideChar: WideChar;
    function AsCurrency: Currency;
    function TryAsOrdinal(out AResult: nativeint): boolean;
    generic function AsType<T>: T;
    function AsUnicodeString: UnicodeString;
    function Cast(ATypeInfo: TTypeInfo; const EmptyAsAnyType: Boolean = True): TValue; overload;
    generic function Cast<T>(const EmptyAsAnyType: Boolean = True): TValue; overload;
    function IsType(ATypeInfo: TTypeInfo; const EmptyAsAnyType: Boolean = True): Boolean; overload;
    generic function IsType<T>(const EmptyAsAnyType: Boolean = True): Boolean; overload;
    function GetArrayElement(aIndex: SizeInt): TValue;
    function GetArrayLength: SizeInt;
    function GetReferenceToRawData: Pointer;
    function IsArray: boolean;
    function IsClass: boolean;
    function IsObject: boolean;
    function IsObjectInstance: boolean;
    function IsOrdinal: boolean;
    function ToString: String; overload;
    function ToString(const AFormatSettings: TFormatSettings): String; overload;
    function TryCast(ATypeInfo: TTypeInfo; out AResult: TValue; const EmptyAsAnyType: Boolean = True): Boolean;

    procedure SetArrayElement(aIndex: SizeInt; const AValue: TValue);
    procedure SetArrayLength(const Size: SizeInt);

    property IsEmpty: boolean read GetIsEmpty; // check if nil or undefined
    property Kind: TTypeKind read GetTypeKind;
    property TypeInfo: TTypeInfo read FTypeInfo;
  end;
  TValueArray = array of TValue;

  TRttiType = class;
  TRttiInstanceType = class;
  TRttiInstanceExternalType = class;

  { TRTTIContext }

  TRTTIContext = record
  public
    class function Create: TRTTIContext; static;
    procedure Free;

    function FindType(const AQualifiedName: String): TRttiType;
    function GetType(aTypeInfo: PTypeInfo): TRTTIType; overload;
    function GetType(aClass: TClass): TRTTIType; overload;
    function GetTypes: specialize TArray<TRttiType>;

    class procedure KeepContext; static;
    class procedure DropContext; static;
  end;

  { TRttiObject }

  TRttiObject = class abstract
  private
    FAttributesLoaded: Boolean;
    FAttributes: TCustomAttributeArray;
    FParent: TRttiObject;
    FHandle: Pointer;
  protected
    function LoadCustomAttributes: TCustomAttributeArray; virtual;
  public
    constructor Create(AParent: TRttiObject; AHandle: Pointer); virtual;

    destructor Destroy; override;

    function GetAttributes: TCustomAttributeArray;
    generic function GetAttribute<T: TCustomAttribute>: T;
    function GetAttribute(const Attribute: TCustomAttributeClass): TCustomAttribute;
    generic function HasAttribute<T: TCustomAttribute>: Boolean;
    function HasAttribute(const Attribute: TCustomAttributeClass): Boolean;

    property Attributes: TCustomAttributeArray read GetAttributes;
    property Handle: Pointer read FHandle;
    property Parent: TRttiObject read FParent;
  end;

  { TRttiNamedObject }

  TRttiNamedObject = class(TRttiObject)
  protected
    function GetName: string; virtual;
  public
    property Name: string read GetName;
  end;


  { TRttiMember }

  TMemberVisibility = (
    mvPrivate,
    mvProtected,
    mvPublic,
    mvPublished);

  TRttiMember = class(TRttiNamedObject)
  private
  protected
    function GetMemberTypeInfo: TTypeMember;
    function GetName: String; override;
    function GetParent: TRttiType;
    function GetStrictVisibility: Boolean; virtual;
    function GetVisibility: TMemberVisibility;
    function LoadCustomAttributes: TCustomAttributeArray; override;
  public
    constructor Create(AParent: TRttiType; ATypeInfo: TTypeMember); reintroduce;

    property MemberTypeInfo: TTypeMember read GetMemberTypeInfo;
    property Parent: TRttiType read GetParent;
    Property StrictVisibility: Boolean Read GetStrictVisibility;
    property Visibility: TMemberVisibility read GetVisibility;
  end;

  { TRttiDataMember }

  TRttiDataMember = class abstract(TRttiMember)
  private
    function GetDataType: TRttiType; virtual; abstract;
    function GetIsReadable: Boolean; virtual; abstract;
    function GetIsWritable: Boolean; virtual; abstract;
  public
    function GetValue(Instance: JSValue): TValue; virtual; abstract;
    procedure SetValue(Instance: JSValue; const AValue: TValue); virtual; abstract;
    property DataType: TRttiType read GetDataType;
    property IsReadable: Boolean read GetIsReadable;
    property IsWritable: Boolean read GetIsWritable;
  end;

  { TRttiField }

  TRttiField = class(TRttiDataMember)
  private
    function GetFieldType: TRttiType;
    function GetFieldTypeInfo: TTypeMemberField;
    function GetDataType: TRttiType; override;
    function GetIsReadable: Boolean; override;
    function GetIsWritable: Boolean; override;
  public
    constructor Create(AParent: TRttiType; ATypeInfo: TTypeMember);

    function GetValue(Instance: JSValue): TValue; override;
    procedure SetValue(Instance: JSValue; const AValue: TValue); override;
    property FieldType: TRttiType read GetFieldType;
    property FieldTypeInfo: TTypeMemberField read GetFieldTypeInfo;
  end;

  TRttiFieldArray = specialize TArray<TRttiField>;

  { TRttiParameter }

  TRttiParameter = class(TRttiNamedObject)
  private
    FParamType: TRttiType;
    FFlags: TParamFlags;
    FName: String;
  protected
    function GetName: string; override;
  public
    property Flags: TParamFlags read FFlags;
    property ParamType: TRttiType read FParamType;
  end;

  TRttiParameterArray = specialize TArray<TRttiParameter>;

  TRttiProcedureSignature = class(TRttiObject)
  private
    FFlags: TProcedureFlags;
    FParameters: TRttiParameterArray;
    FReturnType: TRttiType;

    function GetProcedureSignature: TProcedureSignature;

    procedure LoadFlags;
    procedure LoadParameters;
  public
    constructor Create(const Parent: TRttiObject; const Signature: TProcedureSignature); reintroduce;

    class function Invoke(const Instance: TValue; const Args: array of TValue): TValue; // todo

    property Flags: TProcedureFlags read FFlags;
    property Parameters: TRttiParameterArray read FParameters;
    property ProcedureSignature: TProcedureSignature read GetProcedureSignature;
    property ReturnType: TRttiType read FReturnType;
  end;

  { TRttiMethod }

  TRttiMethod = class(TRttiMember)
  private
    FProcedureSignature: TRttiProcedureSignature;

    function GetIsAsyncCall: Boolean;
    function GetIsClassMethod: Boolean;
    function GetIsConstructor: Boolean;
    function GetIsDestructor: Boolean;
    function GetIsExternal: Boolean;
    function GetIsSafeCall: Boolean;
    function GetIsStatic: Boolean;
    function GetIsVarArgs: Boolean;
    function GetMethodKind: TMethodKind;
    function GetMethodTypeInfo: TTypeMemberMethod;
    function GetProcedureFlags: TProcedureFlags;
    function GetProcedureSignature: TRttiProcedureSignature;
    function GetReturnType: TRttiType;
  protected
    property ProcedureSignature: TRttiProcedureSignature read GetProcedureSignature;
  public
    function GetParameters: TRttiParameterArray;
    function Invoke(const Instance: TValue; const Args: array of TValue): TValue;
    function Invoke(const Instance: TObject; const Args: array of TValue): TValue;
    function Invoke(const aClass: TClass; const Args: array of TValue): TValue;

    property IsAsyncCall: Boolean read GetIsAsyncCall;
    property IsClassMethod: Boolean read GetIsClassMethod;
    property IsConstructor: Boolean read GetIsConstructor;
    property IsDestructor: Boolean read GetIsDestructor;
    property IsExternal: Boolean read GetIsExternal;
    property IsSafeCall: Boolean read GetIsSafeCall;
    property IsStatic: Boolean read GetIsStatic;
    property IsVarArgs: Boolean read GetIsVarArgs;
    property MethodKind: TMethodKind read GetMethodKind;
    property MethodTypeInfo: TTypeMemberMethod read GetMethodTypeInfo;
    property ReturnType: TRttiType read GetReturnType;
  end;

  TRttiMethodArray = specialize TArray<TRttiMethod>;

  { TRttiProperty }

  TRttiProperty = class(TRttiDataMember)
  private
    function GetDataType: TRttiType; override;
    function GetDefault: JSValue;
    function GetIndex: Integer;
    function GetIsClassProperty: boolean;
    function GetPropertyTypeInfo: TTypeMemberProperty;
    function GetPropertyType: TRttiType;
    function GetIsWritable: boolean; override;
    function GetIsReadable: boolean; override;
  public
    constructor Create(AParent: TRttiType; ATypeInfo: TTypeMember);

    function GetValue(Instance: JSValue): TValue; override;

    procedure SetValue(Instance: JSValue; const AValue: TValue); override;

    property PropertyTypeInfo: TTypeMemberProperty read GetPropertyTypeInfo;
    property PropertyType: TRttiType read GetPropertyType;
    property Default: JSValue read GetDefault;
    property Index: Integer read GetIndex;
    property IsClassProperty: boolean read GetIsClassProperty;
    property IsReadable: boolean read GetIsReadable;
    property IsWritable: boolean read GetIsWritable;
    property Visibility: TMemberVisibility read GetVisibility;
  end;

  TRttiInstanceProperty = class(TRttiProperty)
  end;

  TRttiPropertyArray = specialize TArray<TRttiProperty>;

  { TRttiType }

  TRttiType = class(TRttiNamedObject)
  private
    //FMethods: specialize TArray<TRttiMethod>;
    function GetAsInstance: TRttiInstanceType;
    function GetAsInstanceExternal: TRttiInstanceExternalType;
    function GetDeclaringUnitName: string;
    function GetHandle: TTypeInfo;
    function GetQualifiedName: String;
  protected
    function GetName: string; override;
    //function GetHandle: Pointer; override;
    function GetIsInstance: Boolean;
    function GetIsInstanceExternal: Boolean;
    //function GetIsManaged: Boolean; virtual;
    function GetIsOrdinal: Boolean; virtual;
    function GetIsRecord: Boolean; virtual;
    function GetIsSet: Boolean; virtual;
    function GetTypeKind: TTypeKind; virtual;
    //function GetTypeSize: integer; virtual;
    function GetBaseType: TRttiType; virtual;
    function LoadCustomAttributes: TCustomAttributeArray; override;
  public
    function GetField(const AName: string): TRttiField; virtual;
    function GetFields: TRttiFieldArray; virtual;
    function GetMethods: TRttiMethodArray; virtual;
    function GetMethods(const aName: String): TRttiMethodArray; virtual;
    function GetMethod(const aName: String): TRttiMethod; virtual;
    function GetProperty(const AName: string): TRttiProperty; virtual;
    //function GetIndexedProperty(const AName: string): TRttiIndexedProperty; virtual;
    function GetProperties: TRttiPropertyArray; virtual;
    function GetDeclaredProperties: TRttiPropertyArray; virtual;
    //function GetDeclaredIndexedProperties: TRttiIndexedPropertyArray; virtual;
    function GetDeclaredMethods: TRttiMethodArray; virtual;
    function GetDeclaredFields: TRttiFieldArray; virtual;

    property Handle: TTypeInfo read GetHandle;
    property IsInstance: Boolean read GetIsInstance;
    property IsInstanceExternal: Boolean read GetIsInstanceExternal;
    //property isManaged: Boolean read GetIsManaged;
    property IsOrdinal: Boolean read GetIsOrdinal;
    property IsRecord: Boolean read GetIsRecord;
    property IsSet: Boolean read GetIsSet;
    property BaseType: TRttiType read GetBaseType;
    property AsInstance: TRttiInstanceType read GetAsInstance;
    property AsInstanceExternal: TRttiInstanceExternalType read GetAsInstanceExternal;
    property TypeKind: TTypeKind read GetTypeKind;
    //property TypeSize: integer read GetTypeSize;
    property DeclaringUnitName: string read GetDeclaringUnitName;
    property QualifiedName: String read GetQualifiedName;
  end;

  TRttiTypeClass = class of TRttiType;

  TRttiStringKind = (skShortString, skAnsiString, skWideString, skUnicodeString);

  { TRttiStringType }

  TRttiStringType = class(TRttiType)
  private
    function GetStringKind: TRttiStringKind;
  public
    property StringKind: TRttiStringKind read GetStringKind;
  end;

  { TRttiAnsiStringType }

  TRttiAnsiStringType = class(TRttiStringType)
  private
    function GetCodePage: Word;
  public
    property CodePage: Word read GetCodePage;
  end;

  { TRttiStructuredType }

  TRttiStructuredType = class abstract(TRttiType)
  private
    FFields: TRttiFieldArray;
    FMethods: TRttiMethodArray;
    FProperties: TRttiPropertyArray;
  protected
    function GetAncestor: TRttiStructuredType; virtual;
    function GetStructTypeInfo: TTypeInfoStruct;
  public
    constructor Create(AParent: TRttiObject; ATypeInfo: PTypeInfo); override;

    destructor Destroy; override;

    function GetDeclaredFields: TRttiFieldArray; override;
    function GetDeclaredMethods: TRttiMethodArray; override;
    function GetDeclaredProperties: TRttiPropertyArray; override;
    function GetFields: TRttiFieldArray; override;
    function GetMethod(const aName: String): TRttiMethod; override;
    function GetMethods: TRttiMethodArray; override;
    function GetMethods(const aName: String): TRttiMethodArray; override;
    function GetProperties: TRttiPropertyArray; override;
    function GetProperty(const AName: string): TRttiProperty; override;

    property StructTypeInfo: TTypeInfoStruct read GetStructTypeInfo;
  end;

  { TRttiInstanceType }

  TRttiInstanceType = class(TRttiStructuredType)
  private
    function GetAncestorType: TRttiInstanceType;
    function GetClassTypeInfo: TTypeInfoClass;
    function GetMetaClassType: TClass;
  protected
    function GetAncestor: TRttiStructuredType; override;
    function GetBaseType : TRttiType; override;
  public
    constructor Create(AParent: TRttiObject; ATypeInfo: PTypeInfo); override;
    property BaseType : TRttiInstanceType read GetAncestorType;
    property Ancestor: TRttiInstanceType read GetAncestorType;
    property ClassTypeInfo: TTypeInfoClass read GetClassTypeInfo;
    property MetaClassType: TClass read GetMetaClassType;
  end;

  { TRttiInterfaceType }

  TRttiInterfaceType = class(TRttiStructuredType)
  private
    function GetAncestorType: TRttiInterfaceType;
    function GetGUID: TGUID;
    function GetInterfaceTypeInfo: TTypeInfoInterface;
  protected
    function GetAncestor: TRttiStructuredType; override;
    function GetBaseType : TRttiType; override;
  public
    constructor Create(AParent: TRttiObject; ATypeInfo: PTypeInfo); override;

    property BaseType : TRttiInterfaceType read GetAncestorType;
    property Ancestor: TRttiInterfaceType read GetAncestorType;
    property GUID: TGUID read GetGUID;
    property InterfaceTypeInfo: TTypeInfoInterface read GetInterfaceTypeInfo;
  end;

  { TRttiRecordType }

  TRttiRecordType = class(TRttiStructuredType)
  private
    function GetRecordTypeInfo: TTypeInfoRecord;
  protected
    function GetIsRecord: Boolean; override;
  public
    constructor Create(AParent: TRttiObject; ATypeInfo: PTypeInfo); override;

    property RecordTypeInfo: TTypeInfoRecord read GetRecordTypeInfo;
  end;

  { TRttiClassRefType }
  TRttiClassRefType = class(TRttiType)
  private
    function GetClassRefTypeInfo: TTypeInfoClassRef;
    function GetInstanceType: TRttiInstanceType;
    function GetMetaclassType: TClass;
  public
    constructor Create(AParent: TRttiObject; ATypeInfo: PTypeInfo); override;

    property ClassRefTypeInfo: TTypeInfoClassRef read GetClassRefTypeInfo;
    property InstanceType: TRttiInstanceType read GetInstanceType;
    property MetaclassType: TClass read GetMetaclassType;
  end;

  { TRttiInstanceExternalType }

  TRttiInstanceExternalType = class(TRttiType)
  private
    function GetAncestor: TRttiInstanceExternalType;
    function GetExternalName: String;
    function GetExternalClassTypeInfo: TTypeInfoExtClass;
  public
    constructor Create(AParent: TRttiObject; ATypeInfo: PTypeInfo); override;

    property Ancestor: TRttiInstanceExternalType read GetAncestor;
    property ExternalClassTypeInfo: TTypeInfoExtClass read GetExternalClassTypeInfo;
    property ExternalName: String read GetExternalName;
  end;

  { TRttiFloatType }

  TRttiFloatType = class(TRttiType)
  end;

  { TRttiOrdinalType }

  TRttiOrdinalType = class(TRttiType)
  private
    function GetMaxValue: Integer; virtual;
    function GetMinValue: Integer; virtual;
    function GetOrdType: TOrdType;
    function GetOrdinalTypeInfo: TTypeInfoInteger;
  public
    constructor Create(AParent: TRttiObject; ATypeInfo: PTypeInfo); override;

    property OrdType: TOrdType read GetOrdType;
    property MinValue: Integer read GetMinValue;
    property MaxValue: Integer read GetMaxValue;
    property OrdinalTypeInfo: TTypeInfoInteger read GetOrdinalTypeInfo;
  end;

  { TRttiEnumerationType }

  TRttiEnumerationType = class(TRttiOrdinalType)
  private
    function GetEnumerationTypeInfo: TTypeInfoEnum;
  public
    constructor Create(AParent: TRttiObject; ATypeInfo: PTypeInfo); override;

    property EnumerationTypeInfo: TTypeInfoEnum read GetEnumerationTypeInfo;

    function GetNames: TStringArray;
    generic class function GetName<T>(AValue: T): String; reintroduce;
    generic class function GetValue<T>(const AValue: String): T;
  end;

    { TRttiArrayType }

  TRttiArrayType = class(TRttiType)
  private
    function GetDimensionCount: SizeUInt; inline;
    function GetDimension(aIndex: SizeInt): TRttiType; inline;
    function GetElementType: TRttiType; inline;
    function GetStaticArrayTypeInfo: TTypeInfoStaticArray;
    function GetTotalElementCount: SizeInt; inline;
  public
    property DimensionCount: SizeUInt read GetDimensionCount;
    property Dimensions[Index: SizeInt]: TRttiType read GetDimension;
    property ElementType: TRttiType read GetElementType;
    property TotalElementCount: SizeInt read GetTotalElementCount;
    property StaticArrayTypeInfo: TTypeInfoStaticArray read GetStaticArrayTypeInfo;
  end;

  { TRttiDynamicArrayType }

  TRttiDynamicArrayType = class(TRttiType)
  private
    function GetDynArrayTypeInfo: TTypeInfoDynArray;
    function GetElementType: TRttiType;
  public
    constructor Create(AParent: TRttiObject; ATypeInfo: PTypeInfo); override;

    property DynArrayTypeInfo: TTypeInfoDynArray read GetDynArrayTypeInfo;
    property ElementType: TRttiType read GetElementType;
  end;

  { TRttiPointerType }

  TRttiPointerType = class(TRttiType)
  private
    function GetRefType: TRttiType;
    function GetRefTypeInfo: TTypeInfoPointer;
  public
    constructor Create(AParent: TRttiObject; ATypeInfo: PTypeInfo); override;

    property RefType: TRttiType read GetRefType;
    property RefTypeInfo: TTypeInfoPointer read GetRefTypeInfo;
  end;

  EInvoke = EJS;

  TVirtualInterfaceInvokeEvent = reference to procedure(Method: TRttiMethod; const Args: specialize TArray<TValue>; out Result: TValue);
  TVirtualInterfaceInvokeEventJS = reference to function(const MethodName: String; const Args: TJSFunctionArguments): JSValue;

  { TVirtualInterface: A class that can implement any IInterface. Any method
    call is handled by the OnInvoke event. }
  TVirtualInterface = class(TInterfacedObject, IInterface)
  private
    FContext: TRttiContext;
    FInterfaceType: TRttiInterfaceType;
    FOnInvoke: TVirtualInterfaceInvokeEvent;
    FOnInvokeJS: TVirtualInterfaceInvokeEventJS;

    function Invoke(const MethodName: String; const Args: TJSFunctionArguments): JSValue;
  public
    constructor Create(PIID: PTypeInfo); overload;
    constructor Create(PIID: PTypeInfo; const InvokeEvent: TVirtualInterfaceInvokeEvent); overload;
    constructor Create(PIID: PTypeInfo; const InvokeEvent: TVirtualInterfaceInvokeEventJS); overload;

    destructor Destroy; override;

    property OnInvoke: TVirtualInterfaceInvokeEvent read FOnInvoke write FOnInvoke;
    property OnInvokeJS: TVirtualInterfaceInvokeEventJS read FOnInvokeJS write FOnInvokeJS;
  end;

  TFunctionCallFlag = (
    fcfStatic,
    fcfVarargs,  //  // 2^1 = 2
    fcfExternal, // // 2^2 = 4  name may be an expression
    fcfSafeCall,  // 2^3 = 8
    fcfAsync      // 2^4 = 16
  );
  TFunctionCallFlags = set of TFunctionCallFlag;

  { TRttiInvokableType }

  TRttiInvokableType = class(TRttiType)
  private
    function GetIsAsyncCall: Boolean;
  protected
    function GetParameters(aWithHidden: Boolean): TRttiParameterArray; virtual; abstract;
    function GetCallingConvention: TCallConv; virtual; abstract;
    function GetReturnType: TRttiType; virtual; abstract;
    function GetFlags: TFunctionCallFlags; virtual; abstract;
  public type
    TCallbackMethod = procedure(aInvokable: TRttiInvokableType; const aArgs: TValueArray; out aResult: TValue) of object;
    TCallbackProc = procedure(aInvokable: TRttiInvokableType; const aArgs: TValueArray; out aResult: TValue);
  public
    function GetParameters: TRttiParameterArray; inline;
    property CallingConvention: TCallConv read GetCallingConvention;
    property ReturnType: TRttiType read GetReturnType;
    function Invoke(const aProcOrMeth: TValue; const aArgs: array of TValue): TValue; virtual; abstract;
    function ToString : string; override;
    property IsAsyncCall : Boolean Read GetIsAsyncCall;
    property Flags : TFunctionCallFlags Read GetFlags;
  end;


  { TRttiMethodType }

  TRttiMethodType = class(TRttiInvokableType)
  private
    //FCallConv: TCallConv;
    //FReturnType: TRttiType;
    //FParams, FParamsAll: TRttiParameterArray;
    function GetMethodKind: TMethodKind;
  protected
    function GetMethodTypeInfo : TTypeInfoMethodVar;
    function GetParameters(aWithHidden: Boolean): TRttiParameterArray; override;
    function GetCallingConvention: TCallConv; override;
    function GetReturnType: TRttiType; override;
    function GetFlags: TFunctionCallFlags; override;
  public
    function Invoke(const aCallable: TValue; const aArgs: array of TValue): TValue; override;
    property MethodTypeInfo : TTypeInfoMethodVar Read GetMethodTypeInfo;
    property MethodKind: TMethodKind read GetMethodKind;

    function ToString: string; override;
  end;

  { TRttiProcedureType }

  TRttiProcedureType = class(TRttiInvokableType)
  private
    //FParams, FParamsAll: TRttiParameterArray;
    function GetProcTypeInfo: TTypeInfoProcVar;
  protected
    function GetParameters(aWithHidden: Boolean): TRttiParameterArray; override;
    function GetCallingConvention: TCallConv; override;
    function GetReturnType: TRttiType; override;
    function GetFlags: TFunctionCallFlags; override;
  public
    property ProcTypeInfo :  TTypeInfoProcVar Read GetProcTypeInfo;
    function Invoke(const aCallable: TValue; const aArgs: array of TValue): TValue; override;
  end;


procedure CreateVirtualCorbaInterface(InterfaceTypeInfo: Pointer;
  const MethodImplementation: TVirtualInterfaceInvokeEvent; out IntfVar); assembler;

function Invoke(ACodeAddress: Pointer; const AArgs: TJSValueDynArray;
  ACallConv: TCallConv; AResultType: PTypeInfo; AIsStatic: Boolean;
  AIsConstructor: Boolean): TValue;

function ArrayOfConstToTValueArray(const aValues: array of const): TValueArray;
generic function OpenArrayToDynArrayValue<T>(constref aArray: array of T): TValue;

implementation

type
  TRttiPoolTypes = class
  private
    FReferenceCount: Integer;
    FTypes: TJSObject; // maps 'modulename.typename' to TRTTIType
  public
    constructor Create;

    destructor Destroy; override;

    function FindType(const AQualifiedName: String): TRttiType;
    function GetType(const ATypeInfo: PTypeInfo): TRTTIType; overload;
    function GetType(const AClass: TClass): TRTTIType; overload;

    class function AcquireContext: TJSObject; static;

    class procedure ReleaseContext; static;
  end;

var
  Pool: TRttiPoolTypes;
  pas: TJSObject; external name 'pas';

procedure CreateVirtualCorbaInterface(InterfaceTypeInfo: Pointer;
  const MethodImplementation: TVirtualInterfaceInvokeEvent; out IntfVar); assembler;
asm
  var IntfType = InterfaceTypeInfo.interface;
  var i = Object.create(IntfType);
  var o = { $name: "virtual", $fullname: "virtual" };
  i.$o = o;
  do {
    var names = IntfType.$names;
    if (!names) break;
    for (var j=0; j<names.length; j++){
      let fnname = names[j];
      i[fnname] = function(){ return MethodImplementation(fnname,arguments); };
    }
    IntfType = Object.getPrototypeOf(IntfType);
  } while(IntfType!=null);
  IntfVar.set(i);
end;

{ TRttiPoolTypes }

constructor TRttiPoolTypes.Create;
begin
  inherited;

  FTypes := TJSObject.new;
end;

destructor TRttiPoolTypes.Destroy;
var
  Key: String;

  RttiObject: TRttiType;

begin
  for key in FTypes do
    if FTypes.hasOwnProperty(key) then
    begin
      RttiObject := TRttiType(FTypes[key]);

      RttiObject.Free;
    end;
end;

function TRttiPoolTypes.FindType(const AQualifiedName: String): TRttiType;
var
  ModuleName, TypeName: String;

  Module: TTypeInfoModule;

  TypeFound: PTypeInfo;

begin
  if FTypes.hasOwnProperty(AQualifiedName) then
    Result := TRttiType(FTypes[AQualifiedName])
  else
  begin
    Result := nil;

    for ModuleName in TJSObject.Keys(pas) do
      if AQualifiedName.StartsWith(ModuleName + '.') then
      begin
        Module := TTypeInfoModule(pas[ModuleName]);
        TypeName := Copy(AQualifiedName, Length(ModuleName) + 2, Length(AQualifiedName));

        if Module.RTTI.HasOwnProperty(TypeName) then
        begin
          TypeFound := PTypeInfo(Module.RTTI[TypeName]);

          Exit(GetType(TypeFound));
        end;
      end;
  end;
end;

function TRttiPoolTypes.GetType(const ATypeInfo: PTypeInfo): TRTTIType;
var
  RttiTypeClass: array[TTypeKind] of TRttiTypeClass = (
    nil, // tkUnknown
    TRttiOrdinalType, // tkInteger
    TRttiOrdinalType, // tkChar
    TRttiStringType, // tkString
    TRttiEnumerationType, // tkEnumeration
    TRttiType, // tkSet
    TRttiFloatType, // tkDouble
    TRttiType, // tkBool
    TRttiProcedureType, // tkProcVar
    TRttiMethodType, // tkMethod
    TRttiArrayType, // tkArray
    TRttiDynamicArrayType, // tkDynArray
    TRttiRecordType, // tkRecord
    TRttiInstanceType, // tkClass
    TRttiClassRefType, // tkClassRef
    TRttiPointerType, // tkPointer
    TRttiType, // tkJSValue
    TRttiType, // tkRefToProcVar
    TRttiInterfaceType, // tkInterface
    TRttiType, // tkHelper
    TRttiInstanceExternalType // tkExtClass
  );

  TheType: TTypeInfo absolute ATypeInfo;

  Name: String;

  Parent: TRttiObject;

begin
  if IsNull(ATypeInfo) or IsUndefined(ATypeInfo) then
    Exit(nil);

  Name := TheType.Name;

  if isModule(TheType.Module) then
    Name := TheType.Module.Name + '.' + Name;

  if FTypes.hasOwnProperty(Name) then
    Result := TRttiType(FTypes[Name])
  else
  begin
    if (TheType.Kind in [tkClass, tkInterface, tkHelper, tkExtClass]) and TJSObject(TheType).hasOwnProperty('ancestor') then
      Parent := GetType(PTypeInfo(TJSObject(TheType)['ancestor']))
    else
      Parent := nil;

    Result := RttiTypeClass[TheType.Kind].Create(Parent, ATypeInfo);

    FTypes[Name] := Result;
  end;
end;

function TRttiPoolTypes.GetType(const AClass: TClass): TRTTIType;
begin
  if AClass = nil then
    Exit(nil);

  Result := GetType(TypeInfo(AClass));
end;

class function TRttiPoolTypes.AcquireContext: TJSObject;
begin
  if not Assigned(Pool) then
    Pool := TRttiPoolTypes.Create;

  Result := Pool.FTypes;

  Inc(Pool.FReferenceCount);
end;

class procedure TRttiPoolTypes.ReleaseContext;
begin
  Dec(Pool.FReferenceCount);

  if Pool.FReferenceCount = 0 then
    FreeAndNil(Pool);
end;

{ TRttiDynamicArrayType }

function TRttiDynamicArrayType.GetDynArrayTypeInfo: TTypeInfoDynArray;
begin
  Result := TTypeInfoDynArray(inherited Handle);
end;

function TRttiDynamicArrayType.GetElementType: TRttiType;
begin
  Result := Pool.GetType(DynArrayTypeInfo.ElType);
end;

constructor TRttiDynamicArrayType.Create(AParent: TRttiObject; ATypeInfo: PTypeInfo);
begin
  if not (TTypeInfo(ATypeInfo) is TTypeInfoDynArray) then
    raise EInvalidCast.Create('');

  inherited;
end;

{ TRttiOrdinalType }

function TRttiOrdinalType.GetMaxValue: Integer;
begin
  Result := OrdinalTypeInfo.MaxValue;
end;

function TRttiOrdinalType.GetMinValue: Integer;
begin
  Result := OrdinalTypeInfo.MinValue;
end;

function TRttiOrdinalType.GetOrdType: TOrdType;
begin
  Result := OrdinalTypeInfo.OrdType;
end;

function TRttiOrdinalType.GetOrdinalTypeInfo: TTypeInfoInteger;
begin
  Result := TTypeInfoInteger(inherited Handle);
end;

constructor TRttiOrdinalType.Create(AParent: TRttiObject; ATypeInfo: PTypeInfo);
begin
  if not (TTypeInfo(ATypeInfo) is TTypeInfoInteger) then
    raise EInvalidCast.Create('');

  inherited;
end;

{ TRttiEnumerationType }

function TRttiEnumerationType.GetEnumerationTypeInfo: TTypeInfoEnum;
begin
  Result := TTypeInfoEnum(inherited Handle);
end;

function TRttiEnumerationType.GetNames: TStringArray;
var
  A, NamesSize: Integer;

begin
  NamesSize := GetEnumNameCount(EnumerationTypeInfo);

  SetLength(Result, NamesSize);

  for A := 0 to Pred(NamesSize) do
    Result[A] := EnumerationTypeInfo.EnumType.IntToName[A + MinValue];
end;

generic class function TRttiEnumerationType.GetName<T>(AValue: T): String;

Var
  P : PTypeInfo;

begin
  P:=TypeInfo(T);
  if not (TTypeInfo(P).kind=tkEnumeration) then
    raise EInvalidCast.CreateFmt(SErrTypeIsNotEnumerated,[TTypeInfo(P).Name]);
  Result := GetEnumName(TTypeInfoEnum(P), Integer(JSValue(AValue)));
end;

generic class function TRttiEnumerationType.GetValue<T>(const AValue: String): T;

Var
  P : PTypeInfo;

begin
  P:=TypeInfo(T);
  if not (TTypeInfo(P).kind=tkEnumeration) then
    raise EInvalidCast.CreateFmt(SErrTypeIsNotEnumerated,[TTypeInfo(P).Name]);
  Result := T(JSValue(GetEnumValue(TTypeInfoEnum(TypeInfo(T)), AValue)));
end;

constructor TRttiEnumerationType.Create(AParent: TRttiObject; ATypeInfo: PTypeInfo);
begin
  if not (TTypeInfo(ATypeInfo) is TTypeInfoEnum) then
    raise EInvalidCast.Create('');

  inherited;
end;

{ TValue }

function TValue.GetTypeKind: TTypeKind;
begin
  if TypeInfo=nil then
    Result:=tkUnknown
  else
    Result:=FTypeInfo.Kind;
end;

generic function TValue.AsType<T>: T;
begin
  if IsEmpty then
    Result := Default(T)
  else
    Result := T(AsJSValue)
end;

generic class function TValue.From<T>(const Value: T): TValue;
begin
  Make(Value, System.TypeInfo(T), Result);
end;

class procedure TValue.Make(const ABuffer: JSValue; const ATypeInfo: PTypeInfo; var Result: TValue);
begin
  Result.FTypeInfo := ATypeInfo;

  if Result.FTypeInfo.Kind = tkRecord then
  begin
    Result.FData := TTypeInfoRecord(ATypeInfo).RecordInfo.New;

    if Assigned(ABuffer) then
      TRecordInfo(Result.FData).Assign(ABuffer);
  end
  else
    Result.FData := ABuffer;

  if (Result.FTypeInfo.Kind = tkClass) and Result.IsClass and not Result.IsEmpty then
    Result.FTypeInfo := Result.AsObject.ClassInfo;
end;

generic class procedure TValue.Make<T>(const Value: T; var Result: TValue);
begin
  TValue.Make(Value, System.TypeInfo(T), Result);
end;

function TValue.Cast(ATypeInfo: TTypeInfo; const EmptyAsAnyType: Boolean): TValue;
begin
  if not TryCast(ATypeInfo, Result, EmptyAsAnyType) then
    raise EInvalidCast.Create('');
end;

generic function TValue.Cast<T>(const EmptyAsAnyType: Boolean): TValue;
begin
  Result := Cast(System.TypeInfo(T), EmptyAsAnyType);
end;

function TValue.IsType(ATypeInfo: TTypeInfo; const EmptyAsAnyType: Boolean): Boolean;
var
  AnyValue: TValue;

begin
  Result := TryCast(ATypeInfo, AnyValue, EmptyAsAnyType);
end;

generic function TValue.IsType<T>(const EmptyAsAnyType: Boolean): Boolean;
begin
  Result := IsType(System.TypeInfo(T), EmptyAsAnyType);
end;

function TValue.TryCast(ATypeInfo: TTypeInfo; out AResult: TValue; const EmptyAsAnyType: Boolean): Boolean;

  function ConversionAccepted: TTypeKinds;
  begin
    case TypeInfo.Kind of
      tkString: Exit([tkChar, tkString]);

      tkDouble: Exit([tkInteger, tkDouble]);

      tkEnumeration: Exit([tkInteger, tkEnumeration]);

      else Exit([TypeInfo.Kind]);
    end;
  end;

begin
  if EmptyAsAnyType and IsEmpty then
  begin
    AResult := TValue.Empty;

    if ATypeInfo <> nil then
    begin
      AResult.FTypeInfo := ATypeInfo;

      case ATypeInfo.Kind of
        tkBool: AResult.SetData(False);
        tkChar: AResult.SetData(#0);
        tkString: AResult.SetData(EmptyStr);
        tkDouble,
        tkEnumeration,
        tkInteger: AResult.SetData(0);
      end;

      Exit(True);
    end;
  end;

  if not EmptyAsAnyType and (FTypeInfo = nil) then
    Exit(False);

  if FTypeInfo = ATypeInfo then
  begin
    AResult := Self;
    Exit(True);
  end;

  if ATypeInfo = nil then
    Exit(False);

  if ATypeInfo = System.TypeInfo(TValue) then
  begin
    TValue.Make(Self, System.TypeInfo(TValue), AResult);
    Exit(True);
  end;

  Result := ATypeInfo.Kind in ConversionAccepted;

  if Result then
  begin
    AResult.SetData(FData);
    AResult.FTypeInfo := ATypeInfo;
  end;
end;

class function TValue.FromVarRec(const aValue: TVarRec): TValue;

begin
  Result:=Default(TValue);
  case aValue.VType of
    vtInteger:  TValue.Make(aValue.VInteger,System.TypeInfo(Integer),Result);
    vtBoolean: TValue.Make(aValue.VBoolean,System.TypeInfo(Boolean),Result);
    vtWideChar: TValue.Make(aValue.VWideChar,System.TypeInfo(WideChar),Result);
    vtNativeInt: TValue.Make(aValue.VNativeInt,System.TypeInfo(NativeInt),Result);
    vtUnicodeString: TValue.Make(aValue.VUnicodeString,System.TypeInfo(UnicodeString),Result);
    vtObject: TValue.Make(aValue.VObject,TObject.ClassInfo,Result);
    vtInterface: TValue.Make(aValue.VInterface,System.TypeInfo(IInterface),Result);
    vtClass: TValue.Make(aValue.VClass,System.TypeInfo(TClass),Result);
    vtJSValue: TValue.Make(aValue.VJSValue,System.TypeInfo(JSValue),result);
    vtExtended: TValue.Make(aValue.VExtended,System.TypeInfo(Extended),result);
    vtCurrency: TValue.Make(aValue.VCurrency,System.TypeInfo(Currency),result);
  end;
end;

class function TValue.FromJSValue(v: JSValue): TValue;
var
  i: NativeInt;
  TypeOfValue: TTypeInfo;

begin
  case jsTypeOf(v) of
    'number':
      if {$IFDEF FPC_DOTTEDUNITS}JSApi.{$ENDIF}JS.isInteger(v) then
        begin
        i:=NativeInt(v);
        if (i>=low(integer)) and (i<=high(integer)) then
          TypeOfValue:=System.TypeInfo(Integer)
        else
          TypeOfValue:=System.TypeInfo(NativeInt);
        end
      else
        TypeOfValue:=system.TypeInfo(Double);
    'string':  TypeOfValue:=System.TypeInfo(String);
    'boolean': TypeOfValue:=System.TypeInfo(Boolean);
    'object':
      if v=nil then
        Exit(TValue.Empty)
      else if {$IFDEF FPC_DOTTEDUNITS}JSApi.{$ENDIF}JS.isClass(v) and {$IFDEF FPC_DOTTEDUNITS}JSApi.{$ENDIF}JS.isExt(v,TObject) then
        TypeOfValue:=System.TypeInfo(TClass(v))
      else if {$IFDEF FPC_DOTTEDUNITS}JSApi.{$ENDIF}JS.isObject(v) and {$IFDEF FPC_DOTTEDUNITS}JSApi.{$ENDIF}JS.isExt(v,TObject) then
        TypeOfValue:=System.TypeInfo(TObject(v))
      else if isRecord(v) then
        TypeOfValue:=System.TypeInfo(TObject(v))
      else if TJSArray.IsArray(V) then
        TypeOfValue:=System.TypeInfo(TObject(v))
      else
        raise EInvalidCast.Create('Type not recognized in FromJSValue!');
    else
      TypeOfValue:=System.TypeInfo(JSValue);
  end;

  Make(v, TypeOfValue, Result);
end;

class function TValue.FromArray(TypeInfo: TTypeInfo; const Values: specialize TArray<TValue>): TValue;
var
  A: Integer;

  DynTypeInfo: TTypeInfoDynArray absolute TypeInfo;

  NewArray: TJSArray;

  ElementType: TTypeInfo;

begin
  if TypeInfo.Kind <> tkDynArray then
    raise EInvalidCast.Create('Type not an array in FromArray!');

  ElementType := DynTypeInfo.ElType;
  NewArray := TJSArray.new;
  NewArray.Length := Length(Values);

  for A := 0 to High(Values) do
    NewArray[A] := Values[A].Cast(ElementType).AsJSValue;

  Result.SetData(NewArray);
  Result.FTypeInfo := TypeInfo;
end;

class function TValue.FromOrdinal(ATypeInfo: TTypeInfo; AValue: JSValue): TValue;
begin
  if (ATypeInfo = nil) or not (ATypeInfo.Kind in [tkBool, tkEnumeration, tkInteger]) then
    raise EInvalidCast.Create('Invalid type in FromOrdinal');

  if ATypeInfo.Kind = tkBool then
    TValue.Make(AValue = True, ATypeInfo, Result)
  else
    TValue.Make(NativeInt(AValue), ATypeInfo, Result);
end;

function TValue.IsObject: boolean;
begin
  Result:=IsEmpty or (TypeInfo.Kind=tkClass);
end;

function TValue.AsObject: TObject;
begin
  if IsObject or (IsClass and not {$IFDEF FPC_DOTTEDUNITS}JSApi.{$ENDIF}JS.IsObject(GetData)) then
    Result := TObject(GetData)
  else
    raise EInvalidCast.Create(SErrInvalidTypecast);
end;

function TValue.IsObjectInstance: boolean;
begin
  Result:=(TypeInfo<>nil) and (TypeInfo.Kind=tkClass);
end;

function TValue.IsArray: boolean;
begin
  case Kind of
    tkDynArray: Exit(True);
    tkArray: Exit(Length(TTypeInfoStaticArray(FTypeInfo).Dims) = 1);
    else Result := False;
  end;
end;

function TValue.IsClass: boolean;
var
  k: TTypeKind;
begin
  k:=Kind;
  Result := (k = tkClassRef) or ((k in [tkClass,tkUnknown]) and not {$IFDEF FPC_DOTTEDUNITS}JSApi.{$ENDIF}JS.IsObject(GetData));
end;

function TValue.AsClass: TClass;
begin
  if IsClass then
    Result := TClass(GetData)
  else
    raise EInvalidCast.Create(SErrInvalidTypecast);
end;

function TValue.IsOrdinal: boolean;
begin
  Result := IsEmpty or (Kind in [tkBool, tkInteger, tkChar, tkEnumeration]);
end;

function TValue.AsOrdinal: NativeInt;
begin
  if IsOrdinal then
    Result:=NativeInt(GetData)
  else
    raise EInvalidCast.Create(SErrInvalidTypecast);
end;

function TValue.AsBoolean: boolean;
begin
  if (Kind = tkBool) then
    Result:=boolean(GetData)
  else
    raise EInvalidCast.Create(SErrInvalidTypecast);
end;

function TValue.AsInteger: Integer;
begin
  if {$IFDEF FPC_DOTTEDUNITS}JSApi.{$ENDIF}JS.isInteger(GetData) then
    Result:=NativeInt(GetData)
  else
    raise EInvalidCast.Create(SErrInvalidTypecast);
end;

function TValue.AsNativeInt: NativeInt;
begin
  if {$IFDEF FPC_DOTTEDUNITS}JSApi.{$ENDIF}JS.isInteger(GetData) then
    Result:=NativeInt(GetData)
  else
    raise EInvalidCast.Create(SErrInvalidTypecast);
end;

function TValue.AsNativeUInt: NativeUInt;
begin
  if {$IFDEF FPC_DOTTEDUNITS}JSApi.{$ENDIF}JS.isInteger(GetData) then
    Result:=NativeUInt(GetData)
  else
    raise EInvalidCast.Create(SErrInvalidTypecast);
end;

function TValue.AsInterface: IInterface;
var
  k: TTypeKind;
begin
  k:=Kind;
  if k = tkInterface then
    Result := IInterface(GetData)// ToDo
  else if (k in [tkClass, tkClassRef, tkUnknown]) and not {$IFDEF FPC_DOTTEDUNITS}JSApi.{$ENDIF}JS.isObject(GetData) then
    Result := Nil
  else
    raise EInvalidCast.Create(SErrInvalidTypecast);
end;

function TValue.AsString: string;
begin
  if {$IFDEF FPC_DOTTEDUNITS}JSApi.{$ENDIF}JS.isString(GetData) then
    Result:=String(GetData)
  else
    raise EInvalidCast.Create(SErrInvalidTypecast);
end;

function TValue.AsWideChar: WideChar;

begin
  if {$IFDEF FPC_DOTTEDUNITS}JSApi.{$ENDIF}JS.isString(GetData) then
    Result:=String(GetData)[1]
  else
    raise EInvalidCast.Create(SErrInvalidTypecast);
end;

function TValue.AsCurrency: Currency;
begin
  // The actual data is not multiplied by 10000. The
  if {$IFDEF FPC_DOTTEDUNITS}JSApi.{$ENDIF}JS.isNumber(GetData) then
    Result:=Currency(GetData)/10000
  else
    raise EInvalidCast.Create(SErrInvalidTypecast);
end;

function TValue.TryAsOrdinal(out AResult: nativeint): boolean;
begin
  result := IsOrdinal;
  if result then
    AResult := AsOrdinal;
end;

function TValue.AsUnicodeString: UnicodeString;
begin
  Result:=AsString;
end;

function TValue.AsExtended: Extended;
begin
  if {$IFDEF FPC_DOTTEDUNITS}JSApi.{$ENDIF}JS.isNumber(GetData) then
    begin
    Result:=Double(GetData);
    if TypeInfo=System.TypeInfo(Currency) then
      Result:=Result/10000;
    end
  else
    raise EInvalidCast.Create(SErrInvalidTypecast);
end;

function TValue.AsDouble: Double;
begin
  if {$IFDEF FPC_DOTTEDUNITS}JSApi.{$ENDIF}JS.isNumber(GetData) then
    Result:=Double(GetData)
  else
    raise EInvalidCast.Create(SErrInvalidTypecast);
end;

function TValue.AsDateTime: TDateTime;
begin
  if {$IFDEF FPC_DOTTEDUNITS}JSApi.{$ENDIF}JS.isNumber(GetData) then
    Result:=TDateTime(GetData)
  else
    raise EInvalidCast.Create(SErrInvalidTypecast);
end;

function TValue.ToString: String;
begin
  Result := ToString(FormatSettings);
end;

function TValue.ToString(const AFormatSettings: TFormatSettings): String;
var
  v: JSValue;
  Cls: TClass;
begin
  if IsEmpty then
    Exit('(empty)');

  case Kind of
    tkInteger: Result := IntToStr(AsNativeInt);
    tkChar,
    tkString: Result := AsString;
    tkEnumeration: Result := GetEnumName(TTypeInfoEnum(TypeInfo), AsOrdinal);
    tkSet: Result := SetToString(TypeInfo, AsJSValue, True);
    tkDouble: Result := FloatToStr(AsExtended, AFormatSettings);
    tkBool: Result := BoolToStr(AsBoolean, True);
    tkProcVar: Result:='(function '+TypeInfo.Name+')';
    tkMethod: Result:='(method '+str(TTypeInfoMethodVar(TypeInfo).MethodKind)+' '+TypeInfo.Name+')';
    tkArray:
      begin
      // todo: multi Dims
      Result:='(array[0..'+str(GetArrayLength)+'] of '+TTypeInfoStaticArray(TypeInfo).ElType.Name+')';
      end;
    tkDynArray:
      Result:='(dynamic array[0..'+str(GetArrayLength)+'] of '+TTypeInfoDynArray(TypeInfo).ElType.Name+')';
    tkRecord: Result := '(' + TypeInfo.Name + ' record)';
    tkClass:
      if Assigned(AsObject) then
        Result := AsObject.ClassName
      else
        Result := '(empty)';
    tkClassRef:
      begin
      Cls:=AsClass;
      if Assigned(Cls) then
        Result := '(class '''+Cls.ClassName+''')'
      else
        Result:='<empty class ref>';
      end;
    tkPointer:
      if AsJSValue=nil then
        Result:='(pointer nil)'
      else
        Result := '(pointer)';
    tkJSValue:
      begin
      v:=AsJSValue;
      if v=nil then
        Result := '(jsvalue nil)'
      else if isNumber(v) or isString(v) or isUndefined(v) or isBoolean(v) then
        Result := '(jsvalue '+String(v)+')'
      else
        Result := '(jsvalue)';
      end;
    tkRefToProcVar: Result := '(variable of procedure type '+TypeInfo.Name+')';
    tkInterface: Result := '(interface '+TypeInfo.Name+')';
    tkHelper: Result := '(helper '+TypeInfo.Name+')';
    tkExtClass: Result := '(external class '+TypeInfo.Name+')';
  else
    Result := '';
  end;
end;

function TValue.GetArrayLength: SizeInt;
begin
  if IsArray then
    Exit(Length(TJSValueDynArray(GetData)));

  raise EInvalidCast.Create(SErrInvalidTypecast);
end;

function TValue.GetArrayElement(aIndex: SizeInt): TValue;
begin
  if IsArray then
  begin
    case Kind of
      tkArray: Result.FTypeInfo:=TTypeInfoStaticArray(FTypeInfo).ElType;
      tkDynArray: Result.FTypeInfo:=TTypeInfoDynArray(FTypeInfo).ElType;
    end;

    Result.SetData(TJSValueDynArray(GetData)[aIndex]);
  end
  else
    raise EInvalidCast.Create(SErrInvalidTypecast);
end;

procedure TValue.SetArrayLength(const Size: SizeInt);
var
  NewArray: TJSValueDynArray;

begin
  NewArray := TJSValueDynArray(GetData);

  SetLength(NewArray, Size);

  SetData(NewArray);
end;

procedure TValue.SetArrayElement(aIndex: SizeInt; const AValue: TValue);

begin
  if IsArray then
    TJSValueDynArray(GetData)[aIndex] := AValue.AsJSValue
  else
    raise EInvalidCast.Create(SErrInvalidTypecast);
end;

function TValue.GetReferenceToRawData: Pointer;
begin
  Result := Pointer(GetData);
end;


function TValue.GetData: JSValue;
begin
  if FReferenceVariableData then
    Result := TReferenceVariable(FData).Get
  else
    Result := FData;
end;

procedure TValue.SetData(const Value: JSValue);
begin
  if FReferenceVariableData then
    TReferenceVariable(FData).&Set(Value)
  else
    FData := Value;
end;

function TValue.GetIsEmpty: boolean;
begin
  if (TypeInfo=nil) or (GetData=Undefined) or (GetData=nil) then
    exit(true);
  case TypeInfo.Kind of
  tkDynArray:
    Result:=GetArrayLength=0;
  else
    Result:=false;
  end;
end;

function TValue.AsJSValue: JSValue;
begin
  Result := GetData;
end;

class function TValue.Empty: TValue;
begin
  Result.SetData(nil);
  Result.FTypeInfo := nil;
end;

{ TRttiStructuredType }

function TRttiStructuredType.GetMethods: TRttiMethodArray;
var
  A, Start: Integer;

  BaseClass: TRttiStructuredType;

  Declared: TRttiMethodArray;

begin
  BaseClass := Self;
  Result := nil;
  while Assigned(BaseClass) do
  begin
    Declared := BaseClass.GetDeclaredMethods;
    Start := Length(Result);
    SetLength(Result, Start + Length(Declared));
    for A := Low(Declared) to High(Declared) do
      Result[Start + A] := Declared[A];
    BaseClass := BaseClass.GetAncestor;
  end;
end;

function TRttiStructuredType.GetMethods(const aName: String): TRttiMethodArray;
var
  Method: TRttiMethod;
  MethodCount: Integer;

begin
  MethodCount := 0;
  for Method in GetMethods do
    if aName = Method.Name then
      Inc(MethodCount);
  SetLength(Result, MethodCount);
  for Method in GetMethods do
    if aName = Method.Name then
    begin
      Dec(MethodCount);
      Result[MethodCount] := Method;
    end;
end;

function TRttiStructuredType.GetProperties: TRttiPropertyArray;
var
  A, Start: Integer;

  BaseClass: TRttiStructuredType;

  Declared: TRttiPropertyArray;

begin
  BaseClass := Self;
  Result := nil;

  while Assigned(BaseClass) do
  begin
    Declared := BaseClass.GetDeclaredProperties;
    Start := Length(Result);

    SetLength(Result, Start + Length(Declared));

    for A := Low(Declared) to High(Declared) do
      Result[Start + A] := Declared[A];

    BaseClass := BaseClass.GetAncestor;
  end;
end;

function TRttiStructuredType.GetMethod(const aName: String): TRttiMethod;
var
  Method: TRttiMethod;

begin
  for Method in GetMethods do
    if aName = Method.Name then
      Exit(Method);
end;

function TRttiStructuredType.GetProperty(const AName: string): TRttiProperty;
var
  Prop: TRttiProperty;
  lName: String;

begin
  lName := LowerCase(AName);
  for Prop in GetProperties do
    if lowercase(Prop.Name) = lName then
      Exit(Prop);
  Result:=nil;
end;

function TRttiStructuredType.GetDeclaredProperties: TRttiPropertyArray;
var
  A, PropCount: Integer;

begin
  if not Assigned(FProperties) then
  begin
    PropCount := StructTypeInfo.PropCount;

    SetLength(FProperties, PropCount);

    for A := 0 to Pred(PropCount) do
      FProperties[A] := TRttiProperty.Create(Self, StructTypeInfo.GetProp(A));
  end;

  Result := FProperties;
end;

function TRttiStructuredType.GetAncestor: TRttiStructuredType;
begin
  Result := nil;
end;

function TRttiStructuredType.GetStructTypeInfo: TTypeInfoStruct;
begin
  Result:=TTypeInfoStruct(inherited Handle);
end;

constructor TRttiStructuredType.Create(AParent: TRttiObject; ATypeInfo: PTypeInfo);
begin
  if not (TTypeInfo(ATypeInfo) is TTypeInfoStruct) then
    raise EInvalidCast.Create('');

  inherited;
end;

destructor TRttiStructuredType.Destroy;
var
  Method: TRttiMethod;

  Prop: TRttiProperty;

begin
  for Method in FMethods do
    Method.Free;

  for Prop in FProperties do
    Prop.Free;

  inherited Destroy;
end;

function TRttiStructuredType.GetDeclaredMethods: TRttiMethodArray;
var
  A, MethodCount: Integer;

begin
  if not Assigned(FMethods) then
  begin
    MethodCount := StructTypeInfo.MethodCount;
    SetLength(FMethods, MethodCount);

    for A := 0 to Pred(MethodCount) do
      FMethods[A] := TRttiMethod.Create(Self, StructTypeInfo.GetMethod(A));
  end;

  Result := FMethods;
end;

function TRttiStructuredType.GetDeclaredFields: TRttiFieldArray;
var
  A, FieldCount: Integer;

begin
  if not Assigned(FFields) then
  begin
    FieldCount := StructTypeInfo.FieldCount;

    SetLength(FFields, FieldCount);

    for A := 0 to Pred(FieldCount) do
      FFields[A] := TRttiField.Create(Self, StructTypeInfo.GetField(A));
  end;

  Result := FFields;
end;

function TRttiStructuredType.GetFields: TRttiFieldArray;
var
  A, Start: Integer;

  BaseClass: TRttiStructuredType;

  Declared: TRttiFieldArray;

begin
  BaseClass := Self;
  Result := nil;

  while Assigned(BaseClass) do
  begin
    Declared := BaseClass.GetDeclaredFields;
    Start := Length(Result);

    SetLength(Result, Start + Length(Declared));

    for A := Low(Declared) to High(Declared) do
      Result[Start + A] := Declared[A];

    BaseClass := BaseClass.GetAncestor;
  end;
end;

{ TRttiInstanceType }

function TRttiInstanceType.GetClassTypeInfo: TTypeInfoClass;
begin
  Result:=TTypeInfoClass(inherited Handle);
end;

function TRttiInstanceType.GetMetaClassType: TClass;
begin
  Result:=ClassTypeInfo.ClassType;
end;

function TRttiInstanceType.GetAncestor: TRttiStructuredType;
begin
  Result := GetAncestorType;
end;

function TRttiInstanceType.GetBaseType: TRttiType;
begin
  Result:=GetAncestorType;
end;

function TRttiInstanceType.GetAncestorType: TRttiInstanceType;
begin
  Result := inherited Parent as TRttiInstanceType;
end;

constructor TRttiInstanceType.Create(AParent: TRttiObject; ATypeInfo: PTypeInfo);
begin
  if not (TTypeInfo(ATypeInfo) is TTypeInfoClass) then
    raise EInvalidCast.Create('');

  inherited;
end;

{ TRttiInterfaceType }

constructor TRttiInterfaceType.Create(AParent: TRttiObject; ATypeInfo: PTypeInfo);
begin
  if not (TTypeInfo(ATypeInfo) is TTypeInfoInterface) then
    raise EInvalidCast.Create('');

  inherited;
end;

function TRttiInterfaceType.GetGUID: TGUID;
var
  GUID: String;

begin
  GUID := InterfaceTypeInfo.InterfaceInfo.GUID;

  TryStringToGUID(GUID, Result);
end;

function TRttiInterfaceType.GetInterfaceTypeInfo: TTypeInfoInterface;
begin
  Result := TTypeInfoInterface(inherited Handle);
end;

function TRttiInterfaceType.GetAncestor: TRttiStructuredType;
begin
  Result := GetAncestorType;
end;

function TRttiInterfaceType.GetBaseType: TRttiType;
begin
  Result := GetAncestorType;
end;

function TRttiInterfaceType.GetAncestorType: TRttiInterfaceType;
begin
  Result := Pool.GetType(InterfaceTypeInfo.Ancestor) as TRttiInterfaceType;
end;

{ TRttiRecordType }

function TRttiRecordType.GetRecordTypeInfo: TTypeInfoRecord;
begin
  Result := TTypeInfoRecord(inherited Handle);
end;

function TRttiRecordType.GetIsRecord: Boolean;
begin
  Result := True;
end;

constructor TRttiRecordType.Create(AParent: TRttiObject; ATypeInfo: PTypeInfo);
begin
  if not (TTypeInfo(ATypeInfo) is TTypeInfoRecord) then
    raise EInvalidCast.Create('');

  inherited;
end;

{ TRttiClassRefType }

constructor TRttiClassRefType.Create(AParent: TRttiObject; ATypeInfo: PTypeInfo);
begin
  if not (TTypeInfo(ATypeInfo) is TTypeInfoClassRef) then
    raise EInvalidCast.Create('');

  inherited;
end;

function TRttiClassRefType.GetClassRefTypeInfo: TTypeInfoClassRef;
begin
  Result := TTypeInfoClassRef(inherited Handle);
end;

function TRttiClassRefType.GetInstanceType: TRttiInstanceType;
begin
  Result := Pool.GetType(ClassRefTypeInfo.InstanceType) as TRttiInstanceType;
end;

function TRttiClassRefType.GetMetaclassType: TClass;
begin
  Result := InstanceType.MetaClassType;
end;

{ TRttiInstanceExternalType }

function TRttiInstanceExternalType.GetAncestor: TRttiInstanceExternalType;
begin
  Result := Pool.GetType(ExternalClassTypeInfo.Ancestor) as TRttiInstanceExternalType;
end;

function TRttiInstanceExternalType.GetExternalClassTypeInfo: TTypeInfoExtClass;
begin
  Result := TTypeInfoExtClass(inherited Handle);
end;

function TRttiInstanceExternalType.GetExternalName: String;
begin
  Result := ExternalClassTypeInfo.JSClassName;
end;

constructor TRttiInstanceExternalType.Create(AParent: TRttiObject; ATypeInfo: PTypeInfo);
begin
  if not (TTypeInfo(ATypeInfo) is TTypeInfoExtClass) then
    raise EInvalidCast.Create('');

  inherited;
end;

{ TRTTIContext }

class function TRTTIContext.Create: TRTTIContext;
begin
  Pool.AcquireContext;
end;

procedure TRTTIContext.Free;
begin
  Pool.ReleaseContext;
end;

function TRTTIContext.GetType(aTypeInfo: PTypeInfo): TRttiType;
begin
  Result := Pool.GetType(aTypeInfo);
end;

function TRTTIContext.GetType(aClass: TClass): TRTTIType;
begin
  Result := Pool.GetType(aClass);
end;

function TRTTIContext.FindType(const AQualifiedName: String): TRttiType;
begin
  Result := Pool.FindType(AQualifiedName);
end;

function TRTTIContext.GetTypes: specialize TArray<TRttiType>;
var
  ModuleName, ClassName: String;

  ModuleTypes: TSectionRTTI;

begin
  for ModuleName in TJSObject.Keys(pas) do
  begin
    ModuleTypes := TTypeInfoModule(pas[ModuleName]).RTTI;

    for ClassName in ModuleTypes do
      if ClassName[1] <> '$' then
        GetType(PTypeInfo(ModuleTypes[ClassName]));
  end;

  Result := specialize TArray<TRttiType>(TJSObject.Values(Pool.FTypes));
end;

class procedure TRTTIContext.KeepContext;
begin
  Pool.AcquireContext;
end;

class procedure TRTTIContext.DropContext;
begin
  Pool.ReleaseContext;
end;

{ TRttiObject }

constructor TRttiObject.Create(AParent: TRttiObject; AHandle: Pointer);
begin
  FParent := AParent;
  FHandle := AHandle;
end;

destructor TRttiObject.Destroy;
var
  Attribute: TCustomAttribute;
begin
  for Attribute in FAttributes do
    Attribute.Free;

  FAttributes := nil;

  inherited Destroy;
end;

function TRttiObject.LoadCustomAttributes: TCustomAttributeArray;
begin
  Result := nil;
end;

function TRttiObject.GetAttributes: TCustomAttributeArray;
begin
  if not FAttributesLoaded then
  begin
    FAttributes := LoadCustomAttributes;
    FAttributesLoaded := True;
  end;

  Result := FAttributes;
end;

function TRttiObject.GetAttribute(const Attribute: TCustomAttributeClass): TCustomAttribute;
var
  CustomAttribute: TCustomAttribute;

begin
  Result := nil;

  for CustomAttribute in GetAttributes do
    if CustomAttribute is Attribute then
      Exit(CustomAttribute);
end;

generic function TRttiObject.GetAttribute<T>: T;

begin
  Result := T(GetAttribute(TCustomAttributeClass(T.ClassType)));
end;

function TRttiObject.HasAttribute(const Attribute: TCustomAttributeClass): Boolean;
begin
  Result := GetAttribute(Attribute) <> nil;
end;

generic function TRttiObject.HasAttribute<T>: Boolean;
begin
  Result := HasAttribute(TCustomAttributeClass(T.ClassType));
end;

{ TRttiNamedObject }

function TRttiNamedObject.GetName: string;
begin
  Result:='';
end;

{ TRttiArrayType }

function TRttiArrayType.GetDimensionCount: SizeUInt;
begin
  Result:=Length(StaticArrayTypeInfo.Dims);
end;

function TRttiArrayType.GetDimension(aIndex: SizeInt): TRttiType;
begin
  if (aIndex >= DimensionCount) then
    raise ERtti.CreateFmt(SErrDimensionOutOfRange, [aIndex, DimensionCount]);
  if ElementType is TRttiArrayType then
    Result:=TRttiArrayType(ElementType).Dimensions[aIndex-1]
  else
    Result :=ElementType;
end;

function TRttiArrayType.GetElementType: TRttiType;
begin
  Result:=Pool.GetType(GetStaticArrayTypeInfo.ElType);
end;

function TRttiArrayType.GetStaticArrayTypeInfo: TTypeInfoStaticArray;
begin
  Result:=TTypeInfoStaticArray(Handle);
end;

function TRttiArrayType.GetTotalElementCount: SizeInt;
var
  I : integer;
begin
  Result:=StaticArrayTypeInfo.Dims[0];
  For I:=1 to Length(StaticArrayTypeInfo.Dims)-1 do
    Result:=Result*StaticArrayTypeInfo.Dims[i]
end;

{ TRttiMember }

function TRttiMember.GetName: String;
begin
  Result := MemberTypeInfo.Name;
end;

function TRttiMember.GetParent: TRttiType;
begin
  Result := TRttiType(inherited Parent);
end;

function TRttiMember.GetStrictVisibility: Boolean;
begin
  Result:=MemberTypeInfo.Visibility in [tmvStrictPrivate,tmvStrictProtected];
end;

function TRttiMember.GetVisibility: TMemberVisibility;
begin
  case MemberTypeInfo.Visibility of
    tmvPrivate, tmvStrictPrivate: Result:=mvPrivate;
    tmvProtected, tmvStrictProtected: Result:=mvProtected;
    tmvPublic, tmvPublishedPublic: Result:=mvPublic;
  else Result:=mvPublished;
  end;
end;

constructor TRttiMember.Create(AParent: TRttiType; ATypeInfo: TTypeMember);
begin
  if not (ATypeInfo is TTypeMember) then
    raise EInvalidCast.Create('');

  inherited Create(AParent, ATypeInfo);
end;

function TRttiMember.LoadCustomAttributes: TCustomAttributeArray;
begin
  Result := GetRTTIAttributes(MemberTypeInfo.Attributes);
end;

function TRttiMember.GetMemberTypeInfo: TTypeMember;
begin
  Result := TTypeMember(inherited Handle);
end;

{ TRttiField }

constructor TRttiField.Create(AParent: TRttiType; ATypeInfo: TTypeMember);
begin
  if not (ATypeInfo is TTypeMemberField) then
    raise EInvalidCast.Create('');

  inherited;
end;

function TRttiField.GetDataType: TRttiType;
begin
  Result := nil;
end;

function TRttiField.GetIsReadable: Boolean;
begin
  Result := True;
end;

function TRttiField.GetIsWritable: Boolean;
begin
  Result := True;
end;

function TRttiField.GetFieldType: TRttiType;
begin
  Result := Pool.GetType(FieldTypeInfo.TypeInfo);
end;

function TRttiField.GetFieldTypeInfo: TTypeMemberField;
begin
  Result := TTypeMemberField(inherited Handle);
end;

function TRttiField.GetValue(Instance: JSValue): TValue;
var
  JSInstance: TJSObject absolute Instance;

begin
  Result := TValue.FromJSValue(JSInstance[Name]);
end;

procedure TRttiField.SetValue(Instance: JSValue; const AValue: TValue);
var
  JSInstance: TJSObject absolute Instance;

begin
  JSInstance[Name] := AValue.Cast(FieldType.Handle, True).ASJSValue;
end;

{ TRttiParameter }

function TRttiParameter.GetName: String;
begin
  Result := FName;
end;

{ TRttiMethod }

function TRttiMethod.GetMethodTypeInfo: TTypeMemberMethod;
begin
  Result := TTypeMemberMethod(inherited Handle);
end;

function TRttiMethod.GetIsClassMethod: Boolean;
begin
  Result:=MethodTypeInfo.MethodKind in [mkClassFunction,mkClassProcedure];
end;

function TRttiMethod.GetIsConstructor: Boolean;
begin
  Result:=MethodTypeInfo.MethodKind=mkConstructor;
end;

function TRttiMethod.GetIsDestructor: Boolean;
begin
  Result:=MethodTypeInfo.MethodKind=mkDestructor;
end;

function TRttiMethod.GetIsExternal: Boolean;
begin
  Result := pfExternal in GetProcedureFlags;
end;

function TRttiMethod.GetIsStatic: Boolean;
begin
  Result := pfStatic in GetProcedureFlags;
end;

function TRttiMethod.GetIsVarArgs: Boolean;
begin
  Result := pfVarargs in GetProcedureFlags;
end;

function TRttiMethod.GetIsAsyncCall: Boolean;
begin
  Result := pfAsync in GetProcedureFlags;
end;

function TRttiMethod.GetIsSafeCall: Boolean;
begin
  Result := pfSafeCall in GetProcedureFlags;
end;

function TRttiMethod.GetMethodKind: TMethodKind;
begin
  Result:=MethodTypeInfo.MethodKind;;
end;

function TRttiMethod.GetProcedureFlags: TProcedureFlags;
begin
  Result := ProcedureSignature.Flags;
end;

function TRttiMethod.GetReturnType: TRttiType;
begin
  Result := ProcedureSignature.ReturnType;
end;

function TRttiMethod.GetProcedureSignature: TRttiProcedureSignature;
begin
  if not Assigned(FProcedureSignature) then
    FProcedureSignature := TRttiProcedureSignature.Create(Self, MethodTypeInfo.ProcSig);

  Result := FProcedureSignature;
end;

function TRttiMethod.GetParameters: TRttiParameterArray;
begin
  Result := ProcedureSignature.Parameters;
end;

function TRttiMethod.Invoke(const Instance: TValue; const Args: array of TValue): TValue;
var
  A: Integer;
  AArgs: TJSValueDynArray;
  Func: TJSFunction;
  InstanceObject: TJSObject;
  ReturnValue: JSValue;

begin
  InstanceObject := TJSObject(Instance.AsJSValue);

  SetLength(AArgs, Length(Args));

  for A := Low(Args) to High(Args) do
    AArgs[A] := Args[A].AsJSValue;

  if IsConstructor then
  begin
    Func := TJSFunction(InstanceObject['$create']);

    ReturnValue := Func.apply(InstanceObject, [MethodTypeInfo.Name, AArgs]);
  end
  else
  begin
    Func := TJSFunction(InstanceObject[MethodTypeInfo.Name]);

    ReturnValue := Func.apply(InstanceObject, AArgs);
  end;

  if Assigned(ReturnType) then
    TValue.Make(ReturnValue, ReturnType.Handle, Result)
  else if IsAsyncCall then
    TValue.Make(ReturnValue, TypeInfo(TJSPromise), Result)
  else if IsConstructor then
    TValue.Make(ReturnValue, Instance.TypeInfo, Result)
end;

function TRttiMethod.Invoke(const Instance: TObject; const Args: array of TValue): TValue;
var
  v: TValue;

begin
  TValue.Make(Instance, Instance.ClassInfo, v);
  Result := Invoke(v, Args);
end;

function TRttiMethod.Invoke(const aClass: TClass; const Args: array of TValue): TValue;
var
  v: TValue;

begin
  TValue.Make(aClass, aClass.ClassInfo, v);
  Result := Invoke(V, Args);
end;

{ TRttiProperty }

constructor TRttiProperty.Create(AParent: TRttiType; ATypeInfo: TTypeMember);
begin
  if not (ATypeInfo is TTypeMemberProperty) then
    raise EInvalidCast.Create('');

  inherited;
end;

function TRttiProperty.GetDataType: TRttiType;
begin
  Result := GetPropertyType;
end;

function TRttiProperty.GetDefault: JSValue;
begin
  Result:=PropertyTypeInfo.Default;
end;

function TRttiProperty.GetIndex: Integer;
begin
  if isUndefined(PropertyTypeInfo.Index) then
    Result:=0
  else
    Result:=Integer(PropertyTypeInfo.Index);
end;

function TRttiProperty.GetIsClassProperty: boolean;
begin
  Result:=(PropertyTypeInfo.Flags and pfClassProperty) > 0;
end;

function TRttiProperty.GetPropertyTypeInfo: TTypeMemberProperty;
begin
  Result := TTypeMemberProperty(inherited Handle);
end;

function TRttiProperty.GetValue(Instance: JSValue): TValue;
var
  JSObject: TJSObject absolute Instance;

begin
  TValue.Make(GetJSValueProp(JSObject, PropertyTypeInfo), PropertyType.Handle, Result);
end;

procedure TRttiProperty.SetValue(Instance: JSValue; const AValue: TValue);
var
  JSInstance: TJSObject absolute Instance;

begin
  SetJSValueProp(JSInstance, PropertyTypeInfo, AValue.Cast(PropertyType.Handle, True).AsJSValue);
end;

function TRttiProperty.GetPropertyType: TRttiType;
begin
  Result := Pool.GetType(PropertyTypeInfo.TypeInfo);
end;

function TRttiProperty.GetIsWritable: boolean;
begin
  Result := PropertyTypeInfo.Setter<>'';
end;

function TRttiProperty.GetIsReadable: boolean;
begin
  Result := PropertyTypeInfo.Getter<>'';
end;

{ TRttiType }

function TRttiType.GetName: string;
begin
  Result := Handle.Name;
end;

function TRttiType.GetIsInstance: boolean;
begin
  Result:=Self is TRttiInstanceType;
end;

function TRttiType.GetIsInstanceExternal: boolean;
begin
  Result:=Self is TRttiInstanceExternalType;
end;

function TRttiType.GetIsOrdinal: boolean;
begin
  Result:=false;
end;

function TRttiType.GetIsRecord: boolean;
begin
  Result:=false;
end;

function TRttiType.GetIsSet: boolean;
begin
  Result:=false;
end;

function TRttiType.GetTypeKind: TTypeKind;
begin
  Result:=Handle.Kind;
end;

function TRttiType.GetHandle: TTypeInfo;
begin
  Result := TTypeInfo(inherited Handle);
end;

function TRttiType.GetBaseType: TRttiType;
begin
  Result:=Nil;
end;

function TRttiType.GetAsInstance: TRttiInstanceType;
begin
  Result := Self as TRttiInstanceType;
end;

function TRttiType.GetAsInstanceExternal: TRttiInstanceExternalType;
begin
  Result := Self as TRttiInstanceExternalType;
end;

function TRttiType.LoadCustomAttributes: TCustomAttributeArray;
begin
  Result:=GetRTTIAttributes(Handle.Attributes);
end;

function TRttiType.GetDeclaredProperties: TRttiPropertyArray;
begin
  Result:=nil;
end;

function TRttiType.GetProperties: TRttiPropertyArray;
begin
  Result:=nil;
end;

function TRttiType.GetProperty(const AName: string): TRttiProperty;
begin
  Result:=nil;
  if AName='' then ;
end;

function TRttiType.GetMethods: TRttiMethodArray;
begin
  Result:=nil;
end;

function TRttiType.GetMethods(const aName: String): TRttiMethodArray;
begin
  Result:=nil;
  if aName='' then ;
end;

function TRttiType.GetMethod(const aName: String): TRttiMethod;
begin
  Result:=nil;
  if aName='' then ;
end;

function TRttiType.GetDeclaredMethods: TRttiMethodArray;
begin
  Result:=nil;
end;

function TRttiType.GetDeclaredFields: TRttiFieldArray;
begin
  Result:=nil;
end;

function TRttiType.GetField(const AName: string): TRttiField;
var
  AField: TRttiField;

begin
  Result:=nil;
  for AField in GetFields do
    if AField.Name = AName then
      Exit(AField);
end;

function TRttiType.GetFields: TRttiFieldArray;
begin
  Result := nil;
end;

function TRttiType.GetDeclaringUnitName: String;
begin
  if Assigned(Handle.Module) then
    Result := Handle.Module.Name
  else
    Result := 'System';
end;

function TRttiType.GetQualifiedName: String;
begin
  Result := Format('%s.%s', [DeclaringUnitName, Name]);
end;

{ TRttiStringType }

function TRttiStringType.GetStringKind: TRttiStringKind;
begin
  Result:=skUnicodeString;
end;

{ TRttiAnsiStringType }

function TRttiAnsiStringType.GetCodePage: Word;
begin
  Result:=0;
end;

{ TRttiPointerType }

constructor TRttiPointerType.Create(AParent: TRttiObject; ATypeInfo: PTypeInfo);
begin
  if not (TTypeInfo(ATypeInfo) is TTypeInfoPointer) then
    raise EInvalidCast.Create('');
  inherited;
end;

function TRttiPointerType.GetRefType: TRttiType;
begin
  Result := Pool.GetType(RefTypeInfo.RefType);
end;

function TRttiPointerType.GetRefTypeInfo: TTypeInfoPointer;
begin
  Result := TTypeInfoPointer(inherited Handle);
end;

{ TVirtualInterface }

constructor TVirtualInterface.Create(PIID: PTypeInfo);
var
  InterfaceMaps: TJSObject;

  function Jump(MethodName: String): JSValue;
  begin
    Result :=
      function: JSValue
      begin
        Result := TVirtualInterface(JSThis['$o']).Invoke(MethodName, JSArguments);
      end;
  end;

  function GenerateNewMap(InterfaceInfo: TTypeInfoInterface): TJSObject;
  var
    MethodName: String;

  begin
    Result := TJSObject.New;

    while Assigned(InterfaceInfo) do
    begin
      if InterfaceMaps[InterfaceInfo.InterfaceInfo.GUID] = nil then
        for MethodName in InterfaceInfo.Names do
          Result[MethodName] := Jump(MethodName)
      else
        for MethodName in InterfaceInfo.Names do
          Result[MethodName] := TJSObject(InterfaceMaps[InterfaceInfo.InterfaceInfo.GUID])[MethodName];

      InterfaceInfo := InterfaceInfo.Ancestor;
    end;
  end;

var
  InterfaceInfo: TTypeInfoInterface;

begin
  FContext := TRttiContext.Create;
  FInterfaceType := FContext.GetType(PIID) as TRttiInterfaceType;
  if Assigned(FInterfaceType) then
  begin
    InterfaceInfo := FInterfaceType.InterfaceTypeInfo;
    InterfaceMaps := TJSObject.Create(TJSObject(JSThis['$intfmaps']));
    while Assigned(InterfaceInfo) do
    begin
      InterfaceMaps[InterfaceInfo.InterfaceInfo.GUID] := GenerateNewMap(InterfaceInfo);
      InterfaceInfo := InterfaceInfo.Ancestor;
    end;
    JSThis['$intfmaps'] := InterfaceMaps;
  end
  else
    raise EInvalidCast.Create;
end;

constructor TVirtualInterface.Create(PIID: PTypeInfo; const InvokeEvent: TVirtualInterfaceInvokeEvent);
begin
  Create(PIID);
  OnInvoke := InvokeEvent;
end;

constructor TVirtualInterface.Create(PIID: PTypeInfo; const InvokeEvent: TVirtualInterfaceInvokeEventJS);
begin
  Create(PIID);
  OnInvokeJS := InvokeEvent;
end;

destructor TVirtualInterface.Destroy;
begin
  FContext.Free;
  inherited;
end;

function TVirtualInterface.Invoke(const MethodName: String; const Args: TJSFunctionArguments): JSValue;
var
  Method: TRttiMethod;
  Return: TValue;

  function GenerateParams: specialize TArray<TValue>;
  var
    A: Integer;
    Param: TRttiParameter;
    Parameters: specialize TArray<TRttiParameter>;

  begin
    Parameters := Method.GetParameters;
    SetLength(Result, Length(Parameters));
    for A := Low(Parameters) to High(Parameters) do
    begin
      Param := Parameters[A];
      TValue.Make(Args[A], Param.ParamType.Handle, Result[A]);
      Result[A].FReferenceVariableData := (pfVar in Param.Flags) or (pfOut in Param.Flags);
    end;
  end;

begin
  if Assigned(FOnInvokeJS) then
    Result := FOnInvokeJS(MethodName, Args)
  else
  begin
    Method := FInterfaceType.GetMethod(MethodName);
    FOnInvoke(Method, GenerateParams, Return);
    Result := Return.AsJSValue;
  end;
end;

{ TRttiInvokableType }

function TRttiInvokableType.GetIsAsyncCall: Boolean;
begin
  Result:=fcfAsync in GetFlags;
end;

function TRttiInvokableType.GetParameters: TRttiParameterArray;
begin
  Result:=GetParameters(False);
end;

function TRttiInvokableType.ToString: string;
var
  P : TRTTIParameter;
  A : TRTTIParameterArray;
  I : integer;
  RT : TRttiType;

begin
  RT:=GetReturnType;
  if RT=nil then
    Result:=name+' = procedure ('
  else
    Result:=name+' = function (';
  A:=GetParameters(False);
  for I:=0 to Length(a)-1 do
    begin
      P:=A[I];
      if I>0 then
        Result:=Result+'; ';
      Result:=Result+P.Name;
      if Assigned(P.ParamType) then
        Result:=Result+' : '+P.ParamType.Name;
    end;
  result:=Result+')';
  if Assigned(RT) then
    Result:=Result+' : '+RT.Name;
end;

{ TRttiMethodType }

function TRttiMethodType.GetMethodKind: TMethodKind;
begin
  Result:=MethodTypeInfo.MethodKind
end;

function TRttiMethodType.GetMethodTypeInfo: TTypeInfoMethodVar;
begin
  Result:=TTypeInfoMethodVar(Handle);
end;

function TRttiMethodType.GetParameters(aWithHidden: Boolean): TRttiParameterArray;

var
  I : Integer;

begin
  SetLength(Result,Length(MethodTypeInfo.ProcSig.Params));
  For I:=0 to  Length(MethodTypeInfo.ProcSig.Params)-1 do
    Result[i]:=TRttiParameter.Create(Self,MethodTypeInfo.ProcSig.Params[i]);
  if aWithHidden then ;
end;

function TRttiMethodType.GetCallingConvention: TCallConv;
begin
  Result:=ccPascal
end;

function TRttiMethodType.GetReturnType: TRttiType;
begin
  if Assigned(MethodTypeInfo.ProcSig.ResultType) then
    Result:=Pool.GetType(MethodTypeInfo.ProcSig.ResultType)
  else
    Result:=Nil;
end;

const
  ConvertFlags : Array[TFunctionCallFlag] of TProcedureFlag
        = (pfStatic,pfVarArgs,pfExternal,pfSafeCall,pfAsync);

function TRttiMethodType.GetFlags: TFunctionCallFlags;

var
  FF : TFunctionCallFlag;
  lFlag : Integer;

begin
  Result:=[];
  for FF in TFunctionCallFlag do
    begin
    lFlag:=1 shl Ord(ConvertFlags[FF]);
    if (MethodTypeInfo.ProcSig.Flags and lFlag)<>0 then
      Include(Result,FF);
    end;
end;

function TRttiMethodType.Invoke(const aCallable: TValue; const aArgs: array of TValue): TValue;

var
  lLen,lIdx: Integer;
  lArgs: TJSValueDynArray;
  lResult : JSValue;
  cb : TPas2JSRtlCallback;

begin
  lLen:=Length(aArgs);
  SetLength(lArgs,lLen);
  for lIdx:=0 to lLen-1 do
    lArgs[lIdx]:=aArgs[lIdx].AsJSValue;
  cb:=TPas2JSRtlCallback(aCallable.AsJSValue);
  if isString(cb.fn) then
    lResult:=TJSFunction(cb.scope[string(cb.fn)]).apply(cb.scope,lArgs)
  else
    lResult:=TJSFunction(cb.fn).apply(cb.scope,lArgs);
  if Assigned(ReturnType) then
     TValue.Make(lResult,ReturnType.Handle,Result)
  else if IsAsyncCall then
    TValue.Make(lResult, TypeInfo(TJSPromise), Result)
end;

function TRttiMethodType.ToString: string;
begin
  Result:=inherited ToString;
  Result:=Result+' of object';
end;

{ TRttiProcedureType }

function TRttiProcedureType.GetProcTypeInfo: TTypeInfoProcVar;
begin
  Result:=TTypeInfoProcVar(Handle);
end;

function TRttiProcedureType.GetParameters(aWithHidden: Boolean): TRttiParameterArray;
var
  I : Integer;

begin
  SetLength(Result,Length(ProcTypeInfo.ProcSig.Params));
  For I:=0 to  Length(ProcTypeInfo.ProcSig.Params)-1 do
    Result[i]:=TRttiParameter.Create(Self,ProcTypeInfo.ProcSig.Params[i]);
  if aWithHidden then ;
end;

function TRttiProcedureType.GetCallingConvention: TCallConv;
begin
  Result:=ccPascal;
end;

function TRttiProcedureType.GetReturnType: TRttiType;
begin
  if Assigned(ProcTypeInfo.ProcSig.ResultType) then
    Result:=Pool.GetType(ProcTypeInfo.ProcSig.ResultType)
  else
    Result:=Nil;
end;

function TRttiProcedureType.GetFlags: TFunctionCallFlags;
var
  FF : TFunctionCallFlag;
  lFlag : Integer;

begin
  Result:=[];
  for FF in TFunctionCallFlag do
    begin
    lFlag:=1 shl Ord(ConvertFlags[FF]);
    if (ProcTypeInfo.ProcSig.Flags and lFlag)<>0 then
      Include(Result,FF);
    end;
end;

function TRttiProcedureType.Invoke(const aCallable: TValue; const aArgs: array of TValue): TValue;
var
  lLen,lIdx: Integer;
  lArgs: TJSValueDynArray;
  lResult : JSValue;
  cb : TPas2JSRtlCallback;

begin
  lLen:=Length(aArgs);
  SetLength(lArgs,lLen);
  for lIdx:=0 to lLen-1 do
    lArgs[lIdx]:=aArgs[lIdx].AsJSValue;
  cb:=TPas2JSRtlCallback(aCallable.AsJSValue);
  if isString(cb.fn) then
    lResult:=TJSFunction(cb.scope[string(cb.fn)]).apply(cb.scope,lArgs)
  else
    lResult:=TJSFunction(cb.fn).apply(cb.scope,lArgs);
  if Assigned(ReturnType) then
     TValue.Make(lResult,ReturnType.Handle,Result)
  else if IsAsyncCall then
    TValue.Make(lResult, TypeInfo(TJSPromise), Result)
end;

function Invoke(ACodeAddress: Pointer; const AArgs: TJSValueDynArray;
  ACallConv: TCallConv; AResultType: PTypeInfo; AIsStatic: Boolean;
  AIsConstructor: Boolean): TValue;
begin
  if ACallConv=ccReg then ;
  if AIsStatic then ;
  if AIsConstructor then
    raise EInvoke.Create('not supported');
  if isFunction(ACodeAddress) then
    begin
    Result.FData := TJSFunction(ACodeAddress).apply(nil, AArgs);
    if AResultType<>nil then
      Result.FTypeInfo:=AResultType
    else
      Result.FTypeInfo:=TypeInfo(JSValue);
    end
  else
    raise EInvoke.Create(SErrInvokeInvalidCodeAddr);
end;

function ArrayOfConstToTValueArray(const aValues: array of const): TValueArray;

var
  I,Len: Integer;

begin
  Result:=[];
  Len:=Length(aValues);
  SetLength(Result,Len);
  for I:=0 to Len-1 do
    Result[I]:=TValue.FromVarRec(aValues[I]);
end;

generic function OpenArrayToDynArrayValue<T>(constref aArray: array of T): TValue;
var
  arr: specialize TArray<T>;
  i: SizeInt;
begin
  arr:=[];
  SetLength(arr, Length(aArray));
  for i := 0 to High(aArray) do
    arr[i] := aArray[i];
  Result := TValue.specialize From<specialize TArray<T>>(arr);
end;

{ TRttiProcedureSignature }

constructor TRttiProcedureSignature.Create(const Parent: TRttiObject; const Signature: TProcedureSignature);
begin
  inherited Create(Parent, Signature);

  FReturnType := Pool.GetType(Signature.ResultType);

  LoadFlags;

  LoadParameters;
end;

procedure TRttiProcedureSignature.LoadFlags;
const
  PROCEDURE_FLAGS: array[TProcedureFlag] of NativeInt = (1, 2, 4, 8, 16);

var
  Flag: TProcedureFlag;

  ProcedureFlags: NativeInt;

begin
  ProcedureFlags := ProcedureSignature.Flags;
  FFlags := [];

  for Flag := Low(PROCEDURE_FLAGS) to High(PROCEDURE_FLAGS) do
    if PROCEDURE_FLAGS[Flag] and ProcedureFlags > 0 then
      FFlags := FFlags + [Flag];

  if Assigned(ReturnType) and ReturnType.IsInstanceExternal and (ReturnType.AsInstanceExternal.ExternalName = 'Promise') then
    FFlags := FFlags + [pfAsync];
end;

procedure TRttiProcedureSignature.LoadParameters;
const
  FLAGS_CONVERSION: array[TParamFlag] of NativeInt = (1, 2, 4, 8, 16, 32);

var
  A: Integer;

  Flag: TParamFlag;

  Param: TProcedureParam;

  RttiParam: TRttiParameter;

  MethodParams: TProcedureParams;

begin
  MethodParams := ProcedureSignature.Params;

  SetLength(FParameters, Length(MethodParams));

  for A := Low(FParameters) to High(FParameters) do
  begin
    Param := MethodParams[A];
    RttiParam := TRttiParameter.Create(Parent, Param);
    RttiParam.FName := Param.Name;
    RttiParam.FParamType := Pool.GetType(Param.TypeInfo);

    for Flag := Low(FLAGS_CONVERSION) to High(FLAGS_CONVERSION) do
      if FLAGS_CONVERSION[Flag] and Param.Flags > 0 then
        RttiParam.FFlags := RttiParam.FFlags + [Flag];

    FParameters[A] := RttiParam;
  end;
end;

function TRttiProcedureSignature.GetProcedureSignature: TProcedureSignature;
begin
  Result := TProcedureSignature(inherited Handle);
end;

class function TRttiProcedureSignature.Invoke(const Instance: TValue; const Args: array of TValue): TValue;
begin
  if Instance.IsEmpty then ;
  if Args=nil then ;
  Result:=Default(TValue);
  raise Exception.Create('20250726092613 not yet implement');
end;

end.

