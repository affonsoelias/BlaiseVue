{$IFNDEF FPC_DOTTEDUNITS}
unit wasienv;
{$ENDIF}

{$mode ObjFPC}
{$modeswitch externalclass}
{$INTERFACES CORBA}
{$WARN 5024 off}
{$WARN 4501 off}

{ $DEFINE NO_WASI_DEBUG}

interface

uses
{$IFDEF FPC_DOTTEDUNITS}
  System.SysUtils, System.Classes, JSApi.JS, BrowserApi.WebAssembly, System.Types, WasiTypes;
{$ELSE} 
  SysUtils, Classes, JS, WebAssembly, types, WasiTypes;
{$ENDIF}

Const
  SizeInt8     = 1;
  SizeInt16    = 2;
  SizeInt32    = 4;
  SizeInt64    = 8;
  SizeUInt8    = SizeInt8;
  SizeUInt16   = SizeInt16;
  SizeUInt32   = SizeInt32;
  SizeUInt64   = SizeInt64;
  SizeFloat32  = 4;
  SizeFloat64  = 8;

  // Pascal aliases
  SizeShortInt = SizeInt8;
  SizeByte     = SizeUInt8;
  SizeSmallInt = SizeInt16;
  SizeWord     = SizeUInt16;
  SizeLongInt  = SizeInt32;
  SizeCardinal = SizeUInt32;
  SizeQWord    = SizeUInt64;

type
  // An address in Webassembly memory
  TWasmPointer = longint;

  TMemBufferArray = Array of TJSUint8Array;

  TPreLoadFile = record
    url : String;
    localname : string;
  end;
  TPreLoadFileDynArray = Array of TPreLoadFile;

  TLoadFileFailure = record
    url : String;
    error : string;
  end;
  TLoadFileFailureDynArray = Array of TLoadFileFailure;

  TPreLoadFilesResult = record
    failedurls : TLoadFileFailureDynArray;
    loadcount : integer;
  end;

  { EWasmNativeException }

  EWasmNativeException = Class(Exception)
  private
    FNativeClass: String;
    FNativeMessage: String;
  Public
    constructor create(const aNativeClass,aNativeMessage : string); reintroduce;
    Property NativeClass : String read FNativeClass;
    Property NativeMessage : String read FNativeMessage;
  end;

  EWasiError = Class(Exception);

  EWasiFSError = class(Exception)
  Private
   FErrorcode : Integer;
  Public
   constructor Create(const aErrorCode: Integer; aMsg: String);
   constructor CreateFmt(const aErrorCode: Integer; aFmt: String; aArgs : Array of const);
   Property ErrorCode : Integer Read FErrorCode Write FErrorCode;
  end;

  IWASI = WasiTypes.IWASI;

  TWASIWriteEvent = Reference to Procedure(Sender : TObject; Const aOutput : String);

  TLastExceptionInfo = record
    ClassName : string;
    Message : string;
    more : boolean;
    doraise : boolean;
  end;

  // Standard FPC exports.
  TWASIExports = Class External name 'Object' (TJSModulesExports)
  Public
    // Program
    Procedure start; external name '_start';
    // Library
    Procedure initialize; external name '_initialize';
    function AllocMem(aSize : Integer) : Integer; external name 'wasiAlloc';
    function freeMem(aLocation : Integer) : Integer; external name 'wasiFree';
  end;

  TGetConsoleInputBufferEvent = Reference to Procedure(Sender : TObject; Var AInput : TJSUint8Array);
  TGetConsoleInputStringEvent = Reference to Procedure (Sender : TObject; Var AInput : string);

  TImportExtension = Class;

  { TPas2JSWASIEnvironment }

  TPas2JSWASIEnvironment = class (TObject,IWASI)
  Private
    FArguments: TStrings;
    FEnvironment: TStrings;
    FExitCode: Nativeint;
    FImportObject : TJSObject;
    Finstance: TJSWebAssemblyInstance;
    FLogAPI: Boolean;
    FModuleInstanceExports : TJSModulesExports;
    FOnGetConsoleInputBuffer: TGetConsoleInputBufferEvent;
    FOnGetConsoleInputString: TGetConsoleInputStringEvent;
    FOnStdErrorWrite: TWASIWriteEvent;
    FOnStdOutputWrite: TWASIWriteEvent;
    FImportExtensions : TFPList;
    FWasiFS: IWASIFS;
    FWASIImportName : string;
    FMemory : TJSWebAssemblyMemory;
    function DoRead(fd: NativeInt; iovs: TWasmMemoryLocation; iovsLen, atPos: NativeInt; nread: TWasmMemoryLocation): NativeInt;
    function GetConsoleInputBuffer(aMaxSize : Integer): TJSUint8Array;
    function GetFileBuffer(FD,aMaxLen: NativeInt): TJSUint8Array;
    function GetImportObject: TJSObject;
    function getiovs(view: TJSDataView; iovs, iovsLen: NativeInt): TMemBufferArray;
    function GetTotalIOVsLen(iovs: TMemBufferArray): Integer;
    function GetIOVsAsBytes(iovs, iovsLen: NativeInt): TJSUInt8array;
    function GetMemory: TJSWebassemblyMemory;
    procedure SetArguments(AValue: TStrings);
    procedure SetEnvironment(AValue: TStrings);
    procedure SetInstance(AValue: TJSWebAssemblyInstance);
    procedure SetLogAPI(AValue: Boolean);
    procedure WriteFileStatToMem(BufPtr: TWasmMemoryLocation;
      Info: TWasiFileStat);
  Protected
    class function ErrorToCode(E: Exception): NativeInt;
    Class Var UTF8TextDecoder: TJSTextDecoder;
    Class Var UTF8TextEncoder: TJSTextEncoder;
  Protected
    Procedure DoLog(Msg : String);
    Procedure DoLog(Fmt : String; Args : array of const);

    class function GetBigInt64(View: TJSDataView; byteOffset: NativeInt; littleEndian: Boolean): NativeInt;
    class function GetBigUint64(View: TJSDataView; byteOffset: NativeInt; littleEndian: Boolean): NativeUInt;
    class procedure setBigUint64(View: TJSDataView; byteOffset, value: NativeInt; littleEndian: Boolean);
    class procedure setBigInt64(View: TJSDataView; byteOffset, value: NativeInt; littleEndian: Boolean);
    procedure DoConsoleWrite(IsStdErr: Boolean; aBytes: TJSUint8Array); virtual;
    procedure GetImports(aImports: TJSObject); virtual;
    Function GetTime(aClockID : NativeInt): NativeInt; virtual;
    function getModuleMemoryDataView : TJSDataView;
    procedure AddExtension(aExtension : TImportExtension); virtual;
    procedure RemoveExtension(aExtension : TImportExtension); virtual;

    // IWASI calls
    // !! Please keep these sorted !!

    function args_get(argv, argvBuf : TWasmMemoryLocation) : NativeInt; virtual;
    function args_sizes_get(argc, argvBufSize : TWasmMemoryLocation) : NativeInt; virtual;
    function clock_res_get(clockId, resolution: NativeInt): NativeInt; virtual;
    function clock_time_get(clockId, precision : NativeInt; time: TWasmMemoryLocation): NativeInt; virtual;
    function environ_get(environ, environBuf : TWasmMemoryLocation) : NativeInt; virtual;
    function environ_sizes_get(environCount, environBufSize : TWasmMemoryLocation) : NativeInt; virtual;
    function fd_advise (fd, offset, len, advice : NativeInt) : NativeInt; virtual;
    function fd_allocate (fd, offset, len : NativeInt) : NativeInt; virtual;
    function fd_close(fd : NativeInt) : NativeInt; virtual;
    function fd_datasync (fd : NativeInt) : NativeInt; virtual;
    function fd_fdstat_get (fd : NativeInt; bufPtr: TWasmMemoryLocation) : NativeInt; virtual;
    function fd_fdstat_set_flags (fd, flags: NativeInt) : NativeInt; virtual;
    function fd_fdstat_set_rights (fd, fsRightsBase, fsRightsInheriting: NativeInt) : NativeInt; virtual;
    function fd_filestat_get (fd : NativeInt; bufPtr: TWasmMemoryLocation) : NativeInt; virtual;
    function fd_filestat_set_size (fd, stSize: NativeInt) : NativeInt; virtual;
    function fd_filestat_set_times (fd, stAtim, stMtim, fstflags: NativeInt) : NativeInt; virtual;
    function fd_pread(fd: NativeInt; iovs : TWasmMemoryLocation; iovsLen, offset: NativeInt; nread : TWasmMemoryLocation) : NativeInt; virtual;
    function fd_prestat_dir_name(fd : NativeInt; pathPtr : TWasmMemoryLocation; pathLen : NativeInt) : NativeInt; virtual;
    function fd_prestat_get(fd: NativeInt; bufPtr: TWasmMemoryLocation) : NativeInt; virtual;
    function fd_pwrite(fd, iovs, iovsLen, offset, nwritten : NativeInt) : NativeInt;virtual;
    function fd_read(fd: NativeInt; iovs : TWasmMemoryLocation; iovsLen: NativeInt; nread : TWasmMemoryLocation) : NativeInt; virtual;
    function fd_readdir(fd : NativeInt; bufPtr: TWasmMemoryLocation; bufLen, cookie: NativeInt; bufusedPtr : TWasmMemoryLocation) : NativeInt; virtual;
    function fd_renumber(afrom,ato : NativeInt) : NativeInt; virtual;
    function fd_seek(fd, offset, whence : NativeInt; newOffsetPtr : TWasmMemoryLocation) : NativeInt; virtual;
    function fd_sync(fd : NativeInt) : NativeInt; virtual;
    function fd_tell(fd: NativeInt; offsetPtr: TWasmMemoryLocation): NativeInt; virtual;
    function fd_write(fd,iovs,iovsLen,nwritten : NativeInt) : NativeInt; virtual;
    function path_create_directory (fd, pathPtr, pathLen : NativeInt) : NativeInt;
    function path_filestat_get(fd, flags : NativeInt; pathPtr : TWasmMemoryLocation;  pathLen : Nativeint; bufPtr : TWasmMemoryLocation) : NativeInt;
    function path_filestat_set_times(fd, fstflags, pathPtr, pathLen, stAtim, stMtim : NativeInt) : NativeInt;
    function path_link (oldFd, oldFlags : NativeInt; oldPath: TWasmMemoryLocation; oldPathLen, newFd : NativeInt; NewPath: TWasmMemoryLocation; newPathLen: NativeInt) : NativeInt;
    function path_open (dirfd, dirflags : NativeInt; pathPtr : TWasmMemoryLocation; pathLen, oflags, fsRightsBase, fsRightsInheriting, fsFlags : NativeInt; fd : TWasmMemoryLocation) : NativeInt; virtual;
    function path_readlink (fd: NativeInt; pathPtr: TWasmMemoryLocation; pathLen: NativeInt; buf: TWasmMemoryLocation; bufLen : NativeInt; bufused : TWasmMemoryLocation) : NativeInt; virtual;
    function path_remove_directory (fd : NativeInt; pathPtr: TWasmMemoryLocation; pathLen : NativeInt) : NativeInt;
    function path_rename (oldFd, oldPath, oldPathLen, newFd, newPath, newPathLen : NativeInt) : NativeInt;
    function path_symlink (oldPath, oldPathLen, fd, newPath, newPathLen : NativeInt) : NativeInt;
    function path_unlink_file (fd, pathPtr, pathLen : NativeInt) : NativeInt;
    function poll_oneoff(sin, sout, nsubscriptions, nevents : NativeInt) : NativeInt; virtual;
    function proc_exit(rval : NativeInt) : NativeInt; virtual;
    function proc_raise (sig : NativeInt) : NativeInt; virtual;
    function random_get (bufPtr, bufLen: NativeInt) : NativeInt; virtual;
    function sched_yield() : NativeInt; virtual;
    function sock_recv() : NativeInt; virtual;
    function sock_send() : NativeInt; virtual;
    function sock_shutdown() : NativeInt; virtual;
  Protected
    Procedure SetMemory(aMemory : TJSWebAssemblyMemory);
  Public
    Const
      IsLittleEndian = True; // Wasm is apparently l
  Public
    class constructor init;
    Constructor Create;
    Destructor Destroy; override;
    function GetUTF8ByteLength(const AString: String): Integer;
    Function GetUTF8StringFromMem(aLoc, aLen : Longint) : String;
    function GetUTF8StringFromArray(aSourceArray: TJSUint8Array): String;
    function GetUTF16StringFromMem(p : TWasmPointer; LenInChars : Integer) : String;
    // Write string as UTF8 string in memory at aLoc, with max aLen bytes.
    // Return number of bytes written, or -NeededLen if not enough room.
    function SetUTF8StringInMem(aLoc: TWasmMemoryLocation; aLen: Longint; AString: String): Integer;
    function SetUTF8StringInMem(aLoc: TWasmMemoryLocation; aLen: Longint; AStringBuf: TJSUint8Array): Integer;
    Function SetUTF16StringInMem(p : TWasmPointer; const aString : String) : integer;
    function SetMemInfoInt8(aLoc : TWasmMemoryLocation; aValue : ShortInt) : TWasmMemoryLocation;
    function SetMemInfoInt16(aLoc : TWasmMemoryLocation; aValue : SmallInt) : TWasmMemoryLocation;
    function SetMemInfoInt32(aLoc : TWasmMemoryLocation; aValue : Longint) : TWasmMemoryLocation;
    function SetMemInfoInt64(aLoc : TWasmMemoryLocation; aValue : NativeInt) : TWasmMemoryLocation;
    function SetMemInfoUInt8(aLoc : TWasmMemoryLocation; aValue : Byte) : TWasmMemoryLocation;
    function SetMemInfoUInt16(aLoc : TWasmMemoryLocation; aValue : Word) : TWasmMemoryLocation;
    function SetMemInfoUInt32(aLoc : TWasmMemoryLocation; aValue : Cardinal) : TWasmMemoryLocation;
    function SetMemInfoUInt64(aLoc : TWasmMemoryLocation; aValue : NativeUint) : TWasmMemoryLocation;
    function SetMemInfoFloat32(aLoc : TWasmMemoryLocation; aValue : Double) : TWasmMemoryLocation;
    function SetMemInfoFloat64(aLoc : TWasmMemoryLocation; aValue : Double) : TWasmMemoryLocation;
    // Read values
    function GetMemInfoInt8(aLoc : TWasmMemoryLocation) : ShortInt;
    function GetMemInfoInt16(aLoc : TWasmMemoryLocation): SmallInt;
    function GetMemInfoInt32(aLoc : TWasmMemoryLocation): Longint;
    function GetMemInfoInt64(aLoc : TWasmMemoryLocation): NativeInt;
    function GetMemInfoUInt8(aLoc : TWasmMemoryLocation): Byte;
    function GetMemInfoUInt16(aLoc : TWasmMemoryLocation): Word;
    function GetMemInfoUInt32(aLoc : TWasmMemoryLocation): Cardinal;
    function GetMemInfoUInt64(aLoc : TWasmMemoryLocation): NativeUint;
    // Add imports
    Procedure AddImports(aObject: TJSObject);
    procedure SetExports(aExports : TWasiExports);
    Property ImportObject : TJSObject Read GetImportObject;
