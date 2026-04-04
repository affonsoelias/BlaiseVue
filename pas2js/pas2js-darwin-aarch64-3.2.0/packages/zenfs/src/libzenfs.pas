{
    This file is part of the Pas2JS run time library.
    Copyright (c) 2017-2020 by the Pas2JS development team.

    Interface for ZenFS - Core API and internal backends

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$IFNDEF FPC_DOTTEDUNITS}
unit libzenfs;
{$ENDIF}

{$mode ObjFPC}
{$modeswitch externalclass}

interface

uses
  {$IFDEF FPC_DOTTEDUNITS}
  JSAPI.JS, BrowserApi.Web, System.Types;
  {$ELSE}
  JS, Web, Types;
  {$ENDIF}

Type
  (*

  *)
  TBooleanCallback = reference to procedure (res : boolean);
  TStringCallBack = reference to procedure (res : string);
  TNativeIntCallBack = reference to procedure (res : NativeInt);
  TVoidCallBack = reference to procedure;

  TZenFSBuffer= TJSUInt8Array;
  TZenFSBufferEncoding = Class
  Const
    ASCII     = 'ascii';
    UTF8      = 'utf8';
    UTF_8     = 'utf-8';
    UTF16LE   = 'utf16le';
    UTF_16LE  = 'utf-16le';
    UCS2      = 'ucs2';
    UCS_2     = 'ucs-2';
    Base64    = 'base64';
    Base64Url = 'base64url';
    Latin1    = 'latin1';
    Binary    = 'binary';
    Hex       = 'hex';
  end;

  TZenFSDir = class;
  TZenFSCred = class;
  TZenFSStats = class;
  TZenFSDirent = class;

  TZenFSCred = class external name 'Object' (TJSObject)
    egid,
    euid,
    gid,
    sgid,
    suid,
    uid : NativeInt;
  end;


  TZenFSStats = Class external name 'ZenFS.Stats' (TJSObject)
  Public
    atimeNs : NativeInt;
    mtimeNs : NativeInt;
    ctimeNs : NativeInt;
    birthtimeNs : NativeInt;
    dev : NativeInt;
    blocks : NativeInt;
    blksize : NativeInt;
    ino : NativeInt;
    rdev : NativeInt;
    nlink : NativeInt;
    uid : NativeInt;
    guid : NativeInt;
    size : NativeInt;
    constructor new;
    constructor new (aStats : TZenFSStats);
    function isFile() : Boolean;
    function isDirectory() : Boolean;
    function isSymbolicLink() : Boolean;
    function isSocket() : Boolean;
    function isBlockDevice() : Boolean;
    function isCharacterDevice() : Boolean;
    function isFIFO() : Boolean;
    function hasAccess(mode: NativeInt;Cred: TZenFSCred) : Boolean;
    function cred() : TZenFSCred;
    function cred(uid: NativeInt) : TZenFSCred;
    function cred(uid, gid: NativeInt) : TZenFSCred;
    procedure chmod(mode: NativeInt);
    procedure chown(uid, gid: NativeInt);
    atime : TJSDate;
    mtime : TJSDate;
    ctime : TJSDate;
    birthtime : TJSDate;
  end;
  TZenFSStatsCallback = reference to procedure(stats : TZenFSStats);
  TZenFSStatsListener = Procedure (curr : TZenFSStats; prev : TZenFSStats);

  TZenFSBigintStats = Class external name 'ZenFS.BigIntStats' (TJSObject)
  Public
    atimeNs : NativeInt;
    mtimeNs : NativeInt;
    ctimeNs : NativeInt;
    birthtimeNs : NativeInt;
    dev : TJSBigint;
    blocks : TJSBigint;
    blksize : TJSBigint;
    ino : TJSBigint;
    rdev : TJSBigint;
    nlink : TJSBigint;
    uid : TJSBigint;
    guid : TJSBigint;
    size : TJSBigint;
    constructor new;
    constructor new (aStats : TZenFSStats);
    function isFile() : Boolean;
    function isDirectory() : Boolean;
    function isSymbolicLink() : Boolean;
    function isSocket() : Boolean;
    function isBlockDevice() : Boolean;
    function isCharacterDevice() : Boolean;
    function isFIFO() : Boolean;
    function hasAccess(mode: NativeInt;Cred: TZenFSCred) : Boolean;
    function cred() : TZenFSCred;
    function cred(uid: NativeInt) : TZenFSCred;
    function cred(uid, gid: NativeInt) : TZenFSCred;
    procedure chmod(mode: NativeInt);
    procedure chown(uid, gid: NativeInt);
    atime : TJSDate;
    mtime : TJSDate;
    ctime : TJSDate;
    birthtime : TJSDate;
  end;
  TZenFSBigintStatsCallback = reference to procedure(stats : TZenFSBigintStats);
  TZenFSBigintStatsListener = Procedure (curr : TZenFSBigintStats; prev : TZenFSBigintStats);


  { TZenFSDirent }

  TZenFSDirent = Class external name 'ZenFS.Dirent' (TJSObject)
  private
    FPath: string; external name 'path';
  Public
    constructor new (aPath: string; aStats : TZenFSStats);
    function isFile() : Boolean;
    function isDirectory() : Boolean;
    function isBlockDevice() : Boolean;
    function isCharacterDevice() : Boolean;
    function isSymbolicLink() : Boolean;
    function isFIFO() : Boolean;
    function isSocket() : Boolean;
    property path : string read FPath;
  end;
  TZenFSDirentArray = Array of TZenFSDirent;

  TJSDirentCallback = reference to procedure(aDirent : TZenFSDirent);
  TJSDirCloseCallback = reference to procedure;

  { TZenFSDirEnumerator }

  TZenFSDirEnumerator = class
  private
    FDir: TZenFSDir;
    FCurrent : TZenFSDirent;
  public
    constructor Create(Adir: TZenFSDir); reintroduce;
    function GetCurrent: TZenFSDirent;
    function MoveNext: Boolean;
    property Current: TZenFSDirent read GetCurrent;
  end;

  TZenFSDir = Class external name 'ZenFS.Dir' (TJSObject)
  private
    FPath: string; external name 'path';
  Public
    constructor new(aDir : String);
    function checkClosed() : JSValue;
    procedure close(callback : TJSDirCloseCallback);
    procedure close() ; async;
    procedure closeSync();
    function read() : TZenFSDirent; async;
    procedure read(callback: TJSDirCloseCallback);
    function readSync() : TZenFSDirent;
    property Path : string Read FPath;
  end;
  TZenFSDirCallback = reference to procedure (aDir : TZenFSDir);

  { TZenFSDirHelper }

  TZenFSDirHelper = class helper for TZenFSDir
    function getEnumerator: TZenFSDirEnumerator;
  end;

  { TZenFSReadStream }

  TZenFSReadStream = class external name 'ZenFS' (TJSReadableStream)
  private
    FBytesRead: NativeInt; external name 'bytesRead';
    FPath: string; external name 'path';
    FPending: boolean; external name 'pending';
  Public
    procedure close;
    procedure close(Callback : TVoidCallback);
    property pending : boolean read FPending;
    Property bytesRead : NativeInt read FBytesRead;
    Property Path : string Read FPath;
  end;

  TZenFSWriteStream = class external name 'ZenFS' (TJSWritableStream)
  private
    FBytesWritten: NativeInt; external name 'bytesWritten';
    FPath: string; external name 'path';
    FPending: boolean; external name 'pending';
  Public
    procedure close; reintroduce;
    procedure close(Callback : TVoidCallback);
    property pending : boolean read FPending;
    Property bytesWritten : NativeInt read FBytesWritten;
    Property Path : string Read FPath;
  end;

  { TZenFSStatsFS }

  TZenFSStatsFS = Class external name 'ZenFS.StatsFs' (TJSObject)
  private
    fbavail: NativeInt; external name 'bavail';
    fbfree: NativeInt;external name 'bfree';
    fbsize: NativeInt;external name 'bsize';
    fffree: NativeInt;external name 'ffree';
    ffiles: NativeInt;external name 'files';
    ftype: Nativeint;external name 'type';
  public
    Property bavail : NativeInt Read fbavail;
    property bsize : NativeInt Read fbsize;
    property bfree : NativeInt Read fbfree;
    property ffree : NativeInt Read fffree;
    property files : NativeInt Read ffiles;
    property type_ : Nativeint read ftype;
  end;
  TZenFSStatsFSCallback = reference to procedure (statsfs : TZenFSStatsFS);

  TZenFSErrNo = class external name 'Object' (TJSObject)
  const
    EPERM = 1;
    (** No such file or directory **)
    ENOENT = 2;
    (** Interrupted system call **)
    EINTR = 4;
    (** Input/output error **)
    EIO = 5;
    (** No such device or address **)
    ENXIO = 6;
    (** Bad file descriptor **)
    EBADF = 9;
    (** Resource temporarily unavailable **)
    EAGAIN = 11;
    (** Cannot allocate memory **)
    ENOMEM = 12;
    (** Permission denied **)
    EACCES = 13;
    (** Bad address **)
    EFAULT = 14;
    (** Block device required **)
    ENOTBLK = 15;
    (** Resource busy or locked **)
    EBUSY = 16;
    (** File exists **)
    EEXIST = 17;
    (** Invalid cross-device link **)
    EXDEV = 18;
    (** No such device **)
    ENODEV = 19;
    (** File is not a directory **)
    ENOTDIR = 20;
    (** File is a directory **)
    EISDIR = 21;
    (** Invalid argument **)
    EINVAL = 22;
    (** Too many open files in system **)
    ENFILE = 23;
    (** Too many open files **)
    EMFILE = 24;
    (** Text file busy **)
    ETXTBSY = 26;
    (** File is too big **)
    EFBIG = 27;
    (** No space left on disk **)
    ENOSPC = 28;
    (** Illegal seek **)
    ESPIPE = 29;
    (** Cannot modify a read-only file system **)
    EROFS = 30;
    (** Too many links **)
    EMLINK = 31;
    (** Broken pipe **)
    EPIPE = 32;
    (** Numerical argument out of domain **)
    EDOM = 33;
    (** Numerical result out of range **)
    ERANGE = 34;
    (** Resource deadlock would occur **)
    EDEADLK = 35;
    (** File name too long **)
    ENAMETOOLONG = 36;
    (** No locks available **)
    ENOLCK = 37;
    (** Function not implemented **)
    ENOSYS = 38;
    (** Directory is not empty **)
    ENOTEMPTY = 39;
    (** Too many levels of symbolic links **)
    ELOOP = 40;
    (** No message of desired type **)
    ENOMSG = 42;
    (** Invalid exchange **)
    EBADE = 52;
    (** Invalid request descriptor **)
    EBADR = 53;
    (** Exchange full **)
    EXFULL = 54;
    (** No anode **)
    ENOANO = 55;
    (** Invalid request code **)
    EBADRQC = 56;
    (** Device not a stream **)
    ENOSTR = 60;
    (** No data available **)
    ENODATA = 61;
    (** Timer expired **)
    ETIME = 62;
    (** Out of streams resources **)
    ENOSR = 63;
    (** Machine is not on the network **)
    ENONET = 64;
    (** Object is remote **)
    EREMOTE = 66;
    (** Link has been severed **)
    ENOLINK = 67;
    (** Communication error on send **)
    ECOMM = 70;
    (** Protocol error **)
    EPROTO = 71;
    (** Bad message **)
    EBADMSG = 74;
    (** Value too large for defined data type **)
    EOVERFLOW = 75;
    (** File descriptor in bad state **)
    EBADFD = 77;
    (** Streams pipe error **)
    ESTRPIPE = 86;
    (** Socket operation on non-socket **)
    ENOTSOCK = 88;
    (** Destination address required **)
    EDESTADDRREQ = 89;
    (** Message too long **)
    EMSGSIZE = 90;
    (** Protocol wrong type for socket **)
    EPROTOTYPE = 91;
    (** Protocol not available **)
    ENOPROTOOPT = 92;
    (** Protocol not supported **)
    EPROTONOSUPPORT = 93;
    (** Socket type not supported **)
    ESOCKTNOSUPPORT = 94;
    (** Operation is not supported **)
    ENOTSUP = 95;
    (** Network is down **)
    ENETDOWN = 100;
    (** Network is unreachable **)
    ENETUNREACH = 101;
    (** Network dropped connection on reset **)
    ENETRESET = 102;
    (** Connection timed out **)
    ETIMEDOUT = 110;
    (** Connection refused **)
    ECONNREFUSED = 111;
    (** Host is down **)
    EHOSTDOWN = 112;
    (** No route to host **)
    EHOSTUNREACH = 113;
    (** Operation already in progress **)
    EALREADY = 114;
    (** Operation now in progress **)
    EINPROGRESS = 115;
    (** Stale file handle **)
    ESTALE = 116;
    (** Remote I/O error **)
    EREMOTEIO = 121;
    (** Disk quota exceeded **)
    EDQUOT = 122;

  end;

  TZenFSErrnoError = class external name 'ZenFS.ErrnoError' (TJSError)
    constructor New (ErrNo : Integer);
    constructor New (ErrNo : Integer; Message : String);
    constructor New (ErrNo : Integer; Message,Path : String);
    constructor New (ErrNo : Integer; Message,Path,Syscall : String);
    class function fromJSON (aJSOn : TJSObject) : TZenFSErrnoError;
    class function With_ (code : String) : TZenFSErrnoError external name 'With';
    class function With_ (code : String; Path : String) : TZenFSErrnoError external name 'With';
    class function With_ (code : String; Path, SysCall : String) : TZenFSErrnoError external name 'With';
    errno : integer;
    code : string;
    function toJSON : TJSObject;
    function toString : string; reintroduce;
    function bufferSize : integer;
  end;

  TZenFSFileSystemMetaData = Class external name 'ZenFS.FileSystemMetaData' (TJSObject)
    name : string;
    readonly : boolean;
    totalSpace : NativeInt;
    freeSpace : NativeInt;
  end;

  TZenFSFile = Class external name 'ZenFS.File' (TJSObject)
    position: nativeint;
    path: string;
    function stat(): specialize TGPromise<TZenFSStats>;
    function statSync(): TZenFSStats;
    function close(): TJSPromise;
    procedure closeSync();
    function asyncDispose(): TJSPromise;
    procedure dispose();
  end;

  TZenFSFileSystem = Class external name 'ZenFS.FileSystem' (TJSObject)
    constructor new(options : TJSObject);
    function metadata : TZenFSFileSystemMetaData;
    function ready : TJSPromise;
    function rename(aOld,aNew : String; Cred : TZenFSCred) : TJSPromise;
    procedure renameSync(aOld,aNew : String; Cred : TZenFSCred);
    function stat(path: string; cred: TZenFSCred): TJSPromise;
    function statSync(path: string; cred: TZenFSCred): TZenFSStats;
    function openFile(path: string; flag: string; cred: TZenFSCred): TJSPromise;
    function openFileSync(path: string; flag: string; cred: TZenFSCred): TZenFSFile;
    function createFile(path: string; flag: string; mode: Nativeint; cred: TZenFSCred): TJSPromise;
    function createFileSync(path: string; flag: string; mode: Nativeint; cred: TZenFSCred): TZenFSFile;
    function unlink(path: string; cred: TZenFSCred): TJSPromise; overload;
    procedure unlinkSync(path: string; cred: TZenFSCred);overload;
    function rmdir(path: string; cred: TZenFSCred): TJSPromise;
    procedure rmdirSync(path: string; cred: TZenFSCred);
    function mkdir(path: string; mode: Nativeint; cred: TZenFSCred): TJSPromise;
    procedure mkdirSync(path: string; mode: Nativeint; cred: TZenFSCred);
    function readdir(path: string; cred: TZenFSCred): TJSPromise;
    function readdirSync(path: string; cred: TZenFSCred): TStringDynArray;
    function exists(path: string; cred: TZenFSCred): TJSPromise;
    function existsSync(path: string; cred: TZenFSCred): boolean;
    function link(srcpath: string; dstpath: string; cred: TZenFSCred): TJSPromise;
    procedure linkSync(srcpath: string; dstpath: string; cred: TZenFSCred);
    function sync(path: string; data: TJSUint8Array; stats: TZenFSStats): TJSPromise;
    procedure syncSync(path: string; data: TJSUint8Array; stats: TZenFSStats);
  end;

  TZenFSStatOptions = class external name 'Object' (TJSObject)
    bigint : Boolean;
  end;

  TZenFSStatFsOptions = class external name 'Object' (TJSObject)
    bigint : Boolean;
  end;


  { TZenFSOpenAsBlobOptions }

  TZenFSOpenAsBlobOptions = Class external name 'Object' (TJSObject)
  private
    FType: String; external name 'type';
  Public
    Property Type_ : String Read FType Write FType;
  end;

  TZenFSMountObject = Class external name 'Object' (TJSObject)
  Private
    function GetMounts(Name: String): TZenFSFileSystem; external name '[]';
    procedure SetMounts(Name: String; const AValue: TZenFSFileSystem); external name '[]';
  Public
    Property Mounts[aName : string] : TZenFSFileSystem Read GetMounts Write SetMounts; default;
  end;

  TZenFSOpenDirOptions = class external name 'Object' (TJSObject)
    encoding : jsvalue;
    bufferSize : jsvalue;
    recursive : boolean;
  end;

  TZenFSReadDirOptions = class external name 'Object' (TJSObject)
    withFileTypes : Boolean;
  end;

  TZenFSReadAsyncOptions = class external name 'Object' (TJSObject)
      buffer : TZenFSBuffer;
  end;
  TZenFSReadSyncOptions = class external name 'Object' (TJSObject)
    offset : NativeInt;
    length : NativeInt;
    position : NativeInt;
  end;

  TZenFSRmOptions = class external name 'Object' (TJSObject)
    force : Boolean;
    maxRetries : Nativeint;
    recursive : Boolean;
    retryDelay : Nativeint;
  end;

  TZenFSRmDirOptions = class external name 'Object' (TJSObject)
    maxRetries : Nativeint;
    recursive : Boolean;
    retryDelay : Nativeint;
  end;

  TZenFSWatchOptions = class external name 'Object' (TJSObject)
    persistent : boolean;
  end;

  TZenFSStatWatcher = class external name 'Object' (TJSObject)
     Function ref: TJSObject;
     Function unref: TJSObject;
  end;

  TZenFSWatcher = class external name 'EventTarget' (TJSEventTarget);

  TZenFSReadCallback = Procedure (err : jsvalue; bytesRead : NativeInt; buffer : TZenFSBuffer);
  TZenFSWriteCallback = Procedure (err : jsvalue; bytesWritten : NativeInt; buffer : TZenFSBuffer);
  TZenFSReadVCallback = Procedure (err : jsvalue; bytesRead : NativeInt; buffer : Array of TJSDataView);
  TZenFSWriteVCallback = Procedure (err : jsvalue; bytesWritten : NativeInt; buffers : array of TJSDataView);
  TZenFSReadFileCallback = Procedure (err : jsvalue; data : TZenFSBuffer);
  TZenFSReadDirCallback = Procedure (err : jsvalue; files : TStringDynArray);
  TZenFSErrorNoError = class external name 'ZenFS.ErrorNoError' (TJSObject);
  TZenFSWatchListener = Procedure (event : string; filename : string);


  TZenFS = Class external name 'ZenFS' (TJSObject)
  private
    FMounts: TJSMap;
  Public
    class var Errno : TZenFSErrNo;
    procedure access(path : string; callback: TVoidCallback);
    procedure access(path : string; mode : integer; callback: TVoidCallback);
    procedure accessSync(path : string);
    procedure accessSync(path : string; mode : integer);
    procedure appendFile(filename : string; Data : String; callback: TVoidCallback);
    procedure appendFile(filename : string; Data : String);
    procedure appendFile(filename : string; Data : TJSDataView; callback: TVoidCallback);
    procedure appendFile(filename : string; Data : TJSDataView);
    procedure appendFile(filename : string; Data : TJSArray; callback: TVoidCallback);
    procedure appendFile(filename : string; Data : TJSArray);

    procedure appendFile(filename : string; Data : String; Options : JSValue; callback: TVoidCallback);
    procedure appendFile(filename : string; Data : String; Options : JSValue);
    procedure appendFile(filename : string; Data : TJSDataView; Options : JSValue; callback: TVoidCallback);
    procedure appendFile(filename : string; Data : TJSDataView; Options : JSValue);
    procedure appendFile(filename : string; Data : TJSArray; Options : JSValue; callback: TVoidCallback);
    procedure appendFile(filename : string; Data : TJSArray; Options : JSValue);

    procedure appendFileSync(filename : string; Data : String; Options : JSValue);
    procedure appendFileSync(filename : string; Data : TJSDataView; Options : JSValue);
    procedure appendFileSync(filename : string; Data : TJSArray; Options : JSValue);
    procedure appendFileSync(filename : string; Data : String);
    procedure appendFileSync(filename : string; Data : TJSDataView);
    procedure appendFileSync(filename : string; Data : TJSArray);

    function attachFS(arg1: JSValue;arg2: JSValue) : JSValue;
    function attachStore(arg1: JSValue;arg2: JSValue) : JSValue;

    procedure chmod(path : string; mode : string; callback:  TVoidCallback);
    procedure chmod(path : string; mode : string);
    procedure chmod(path : string; mode : NativeInt; callback:  TVoidCallback);
    procedure chmod(path : string; mode : NativeInt);

    procedure chmodSync(path : string; mode : string);
    procedure chmodSync(path : string; mode : NativeInt);


    procedure chown(Path : string; uid,gid : NativeInt; callback : TVoidCallback);
    procedure chown(Path : string; uid,gid : NativeInt);
    procedure chownSync(Path : string; uid,gid : NativeInt);

    procedure close(fd : NativeInt; callback : TVoidCallback);
    procedure close(fd : NativeInt);
    procedure closeSync(fd : NativeInt; callback : TVoidCallback);
    procedure closeSync(fd : NativeInt);

    function configure(config: TJSObject) : TJSPromise;

    procedure copyFile(src,dest : string; callback : TVoidCallback);
    procedure copyFile(src,dest : string);
    procedure copyFileSync(src,dest : string);

    procedure cp(src,dest : string; callback : TVoidCallback);
    procedure cp(src,dest : string);
    procedure cpSync(src,dest : string);


    function createReadStream(path : string; options : JSValue) : TZenFSReadStream;
    function createWriteStream(path : string; options : JSValue) : TZenFSWriteStream;

    procedure exists(path : String; cb : TBooleanCallback);
    function existsSync(path : String) : Boolean;

    procedure fchmod(fd : NativeInt; mode : string; callback:  TVoidCallback);
    procedure fchmod(fd : NativeInt; mode : string);
    procedure fchmod(fd : NativeInt; mode : NativeInt; callback:  TVoidCallback);
    procedure fchmod(fd : NativeInt; mode : NativeInt);

    procedure fchmodSync(fd : NativeInt; mode : string);
    procedure fchmodSync(fd : NativeInt; mode : NativeInt);

    procedure fchown(fd : NativeInt; uid,gid : NativeInt; callback : TVoidCallback);
    procedure fchown(fd : NativeInt; uid,gid : NativeInt);
    procedure fchownSync(fd : NativeInt; uid,gid : NativeInt);

    procedure fdatasync(fd : NativeInt);
    procedure fdatasync(fd : NativeInt; callback : TVoidCallback);
    procedure fdatasyncSync(fd : NativeInt);

    procedure fstat(fd : NativeInt; callback : TZenFSStatsCallback);
    procedure fstat(fd : NativeInt; options: TJSObject; callback : TZenFSStatsCallback);
    function fstatSync(fd : NativeInt; options: TJSObject) : TZenFSStats;
    function fstatSync(fd : NativeInt) : TZenFSStats;

    procedure fsync(fd: NativeInt);
    procedure fsync(fd: NativeInt; callback : TVoidCallback);
    procedure fsyncSync(fd: NativeInt);

    procedure ftruncate(fd: NativeInt; callback : TVoidCallback);
    procedure ftruncate(fd, len: NativeInt; callback : TVoidCallback);
    procedure ftruncate(fd: NativeInt);
    procedure ftruncate(fd, len: NativeInt);
    procedure ftruncateSync(fd: NativeInt);
    procedure ftruncateSync(fd, len: NativeInt);

    procedure futimes(fd : NativeInt; aTime : NativeInt; mTime : NativeInt; callback : TVoidCallback);
    procedure futimes(fd : NativeInt; aTime : TJSDate; mTime : TJSDate; callback : TVoidCallback);
    procedure futimes(fd : NativeInt; aTime : NativeInt; mTime : NativeInt);
    procedure futimes(fd : NativeInt; aTime : TJSDate; mTime : TJSDate);
    procedure futimesSync(fd : NativeInt; aTime : NativeInt; mTime : NativeInt);
    procedure futimesSync(fd : NativeInt; aTime : TJSDate; mTime : TJSDate);

    function isAppendable(arg1: JSValue) : JSValue;
    function isBackend(arg1: JSValue) : JSValue;
    function isBackendConfig(arg1: JSValue) : JSValue;
    function isExclusive(arg1: JSValue) : JSValue;
    function isReadable(arg1: JSValue) : JSValue;
    function isSynchronous(arg1: JSValue) : JSValue;
    function isTruncating(arg1: JSValue) : JSValue;
    function isWriteable(arg1: JSValue) : JSValue;
    procedure lchmod(path  : String; mode : string; callback:  TVoidCallback);
    procedure lchmod(path  : String; mode : string);
    procedure lchmod(path  : String; mode : NativeInt; callback:  TVoidCallback);
    procedure lchmod(path  : String; mode : NativeInt);

    procedure lchmodSync(path  : String; mode : string);
    procedure lchmodSync(path  : String; mode : NativeInt);

    procedure link(existing, newpath : string; callback : TVoidCallback);
    procedure link(existing, newpath : string);
    procedure linkSync(existing, newpath : string);

    function lopenSync(path : string; flag : string; mode : nativeInt) : NativeInt;
    function lopenSync(path : string; flag : string; mode : string) : NativeInt;

    procedure lstat(path  : String; callback : TZenFSStatsCallback);
    procedure lstat(path  : String; options: TJSObject; callback : TZenFSStatsCallback);
    function lstatSync(path  : String; options: TJSObject) : TZenFSStats;
    function lstatSync(path  : String) : TZenFSStats;

    function lstat(arg1: JSValue;arg2: JSValue) : JSValue;
    function lstatSync(arg1: JSValue;arg2: JSValue) : JSValue;

    procedure lutimes(path  : String; aTime : NativeInt; mTime : NativeInt; callback : TVoidCallback);
    procedure lutimes(path  : String; aTime : TJSDate; mTime : TJSDate; callback : TVoidCallback);
    procedure lutimes(path  : String; aTime : NativeInt; mTime : NativeInt);
    procedure lutimes(path  : String; aTime : TJSDate; mTime : TJSDate);
    procedure lutimesSync(path  : String; aTime : NativeInt; mTime : NativeInt);
    procedure lutimesSync(path  : String; aTime : TJSDate; mTime : TJSDate);

    procedure mkdir(path  : String; mode : Nativeint; callback : TVoidCallback);
    procedure mkdir(path  : String; mode : Nativeint);
    procedure mkdirSync(path  : String; mode : Nativeint);

    procedure mkdtemp(prefix : string; encoding : string; callback : TStringCallBack);
    procedure mkdtemp(prefix : string; callback : TStringCallBack);
    function mkdtempSync(prefix : string; encoding : string) : string;
    function mkdtempSync(prefix : string) : String;

    procedure mount(mountPoint : String; fs : TZenFSFileSystem);
    procedure mountObject(Mounts : TZenFSMountObject);

    procedure open(path : string; flag : string; CallBack : TNativeIntCallBack);
    procedure open(path : string; flag : string; Mode : NativeInt; CallBack : TNativeIntCallBack);
    procedure open(path : string; flag : string; Mode : String; CallBack : TNativeIntCallBack);
    procedure open(path : string; flag : string; Mode : NativeInt);
    procedure open(path : string; flag : string; Mode : String);
    procedure open(path : string; flag : string);

    function openAsBlob(path : string; options : TZenFSOpenAsBlobOptions): TJSBlob; async;

    function openSync(path : string; flag : string; Mode : NativeInt) : NativeInt;
    function openSync(path : string; flag : string; Mode : String): NativeInt;
    function openSync(path : string; flag : string): NativeInt;

    Procedure opendir(path : string; callback : TZenFSDirCallback); overload;
    Procedure opendir(path : string; options : TZenFSOpenDirOptions; cb : TZenFSDirCallback); overload;
    Function opendirSync(path : string; options : TZenFSOpenDirOptions): TZenFSDir; overload;
    Function opendirSync(path : string): TZenFSDir; overload;

    Procedure read(fd : NativeInt; buffer : TZenFSBuffer; offset : Double; &length : Double; position : jsvalue; callback : TZenFSReadCallback); overload;
    Procedure read(fd : NativeInt; options : TZenFSReadAsyncOptions; callback : TZenFSReadCallback); overload;
    Procedure read(fd : NativeInt; callback : TZenFSReadCallback); overload;

    Procedure readFile(path : String; options : jsvalue; callback : TZenFSreadFileCallback); overload;
    Procedure readFile(path : String; callback : TZenFSreadFileCallback); overload;
    Procedure readFile(path : NativeInt; options : jsvalue; callback : TZenFSreadFileCallback); overload;
    Procedure readFile(path : NativeInt; callback : TZenFSreadFileCallback); overload;
    Function readFileSync(path : String; options : string): TZenFSBuffer; overload;
    Function readFileSync(path : String): TZenFSBuffer; overload;
    Function readFileSync(path : NativeInt; options : string): TZenFSBuffer; overload;
    Function readFileSync(path : NativeInt): TZenFSBuffer; overload;

    Function readSync(fd : NativeInt; buffer : TJSDataView; offset : NativeInt; length : NativeInt; position : NativeInt): NativeInt; overload;
    Function readSync(fd : NativeInt; buffer : TJSDataView; opts : TZenFSReadSyncOptions): NativeInt; overload;
    Function readSync(fd : NativeInt; buffer : TJSDataView): NativeInt; overload;


    Procedure readdir(path : String; options : TZenFSReadDirOptions; callback : TZenFSReadDirCallback); overload;
    Procedure readdir(path : String; callback : TZenFSReadDirCallback); overload;

    Function readdirSync(path : String; options : TZenFSReadDirOptions): TStringDynArray; overload;
    Function readdirSync(path : String): TStringDynArray; overload;
    Function readdirSyncDirent(path : String; options : TZenFSReadDirOptions): TZenFSDirentArray; external name 'readdirSync';


    Procedure readlink(path : String; options : String; callback : TStringCallBack); overload;
    Procedure readlink(path : String; callback : TStringCallBack); overload;
    Function readlinkSync(path : String; options : string): string; overload;
    Function readlinkSync(path : String): string; overload;
    Procedure readv(fd : NativeInt; buffers : array of TJSDataView; cb : TZenFSReadVCallback); overload;
    Procedure readv(fd : NativeInt; buffers : array of TJSDataView; position : NativeInt; cb : TZenFSReadVCallback); overload;

    Function readvSync(fd : NativeInt; buffers : array of TJSDataView; position : NativeInt): NativeInt; overload;
    Function readvSync(fd : NativeInt; buffers : array of TJSDataView): NativeInt; overload;

    Procedure realpath(path : String; options : String; callback : TStringCallback); overload;
    Procedure realpath(path : String; callback : TStringCallback); overload;

    Function realpathSync(path : String; options : string): string; overload;
    Function realpathSync(path : String): string; overload;

    Procedure rename(oldPath : String; newPath : String; callback : TVoidCallback);
    Procedure renameSync(oldPath : String; newPath : String);

    Procedure rm(path : String; callback : TVoidCallback); overload;
    Procedure rm(path : String; options : TZenFSRmOptions; callback : TVoidCallback); overload;
    Procedure rmSync(path : String; options : TZenFSRmOptions); overload;
    Procedure rmSync(path : String); overload;

    Procedure rmdir(path : String; callback : TVoidCallback); overload;
    Procedure rmdir(path : String; options : TZenFSRmDirOptions; callback : TVoidCallback); overload;
    Procedure rmdirSync(path : String; options : TZenFSRmDirOptions); overload;
    Procedure rmdirSync(path : String); overload;

    Procedure stat(path : String; callback : TZenFSStatsCallback); overload;
    Procedure stat(path : String; options : TZenFSStatOptions; callback : TZenFSStatsCallback); overload;
    function statSync(path : String) : TZenFSStats; overload;
    function statSync(path : String; options : TZenFSStatOptions) : TZenFSStats; overload;

    Procedure statfs(path : String; callback : TZenFSStatsFSCallback); overload;
    Procedure statfs(path : String; options : TZenFSStatOptions; callback : TZenFSStatsFSCallback); overload;
    Function statfsSync(path : String): TZenFSStatsFs; overload;
    function statfsSync(path : String; options : TZenFSStatOptions): TZenFSStatsFs; overload;

    Procedure symlink(target : String; path : String; type_ : string; callback : TVoidCallback); overload;
    Procedure symlink(target : String; path : String; callback : TVoidCallback); overload;
    Procedure symlinkSync(target : String; path : String; &type : jsvalue); overload;
    Procedure symlinkSync(target : String; path : String); overload;

    Procedure truncate(path : String; len : NativeInt; callback : TVoidCallback); overload;
    Procedure truncate(path : String; callback : TVoidCallback); overload;
    Procedure truncateSync(path : String; len : NativeInt); overload;
    Procedure truncateSync(path : String); overload;

    procedure umount(MountPount : String);

    Procedure unlink(path : String; callback : TVoidCallback);
    Procedure unlinkSync(path : String);

    Procedure unwatchFile(filename : String; listener : TZenFSStatsListener); overload;
    Procedure unwatchFile(filename : String); overload;

    procedure utimes(path  : String; aTime : NativeInt; mTime : NativeInt; callback : TVoidCallback);
    procedure utimes(path  : String; aTime : TJSDate; mTime : TJSDate; callback : TVoidCallback);
    procedure utimes(path  : String; aTime : NativeInt; mTime : NativeInt);
    procedure utimes(path  : String; aTime : TJSDate; mTime : TJSDate);
    procedure utimesSync(path  : String; aTime : NativeInt; mTime : NativeInt);
    procedure utimesSync(path  : String; aTime : TJSDate; mTime : TJSDate);

    Function watch(filename : String; options : jsvalue; listener : TZenFSWatchListener): TZenFSWatcher; overload;
    Function watch(filename : String; options : jsvalue): TZenFSWatcher; overload;
    Function watch(filename : String): TZenFSWatcher; overload;
    Function watch(filename : String; listener : TZenFSWatchListener): TZenFSWatcher; overload;

    Function watchFile(filename : String; options : TZenFSWatchOptions; listener : TZenFSStatsListener): TZenFSStatWatcher;  overload;
    Function watchFile(filename : String; listener : TZenFSStatsListener): TZenFSStatWatcher; overload;


    Procedure write(fd : NativeInt; buffer : TZenFSBuffer; offset : NativeInt; length : NativeInt; position : NativeInt; callback : TZenFSWriteCallback); overload;
    Procedure write(fd : NativeInt; buffer : TZenFSBuffer; offset : NativeInt; length : NativeInt; callback : TZenFSWriteCallback); overload;
    Procedure write(fd : NativeInt; buffer : TZenFSBuffer; offset : NativeInt; callback : TZenFSWriteCallback); overload;
    Procedure write(fd : NativeInt; buffer : TZenFSBuffer; callback : TZenFSWriteCallback); overload;
    Procedure write(fd : NativeInt; aString : string; position : NativeInt; encoding : string; callback : TZenFSWriteCallback); overload;
    Procedure write(fd : NativeInt; aString : string; position : NativeInt; callback : TZenFSWriteCallback); overload;
    Procedure write(fd : NativeInt; astring : string; callback : TZenFSWriteCallback); overload;

    Procedure writeFile(afile : String; data : string; options : string; callback : TVoidCallback); overload;
    Procedure writeFile(afile : String; data : string; callback : TVoidCallback); overload;
    Procedure writeFile(afile : String; data : TJSDataView; options : string; callback : TVoidCallback); overload;
    Procedure writeFile(afile : String; data : TJSDataView; callback : TVoidCallback); overload;

    Procedure writeFileSync(afile : String; data : string; options : string); overload;
    Procedure writeFileSync(afile : String; data : string); overload;
    Procedure writeFileSync(afile : String; data : TJSDataView; options : string); overload;
    Procedure writeFileSync(afile : String; data : TJSDataView); overload;

    Function writeSync(fd : NativeInt; buffer : TJSDataView; offset : NativeInt; length : NativeInt; position : NativeInt): NativeInt; overload;
    Function writeSync(fd : NativeInt; buffer : TJSDataView; offset : NativeInt; length : NativeInt): NativeInt; overload;
    Function writeSync(fd : NativeInt; buffer : TJSDataView; offset : NativeInt): NativeInt; overload;
    Function writeSync(fd : NativeInt; buffer : TJSDataView): NativeInt; overload;
    Function writeSync(fd : NativeInt; aString : string; position : NativeInt; encoding : String): NativeInt; overload;
    Function writeSync(fd : NativeInt; aString : string): NativeInt; overload;
    Function writeSync(fd : NativeInt; aString : string; position : NativeInt): NativeInt; overload;

    Procedure writev(fd : NativeInt; buffers : array of TJSDataView; cb : TZenFSWriteVCallback); overload;
    Procedure writev(fd : NativeInt; buffers : array of TJSDataView; position : NativeInt; cb : TZenFSWriteVCallback); overload;
    Function writevSync(fd : NativeInt; buffers : array of TJSDataView; position : NativeInt): NativeInt; overload;
    Function writevSync(fd : NativeInt; buffers : array of TJSDataView): NativeInt; overload;

    Property mounts : TJSMap Read FMounts;
  end;

// Using this function is dangerous, it is not part of the API !
function fd2file(fd : Integer) : TZenFSFile; external name 'fd2file';

var
  ZenFS : TZenFS; external name 'ZenFS';

implementation

{ TZenFSDirEnumerator }

constructor TZenFSDirEnumerator.Create(Adir: TZenFSDir);
begin
  FDir:=aDir;
  FCurrent:=Nil;
end;

function TZenFSDirEnumerator.GetCurrent: TZenFSDirent;
begin
  Result:=FCurrent;
end;

function TZenFSDirEnumerator.MoveNext: Boolean;
begin
  FCurrent:=FDir.ReadSync;
  Result:=Assigned(Current);
end;

{ TZenFSDirHelper }

function TZenFSDirHelper.getEnumerator: TZenFSDirEnumerator;
begin
  Result:=TZenFSDirEnumerator.Create(Self);
end;

end.