//    Property IsLittleEndian : Boolean Read FIsLittleEndian Write FIsLittleEndian;
    // Filesystem
    function PreLoadFiles(aFiles: array of string): TPreLoadFilesResult; async;
    function PreLoadFiles(aFiles: TPreLoadFileDynArray): TPreLoadFilesResult; async;
    function PreLoadFilesIntoDirectory(aDirectory : String; aFiles: array of string): TPreLoadFilesResult; async;

    Property OnStdOutputWrite : TWASIWriteEvent Read FOnStdOutputWrite Write FOnStdOutputWrite;
    Property OnStdErrorWrite : TWASIWriteEvent Read FOnStdErrorWrite Write FOnStdErrorWrite;
    Property OnGetConsoleInputBuffer : TGetConsoleInputBufferEvent Read FOnGetConsoleInputBuffer Write FOnGetConsoleInputBuffer;
    Property OnGetConsoleInputString : TGetConsoleInputStringEvent Read FOnGetConsoleInputString Write FOnGetConsoleInputString;
    Property Instance : TJSWebAssemblyInstance Read Finstance Write SetInstance;
    Property Memory : TJSWebassemblyMemory Read GetMemory;
    Property Exitcode : Nativeint Read FExitCode;
    // Default is set to the one expected by FPC runtime: wasi_snapshot_preview1
    Property WASIImportName : String Read FWASIImportName Write FWASIImportName;
    Property LogAPI : Boolean REad FLogAPI Write SetLogAPI;
    Property FS : IWASIFS Read FWasiFS Write FWasiFS;
    Property Arguments : TStrings Read FArguments Write SetArguments;
    Property Environment : TStrings Read FEnvironment Write SetEnvironment;
  end;

  { TImportExtension }

  TImportExtension = class (TObject)
  Private
    FEnv : TPas2JSWASIEnvironment;
    FInstanceExports: TWASIExports;
    FLogAPI: Boolean;
  Protected
    property LogAPI : Boolean Read FLogAPI Write FLogAPI;
    procedure DoError(const Msg: String); overload;
    procedure DoError(const Fmt: String; const Args: array of const); overload;
    procedure DoLog(const Msg : String); overload;
    procedure DoLog(const Fmt : String; const args : Array of const); overload;
    procedure SetInstanceExports(const AValue: TWASIExports); virtual;
    function getModuleMemoryDataView : TJSDataView;
  Public
    Constructor Create(aEnv : TPas2JSWASIEnvironment); virtual;
    Destructor Destroy; override;
    class procedure register;
    class function RegisterName : string; virtual;
    Procedure FillImportObject(aObject : TJSObject); virtual; abstract;
    Function ImportName : String; virtual; abstract;
    Property Env : TPas2JSWASIEnvironment Read FEnv;
    Property InstanceExports : TWASIExports Read FInstanceExports Write SetInstanceExports;
  end;
  TImportExtensionArray = Array of TImportExtension;

  TImportExtensionClass = class of TImportExtension;
  TImportExtensionClassArray = Array of TImportExtensionClass;

  { TImportExtensionRegistry }

  TImportExtensionRegistry = class(TObject)
  Private
    class var _Instance : TImportExtensionRegistry;
  Private
    FExtensions : TImportExtensionClassArray;
    FExtensionCount : Integer;
    procedure Grow;
  Public
    class constructor init;
    constructor create; virtual;
    destructor destroy; override;
    function Find(const aExtension: String): TImportExtensionClass;
    function IndexOf(const aExtension: String): Integer;
    Function GetExtensions : TImportExtensionClassArray;
    Procedure RegisterExtension(aExtension : TImportExtensionClass);
    Procedure UnRegisterExtension(aExtension : TImportExtensionClass);
    class property instance : TImportExtensionRegistry Read _Instance;
  end;

  TRunWebassemblyProc = reference to Procedure(aExports : TWASIExports);
  TWebAssemblyStartDescriptor = record
    // Module
    Module : TJSWebAssemblyModule;
    // memory to use
    Memory : TJSWebAssemblyMemory;
    // Table to use
    Table : TJSWebAssemblyTable;
    // Exports of module
    Exported : TWASIExports;
    // Imports of module
    Imports : TJSOBject;
    // Instance
    Instance : TJSWebAssemblyInstance;
    // Procedure to actually run a function.
    CallRun : TRunWebassemblyProc;
    // After run, if an exception occurred, this is filled with error class/message.
    RunExceptionClass : String;
    RunExceptionMessage : String;
  end;


  TBeforeStartCallBack = Reference to Function (Sender : TObject; aDescriptor : TWebAssemblyStartDescriptor) : Boolean;
  TAfterStartCallBack = Reference to Procedure (Sender : TObject; aDescriptor : TWebAssemblyStartDescriptor);

  TBeforeStartEvent = Procedure (Sender : TObject; aDescriptor : TWebAssemblyStartDescriptor; var aAllowRun : Boolean) of object;
  TAfterStartEvent = Procedure (Sender : TObject; aDescriptor : TWebAssemblyStartDescriptor) of object;

  TFailEvent =  Procedure (Sender : TObject; aFail : JSValue) of object;

  TConsoleReadEvent = Procedure(Sender : TObject; Var AInput : String) of object;
  TConsoleWriteEvent = Procedure (Sender : TObject; aOutput : string) of object;
  TCreateExtensionEvent = procedure (sender : TObject; aExtension : TImportExtension) of object;
  TWasmExceptionEvent = procedure (Sender : TObject; var aInfo : TLastExceptionInfo) of object;
  { TWASIHost }

  TWASIHost = Class(TComponent)
  Private
    FAfterInstantation: TNotifyEvent;
    FAfterStart: TAfterStartEvent;
    FAutoCreateExtensions: Boolean;
    FBeforeInstantation: TNotifyEvent;
    FBeforeStart: TBeforeStartEvent;
    FConvertNativeExceptions: Boolean;
    FEnv: TPas2JSWASIEnvironment;
    FExcludeExtensions: TStrings;
    FExported: TWASIExports;
    FOnAllExtensionsCreated: TNotifyEvent;
    FOnExtensionCreated: TCreateExtensionEvent;
    FOnInstantiateFail: TFailEvent;
    FOnLoadFail: TFailEvent;
    FOnWasmException: TWasmExceptionEvent;
    FPreparedStartDescriptor: TWebAssemblyStartDescriptor;
    FMemoryDescriptor : TJSWebAssemblyMemoryDescriptor;
    FOnConsoleRead: TConsoleReadEvent;
    FOnConsoleWrite: TConsoleWriteEvent;
    FPredefinedConsoleInput: TStrings;
    FReadLineCount : Integer;
    FRunEntryFunction: String;
    FTableDescriptor : TJSWebAssemblyTableDescriptor;
    FExtensions : TImportExtensionArray;
    function GetEnv: TPas2JSWASIEnvironment;
    function GetIsLibrary: Boolean;
    function GetIsProgram: Boolean;
    function GetStartDescriptorReady: Boolean;
    function GetUseSharedMemory: Boolean;
    procedure SetExcludeExtensions(AValue: TStrings);
    procedure SetPredefinedConsoleInput(AValue: TStrings);
    procedure SetUseSharedMemory(AValue: Boolean);
  protected
    class function NeedSharedMemory : Boolean; virtual;
    // Calls GetExceptionInfo to get exception info and calls OnWasmException if assigned. Return true if exception must be reraised.
    function ConvertWasmException: boolean;
    // Wrap exported functions in a wrapper that converts native exceptions to actual exceptions.
    function WrapExports(aExported: TWASIExports): TWASIExports;
    // Delete all created extensions
    procedure DeleteExtensions;
    // Create registered extensions
    procedure DoCreateStandardExtensions; virtual;
    // Create a standard extension, call OnExtensionCreated callback
    function CreateStandardExtension(aClass: TImportExtensionClass): TImportExtension;
    // Called after instantiation was OK.
    Procedure DoAfterInstantiate; virtual;
    // Called before instantiation starts.
    Procedure DoBeforeInstantiate; virtual;
    // Called when loading fails
    Procedure DoLoadFail(aError : JSValue); virtual;
    // Called when instantiating fails
    Procedure DoInstantiateFail(aError : JSValue); virtual;
    // Call the run function on an instantiated webassembly
    function RunWebAssemblyInstance(aBeforeStart: TBeforeStartCallback; aAfterStart: TAfterStartCallback; aRun : TRunWebassemblyProc): Boolean; virtual; overload;
    // Prepare and run web assembly instance.
    function RunWebAssemblyInstance(aDescr: TWebAssemblyStartDescriptor; aBeforeStart: TBeforeStartCallback; aAfterStart: TAfterStartCallback): Boolean; overload;
    // Standard Input/Output reads
    procedure DoStdRead(Sender: TObject; var AInput: string); virtual;
    procedure DoStdWrite(Sender: TObject; const aOutput: String); virtual;
    // Load file from path ans instantiate a webassembly from it.
    function CreateWebAssembly(aPath: string; aImportObject: TJSObject): TJSPromise; virtual;
    // Create a WASI environment. Called during constructor, override to customize.
    Function CreateWasiEnvironment : TPas2JSWASIEnvironment; virtual;
    // Create Standard webassembly table description
    function GetTable: TJSWebAssemblyTable; virtual;
    // Create tandard webassembly memory.
    function GetMemory: TJSWebAssemblyMemory; virtual;
  public
    Constructor Create(aOwner : TComponent); override;
    Destructor Destroy; override;
    // Create all registered extensions. Called automatically when the environment is created and AutoCreateExtensions is true.
    procedure CreateStandardExtensions;
    // Find an extension by registered or class name.
    Function FindExtension(const aExtension : string) : TImportExtension;
    // Get an extension by registered or class name. Raises exception if it does not exist or has wrong class
    Generic Function GetExtension<T : TImportExtension>(const aExtension : string) : T;
    // Retrieves webassembly exception info. Pops exception object from the stack.
    function GetExceptionInfo(var aInfo: TLastExceptionInfo): boolean;
    // Will call OnConsoleWrite or write to console
    procedure WriteOutput(const aOutput: String); virtual;
    // Prepare start descriptor
    Procedure PrepareWebAssemblyInstance(aDescr: TWebAssemblyStartDescriptor); virtual;
    // Get prepared descriptor
    Property PreparedStartDescriptor : TWebAssemblyStartDescriptor Read FPreparedStartDescriptor;
    // Initialize a start descriptor.
    function InitStartDescriptor(aMemory: TJSWebAssemblyMemory; aTable: TJSWebAssemblyTable; aImportObj: TJSObject): TWebAssemblyStartDescriptor;
    // Load and start webassembly. If DoRun is true, then Webassembly entry point is called.
    // If aBeforeStart is specified, then it is called prior to calling run, and can disable running.
    // If aAfterStart is specified, then it is called after calling run. It is not called if running was disabled.
    function StartWebAssembly(aPath: string; DoRun: Boolean;  aBeforeStart: TBeforeStartCallback; aAfterStart: TAfterStartCallback) : TJSPromise;
    // Run the prepared descriptor
    Procedure RunPreparedDescriptor;
    // Initial memory descriptor
    Property MemoryDescriptor : TJSWebAssemblyMemoryDescriptor Read FMemoryDescriptor Write FMemoryDescriptor;
    // Import/export table descriptor
    Property TableDescriptor : TJSWebAssemblyTableDescriptor Read FTableDescriptor Write FTableDescriptor;
    // Environment to be used
    Property WasiEnvironment : TPas2JSWASIEnvironment Read GetEnv;
    // Exported functions. Also available in start descriptor.
    Property Exported : TWASIExports Read FExported;
    // Is the descriptor prepared ?
    Property StartDescriptorReady : Boolean Read GetStartDescriptorReady;
    // Default console input
    Property PredefinedConsoleInput : TStrings Read FPredefinedConsoleInput Write SetPredefinedConsoleInput;
    // Is it a library ?
    Property IsLibrary : Boolean Read GetIsLibrary;
    // Is it a program ?
    Property IsProgram : Boolean Read GetIsProgram;
    // Name of function to run. If empty, the FPC default _start is used.
    Property RunEntryFunction : String Read FRunEntryFunction Write FRunEntryFunction;
    // When calling a function and an exception is raised, attempt to get information on native FPC exceptions
    Property ConvertNativeExceptions : Boolean Read FConvertNativeExceptions Write FConvertNativeExceptions;
    // Called after webassembly start was run. Not called if webassembly was not run.
    Property AfterStart : TAfterStartEvent Read FAfterStart Write FAfterStart;
    // Called before running webassembly. If aAllowRun is false, running is disabled
    Property BeforeStart : TBeforeStartEvent Read FBeforeStart Write FBeforeStart;
    // Called when reading from console (stdin). If not set, PredefinedConsoleinput is used.
    property OnConsoleRead : TConsoleReadEvent Read FOnConsoleRead Write FOnConsoleRead;
    // Called when writing to console (stdout). If not set, console.log is used.
    property OnConsoleWrite : TConsoleWriteEvent Read FOnConsoleWrite Write FOnConsoleWrite;
    // Called when fetch of the wasm module fails.
    Property OnLoadFail : TFailEvent Read FOnLoadFail Write FOnLoadFail;
    // Called when instantiation of the wasm module fails.
    Property OnInstantiateFail : TFailEvent Read FOnInstantiateFail Write FOnInstantiateFail;
    // Use Shared memory for webassembly instances ?
    Property UseSharedMemory : Boolean Read GetUseSharedMemory Write SetUseSharedMemory;
    // Executed after instantiation
    Property AfterInstantation : TNotifyEvent Read FAfterInstantation Write FAfterInstantation;
    // Executed before instantiation
    Property BeforeInstantation : TNotifyEvent Read FBeforeInstantation Write FBeforeInstantation;
    // Create all registered extensions
    property AutoCreateExtensions : Boolean Read FAutoCreateExtensions Write FAutoCreateExtensions;
    // Extensions not to create
    // Create all registered extensions
    property ExcludeExtensions : TStrings Read FExcludeExtensions Write SetExcludeExtensions;
    // Called for each auto-created extension
    Property OnExtensionCreated : TCreateExtensionEvent Read FOnExtensionCreated Write FOnExtensionCreated;
    // Called for each auto-created extension
    Property OnAllExtensionsCreated : TNotifyEvent Read FOnAllExtensionsCreated Write FOnAllExtensionsCreated;
    // When a webassembly exception was found, this is called. Return true if it must be treated (i.e. raised) and false if it can be ignored
    Property OnWasmException: TWasmExceptionEvent Read FOnWasmException Write FOnWasmException;
  end;
  TWASIHostClass = class of TWASIHost;

implementation

uses 
{$IFDEF FPC_DOTTEDUNITS}
  BrowserApi.WebOrWorker;
{$ELSE} 
  WebOrWorker;
{$ENDIF}

{ TWASIHost }

procedure TWASIHost.DoStdRead(Sender: TObject; var AInput: string);

Var
  S : String;
begin
  S:='';
  if Assigned(FOnConsoleRead) then
    FOnConsoleRead(Self,S)
  else
    begin
    if (FReadLineCount<FPredefinedConsoleInput.Count) then
      begin
      S:=FPredefinedConsoleInput[FReadLineCount];
      Inc(FReadLineCount);
      end;
    end;
  aInput:=S;
end;

procedure TWASIHost.SetPredefinedConsoleInput(AValue: TStrings);
begin
  if FPredefinedConsoleInput=AValue then Exit;
  FPredefinedConsoleInput.Assign(AValue);
end;

function TWASIHost.GetUseSharedMemory: Boolean;
begin
  Result:=FMemoryDescriptor.shared;
  if isUndefined(Result) then
    Result:=False;
end;

procedure TWASIHost.SetExcludeExtensions(AValue: TStrings);
begin
  if FExcludeExtensions=AValue then Exit;
  FExcludeExtensions.Assign(AValue);
end;

function TWASIHost.GetStartDescriptorReady: Boolean;
begin
  With FPreparedStartDescriptor do
    Result:=Assigned(Memory) and Assigned(Module);
end;

function TWASIHost.GetIsLibrary: Boolean;
begin
  Result:=Assigned(FExported.functions['_initialize']);
end;

function TWASIHost.GetEnv: TPas2JSWASIEnvironment;
begin
  if FEnv=Nil then
    begin
    FEnv:=CreateWasiEnvironment;
    FEnv.OnStdErrorWrite:=@DoStdWrite;
    FEnv.OnStdOutputWrite:=@DoStdWrite;
    Fenv.OnGetConsoleInputString:=@DoStdRead;
    if AutoCreateExtensions then
      CreateStandardExtensions;
    end;
  Result:=FEnv;
end;

function TWASIHost.GetIsProgram: Boolean;
begin
  Result:=Assigned(FExported.functions['_start']);
end;

procedure TWASIHost.SetUseSharedMemory(AValue: Boolean);
begin
  FMemoryDescriptor.shared:=aValue;
end;

class function TWASIHost.NeedSharedMemory: Boolean;
begin
  Result:=False;
end;

procedure TWASIHost.DoAfterInstantiate;
begin
  If Assigned(FAfterInstantation) then
    FAfterInstantation(Self);
end;

procedure TWASIHost.DoBeforeInstantiate;
begin
  If Assigned(FBeforeInstantation) then
    FBeforeInstantation(Self);
end;

procedure TWASIHost.DoLoadFail(aError: JSValue);
begin
  If Assigned(FOnLoadFail) then
    FOnLoadFail(Self,aError);
end;

procedure TWASIHost.DoInstantiateFail(aError: JSValue);
begin
  If Assigned(FOnInstantiateFail) then
    FOnInstantiateFail(Self,aError);
end;

function TWASIHost.GetExceptionInfo(var aInfo : TLastExceptionInfo) : boolean;

type
  TGetExceptionInfoProc = function : TWasmPointer;
  TReleaseExceptionInfoProc = procedure(aInfo : TWasmPointer);
var
  lPtr,lPointer,lString : TWasmPointer;
  lLen : integer;
  lVal,lVal2 : JSValue;
  lProc : TGetExceptionInfoProc absolute lVal;
  lProc2 : TReleaseExceptionInfoProc absolute lVal2;
begin
  Result:=False;
  lVal:=Exported['GetLastExceptionInfo'];
  lVal2:=Exported['FreeLastExceptionInfo'];
  if not (IsDefined(lVal) and IsDefined(lVal2)) then
    exit;
  lPointer:=lProc();
  if lPointer=0 then
    exit;
  lPtr:=lPointer;
  lString:=WasiEnvironment.GetMemInfoInt32(lPtr);
  inc(lPtr,SizeInt32);
  lLen:=WasiEnvironment.GetMemInfoInt32(lPtr);
  inc(lPtr,SizeInt32);
  aInfo.ClassName:=WasiEnvironment.GetUTF8StringFromMem(lString,lLen);
  lString:=WasiEnvironment.GetMemInfoInt32(lPtr);
  inc(lPtr,SizeInt32);
  lLen:=WasiEnvironment.GetMemInfoInt32(lPtr);
  inc(lPtr,SizeInt32);
  aInfo.Message:=WasiEnvironment.GetUTF8StringFromMem(lString,lLen);
  aInfo.More:=WasiEnvironment.GetMemInfoInt8(lPtr)<>0;
  lProc2(lPointer);
  Result:=True;
end;

function TWASIHost.ConvertWasmException : boolean;

var
  lInfo : TLastExceptionInfo;

begin
  // if there is no info, we must raise
  lInfo:=Default(TLastExceptionInfo);
  Result:=not GetExceptionInfo(lInfo);
  if Result then
    exit;
  lInfo.doraise:=true;
  if Assigned(OnWasmException) then
    FOnWasmException(Self,lInfo);
  if lInfo.DoRaise then
    Raise EWasmNativeException.Create(lInfo.ClassName,lInfo.Message);
end;

function TWASIHost.WrapExports(aExported : TWASIExports) : TWASIExports;

  function createwrapper(aScope, aFunc : jsValue) : jsvalue;
  begin
    Result:=function() : jsvalue
        begin
          Result:=undefined;
          try
            asm
              Result=aFunc.apply(aScope,arguments);
            end;
          except
            on E : TJSWebAssemblyException do
              begin
              if ConvertWasmException then // will raise
                Raise;
              end;
          end;
        end;
  end;

var
  S : String;
  lFunc : JSValue;
  LNew : TWASIExports;

begin
  LNew:=TWASIExports.new;
  For S in TJSObject.getOwnPropertyNames(aExported) do
    begin
    lFunc:=aExported[s];
    if (not isFunction(lFunc)) or (S='GetLastExceptionInfo') or (S='FreeLastExceptionInfo') then
      lNew.Properties[s]:=lFunc
    else
      lNew.Properties[s]:=CreateWrapper(jsthis,lFunc);
  end;
  Result:=LNew;
end;

procedure TWASIHost.PrepareWebAssemblyInstance(aDescr: TWebAssemblyStartDescriptor);
begin
  if ConvertNativeExceptions then
    aDescr.Exported:=WrapExports(aDescr.Exported);
  FPreparedStartDescriptor:=aDescr;
  FExported:=FPreparedStartDescriptor.Exported;
  WasiEnvironment.Instance:=aDescr.Instance;
  WasiEnvironment.SetMemory(aDescr.Memory);
  WasiEnvironment.SetExports(FExported);
  //if ConvertExceptions then
  // We do this here, so in the event, the FPreparedStartDescriptor Is ready.
  DoAfterInstantiate;
end;

function TWASIHost.RunWebAssemblyInstance(aBeforeStart: TBeforeStartCallback; aAfterStart: TAfterStartCallback; aRun : TRunWebassemblyProc): Boolean;

begin
  Result:=True;
  // Writeln('Entering RunWebAssemblyInstance');
  if Assigned(aBeforeStart) then
    Result:=aBeforeStart(Self,FPreparedStartDescriptor);
  if Assigned(FBeforeStart) then
    FBeforeStart(Self,FPreparedStartDescriptor,Result);
  if not Result then
    exit;
  try
    if aRun=Nil then
      aRun:=FPreparedStartDescriptor.CallRun;
    aRun(FPreparedStartDescriptor.Exported);
    if Assigned(aAfterStart) then
      aAfterStart(Self,FPreparedStartDescriptor);
    if Assigned(FAfterStart) then
      FAfterStart(Self,FPreparedStartDescriptor)
  except
    On E : exception do
      begin
      FPreparedStartDescriptor.RunExceptionClass:=E.ClassName;
      FPreparedStartDescriptor.RunExceptionMessage:=E.Message;
      end;
    On JE : TJSError do
      begin
      FPreparedStartDescriptor.RunExceptionClass:=jsTypeOf(JE);
      FPreparedStartDescriptor.RunExceptionMessage:=JE.Message;
      end;
    On OE : TJSObject do
      begin
      FPreparedStartDescriptor.RunExceptionClass:=jsTypeOf(OE);
      FPreparedStartDescriptor.RunExceptionMessage:=TJSJSON.Stringify(OE);
      end;
  end;
  if FPreparedStartDescriptor.RunExceptionClass<>'' then
    Console.error('Running Webassembly resulted in exception. Exception class: ',FPreparedStartDescriptor.RunExceptionClass,', message:',FPreparedStartDescriptor.RunExceptionMessage);
end;

procedure TWASIHost.DoStdWrite(Sender: TObject; const aOutput: String);
begin
  WriteOutput(aOutput);
end;

function ValueToMessage(Res : JSValue) : string;

begin
  if isObject(Res) then
    begin
    Result:=TObject(Res).ClassName;
    if TObject(Res) is Exception then
      Result:=Result+': '+Exception(Res).Message
    end;
  if (JsTypeOf(Res)='object') and (TJSObject(Res).hasOwnProperty('message')) then
    Result:=String(TJSObject(Res)['message'])
  else
    Result:=TJSJSON.Stringify(Res);
end;

function TWASIHost.CreateWebAssembly(aPath: string; aImportObject: TJSObject
  ): TJSPromise;

  Function InstantiateOK(Res : JSValue) : JSValue;
  begin
    Result:=res;
  end;

  Function InstantiateFail(Res : JSValue) : JSValue;
  begin
    Result:=False;
    console.Log('Instantiating of WebAssembly from '+aPath+' failed '+ValueToMessage(Res));
    DoInstantiateFail(res);
  end;

  Function ArrayOK(res2 : jsValue) : JSValue;
  begin
    DoBeforeInstantiate;
    Result:=TJSWebAssembly.instantiate(TJSArrayBuffer(res2),aImportObject)._then(@InstantiateOK,@InstantiateFail);
  end;

  function DoFail(res : jsValue) : JSValue;
  begin
    Result:=False;
    console.Log('Loading of WebAssembly from URL "'+aPath+'" failed: '+ValueToMessage(Res));
    DoLoadFail(res);
  end;

  function fetchOK(res : jsValue) : JSValue;

  var
    Resp : TJSResponse absolute res;

  begin
    if (Resp.status div 100)<>2 then
      begin
      DoLoadFail(res);
      Raise TJSError.new('Loading of WebAssembly from URL "'+aPath+'" failed: status: '+IntToStr(Resp.status)+' '+Resp.statusText);
      end
    else
      Result:=TJSResponse(Res).arrayBuffer._then(@ArrayOK,Nil);
  end;


begin
  Result:=fetch(aPath)._then(@fetchOK,@DoFail);//.Catch(@DoFail);
end;

function TWASIHost.CreateWasiEnvironment: TPas2JSWASIEnvironment;
begin
  Result:=TPas2JSWASIEnvironment.Create;
end;

function TWASIHost.GetTable: TJSWebAssemblyTable;
begin
  Result:=TJSWebAssemblyTable.New(FTableDescriptor);
end;

function TWASIHost.GetMemory: TJSWebAssemblyMemory;
begin
  Result:=TJSWebAssemblyMemory.New(FMemoryDescriptor);
end;

constructor TWASIHost.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FMemoryDescriptor.initial:=256;
  FMemoryDescriptor.maximum:=256;
  FMemoryDescriptor.shared:=NeedSharedMemory;
  FTableDescriptor.initial:=0;
  FTableDescriptor.maximum:=0;
  FTableDescriptor.element:='anyfunc';
  FPredefinedConsoleInput:=TStringList.Create;
  FExcludeExtensions:=TStringList.Create;
  FConvertNativeExceptions:=True;
end;

destructor TWASIHost.Destroy;
begin
  FreeAndNil(FExcludeExtensions);
  FreeAndNil(FPredefinedConsoleInput);
  FreeAndNil(FEnv);
  inherited Destroy;
end;

function TWASIHost.CreateStandardExtension(aClass : TImportExtensionClass) : TImportExtension;

begin
  Result:=aClass.Create;
  if Assigned(FOnExtensionCreated) then
    FOnExtensionCreated(Self,Result);
end;

procedure TWASIHost.DeleteExtensions;
var
  I : Integer;
begin
  For I:=0 to Length(FExtensions)-1 do
    FreeAndNil(FExtensions[i]);
  SetLength(FExtensions,0);
end;

procedure TWASIHost.DoCreateStandardExtensions;
var
  lCount : Integer;
  lClass : TImportExtensionClass;
  lClasses : TImportExtensionClassArray;
begin
  DeleteExtensions;
  lClasses:=TImportExtensionRegistry.Instance.GetExtensions;
  SetLength(FExtensions,Length(lClasses));
  lCount:=0;
  for lClass in lClasses do
    if (FExcludeExtensions.IndexOf(lClass.RegisterName)=-1) and
       (FExcludeExtensions.IndexOf(lClass.ClassName)=-1) then
      begin
      FExtensions[lCount]:=CreateStandardExtension(lClass);
      inc(lCount);
      end;
end;

procedure TWASIHost.CreateStandardExtensions;
begin
  DoCreateStandardExtensions;
  if Assigned(FOnAllExtensionsCreated) then
    FOnAllExtensionsCreated(Self);
end;

function TWASIHost.FindExtension(const aExtension: string): TImportExtension;
var
  I : Integer;
begin
  I:=Length(FExtensions)-1;
  While (I>=0) and not (SameText(aExtension,FExtensions[i].ClassName) or SameText(aExtension,FExtensions[i].RegisterName)) do
    Dec(I);
  if I<0 then
    Result:=Nil
  else
    Result:=FExtensions[i];
end;

generic function TWASIHost.GetExtension<T>(const aExtension: string): T;
var
  Ext : TImportExtension;
begin
  Ext:=FindExtension(aExtension);
  if Not Assigned(Ext) then
    Raise EWasiError.CreateFmt('No extension "%s" found',[aExtension]);
  if not (Ext is T) then
    Raise EWasiError.CreateFmt('Class of extension "%s" (%s) is not a %',[aExtension,Ext.ClassName,T.ClassName]);
  Result:=T(Ext);
end;

procedure TWASIHost.WriteOutput(const aOutput: String);
begin
  if assigned(FOnConsoleWrite) then
    FOnConsoleWrite(Self,aOutput)
  else
    Writeln(aOutput);
end;


function TWASIHost.RunWebAssemblyInstance(aDescr: TWebAssemblyStartDescriptor;
  aBeforeStart: TBeforeStartCallback;
  aAfterStart: TAfterStartCallback): Boolean;

begin
  FPreparedStartDescriptor:=aDescr;
  Result:=RunWebAssemblyInstance(aBeforeStart,aAfterStart,Nil);
end;

function TWASIHost.StartWebAssembly(aPath: string; DoRun: Boolean; aBeforeStart: TBeforeStartCallback; aAfterStart: TAfterStartCallback) : TJSPromise;

Var
  WASD : TWebAssemblyStartDescriptor;

  function InitEnv(aValue: JSValue): JSValue;

  Var
    InstResult : TJSInstantiateResult absolute aValue;

  begin
    if not (jsTypeOf(aValue)='object') then
      Raise EWasiError.Create('Did not get a instantiated webassembly');
    WASD.Instance:=InstResult.Instance;
    WASD.Module:=InstResult.Module;
    WASD.Exported:=TWASIExports(TJSObject(WASD.Instance.exports_));
    WASD.CallRun:=Procedure(aExports : TWASIExports)
      begin
      if FRunEntryFunction='' then
        if Assigned(aExports['_initialize']) then
          aExports.initialize
        else
          aExports.Start
      else
        TProcedure(aExports[RunEntryFunction])();
      end;
    PrepareWebAssemblyInstance(WASD);
    if DoRun then
      RunWebAssemblyInstance(aBeforeStart,aAfterStart,Nil);
    Result:=TJSPromise.resolve(WASD);
  end;

  function DoFail(aValue: JSValue): JSValue;

  begin
    Result:=True;
    Console.Log('Failed to create webassembly. Reason:');
    Console.Debug(aValue);
    if isObject(aValue) then
      Raise TJSError(aValue);
  end;

begin
  FReadLineCount:=0;
  // Clear current descriptor.
  FPreparedStartDescriptor:=Default(TWebAssemblyStartDescriptor);
  WASD:=InitStartDescriptor(GetMemory,GetTable,Nil);
  Result:=CreateWebAssembly(aPath,WASD.Imports)._then(@initEnv,@DoFail);
end;

procedure TWASIHost.RunPreparedDescriptor;
begin
  RunWebAssemblyInstance(Nil,Nil,Nil)
end;

function TWASIHost.InitStartDescriptor(aMemory: TJSWebAssemblyMemory;
  aTable: TJSWebAssemblyTable; aImportObj: TJSObject
  ): TWebAssemblyStartDescriptor;

begin
  Result.Memory:=aMemory;
  Result.Table:=aTable;
  if Not assigned(aImportObj) then
    aImportObj:=TJSObject.New;
  aImportObj['env']:=new([
    'memory', Result.Memory,
    'tbl', Result.Table
  ]);
  WasiEnvironment.AddImports(aImportObj);
  Result.Imports:=aImportObj;
end;

{ EWasmNativeException }

constructor EWasmNativeException.create(const aNativeClass, aNativeMessage: string);
begin
  Inherited createFmt('Webassembly code raised an exception %s : %s',[aNativeClass,aNativeMessage]);
  FNativeClass:=aNativeClass;
  FNativeMessage:=aNativeMessage;
end;

{ EWasiFSError }

constructor EWasiFSError.Create(const aErrorCode: Integer; aMsg: String);
begin
  FErrorcode:=aErrorCode;
  Inherited Create(aMsg);
end;

constructor EWasiFSError.CreateFmt(const aErrorCode: Integer; aFmt: String;
  aArgs: array of const);
begin
  FErrorcode:=aErrorCode;
  Inherited CreateFmt(aFmt,aArgs);
end;

procedure TImportExtension.DoLog(const Msg: String);
begin
  if LogApi then
    Writeln(ClassName+': '+Msg);
end;

procedure TImportExtension.DoLog(const Fmt: String; const args: array of const);
begin
  if LogApi then
    DoLog(Format(Fmt,Args));
end;

procedure TImportExtension.DoError(const Msg: String);
begin
  Console.Error(ClassName+': '+Msg);
end;

procedure TImportExtension.DoError(const Fmt: String; const Args: array of const);
begin
  Console.Error(ClassName+': '+Format(Fmt,Args));
end;

procedure TImportExtension.SetInstanceExports(const AValue: TWASIExports);
begin
  if FInstanceExports=AValue then Exit;
  FInstanceExports:=AValue;
end;

function TImportExtension.getModuleMemoryDataView : TJSDataView;  

begin
  Result:=FEnv.getModuleMemoryDataView;
end;

constructor TImportExtension.Create(aEnv: TPas2JSWASIEnvironment);

begin
  FEnv:=aEnv;
  if Assigned(Fenv) then
    Fenv.AddExtension(Self);
end;

destructor TImportExtension.Destroy;
begin
  if Assigned(Fenv) then
    Fenv.RemoveExtension(Self);
  inherited Destroy;
end;

class procedure TImportExtension.register;
begin
  TImportExtensionRegistry.Instance.RegisterExtension(Self);
end;

class function TImportExtension.RegisterName: string;
begin
  Result:=ClassName;
end;

{ TImportExtensionRegistry }

procedure TImportExtensionRegistry.Grow;
begin
  SetLength(FExtensions,Length(FExtensions)+1);
end;

class constructor TImportExtensionRegistry.init;
begin
  _instance:=TImportExtensionRegistry.Create;
end;


constructor TImportExtensionRegistry.create;
begin
  FExtensionCount:=0;
  Grow;
end;

destructor TImportExtensionRegistry.destroy;
begin
  inherited destroy;
end;

function TImportExtensionRegistry.IndexOf(const aExtension : String) : Integer;
begin
  Result:=FExtensionCount-1;
  While (Result>=0) and not SameText(FExtensions[Result].RegisterName,aExtension) do
    Dec(Result);
end;

function TImportExtensionRegistry.GetExtensions: TImportExtensionClassArray;
begin
  Result:=Copy(FExtensions,0,FExtensionCount);
end;

function TImportExtensionRegistry.Find(const aExtension: String): TImportExtensionClass;

var
  Idx: Integer;

begin
  Result:=Nil;
  Idx:=IndexOf(aExtension);
  if (Idx<>-1) then
    Result:=FExtensions[Idx];
end;

procedure TImportExtensionRegistry.RegisterExtension(aExtension: TImportExtensionClass);
var
  Idx : Integer;
begin
  Idx:=IndexOf(aExtension.RegisterName);
  if Idx<>-1 then
    FExtensions[Idx]:=aExtension
  else
    begin
    if FExtensionCount=Length(FExtensions) then
      grow;
    FExtensions[FExtensionCount]:=aExtension;
    Inc(FExtensionCount);
    end;
end;

procedure TImportExtensionRegistry.UnRegisterExtension(aExtension: TImportExtensionClass);
begin

end;

procedure TPas2JSWASIEnvironment.AddImports(aObject: TJSObject);

Var
  Ext : TImportExtension;
  I : Integer;
  O : TJSObject;
  
begin
  aObject[WASIImportName]:=ImportObject;
  if Assigned(FImportExtensions) then
    For I:=0 to FImportExtensions.Count-1 do
      begin
      Ext:=TImportExtension(FImportExtensions[i]);
      O:=TJSObject.New;
      Ext.FillImportObject(O);
      aObject[Ext.ImportName]:=O;
      end;
end;

procedure TPas2JSWASIEnvironment.SetExports(aExports: TWasiExports);
Var
  Ext : TImportExtension;
  I : Integer;
begin
  if Assigned(FImportExtensions) then
    For I:=0 to FImportExtensions.Count-1 do
      begin
      Ext:=TImportExtension(FImportExtensions[i]);
      Ext.InstanceExports:=aExports;
      end;
end;

procedure TPas2JSWASIEnvironment.AddExtension(aExtension : TImportExtension); 
begin
  if Not Assigned(FImportExtensions) then
    FImportExtensions:=TFPList.Create;
  FImportExtensions.Add(aExtension);
end;

procedure TPas2JSWASIEnvironment.RemoveExtension(aExtension: TImportExtension);

begin
 if Assigned(FImportExtensions) then
   FImportExtensions.Remove(aExtension);
end;


function TPas2JSWASIEnvironment.getModuleMemoryDataView: TJSDataView;
begin
  Result:=TJSDataView.New(Memory.buffer);
end;

function TPas2JSWASIEnvironment.fd_prestat_get(fd: NativeInt;
  bufPtr: TWasmMemoryLocation): NativeInt;

var
  S : String;

begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    Dolog('TPas2JSWASIEnvironment.fd_prestat_get(%d,[%d])',[fd,BufPtr]);
  {$endif}
  if Assigned(FS) then
    begin
    S:=FS.GetPrestat(fd);
    if S<>'' then
      begin
      // Alignment is 4
      SetMemInfoInt32(BufPtr,0);
      SetMemInfoInt32(BufPtr+4,Length(S));
      Result:=WASI_ESUCCESS;
      end
    else
      Result:=WASI_EBADF;
    end
  else
    begin
    if (fd=3) then
      begin
      // Alignment is 4
      SetMemInfoInt32(BufPtr,0);
      SetMemInfoInt32(BufPtr+4,1);
      Result:=WASI_ESUCCESS;
      end;
    Result:=WASI_EBADF;
    end;
end;

function TPas2JSWASIEnvironment.fd_prestat_dir_name(fd: NativeInt;
  pathPtr: TWasmMemoryLocation; pathLen: NativeInt): NativeInt;
var
  S : String;
  Len : Integer;

begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.fd_prestat_dir_name(%d,[%d],%d)',[fd,pathPtr,PathLen]);
  {$ENDIF}
  if Assigned(FS) then
    begin
    S:=FS.GetPrestat(fd);
    if (S<>'') then
      begin
      Len:=Length(s);
      if Len>PathLen then
        Len:=PathLen;
      SetUTF8StringInMem(PathPtr,Len,S);
      Result:=WASI_ESUCCESS;
      end
    else
      Result:=WASI_EBADF;
    end
  else
    begin
    if (fd=3) then
      begin
      SetUTF8StringInMem(PathPtr,1,'/');
      Result:=WASI_ESUCCESS;
      end
    else
      Result:=WASI_EBADF;
    end;
end;

function TPas2JSWASIEnvironment.environ_sizes_get(environCount,
  environBufSize: TWasmMemoryLocation): NativeInt;

Var
  View : TJSDataView;
  Size : integer;

begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.environ_sizes_get([%x],[%x])',[environCount,environBufSize]);
  {$ENDIF}
  view:=getModuleMemoryDataView();
  view.setUint32(environCount, Environment.Count, IsLittleEndian);
  Size:=0;
  // the LF will be counted for null terminators
  if Environment.Count>0 then
    Size:=Length(Environment.Text)+1;
  view.setUint32(environBufSize, Size, IsLittleEndian);
  Result:= WASI_ESUCCESS;
end;

function TPas2JSWASIEnvironment.environ_get(environ, environBuf: TWasmMemoryLocation): NativeInt;

var
  S : String;
  I : Integer;
  PtrV,Ptr : Integer;
begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.environ_get([%x],[%x])',[environ,environBuf]);
  {$ENDIF}
  Ptr:=EnvironBuf;
  PtrV:=environ;
  for I:=0 to Environment.Count-1 do
    begin
    S:=Environment[I];
    PtrV:=SetMemInfoUInt32(PtrV,Ptr);
    Ptr:=Ptr+SetUTF8StringInMem(Ptr,Length(S),S);
    Ptr:=SetMemInfoUInt8(Ptr,0);
    end;
  Result:=WASI_ESUCCESS;
end;

function TPas2JSWASIEnvironment.args_sizes_get(argc, argvBufSize: TWasmMemoryLocation): NativeInt;

Var
  View : TJSDataView;
  Size : Integer;
begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.args_sizes_get([%x],[%x])',[argc,argvbufsize]);
  {$ENDIF}
  view:=getModuleMemoryDataView();
  view.setUint32(argc, Arguments.Count, IsLittleEndian);
  // the LF will be counted for null terminators
  Size:=0;
  if Arguments.Count>0 then
    Size:=Length(Arguments.Text)+1;
  view.setUint32(argvBufSize, Size , IsLittleEndian);
  Result:=WASI_ESUCCESS;
end;

function TPas2JSWASIEnvironment.args_get(argv, argvBuf: TWasmMemoryLocation): NativeInt;

var
  Ptr : TWasmMemoryLocation;
  PtrV : TWasmMemoryLocation;
  S : String;
  i : Integer;

begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.args_get([%x],[%x])',[argv, argvBuf]);
  {$ENDIF}
  Ptr:=ArgvBuf;
  PtrV:=ArgV;
  for I:=0 to Arguments.Count-1 do
    begin
    S:=Arguments[I];
    PtrV:=SetMemInfoUInt32(PtrV,Ptr);
    Ptr:=Ptr+SetUTF8StringInMem(Ptr,Length(S),S);
    Ptr:=SetMemInfoUInt8(Ptr,0);
    end;
  Result:=WASI_ESUCCESS;
end;

class procedure TPas2JSWASIEnvironment.setBigUint64(View: TJSDataView;
  byteOffset, value: NativeInt; littleEndian: Boolean);

Var
  LowWord,HighWord : Integer;

begin
  lowWord:=value;
  highWord:=value shr 32;
  if LittleEndian then
    begin
    view.setUint32(ByteOffset+0, lowWord, littleEndian);
    view.setUint32(ByteOffset+4, highWord, littleEndian);
    end
  else
    begin
    view.setUint32(ByteOffset+4, lowWord, littleEndian);
    view.setUint32(ByteOffset+0, highWord, littleEndian);
    end;
end;

class function TPas2JSWASIEnvironment.GetBigUint64(View: TJSDataView;
  byteOffset: NativeInt; littleEndian: Boolean) : NativeUInt ;

Var
  LowWord,HighWord : Integer;

begin
  if LittleEndian then
    begin
    lowWord:=view.getUint32(ByteOffset+0, littleEndian);
    highWord:=view.getUint32(ByteOffset+4, littleEndian);
    end
  else
    begin
    lowWord:=view.getUint32(ByteOffset+4, littleEndian);
    highWord:=view.getUint32(ByteOffset+0, littleEndian);
    end;
  Result:=LowWord+(HighWord shl 32);
end;

class function TPas2JSWASIEnvironment.GetBigInt64(View: TJSDataView; byteOffset : NativeInt; littleEndian: Boolean) : NativeInt ;

Var
  LowWord,HighWord : Integer;

begin
  if LittleEndian then
    begin
    lowWord:=view.getUint32(ByteOffset+0, littleEndian);
    highWord:=view.getUint32(ByteOffset+4, littleEndian);
    end
  else
    begin
    lowWord:=view.getUint32(ByteOffset+4, littleEndian);
    highWord:=view.getUint32(ByteOffset+0, littleEndian);
    end;
  Result:=LowWord+(HighWord shl 32);
end;


class procedure TPas2JSWASIEnvironment.setBigInt64(View: TJSDataView;
  byteOffset, value: NativeInt; littleEndian: Boolean);

Var
  LowWord,HighWord : Integer;

begin
  lowWord:=value;
  highWord:=value shr 32;
  if LittleEndian then
    begin
    view.setint32(ByteOffset+0, lowWord, littleEndian);
    view.setint32(ByteOffset+4, highWord, littleEndian);
    end
  else
    begin
    view.setint32(ByteOffset+4, lowWord, littleEndian);
    view.setint32(ByteOffset+0, highWord, littleEndian);
    end;
end;


procedure TPas2JSWASIEnvironment.SetInstance(AValue: TJSWebAssemblyInstance);
begin
  if Finstance=AValue then Exit;
  Finstance:=AValue;
  FModuleInstanceExports:=Finstance.exports_;
  if Not Assigned(FMemory) and Assigned(FModuleInstanceExports.Memory) then
    FMemory:=FModuleInstanceExports.Memory;
end;

procedure TPas2JSWASIEnvironment.SetLogAPI(AValue: Boolean);
begin
  {$IFNDEF NO_WASI_DEBUG}
  if FLogAPI=AValue then Exit;
  FLogAPI:=AValue;
  {$ELSE}
  FLogAPI:=False;
  {$ENDIF}
end;

class function TPas2JSWASIEnvironment.ErrorToCode(E: Exception): NativeInt;

var
  EW : EWasiFSError;

begin
  if E is EWasiFSError then
    Result:=EW.ErrorCode
  else
    Result:=0;
  if (Result=0) then
    Result:=WASI_ENOSYS;
end;

procedure TPas2JSWASIEnvironment.DoLog(Msg: String);
begin
  {$IFNDEF NO_WASI_DEBUG}
  Writeln(Msg);
  {$ENDIF}
end;

procedure TPas2JSWASIEnvironment.DoLog(Fmt: String; Args: array of const);
begin
  {$IFNDEF NO_WASI_DEBUG}
  Writeln(Format(Fmt,Args));
  {$ENDIF}
end;

function TPas2JSWASIEnvironment.GetTime(aClockID: NativeInt): NativeInt;
begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.GetTime(%d)',[aClockID]);
  {$ENDIF}
  Result:=-1;
  Case aClockId of
  WASI_CLOCK_MONOTONIC:
    Result:=TJSDate.Now;
  WASI_CLOCK_REALTIME:
    Result:=TJSDate.Now;
  WASI_CLOCK_PROCESS_CPUTIME_ID,
  WASI_CLOCK_THREAD_CPUTIME_ID:
    Result:=TJSDate.Now;
  end;
  Result:=Result*1000000
end;


function TPas2JSWASIEnvironment.fd_fdstat_get(fd: NativeInt;
  bufPtr: TWasmMemoryLocation): NativeInt;

Var
  View : TJSDataView;

begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.fd_fdstat_get(%d,%d)',[fd,BufPtr]);
  {$ENDIF}
  view:=getModuleMemoryDataView();
  view.setUint8(bufPtr, fd);
  view.setUint16(bufPtr + 2, 0, IsLittleEndian);
  view.setUint16(bufPtr + 4, 0, IsLittleEndian);
  setBigUint64(View, bufPtr + 8, 0, IsLittleEndian);
  setBigUint64(View, bufPtr + 8 + 8, 0, IsLittleEndian);
  Result:= WASI_ESUCCESS;
end;

function TPas2JSWASIEnvironment.fd_fdstat_set_flags(fd, flags: NativeInt): NativeInt;
begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.fd_fdstat_set_flags(%d,%d)',[fd,flags]);
  {$ENDIF}
  console.log('Unimplemented: TPas2JSWASIEnvironment.fd_fdstat_set_flags');
  Result:= WASI_ENOSYS;
end;

function TPas2JSWASIEnvironment.fd_fdstat_set_rights(fd, fsRightsBase, fsRightsInheriting: NativeInt): NativeInt;
begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.fd_fdstat_set_rights(%d,%d,%d)',[fd,fsRightsBase,fsRightsInheriting]);
  {$ENDIF}
  console.log('Unimplemented: TPas2JSWASIEnvironment.fd_fdstat_set_rights');
  Result:= WASI_ENOSYS;
end;

function TPas2JSWASIEnvironment.getiovs(view: TJSDataView; iovs,
  iovsLen: NativeInt): TMemBufferArray;

Var
  I : integer;
  ArrayBuf : TJSUint8Array;
  Ptr,Buf,BufLen : Integer;

begin
  SetLength(Result,iovsLen);
  Ptr:=iovs;
  For I:=0 to iovsLen-1 do
    begin
    buf:=view.getUint32(ptr, IsLittleEndian);
    bufLen:=view.getUint32(ptr + 4, IsLittleEndian);
    ArrayBuf:=TJSUint8Array.New(Memory.buffer, buf, bufLen);
    Result[I]:=ArrayBuf;
    Inc(ptr,8);
    end;
end;

function TPas2JSWASIEnvironment.GetTotalIOVsLen(iovs: TMemBufferArray): Integer;

var
  BufLen : integer;

  function calclen(element : JSValue; index: NativeInt; anArray : TJSArray) : Boolean;

  var
    iov: TJSUint8Array absolute Element;

  begin
    buflen:=buflen+iov.byteLength;
    Result:=true;
  end;

begin
  TJSArray(iovs).forEach(@calclen);
  Result:=buflen;
end;

function TPas2JSWASIEnvironment.GetMemory: TJSWebassemblyMemory;
begin
{  if Assigned(FMemory) then
    Result:=FMemory
  else }
    Result:= FModuleInstanceExports.Memory;
end;

procedure TPas2JSWASIEnvironment.SetArguments(AValue: TStrings);
begin
  if FArguments=AValue then Exit;
  FArguments.Assign(AValue);
end;

procedure TPas2JSWASIEnvironment.SetEnvironment(AValue: TStrings);
begin
  if FEnvironment=AValue then Exit;
  FEnvironment.Assign(AValue);
end;

function TPas2JSWASIEnvironment.GetIOVsAsBytes(iovs, iovsLen : NativeInt) : TJSUInt8array;

var
  view : TJSDataView;
  buflen,Written : Integer;
  bufferBytes : TJSArrayBuffer;
  Buffers : TMembufferArray;
  Buf : TJSUint8Array;

  function writev(element : JSValue; index: NativeInt; anArray : TJSArray) : Boolean;

  var
    iov: TJSUint8Array absolute Element;

  begin
    buf._set(iov,written);
    inc(written,iov.byteLength);
    Result:=true;
  end;

begin
  view:=getModuleMemoryDataView();
  written:=0;
  buflen:=0;
  buffers:=getiovs(view, iovs, iovsLen);
  buflen:=GetTotalIOVsLen(Buffers);
  BufferBytes:=TJSArrayBuffer.New(buflen);
  Buf:=TJSUint8Array.New(BufferBytes);
  TJSArray(buffers).forEach(@writev);
  Result:=Buf;
end;

function TPas2JSWASIEnvironment.fd_write(fd, iovs, iovsLen, nwritten: NativeInt): NativeInt;

var
  view : TJSDataView;
  Buf : TJSUint8Array;
  written : longint;

begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.fd_write(%d,[%d],%d,[%d])',[fd,iovs,iovslen,nwritten]);
  {$ENDIF}
  view:=getModuleMemoryDataView();
  if (fd = WASI_STDOUT_FILENO) or (fd = WASI_STDERR_FILENO) then
    begin
    Buf:=GetIOVsAsBytes(iovs,iovsLen);
    written:=Buf.byteLength;
    DoConsoleWrite((fd=WASI_STDERR_FILENO),Buf);
    view.setUint32(nwritten, written, IsLittleEndian);
    Result:=WASI_ESUCCESS;
    end
  else if not Assigned(FS) then
    Result:=WASI_ENOSYS
  else
    begin
    Buf:=GetIOVsAsBytes(iovs,iovsLen);
    Result:=FS.Write(fd,Buf,-1,Written);
    if Result=WASI_ESUCCESS then
      view.setUint32(nwritten, written, IsLittleEndian);
    end;

end;

function TPas2JSWASIEnvironment.fd_pwrite(fd, iovs, iovsLen, offset,  nwritten: NativeInt): NativeInt;
var
  view : TJSDataView;
  Buf : TJSUint8Array;
  written : longint;

begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.fd_prite(%d,[%d],%d,%d,[%d])',[fd,iovs,iovslen,offset,nwritten]);
  {$ENDIF}
  if (fd = WASI_STDOUT_FILENO) or (fd = WASI_STDERR_FILENO) then
    begin
    // Normally this cannot happen
    Buf:=GetIOVsAsBytes(iovs,iovsLen);
    written:=Buf.byteLength;
    DoConsoleWrite((fd=WASI_STDERR_FILENO),Buf);
    view.setUint32(nwritten, written, IsLittleEndian);
    Result:=WASI_ESUCCESS;
    end
  else if not Assigned(FS) then
    Result:=WASI_ENOSYS
  else
    begin
    Buf:=GetIOVsAsBytes(iovs,iovsLen);
    Result:=FS.Write(fd,Buf,-1,Written);
    if Result=WASI_ESUCCESS then
      view.setUint32(nwritten, written, IsLittleEndian);
    end;
  Result:=WASI_ENOSYS;
end;

procedure TPas2JSWASIEnvironment.DoConsoleWrite(IsStdErr: Boolean; aBytes: TJSUint8Array);

  Function TryConvert : string;

  begin
    Result:='';
    asm
      Result=String.fromCharCode.apply(null, aBytes);
    end;
  end;

Var
  S : String;
  Evt : TWASIWriteEvent;

begin
  try
    S:=GetUTF8StringFromArray(aBytes);
  except
    // Depending on buffer size, FPC can do a flush mid-codepoint.
    // The resulting bytes will not form a complete codepoint at the end.
    // So we try to convert what is possible...
    S:=TryConvert
  end;
  if IsStdErr then
    evt:=FOnStdErrorWrite
  else
    evt:=FOnStdOutputWrite;
  if Assigned(evt) then
    Evt(Self,S)
end;

function TPas2JSWASIEnvironment.clock_res_get (clockId, resolution : NativeInt) : NativeInt;
Var
  view: TJSDataView;

begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.clock_res_get(%d,%d)',[clockid,resolution]);
  {$ENDIF}
  view:=getModuleMemoryDataView;
  setBigUint64(view,resolution, 0,IsLittleEndian);
  Result:=WASI_ESUCCESS;
end;

function TPas2JSWASIEnvironment.clock_time_get(clockId, precision: NativeInt; time: TWasmMemoryLocation) : NativeInt;

Var
  view: TJSDataView;
  n : NativeInt;
begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.clock_time_get(%d,%d,[%x])',[clockid,precision,time]);
  {$ENDIF}
  view:=getModuleMemoryDataView;
  n:=GetTime(clockId);
  if N=-1 then
    Result:=WASI_EINVAL
  else
    begin
    setBigUint64(view,time,n,IsLittleEndian);
    Result:=WASI_ESUCCESS;
    end;
end;

function TPas2JSWASIEnvironment.GetImportObject: TJSObject;

begin
  // We need this trick to be able to access self or this.
  // The webassembly callbacks get called without a this.
  if Not Assigned(FImportObject) then
    begin
    FImportObject:=TJSObject.New;
    GetImports(FImportObject);
    end;
  Result:=FImportObject;
end;


function TPas2JSWASIEnvironment.poll_oneoff(sin, sout, nsubscriptions,
  nevents: NativeInt): NativeInt;

const
  TagOffset = 8;
  TimeoutOffset = 24;
  PrecisionOffset = 32;

var
  Tag : NativeInt;
  {$IFNDEF WEB_WORKER}
  Precision,TimeOut,msTimeOut : TJSBigInt;
  {$endif}
  msTimeout32 : Integer;
  arr : TJSint32array;
  mem : TJSDataView;

begin
  {$IFNDEF WEB_WORKER}
  // Only used for sleep at the moment. We check the tag
  Tag:=GetMemInfoInt8(sin+tagOffset);
  if (Tag=WASI_EVENTTYPE_CLOCK) then
    begin
    mem:=getModuleMemoryDataView;
    TimeOut:= Mem.getBigInt64(sin+TimeOutOffset,IsLittleEndian);
    Precision:=Mem.GetBigInt64(sin+PrecisionOffset,IsLittleEndian);
    asm
    msTimeOut = TimeOut / Precision;
    end;
    arr:=TJSint32array.new(FMemory.buffer);
    TJSAtomics.Store(arr,256,0);
    msTimeout32:=StrToInt(msTimeOut.toString);
    // Writeln('Timeout is: ',msTImeout32);
    TJSAtomics.wait(Arr,256,0,msTimeout32);
    // Writeln('Done timeout');
    end;
  Result:= WASI_ESUCCESS;
  {$ELSE}
  Result:= WASI_ENOSYS;
  {$ENDIF}
end;

function TPas2JSWASIEnvironment.proc_exit(rval: NativeInt): NativeInt;
begin
  FExitCode:=rval;
  Result:=WASI_ESUCCESS;
end;

function TPas2JSWASIEnvironment.proc_raise(sig: NativeInt): NativeInt;
begin
  console.log('Unimplemented: TPas2JSWASIEnvironment.proc_raise');
  Result:=WASI_ENOSYS;
end;

function TPas2JSWASIEnvironment.sched_yield: NativeInt;
begin
  Result:=WASI_ESUCCESS;
end;

function TPas2JSWASIEnvironment.sock_recv: NativeInt;
begin
  console.log('Unimplemented: TPas2JSWASIEnvironment.sock_recv');
  Result:=WASI_ENOSYS;
end;

function TPas2JSWASIEnvironment.sock_send: NativeInt;
begin
  console.log('Unimplemented: TPas2JSWASIEnvironment.sock_recv');
  Result:=WASI_ENOSYS;
end;

function TPas2JSWASIEnvironment.sock_shutdown: NativeInt;
begin
  console.log('Unimplemented: TPas2JSWASIEnvironment.sock_shutdown');
  Result:=WASI_ENOSYS;
end;


procedure TPas2JSWASIEnvironment.GetImports(aImports: TJSObject);

begin
  aImports['args_get']:=@args_get;
  aImports['args_sizes_get']:=@args_sizes_get;
  aImports['clock_res_get']:=@clock_res_get;
  aImports['clock_time_get']:=@clock_time_get;
  aImports['environ_get']:=@environ_get;
  aImports['environ_sizes_get']:=@environ_sizes_get;
  aImports['fd_advise']:=@fd_advise;
  aImports['fd_allocate']:=@fd_allocate;
  aImports['fd_close']:=@fd_close;
  aImports['fd_datasync']:=@fd_datasync;
  aImports['fd_fdstat_get']:=@fd_fdstat_get;
  aImports['fd_fdstat_set_flags']:=@fd_fdstat_set_flags;
  aImports['fd_fdstat_set_rights']:=@fd_fdstat_set_rights;
  aImports['fd_filestat_get']:=@fd_filestat_get;
  aImports['fd_filestat_set_size']:=@fd_filestat_set_size;
  aImports['fd_filestat_set_times']:=@fd_filestat_set_times;
  aImports['fd_pread']:=@fd_pread;
  aImports['fd_prestat_dir_name']:=@fd_prestat_dir_name;
  aImports['fd_prestat_get']:=@fd_prestat_get;
  aImports['fd_pwrite']:=@fd_pwrite;
  aImports['fd_read']:=@fd_read;
  aImports['fd_readdir']:=@fd_readdir;
  aImports['fd_renumber']:=@fd_renumber;
  aImports['fd_seek']:=@fd_seek;
  aImports['fd_sync']:=@fd_sync;
  aImports['fd_tell']:=@fd_tell;
  aImports['fd_write']:=@fd_write;
  aImports['path_create_directory']:=@path_create_directory;
  aImports['path_filestat_get']:=@path_filestat_get;
  aImports['path_filestat_set_times']:=@path_filestat_set_times;
  aImports['path_link']:=@path_link;
  aImports['path_open']:=@path_open;
  aImports['path_readlink']:=@path_readlink;
  aImports['path_remove_directory']:=@path_remove_directory;
  aImports['path_rename']:=@path_rename;
  aImports['path_symlink']:=@path_symlink;
  aImports['path_unlink_file']:=@path_unlink_file;
  aImports['poll_oneoff']:=@poll_oneoff;
  aImports['proc_exit']:=@proc_exit;
  aImports['proc_raise']:=@proc_raise;
  aImports['random_get']:=@random_get;
  aImports['sched_yield']:=@sched_yield;
  aImports['sock_recv']:=@sock_recv;
  aImports['sock_send']:=@sock_send;
  aImports['sock_shutdown']:=@sock_shutdown;
end;


function TPas2JSWASIEnvironment.random_get(bufPtr, bufLen: NativeInt ): NativeInt;
var
  arr: TJSUint8Array;
  I : integer;
  View : TJSDataView;
begin
  arr:=TJSUint8Array.new(BufLen);

  crypto.getRandomValues(arr);

  view:=getModuleMemoryDataView;
  For I:=0 to arr.length-1 do
    view.setInt8(bufptr+i,arr[i]);
  Result:=WASI_ESUCCESS;
end;


procedure TPas2JSWASIEnvironment.SetMemory(aMemory: TJSWebAssemblyMemory);
begin
  FMemory:=aMemory;
end;

class constructor TPas2JSWASIEnvironment.init;
Var
  Opts : TJSTextDecoderOptions;

begin
  Opts:=TJSTextDecoderOptions.New;
  Opts.ignoreBOM:=true;
  Opts.fatal:=True;
  UTF8TextDecoder:=TJSTextDecoder.new ('utf-8',Opts);
  UTF8TextEncoder:=TJSTextEncoder.new ();
end;

function TPas2JSWASIEnvironment.fd_advise(fd, offset, len, advice: NativeInt
  ): NativeInt;
begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.fd_advise(%d,%d,%d,%d)',[fd,offset,len,advice]);
  {$ENDIF}
  console.log('Unimplemented: TPas2JSWASIEnvironment.fd_advise');
  Result:= WASI_ENOSYS;
end;

function TPas2JSWASIEnvironment.fd_allocate(fd, offset, len: NativeInt
  ): NativeInt;
begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.fd_allocate(%d,%d,%d)',[fd,offset,len]);
  {$ENDIF}
  console.log('Unimplemented: TPas2JSWASIEnvironment.fd_allocate');
  Result:= WASI_ENOSYS;
end;

function TPas2JSWASIEnvironment.fd_close(fd: NativeInt): NativeInt;
begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.fd_close(%d)',[fd]);
  {$ENDIF}
  if not Assigned(FS) then
    Result:=WASI_ENOSYS
  else
    try
      Result:=FS.Close(fd);
    except
      On E : Exception do
        Result:=ErrorToCode(E);
    end;
end;

function TPas2JSWASIEnvironment.fd_datasync(fd: NativeInt): NativeInt;
begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.fd_datasync(%d)',[fd]);
  {$ENDIF}
  if not Assigned(FS) then
    Result:=WASI_ENOSYS
  else
    try
      Result:=FS.dataSync(fd);
    except
      On E : Exception do
        Result:=ErrorToCode(E);
    end;
end;

function TPas2JSWASIEnvironment.fd_seek(fd, offset, whence: NativeInt; newOffsetPtr : TWasmMemoryLocation): NativeInt;

var
  lWhence : TSeekWhence;
  NewPos : integer;

begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.fd_seek(%d,%d,%d,[%x])',[fd,offset,whence,newOffsetPtr]);
  {$ENDIF}
  if not Assigned(FS) then
    Result:=WASI_ENOSYS
  else
    try
      lWhence:=swBeginning;
      Case Whence of
        __WASI_WHENCE_CUR : lWhence:=swCurrent;
        __WASI_WHENCE_END : lWhence:=swEnd;
        __WASI_WHENCE_SET : lWhence:=swBeginning;
      else
        Result:=WASI_EINVAL;
      end;
      Result:=FS.Seek(fd,Offset,lWhence,NewPos);
      if Result=WASI_ESUCCESS then
        SetMemInfoInt64(newOffsetPtr,NewPos);
    except
      On E : Exception do
        Result:=ErrorToCode(E);
    end;
end;

function TPas2JSWASIEnvironment.fd_sync(fd: NativeInt): NativeInt;
begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.fd_sync(%d)',[fd]);
  {$ENDIF}
  if not Assigned(FS) then
    Result:=WASI_ENOSYS
  else
    try
      Result:=FS.Sync(fd);
    except
      On E : Exception do
        Result:=ErrorToCode(E);
    end;
end;

function TPas2JSWASIEnvironment.fd_pread(fd: NativeInt; iovs : TWasmMemoryLocation; iovsLen, offset: NativeInt; nread : TWasmMemoryLocation) : NativeInt;

begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.fd_pread(%d,[%x],%d,%d,[%x])',[fd,iovs,iovslen,offset,nread]);
  {$ENDIF}
  Result:=DoRead(fd,iovs,iovslen,offset,nread);
end;


function toUTF8Array(str : string) : TJSUint8Array;

Var
  Len,I,P : integer;
  charCode : NativeInt;

  procedure push (abyte : Byte);

  begin
    Result[P]:=aByte;
    inc(P);
  end;

begin
  Result:=TJSUint8Array.new(Length(str)*4);
  P:=0;
  Len:=Length(str);
  I:=1;
  While i<=Len do
    begin
    charcode:=Ord(Str[i]);
    if (charcode < $80) then
      push(charcode)
    else if (charcode < $800) then
      begin
      push($c0 or (charcode shr 6));
      push($80 or (charcode and $3f));
      end
    else if (charcode < $d800) or (charcode >= $e000) then
      begin
      push($e0 or (charcode shr 12));
      push($80 or ((charcode shr 6) and $3f));
      push($80 or (charcode and $3f));
      end
    else
      begin
      Inc(I);
      // UTF-16 encodes 0x10000-0x10FFFF by
      // subtracting 0x10000 and splitting the
      // 20 bits of 0x0-0xFFFFF into two halves
      charcode := $10000 + (((charcode and $3ff) shl 10) or (Ord(Str[i]) and $3ff));
      push($f0 or (charcode shr 18));
      push($80 or ((charcode shr 12) and $3f));
      push($80 or ((charcode shr 6) and $3f));
      push($80 or (charcode and $3f));
      end;
    inc(I);
    end;
  Result:=TJSUint8Array(Result.slice(0,p));
end;

function TPas2JSWASIEnvironment.DoRead(fd: NativeInt; iovs: TWasmMemoryLocation; iovsLen, atPos: NativeInt; nread: TWasmMemoryLocation): NativeInt;

var
  view : TJSDataView;
  avail,bytesRead : Integer;
  ReadBuffer : TJSUint8Array;
  WasiBuffers : TMembufferArray;
  TotalBufSize : Integer;

  function readv(element : JSValue; index: NativeInt; anArray : TJSArray) : Boolean;

  var
    b : NativeInt;
    iov: TJSUint8Array absolute Element;

  begin
    b:=0;
    While (B<iov.byteLength) and (BytesRead<avail) do
      begin
      iov[b]:=ReadBuffer[BytesRead];
      inc(b);
      inc(BytesRead);
      end;
    Result:=true;
  end;

begin
  TotalBufSize:=0;
  bytesRead:=0;
  view:=getModuleMemoryDataView();
  Wasibuffers:=getiovs(view, iovs, iovsLen);
  TotalBufSize:=GetTotalIOVsLen(Wasibuffers);
  if (fd = WASI_STDIN_FILENO) then
    begin
    ReadBuffer:=GetConsoleInputBuffer(TotalBufSize);
    avail:=ReadBuffer.byteLength;
    end
  else if Assigned(FS) then
    try
      ReadBuffer:=TJSUint8Array.new(TJSArrayBuffer.New(TotalBufSize));
      Result:=FS.Read(FD,ReadBuffer,atPos,Avail);
      if Result<>WASI_ESUCCESS then exit;
    except
      On E : Exception do
        Result:=ErrorToCode(E);
    end
  else
    begin
    ReadBuffer:=GetFileBuffer(FD,TotalBufSize);
    avail:=ReadBuffer.byteLength;
    end;
  if (avail>0) then
    TJSArray(Wasibuffers).forEach(@readv);
  view.setUint32(nread, bytesRead, IsLittleEndian);
  Result:=WASI_ESUCCESS;
end;

function TPas2JSWASIEnvironment.fd_read(fd: NativeInt;
  iovs: TWasmMemoryLocation; iovsLen: NativeInt; nread: TWasmMemoryLocation
  ): NativeInt;


begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.fd_read(%d,[%x],%d,[%x])',[fd,iovs,iovslen,nread]);
  {$ENDIF}
  Result:=DoRead(fd,iovs,iovslen,-1,nread);
end;

function TPas2JSWASIEnvironment.GetFileBuffer(FD, aMaxLen: NativeInt
  ): TJSUint8Array;

begin
  Result:=TJSUint8Array.new(0);
end;

function TPas2JSWASIEnvironment.GetConsoleInputBuffer(aMaxSize : Integer) : TJSUint8Array;

Var
  S : String;

begin
  Result:=Nil;
  If Assigned(OnGetConsoleInputBuffer) then
    OnGetConsoleInputBuffer(Self,Result)
  else If Assigned(OnGetConsoleInputString) then
    begin
    S:='';
    OnGetConsoleInputString(Self,S);
    S:=Copy(S,1,aMaxSize);
    Result:=toUTF8Array(S);
    end
  else
    Result:=TJSUint8Array.New(0);
end;

function TPas2JSWASIEnvironment.fd_readdir(fd: NativeInt; bufPtr: TWasmMemoryLocation; bufLen, cookie: NativeInt;
  bufusedPtr: TWasmMemoryLocation): NativeInt;

var
  Dirent : TWasiFSDirent;
  NameArray : TJSUint8Array;
  NameLen : integer;
  Ptr : TWasmMemoryLocation;
  Res : Integer;


begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.fd_readdir(%d,[%x],%d,%d,[%x])',[fd,bufPtr,buflen,cookie,bufusedptr]);
  {$ENDIF}
  if not Assigned(FS) then
    Result:=WASI_ENOSYS
  else
    try
      Res:=FS.ReadDir(FD,AsIntNumber(Cookie),Dirent);
      Result:=WASI_ESUCCESS;
      Ptr:=BufPtr;
      While ((Ptr-BufPtr)<BufLen) and (Res=WASI_ESUCCESS) do
        begin
        NameArray:=UTF8TextEncoder.encode(Dirent.name);
        NameLen:=NameArray.byteLength;
        Ptr:=SetMemInfoUInt64(Ptr,Dirent.Next);
        Ptr:=SetMemInfoUInt64(Ptr,Dirent.ino);
        Ptr:=SetMemInfoInt32(Ptr,NameLen);
        Ptr:=SetMemInfoInt32(Ptr,DirentMap[Dirent.EntryType]);
        if SetUTF8StringInMem(Ptr,BufLen-18,Dirent.Name)<>-1 then
          begin
          Ptr:=Ptr+NameLen;
          Cookie:=Dirent.Next;
          Res:=FS.ReadDir(FD,AsIntNumber(Cookie),Dirent)
          end
        else
          Res:=WASI_ENOMEM;
        end;
      SetMemInfoInt32(bufusedPtr,Ptr-BufPtr);
    except
      On E : Exception do
        Result:=ErrorToCode(E);
    end;
end;

function TPas2JSWASIEnvironment.fd_renumber(afrom, ato: NativeInt): NativeInt;
begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.fd_renumber(%d,%d)',[aFrom,aTo]);
  {$ENDIF}
  console.log('Unimplemented: TPas2JSWASIEnvironment.fd_renumber');
  Result:= WASI_ENOSYS;
end;

function TPas2JSWASIEnvironment.fd_tell(fd : NativeInt;  offsetPtr: TWasmMemoryLocation): NativeInt;

var
  NewPos : integer;

begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.fd_tell(%d,[%x])',[fd,offsetPtr]);
  {$ENDIF}
  if not Assigned(FS) then
    Result:=WASI_ENOSYS
  else
    try
      Result:=FS.Seek(FD,0,swCurrent,NewPos);
      if Result=WASI_ESUCCESS then
        SetMemInfoInt32(OffsetPtr,NewPos);
    except
      On E : Exception do
        Result:=ErrorToCode(E);
    end;
end;

function TPas2JSWASIEnvironment.fd_filestat_get(fd: NativeInt;
  bufPtr: TWasmMemoryLocation): NativeInt;
var
  Info : TWasiFileStat;
begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.fd_filestat_get(%d,[%x])',[fd,bufPtr]);
  {$ENDIF}
  console.log('Unimplemented: TPas2JSWASIEnvironment.fd_filestat_get');
  if not Assigned(FS) then
    Result:=WASI_ENOSYS
  else
    try
      Result:=FS.StatFD(fd,Info);
      if Result=WASI_ESUCCESS then
        WriteFileStatToMem(BufPtr,Info);
    except
      On E : Exception do
        Result:=ErrorToCode(E);
    end;
end;

function TPas2JSWASIEnvironment.fd_filestat_set_size(fd, stSize: NativeInt
  ): NativeInt;
begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.fd_filestat_set_size(%d,%d)',[fd,stSize]);
  {$ENDIF}
  console.log('Unimplemented: TPas2JSWASIEnvironment.fd_filestat_set_size');

  Result:= WASI_ENOSYS;
end;

function TPas2JSWASIEnvironment.fd_filestat_set_times(fd, stAtim, stMtim,
  fstflags: NativeInt): NativeInt;

var
  Flags : TSetTimesFlags;

  Procedure MaybeFlag(src : Integer; Flag :TSetTimesFlag);
  begin
    if ((fstflags and Src)=Src) then
      Include(Flags,Flag);
  end;

begin
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.fd_filestat_set_times(%d,%d,%d)',[fd,stAtim,stMtim,fstFlags]);
  {$ENDIF}
  console.log('Unimplemented: TPas2JSWASIEnvironment.fd_filestat_set_times');
  if not Assigned(FS) then
    Result:=WASI_ENOSYS
  else
    try
      MaybeFlag(__WASI_FSTFLAGS_ATIM,stfaTime);
      MaybeFlag(__WASI_FSTFLAGS_ATIM_NOW,stfaTimeNow);
      MaybeFlag(__WASI_FSTFLAGS_MTIM,stfmTime);
      MaybeFlag(__WASI_FSTFLAGS_MTIM_NOW,stfmTimeNow);
      Result:=FS.UTimes(fd,TJSDate.new(stAtim),TJSDate.new(stMTim),Flags);
    except
      On E : Exception do
        Result:=ErrorToCode(E);
    end;
end;


function TPas2JSWASIEnvironment.path_readlink (fd: NativeInt; pathPtr: TWasmMemoryLocation; pathLen: NativeInt; buf: TWasmMemoryLocation; bufLen : NativeInt; bufused : TWasmMemoryLocation) : NativeInt;

var
  lTarget, lPath : String;
  Written : Integer;

begin
  lPath:=GetUTF8StringFromMem(PathPtr,PathLen);
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.path_readlink(%d,''%s'',[%x],%d,%d,[%x])',[fd,lPath,buf,buflen,bufused]);
  {$ENDIF}
  console.log('Unimplemented: TPas2JSWASIEnvironment.path_readlink');
  if not Assigned(FS) then
    Result:=WASI_ENOSYS
  else
    try
      Result:=FS.ReadLinkAt(fd,lPath,lTarget);
      if Result=__WASI_ERRNO_SUCCESS then
        begin
        Written:=SetUTF8StringInMem(Buf,BufLen,lTarget);
        if Written=-1 then
          Result:=__WASI_ERRNO_2BIG
        else
          SetMemInfoInt32(bufUsed,Written);
        end;
    except
      On E : Exception do
        Result:=ErrorToCode(E);
    end;

  Result:= WASI_ENOSYS;
end;

function TPas2JSWASIEnvironment.path_create_directory(fd, pathPtr,
  pathLen: NativeInt): NativeInt;
var
  S : String;
begin
  S:=GetUTF8StringFromMem(PathPtr,PathLen);
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.path_create_directory(%d,''%s'')',[fd,S]);
  {$ENDIF}
  if not Assigned(FS) then
    Result:=WASI_ENOSYS
  else
    try
      Result:=FS.MkDirAt(fd,S);
    except
      On E : Exception do
        Result:=ErrorToCode(E);
    end;
end;

procedure TPas2JSWASIEnvironment.WriteFileStatToMem(
  BufPtr: TWasmMemoryLocation; Info: TWasiFileStat);

var
  Loc : TWasmMemoryLocation;

begin
  Loc:=BufPtr;
  Loc:=SetMemInfoInt64(Loc,Info.dev);
  Loc:=SetMemInfoUInt64(Loc,Info.Ino);
  Loc:=SetMemInfoUInt64(Loc,Info.filetype);
  Loc:=SetMemInfoUInt64(Loc,Info.nLink);
  Loc:=SetMemInfoUInt64(Loc,Info.size);
  Loc:=SetMemInfoUInt64(Loc,Info.atim*1000*1000);
  Loc:=SetMemInfoUInt64(Loc,Info.mtim*1000*1000);
  Loc:=SetMemInfoUInt64(Loc,Info.ctim*1000*1000);
end;

function TPas2JSWASIEnvironment.path_filestat_get(fd, flags: NativeInt;
  pathPtr: TWasmMemoryLocation; pathLen: Nativeint; bufPtr: TWasmMemoryLocation
  ): NativeInt;

var
  aPath : String;
  Info : TWasiFileStat;

begin
  aPath:=GetUTF8StringFromMem(PathPtr,PathLen);
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.path_filestat_get(%d,%d,''%s'',[%x])',[fd,flags,aPath,bufptr]);
  {$ENDIF}
  if not Assigned(FS) then
    Result:=WASI_ENOSYS
  else
    try
      Result:=FS.StatAt(fd,aPath,Info);
      if Result=WASI_ESUCCESS then
        WriteFileStatToMem(BufPtr,Info);
    except
      On E : Exception do
        Result:=ErrorToCode(E);
    end;
end;

function TPas2JSWASIEnvironment.path_link (oldFd, oldFlags : NativeInt; oldPath: TWasmMemoryLocation; oldPathLen, newFd : NativeInt; NewPath: TWasmMemoryLocation; newPathLen: NativeInt) : NativeInt;


var
  lOld,lNew : String;

begin
  lOld:=GetUTF8StringFromMem(oldPath,OldPathLen);
  lNew:=GetUTF8StringFromMem(newPath,NewPathLen);
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.path_link(%d,%d,''%s'',%d,''%s'')',[oldfd,oldFlags,lOld,Newfd,lNew]);
  {$ENDIF}
  if not Assigned(FS) then
    Result:=WASI_ENOSYS
  else
    try
      Result:=FS.LinkAt(Oldfd,lOld,newFD,lNew);
    except
      On E : Exception do
        Result:=ErrorToCode(E);
    end;
end;

function TPas2JSWASIEnvironment.path_remove_directory (fd : NativeInt; pathPtr: TWasmMemoryLocation; pathLen : NativeInt) : NativeInt;

var
  lPath : String;

begin
  lPath:=GetUTF8StringFromMem(PathPtr,PathLen);
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.path_remove_directory(%d,''%s'')',[fd,lPath]);
  {$ENDIF}
  if not Assigned(FS) then
    Result:=WASI_ENOSYS
  else
    try
      Result:=FS.rmDirAt(fd,lPath);
    except
      On E : Exception do
        Result:=ErrorToCode(E);
    end;
end;

function TPas2JSWASIEnvironment.path_rename(oldFd, oldPath, oldPathLen, newFd,
  newPath, newPathLen: NativeInt): NativeInt;
var
  lOld,lNew : String;
begin
  lOld:=GetUTF8StringFromMem(oldPath,OldPathLen);
  lNew:=GetUTF8StringFromMem(newPath,NewPathLen);
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.path_rename(%d,''%s'',%d,''%s'')',[oldfd,lOld,Newfd,lnew]);
  {$ENDIF}
  if not Assigned(FS) then
    Result:=WASI_ENOSYS
  else
    try
      Result:=FS.RenameAt(Oldfd,lOld,newFD,lNew);
    except
      On E : Exception do
        Result:=ErrorToCode(E);
    end;
end;

function TPas2JSWASIEnvironment.path_symlink(oldPath, oldPathLen, fd, newPath,
  newPathLen: NativeInt): NativeInt;
var
  lOld,lNew : String;
begin
  lOld:=GetUTF8StringFromMem(oldPath,OldPathLen);
  lNew:=GetUTF8StringFromMem(newPath,NewPathLen);
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.path_symlink(''%s'',%d,''%s'')',[lOld,fd,lNew]);
  {$ENDIF}
  if not Assigned(FS) then
    Result:=WASI_ENOSYS
  else
    try
      Result:=FS.SymLinkAt(fd,lOld,lNew);
    except
      On E : Exception do
        Result:=ErrorToCode(E);
    end;
end;

function TPas2JSWASIEnvironment.path_unlink_file(fd, pathPtr, pathLen: NativeInt
  ): NativeInt;
var
  lPath : String;

begin
  lPath:=GetUTF8StringFromMem(PathPtr,PathLen);
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.path_unlink_file(%d,''%s'')',[fd,lPath]);
  {$ENDIF}
  if not Assigned(FS) then
    Result:=WASI_ENOSYS
  else
    try
      Result:=FS.unLinkAt(fd,lPath);
    except
      On E : Exception do
        Result:=ErrorToCode(E);
    end;
end;

function TPas2JSWASIEnvironment.path_open(dirfd, dirflags: NativeInt;
  pathPtr: TWasmMemoryLocation; pathLen, oflags, fsRightsBase,
  fsRightsInheriting, fsFlags: NativeInt; fd: TWasmMemoryLocation): NativeInt;

var
  lPath : String;
  lFD : Integer;

begin
  lPath:=GetUTF8StringFromMem(PathPtr,PathLen);
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.path_open(%d,%d,''%s'',%d,%d,%d,%d,[%x])',[dirfd, dirflags, lpath, oflags, fsRightsBase, fsRightsInheriting, fsFlags, fd]);
  {$ENDIF}
  if not Assigned(FS) then
    Result:=WASI_ENOSYS
  else
    try
      Result:=FS.OpenAt(dirfd,dirFlags,lPath,oFlags,fsRightsBase,fsRightsInheriting,fsFlags,lFD);
      if Result=WASI_ESUCCESS then
        SetMemInfoInt32(fd,lFD);
    except
      On E : Exception do
        Result:=ErrorToCode(E);
    end;
end;

function TPas2JSWASIEnvironment.path_filestat_set_times(fd, fstflags, pathPtr,
  pathLen, stAtim, stMtim: NativeInt): NativeInt;

var
  aPath : String;
begin
  aPath:=GetUTF8StringFromMem(PathPtr,PathLen);
  {$IFNDEF NO_WASI_DEBUG}
  if LogAPI then
    DoLog('TPas2JSWASIEnvironment.path_filestat_set_times(%d,%d,''%s'',%d,%d)',[fd,fstflags,aPath,stAtim,stMtim]);
  {$ENDIF}
  if not Assigned(FS) then
    Result:=WASI_ENOSYS
  else
    try
      Result:=FS.UTimesAt(fd,aPath,TJSDate.New(stAtim),TJSDate.New(stMtim),False);
    except
      On E : Exception do
        Result:=ErrorToCode(E);
    end;
end;

constructor TPas2JSWASIEnvironment.Create;

var
  I : Integer;

begin
  // Default expected by FPC runtime
  WASIImportName:='wasi_snapshot_preview1';
  FArguments:=TStringList.Create;
  FEnvironment:=TStringList.Create;
  For I:=0 to GetEnvironmentVariableCount-1 do
    FEnvironment.Add(GetEnvironmentString(i));
end;

destructor TPas2JSWASIEnvironment.Destroy;
begin
  FreeAndNil(FEnvironment);
  FreeAndNil(FArguments);
  FreeAndNil(FImportExtensions);
  inherited Destroy;
end;


function TPas2JSWASIEnvironment.GetUTF8StringFromArray(aSourceArray:TJSUint8Array): String;

var
 TmpBytes : TJSTypedArray;

begin
  TmpBytes:=SharedToNonShared(aSourceArray);
  Result:=UTF8TextDecoder.Decode(tmpBytes);
end;

function TPas2JSWASIEnvironment.GetUTF16StringFromMem(p: TWasmPointer; LenInChars: Integer): String;

  function String_fromCharCode_apply(aThis : TJSObject; aBuffer : TJSUint16Array) : String; external name 'String.fromCharCode.apply';

var
  bytes : TJSUint16Array;

begin
  Result:='';
  if LenInChars <=0 then
    exit;
  bytes := TJSUint16Array.new(Memory.buffer, p, LenInChars);
  Result := String_fromCharCode_apply(nil, bytes);
end;

function TPas2JSWASIEnvironment.GetUTF8StringFromMem(aLoc, aLen: Longint): String;

var
  tmpBuf : TJSArrayBuffer;

begin
  tmpBuf:=SharedToNonShared(getModuleMemoryDataView.buffer.slice(aLoc,aLoc+alen));
  Result:=UTF8TextDecoder.Decode(tmpBuf);
end;

function TPas2JSWASIEnvironment.GetUTF8ByteLength(const AString: String) : Integer;

var
  Arr : TJSUint8Array;

begin
  Arr:=UTF8TextEncoder.Encode(AString);
  Result:=Arr.byteLength;
end;

function TPas2JSWASIEnvironment.SetUTF8StringInMem(aLoc: TWasmMemoryLocation; aLen: Longint; AString: String) : Integer;

var
  Arr : TJSUint8Array;

begin
  Arr:=UTF8TextEncoder.Encode(AString);
  if (Arr.byteLength>aLen) then
    Result:=-Arr.byteLength
  else if Arr.byteLength=0 then
    Result:=0
  else
    Result:=SetUTF8StringInMem(aLoc,aLen,Arr);
end;

function TPas2JSWASIEnvironment.SetUTF8StringInMem(aLoc: TWasmMemoryLocation; aLen: Longint; AStringBuf: TJSUint8Array): Integer;

var
  Arr : TJSUint8Array;

begin
  if aStringBuf=Null then
    exit(0);
  Arr:=TJSUint8Array.New(getModuleMemoryDataView.buffer,aLoc,aLen);
  Arr._set(aStringBuf);
  Result:=aStringBuf.byteLength;
end;

function TPas2JSWASIEnvironment.SetUTF16StringInMem(p: TWasmPointer; const aString: String): integer;
var
  i : Integer;
  view : TJSDataView;
begin
  view := GetModuleMemoryDataView;
  for i := 0 to Length(aString)-1 do
    begin
    view.setUint16(p, TJSString(aString).charCodeAt(i), IsLittleEndian);
    inc(p,SizeUInt16);
    end;
  Result:=Length(aString)*SizeUInt16;
end;


function TPas2JSWASIEnvironment.SetMemInfoInt8(aLoc: TWasmMemoryLocation; aValue: ShortInt
  ): TWasmMemoryLocation;

Var
  View : TJSDataView;

begin
  view:=getModuleMemoryDataView();
  view.setint8(aLoc,aValue);
  result:=aLoc+SizeInt8;
end;

function TPas2JSWASIEnvironment.SetMemInfoInt16(aLoc: TWasmMemoryLocation;
  aValue: SmallInt): TWasmMemoryLocation;

Var
  View : TJSDataView;

begin
  view:=getModuleMemoryDataView();
  view.setint16(aLoc,aValue, IsLittleEndian);
  Result:=aLoc+SizeInt16;
end;

function TPas2JSWASIEnvironment.SetMemInfoInt32(aLoc: TWasmMemoryLocation;
  aValue: Longint): TWasmMemoryLocation;

Var
  View : TJSDataView;

begin
  view:=getModuleMemoryDataView();
  view.setInt32(aLoc,aValue,IsLittleEndian);
  Result:=aLoc+SizeInt32;
end;

function TPas2JSWASIEnvironment.SetMemInfoInt64(aLoc: TWasmMemoryLocation;
  aValue: NativeInt): TWasmMemoryLocation;

Var
  View : TJSDataView;

begin
  view:=getModuleMemoryDataView();
  setBigInt64(View,aLoc,aValue,IsLittleEndian);
  Result:=aLoc+sizeInt64;
end;

function TPas2JSWASIEnvironment.SetMemInfoUInt8(aLoc: TWasmMemoryLocation;
  aValue: Byte): TWasmMemoryLocation;
Var
  View : TJSDataView;

begin
  view:=getModuleMemoryDataView();
  view.setUInt8(aLoc,aValue);
  result:=aLoc+SizeUint8;
end;

function TPas2JSWASIEnvironment.SetMemInfoUInt16(aLoc: TWasmMemoryLocation;
  aValue: Word): TWasmMemoryLocation;
Var
  View : TJSDataView;

begin
  view:=getModuleMemoryDataView();
  view.setUint16(aLoc,aValue,IsLittleEndian);
  result:=aLoc+SizeUint16;
end;

function TPas2JSWASIEnvironment.SetMemInfoUInt32(aLoc: TWasmMemoryLocation;
  aValue: Cardinal): TWasmMemoryLocation;
Var
  View : TJSDataView;

begin
  view:=getModuleMemoryDataView();
  view.setUint32(aLoc,aValue,IsLittleEndian);
  result:=aLoc+SizeUInt32;
end;

function TPas2JSWASIEnvironment.SetMemInfoUInt64(aLoc: TWasmMemoryLocation;
  aValue: NativeUint): TWasmMemoryLocation;
Var
  View : TJSDataView;

begin
  view:=getModuleMemoryDataView();
  setBigUint64(View,aLoc,aValue,IsLittleEndian);
  Result:=aLoc+SizeUint64;
end;

function TPas2JSWASIEnvironment.SetMemInfoFloat32(aLoc: TWasmMemoryLocation; aValue: Double): TWasmMemoryLocation;
Var
  View : TJSDataView;

begin
  view:=getModuleMemoryDataView();
  view.setFloat32(aLoc,aValue,IsLittleEndian);
  Result:=aLoc+SizeFloat32;
end;

function TPas2JSWASIEnvironment.SetMemInfoFloat64(aLoc: TWasmMemoryLocation; aValue: Double): TWasmMemoryLocation;

Var
  View : TJSDataView;

begin
  view:=getModuleMemoryDataView();
  view.setFloat64(aLoc,aValue,IsLittleEndian);
  Result:=aLoc+SizeFloat64;
end;

function TPas2JSWASIEnvironment.GetMemInfoInt8(aLoc: TWasmMemoryLocation): ShortInt;

Var
 View : TJSDataView;

begin
  view:=getModuleMemoryDataView();
  Result:=view.getint8(aLoc);
end;

function TPas2JSWASIEnvironment.GetMemInfoInt16(aLoc: TWasmMemoryLocation): SmallInt;

Var
 View : TJSDataView;

begin
  view:=getModuleMemoryDataView();
  Result:=view.getint16(aLoc,IsLittleEndian);
end;

function TPas2JSWASIEnvironment.GetMemInfoInt32(aLoc: TWasmMemoryLocation): Longint;
Var
 View : TJSDataView;

begin
  view:=getModuleMemoryDataView();
  Result:=view.getint32(aLoc,IsLittleEndian);
end;

function TPas2JSWASIEnvironment.GetMemInfoInt64(aLoc: TWasmMemoryLocation): NativeInt;

Var
  View : TJSDataView;

begin
  view:=getModuleMemoryDataView();
  Result:=GetBigInt64(View,aLoc,IsLittleEndian);
end;

function TPas2JSWASIEnvironment.GetMemInfoUInt8(aLoc: TWasmMemoryLocation): Byte;

Var
  View : TJSDataView;

begin
  view:=getModuleMemoryDataView();
  Result:=view.getUint8(aLoc);
end;

function TPas2JSWASIEnvironment.GetMemInfoUInt16(aLoc: TWasmMemoryLocation): Word;
Var
  View : TJSDataView;

begin
  view:=getModuleMemoryDataView();
  Result:=view.getUint16(aLoc,IsLittleEndian);
end;

function TPas2JSWASIEnvironment.GetMemInfoUInt32(aLoc: TWasmMemoryLocation): Cardinal;
Var
  View : TJSDataView;

begin
  view:=getModuleMemoryDataView();
  Result:=view.getUint32(aLoc,IsLittleEndian);
end;

function TPas2JSWASIEnvironment.GetMemInfoUInt64(aLoc: TWasmMemoryLocation): NativeUint;
Var
  View : TJSDataView;

begin
  view:=getModuleMemoryDataView();
  Result:=GetBigInt64(View,aLoc,IsLittleEndian);
end;

function TPas2JSWASIEnvironment.PreLoadFiles(aFiles: array of string): TPreLoadFilesResult;

var
  I,Idx,Len : Integer;
  FileArray : TPreLoadFileDynArray;

begin
  if not assigned(FS) then
    Raise EWasiError.Create('No filesystem available');
  Len:=Length(aFiles);
  if (Len mod 2)=1 then
    Raise EWasiError.Create('Number of arguments must be even: pairs of url, local');
 SetLength(FileArray,Len div 2);
 I:=0;
 Idx:=0;
 while I<Len do
   begin
   FileArray[Idx].Url:=aFiles[i];
   FileArray[Idx].localname:=aFiles[i+1];
   Inc(I,2);
   Inc(Idx);
   end;
  Result:=Await(PreloadFiles(FileArray));
end;

function TPas2JSWASIEnvironment.PreLoadFiles(aFiles: TPreLoadFileDynArray): TPreLoadFilesResult;

var
  I,res,failcount : Integer;
  Resp: TJSResponse;
  blob : TJSBlob;
  buf : TJSarrayBuffer;
  Fails : TLoadFileFailureDynArray;

  procedure AddFailure(aUrl,aError: String);

  begin
    fails[FailCount].url:=aUrl;
    fails[FailCount].error:=aError;
    inc(Failcount);
  end;

begin
  if not assigned(FS) then
    Raise EWasiError.Create('No filesystem available');
  Res:=0;
  failcount:=0;
  SetLength(Fails,Length(aFiles));
  For I:=0 to Length(afiles)-1 do
    try
      resp:=await(fetch(aFiles[I].url));
      blob:=await(resp.blob);
      buf:=await(TJSArrayBuffer,blob.arrayBuffer);
      FS.PreloadFile(aFiles[i].localname,TJSDataView.new(Buf));
      inc(Res);
    except
      on E : Exception do
        AddFailure(aFiles[i].Url,E.Message);
      on JE : TJSError do
        AddFailure(aFiles[i].Url,JE.Message);
      on OE : TJSObject do
        AddFailure(aFiles[i].Url,TJSJSON.Stringify(OE));
    end;
  SetLength(Fails,FailCount);
  Result.failedurls:=Fails;
  Result.LoadCount:=Res;
end;

function TPas2JSWASIEnvironment.PreLoadFilesIntoDirectory(aDirectory: String; aFiles: array of string): TPreLoadFilesResult;

  function ExtractFileFromURL(aURL : String) : string;

  var
    S : String;
    URLObj : TJSURL;

  begin
    if aUrl.StartsWith('http://',true) or aUrl.StartsWith('https://',true) then
      begin
      UrlObj:=TJSURL.new(aURL);
      S:=UrlObj.PathName
      end
    else
      S:=aURL;
    Result:=ExtractFileName(S);
  end;

var
  I,Len : Integer;
  FileArray : TPreLoadFileDynArray;

begin
  if not assigned(FS) then
    Raise EWasiError.Create('No filesystem available');
 Len:=Length(aFiles);
 SetLength(FileArray,Len);
 aDirectory:=IncludeTrailingPathDelimiter(aDirectory);
 I:=0;
 while I<Len do
   begin
   FileArray[I].Url:=aFiles[i];
   FileArray[I].localname:=aDirectory+ExtractFileFromURL(aFiles[i]);
   Inc(I);
   end;
  Result:=Await(PreloadFiles(FileArray));
end;


initialization

end.

