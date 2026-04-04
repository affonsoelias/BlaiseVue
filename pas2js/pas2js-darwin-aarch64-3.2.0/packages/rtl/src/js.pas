{
    This file is part of the Pas2JS run time library.
    Copyright (c) 2017-2020 by the Pas2JS development team.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$IFNDEF FPC_DOTTEDUNITS}
unit JS;
{$ENDIF}

{$mode objfpc}
{$modeswitch externalclass}
{$modeswitch typehelpers}

interface

uses
{$IFDEF FPC_DOTTEDUNITS}
  System.Types;
{$ELSE}
  Types;
{$ENDIF}

type
  // We cannot use EConvertError or Exception, this would result in a circular dependency.
  TJSArray = class;
  TJSMap = class;
  TJSBigInt = Class;
  { EJS }

  EJS = class(TObject)
  private
    FMessage: string;
  Public
    constructor Create(const Msg: String); reintroduce;
    property Message : string Read FMessage Write FMessage;
  end;

  TJSObjectPropertyDescriptor = JSValue;
  Float32 = Double;
  Float64 = Double;

  { TJSObject }

  TJSObject = class external name 'Object'
  private
    function GetProperties(Name: String): JSValue; external name '[]';
    procedure SetProperties(Name: String; const AValue: JSValue); external name '[]';
  public
    constructor new;
    class function create(const proto: TJSObject): TJSObject;
    class function create(const proto, propertiesObject: TJSObject): TJSObject;
    class function assign(const Target, Source1: TJSObject): TJSObject; varargs;
    class procedure defineProperty(const obj: TJSObject; propname: String; const descriptor: TJSObjectPropertyDescriptor);
    //class procedure defineProperties
    class function freeze(const obj: TJSObject): TJSObject;
    class function getOwnPropertyDescriptor(const obj: TJSObject; propname: String): TJSObjectPropertyDescriptor;
    //class function getOwnPropertyDescriptors
    class function getOwnPropertyNames(const obj: TJSObject): TStringDynArray;
    class function values(const obj: JSValue): TJSObject;
    {$IFDEF FIREFOX}
    class function getOwnPropertySymbols(const obj: TJSObject): TJSValueDynArray;
    {$ENDIF}
    class function getPrototypeOf(const obj: TJSObject): TJSObject;
    {$IFDEF FIREFOX}
    class function _is(const value1, value2: JSValue): boolean;
    {$ENDIF}
    class function fromEntries(const obj: TJSObject): TJSObject;
    class function fromEntries(const obj: TJSArray): TJSObject;
    class function fromEntries(const obj: TJSMap): TJSObject;
    class function isExtensible(const obj: TJSObject): boolean;
    class function isFrozen(const obj: TJSObject): boolean;
    class function isSealed(const obj: TJSObject): boolean;
    class function keys(const obj: TJSObject): TStringDynArray;
    class function preventExtensions(const obj: TJSObject): TJSObject;
    class function seal(const obj: TJSObject): TJSObject;
    class function setPrototypeOf(const obj, prototype: TJSObject): TJSObject;
    function hasOwnProperty(prop: String): boolean;
    function isPrototypeOf(const obj: TJSObject): boolean;
    function propertyIsEnumerable(propname: String): boolean;
    function toLocaleString: String;
    function toString: String;
    function valueOf: JSValue;
    property Properties[Name: String]: JSValue read GetProperties write SetProperties; default;
  end;
  TJSObjectClass = class of TJSObject;

  TJSObjectDynArray = Array of TJSObject;
  TJSObjectDynArrayArray = Array of TJSObjectDynArray;
  TJSStringDynArray = Array of String;


  { TJSIteratorValue }
  TJSIteratorValue = class external name 'IteratorValue'
  public
    value : JSValue; external name 'value';
    done : boolean; external name 'done';
  end;

  { TJSIterator }
  TJSIterator = class external name 'Iterator'
  Public
    function next: TJSIteratorValue;
  end;


  TJSSet = class;

  TJSSetEventProc = reference to procedure(value : JSValue; key: NativeInt; set_: TJSSet);
  TJSSetProcCallBack = reference  to procedure(value: JSValue; key: JSValue);

  { TJSSet }
  TJSSet = class external name 'Set'
  private
    FSize : NativeInt; external name 'size';
  public
    constructor new; overload;
    constructor new(aElement1 : JSValue); varargs; overload;
    function add(value: JSValue): TJSSet;
    function has(value: JSValue): Boolean;
    function delete(value: JSValue): Boolean;
    procedure clear;
    function values: TJSIterator;
    procedure forEach(const aCallBack: TJSSetEventProc); overload;
    procedure forEach(const aCallBack: TJSSetProcCallBack); overload;
    procedure forEach(const aCallBack: TJSSetEventProc; thisArg: JSValue); overload;
    function entries: TJSIterator;
    function keys: TJSIterator;
    Property size : NativeInt Read FSize;
  end;

  TJSMapFunctionCallBack = reference  to function(arg : JSValue): JSValue;
  TJSMapProcCallBack = reference  to procedure(value: JSValue; key: JSValue);

  { TJSMap }

  TJSMap = class external name 'Map'
  Private
    FSize : NativeInt; external name 'size';
  public
    constructor new; varargs; overload;
    constructor new(aElement1 : JSValue); varargs; overload;
    function &set(key: JSValue; value: JSValue) :TJSMap;
    function get(key : JSValue): JSValue;
    function has(key: JSValue): Boolean;
    function delete(key: JSValue): Boolean;
    procedure clear;
    function entries: TJSIterator;
    procedure forEach(const aCallBack: TJSMapFunctionCallBack); overload;
    procedure forEach(const aCallBack: TJSMapFunctionCallBack; thisArg: JSValue); overload;
    procedure forEach(const aCallBack: TJSMapProcCallBack); overload;
    function keys: TJSIterator;
    function values: TJSIterator;
    property size : NativeInt Read FSize;
  end;

  { TJSFunction }

  TJSFunction = class external name 'Function'(TJSObject)
  private
    Flength: NativeInt external name 'length';
    Fprototyp: TJSFunction external name 'prototyp';
  public
    name: String;
    property prototyp: TJSFunction read Fprototyp;
    property length: NativeInt read Flength;
    function apply(thisArg: TJSObject; const ArgArray: TJSValueDynArray): JSValue; varargs;
    function bind(thisArg: TJSObject): JSValue; varargs;
    function call(thisArg: TJSObject): JSValue; varargs;
  end;

  { TJSDate - wrapper for JavaScript Date }

  TJSDate = class external name 'Date'(TJSFunction)
  private
    function getDate: NativeInt;
    function getFullYear: NativeInt;
    function getHours: NativeInt;
    function getMilliseconds: NativeInt;
    function getMinutes: NativeInt;
    function getMonth: NativeInt;
    function getSeconds: NativeInt;
    function getYear: NativeInt;
    function getTime: NativeInt;
    function getUTCDate: NativeInt;
    function getUTCFullYear: NativeInt;
    function getUTCHours: NativeInt;
    function getUTCMilliseconds: NativeInt;
    function getUTCMinutes: NativeInt;
    function getUTCMonth: NativeInt;
    function getUTCSeconds: NativeInt;
    procedure setDate(const AValue: NativeInt);
    procedure setFullYear(const AValue: NativeInt);
    procedure setHours(const AValue: NativeInt);
    procedure setMilliseconds(const AValue: NativeInt);
    procedure setMinutes(const AValue: NativeInt);
    procedure setMonth(const AValue: NativeInt);
    procedure setSeconds(const AValue: NativeInt);
    procedure setYear(const AValue: NativeInt);
    procedure setTime(const AValue: NativeInt);
    procedure setUTCDate(const AValue: NativeInt);
    procedure setUTCFullYear(const AValue: NativeInt);
    procedure setUTCHours(const AValue: NativeInt);
    procedure setUTCMilliseconds(const AValue: NativeInt);
    procedure setUTCMinutes(const AValue: NativeInt);
    procedure setUTCMonth(const AValue: NativeInt);
    procedure setUTCSeconds(const AValue: NativeInt);
  public
    constructor New; reintroduce;
    constructor New(const MilliSecsSince1970: NativeInt); // milliseconds since 1 January 1970 00:00:00 UTC, with leap seconds ignored
    constructor New(const aDateString: String); // RFC 2822, ISO8601
    constructor New(aYear: NativeInt; aMonth: NativeInt; aDayOfMonth: NativeInt = 1;
      TheHours: NativeInt = 0; TheMinutes: NativeInt = 0; TheSeconds: NativeInt = 0;
      TheMilliseconds: NativeInt = 0);
    class function now: NativeInt; // current date and time in milliseconds since 1 January 1970 00:00:00 UTC, with leap seconds ignored
    class function parse(const aDateString: string): NativeInt; // format depends on browser
    class function UTC(aYear: NativeInt; aMonth: NativeInt = 0; aDayOfMonth: NativeInt = 1;
      TheHours: NativeInt = 0; TheMinutes: NativeInt = 0; TheSeconds: NativeInt = 0;
      TheMilliseconds: NativeInt = 0): NativeInt;
    function getDay: NativeInt;
    function getTimezoneOffset: NativeInt;
    function getUTCDay: NativeInt; // day of the week
    function toDateString: string; // human readable date, without time
    function toISOString: string; // ISO 8601 Extended Format
    function toJSON: string;
    function toGMTString: string; // in GMT timezone
    function toLocaleDateString: string; overload; // date in locale timezone, no time
    function toLocaleDateString(const aLocale : string) : string; overload; // date in locale timezone, no time
    function toLocaleDateString(const aLocale : string; aOptions : TJSObject) : string; overload; // date in locale timezone, no time
    function toLocaleString: string; reintroduce; // date and time in locale timezone
    function toLocaleTimeString: string; // time in locale timezone, no date
    function toTimeString: string; // time human readable, no date
    function toUTCString: string; // date and time using UTC timezone
    property Year: NativeInt read getYear write setYear;
    property Time: NativeInt read getTime write setTime; // milliseconds since 1 January 1970 00:00:00 UTC, with leap seconds ignored
    property FullYear: NativeInt read getFullYear write setFullYear;
    property UTCDate: NativeInt read getUTCDate write setUTCDate; // day of month
    property UTCFullYear: NativeInt read getUTCFullYear write setUTCFullYear;
    property UTCHours: NativeInt read getUTCHours write setUTCHours;
    property UTCMilliseconds: NativeInt read getUTCMilliseconds write setUTCMilliseconds;
    property UTCMinutes: NativeInt read getUTCMinutes write setUTCMinutes;
    property UTCMonth: NativeInt read getUTCMonth write setUTCMonth;
    property UTCSeconds: NativeInt read getUTCSeconds write setUTCSeconds;
    property Month: NativeInt read getMonth write setMonth;
    property Date: NativeInt read getDate write setDate; // day of the month, starting at 1
    property Hours: NativeInt read getHours write setHours;
    property Minutes: NativeInt read getMinutes write setMinutes;
    property Seconds: NativeInt read getSeconds write setSeconds;
    property Milliseconds: NativeInt read getMilliseconds write setMilliseconds;
  end;

  { TJSSymbol }

  TJSSymbol = class external name 'Symbol' (TJSFunction)
  private
  Private
    FDescription: String; external name 'description';
  Public
    constructor new (aValue : JSValue);
    class function for_ (key : string) : TJSSymbol;
    class function keyFor (aSymbol : TJSSymbol) : string;
    property Description : String Read FDescription;
  end;

  TLocaleCompareOptions = record
    localematched : string;
    usage: string;
    sensitivity : string;
    ignorePunctuation : Boolean;
    numeric : boolean;
    caseFirst : string;
  end;

  TJSRegexp = class external name 'RegExp'
  private
    FDotAll : boolean; external name 'dotall';
    FFlags : string; external name 'flags';
    FSticky : boolean; external name 'sticky';
    fglobal: boolean; external name 'global';
    fhasIndices: boolean; external name 'hasIndices';
    fignoreCase : boolean; external name 'ignoreCase';
    fmultiline : boolean; external name 'multiline';
    fsource : string; external name 'source';
    funicode : boolean; external name 'unicode';
    funicodeSets : boolean; external name 'unicodeSets';
  public
    Constructor New(Pattern : string);
    Constructor New(Pattern, Flags : string);
    lastIndex: NativeInt;
    function exec(aString : string): TStringDynArray;
    function execFull(aString : string): TJSObject; external name 'exec';
    function test(aString : string) : boolean;
    function toString : String;
    property dotAll : Boolean Read FDotAll;
    property Global : boolean read fglobal;
    property IgnoreCase : Boolean read FIgnoreCase;
    property Multiline : Boolean Read FMultiLine;
    Property Source : string Read FSource;
    Property Unicode : boolean Read FUnicode;
    Property UnicodeSets : boolean Read FUnicodeSets;
    Property HasIndices : Boolean Read FHasIndices;
    property Flags : string read FFlags;
    property Sticky : boolean read FSticky;
  end;


  TReplaceCallBack = reference to Function (Const match : string) : string; varargs;
  TReplaceCallBack0 = reference to Function (Const match : string; offset : Integer; AString : String) : string;
  TReplaceCallBack1 = reference to Function (Const match,p1 : string; offset : Integer; AString : String) : string;
  TReplaceCallBack2 = reference to Function (Const match,p1,p2 : string; offset : Integer; AString : String) : string;

  TJSString = class external name 'String'
  private
    flength : NativeInt; external name 'length';
  public 
    constructor New(Const S : String);
    constructor New(Const I : NativeInt);
    constructor New(Const D : double);
    property length : NativeInt read flength; 
    class function fromCharCode() : string; varargs;
    class function fromCodePoint() : string; varargs;
    function anchor(const aName : string) : string; deprecated;
    function at(const index: Integer): String;
    function charAt(aIndex : NativeInt) : string;
    function charCodeAt(aIndex : NativeInt) : NativeInt;
    function codePointAt(aIndex : NativeInt) : NativeInt;
    function concat(s : string) : string; varargs;
    function endsWith(aSearchString : string) : boolean; overload;
    function endsWith(aSearchString : string; Pos : NativeInt) : boolean; overload;
    function includes(aSearchString : string; Pos : NativeInt = 0) : boolean;
    function indexOf(aSearchString : String; Pos : NativeInt = 0) : Integer;
    function isWellFormed: Boolean;
    function lastIndexOf(aSearchString : String) : NativeInt;overload;
    function lastIndexOf(aSearchString : String; Pos : NativeInt) : Integer;overload;
    function link(aUrl : string) : String; deprecated;
    function localeCompare(aCompareString : string) : NativeInt; overload;
    function localeCompare(aCompareString : string; aLocales: string) : integer; overload;
    function localeCompare(compareString : string; locales: string; Options : TlocaleCompareOptions) : integer; overload;
    function match(aRegexp : TJSRegexp) : TStringDynArray; overload;
    function match(aRegexp : String) : TStringDynArray; overload;
    function matchAll(aRegexp : TJSRegexp) : TJSIterator; overload;
    function matchAll(aRegexp : String) : TJSIterator; overload;
    {$IFDEF ECMAScript6}
    function normalize : string;
    function normalize(aForm : string) : string;
    {$ENDIF}
    function padEnd(targetLength: Integer): String; overload;
    function padEnd(targetLength: Integer; padString: String): String; overload;
    function padStart(targetLength: Integer): String; overload;
    function padStart(targetLength: Integer; padString: String): String; overload;
    function _repeat(aCount : NativeInt) : Integer; external name 'repeat';
    function replace(aRegexp : String; NewString : String) : String; overload;
    function replace(aRegexp : TJSRegexp; NewString : String) : String; overload;
    function replace(Regexp : String; aCallback : TReplaceCallBack) : String; overload;
    function replace(Regexp : TJSRegexp; aCallback : TReplaceCallBack) : String; overload;
    function replace(Regexp : String; aCallback : TReplaceCallBack0) : String; overload;
    function replace(Regexp : TJSRegexp; aCallback : TReplaceCallBack0) : String; overload;
    function replace(Regexp : String; aCallback : TReplaceCallBack1) : String; overload;
    function replace(Regexp : TJSRegexp; aCallback : TReplaceCallBack1) : String; overload;
    function replace(Regexp : String; aCallback : TReplaceCallBack2) : String; overload;
    function replace(Regexp : TJSRegexp; aCallback : TReplaceCallBack2) : String; overload;
    function replaceAll(aRegexp : String; NewString : String) : String; overload;
    function replaceAll(aRegexp : TJSRegexp; NewString : String) : String; overload;
    function replaceAll(Regexp : String; aCallback : TReplaceCallBack) : String; overload;
    function replaceAll(Regexp : TJSRegexp; aCallback : TReplaceCallBack) : String; overload;
    function replaceAll(Regexp : String; aCallback : TReplaceCallBack0) : String; overload;
    function replaceAll(Regexp : TJSRegexp; aCallback : TReplaceCallBack0) : String; overload;
    function replaceAll(Regexp : String; aCallback : TReplaceCallBack1) : String; overload;
    function replaceAll(Regexp : TJSRegexp; aCallback : TReplaceCallBack1) : String; overload;
    function replaceAll(Regexp : String; aCallback : TReplaceCallBack2) : String; overload;
    function replaceAll(Regexp : TJSRegexp; aCallback : TReplaceCallBack2) : String; overload;
    function search(Regexp : TJSRegexp) : NativeInt; overload;
    function search(Regexp : JSValue) : NativeInt; overload;
    function slice(aBeginIndex : NativeInt) : String; overload;
    function slice(aBeginIndex, aEndIndex : NativeInt) : String; overload;
    function split : TStringDynArray; overload;
    function split(aRegexp : TJSRegexp) : TStringDynArray; overload;
    function split(aSeparator : string) : TStringDynArray; overload;
    function split(aSeparator : string; aLimit : NativeInt) : TStringDynArray; overload;
    function split(aSeparator : array of string) : TStringDynArray; overload;
    function split(aSeparator : array of string; aLimit : NativeInt) : TStringDynArray; overload;
    function startsWith(aSearchString : String) : Boolean; overload;
    function startsWith(aSearchString : String; aPosition : NativeInt) : Boolean; overload;
    function substr(aStartIndex : NativeInt) : String; overload; deprecated;
    function substr(aStartIndex,aLength : NativeInt) : String; overload; deprecated;
    function substring(aStartIndex : NativeInt) : String; overload;
    function substring(aStartIndex,aEndIndex : NativeInt) : String; overload;
    function toLocaleLowerCase : String;
    function toLocaleUpperCase : String;
    function toLowerCase : String;
    function toString : string;
    function toUpperCase : String;
    function toWellFormed: String;
    function trim : string;
    function trimEnd: String;
    function trimStart: String;
    function valueOf : string;
  end;

  
  TJSArrayEventProc = reference to procedure(element : JSValue; index: NativeInt; anArray : TJSArray);
  TJSArrayEvent = reference to function (element : JSValue; index: NativeInt; anArray : TJSArray) : Boolean;
  TJSArrayMapEvent = reference to function (element : JSValue; index: NativeInt; anArray : TJSArray) : JSValue;
  TJSArrayReduceEvent = reference to function (accumulator, currentValue : JSValue; currentIndex : NativeInt; anArray : TJSArray) : JSValue;
  TJSArrayCompareEvent = reference to function (a,b : JSValue) : NativeInt;
  TJSArrayCallback = TJSArrayEvent;
  TJSArrayMapCallback = TJSArrayMapEvent;
  TJSArrayReduceCallBack = TJSArrayReduceEvent;
  TJSArrayCompareCallBack = TJSArrayCompareEvent;

  { TJSArray }

  TJSArray = Class external name 'Array'
  private
    function GetElements(Index: NativeInt): JSValue; external name '[]';
    procedure SetElements(Index: NativeInt; const AValue: JSValue); external name '[]';
  public
    FLength : NativeInt; external name 'length';
    constructor new; overload;
    constructor new(aLength : NativeInt); overload;
    constructor new(aElement1 : JSValue); varargs; overload;
    class function _of() : TJSArray; varargs; external name 'of'; 
    class function isArray(a: JSValue) : Boolean;
    class function from(a : JSValue) : TJSArray;
    class function from(arrayLike : JSValue; mapFunction : TJSMapFunctionCallBack): TJSArray; overload;
    class function from(arrayLike : JSValue; mapFunction : TJSMapFunctionCallBack; thisArg : JSValue): TJSArray; overload;

    function concat(el : JSValue) : TJSArray; varargs;
    function copyWithin(aTarget : NativeInt) : TJSArray;overload; // not in IE
    function copyWithin(aTarget, aStart : NativeInt) : TJSArray;overload; // not in IE
    function copyWithin(aTarget, aStart, aEnd : NativeInt) : TJSArray;overload; // not in IE
    function entries: TJSIterator;
    Function every(const aCallback : TJSArrayCallBack) : boolean;overload;
    Function every(const aCallback : TJSArrayEvent; aThis : TObject) : boolean;overload;
    Function filter(const aCallBack : TJSArrayCallBack) : TJSArray; overload;
    Function filter(const aCallBack : TJSArrayEvent; aThis : TObject) : TJSArray;overload;
    Function fill(aValue : JSValue) : TJSArray; overload;
    Function fill(aValue : JSValue; aStartIndex : NativeInt) : TJSArray; overload;
    Function fill(aValue : JSValue; aStartIndex,aEndIndex : NativeInt) : TJSArray; overload;
    Function find(const aCallBack : TJSArrayCallBack) : JSValue; overload;
    Function find(const aCallBack : TJSArrayEvent; aThis : TObject) : JSValue; overload;
    Function findIndex(const aCallBack : TJSArrayCallBack) : NativeInt; overload;
    Function findIndex(const aCallBack : TJSArrayEvent; aThis : TObject) : NativeInt; overload;
    procedure forEach(const aCallBack : TJSArrayEventProc); overload;
    procedure forEach(const aCallBack : TJSArrayEvent); overload;
    procedure forEach(const aCallBack : TJSArrayEvent; aThis : TObject); overload;
    function includes(aElement : JSValue) : Boolean; overload;
    function includes(aElement : JSValue; FromIndex : NativeInt) : Boolean; overload;
    function indexOf(aElement : JSValue) : NativeInt; overload;
    function indexOf(aElement : JSValue; FromIndex : NativeInt) : NativeInt; overload;
    function join : String; overload;
    function join (aSeparator : string) : String; overload;
    function keys: TJSIterator;
    function lastIndexOf(aElement : JSValue) : NativeInt; overload;
    function lastIndexOf(aElement : JSValue; FromIndex : NativeInt) : NativeInt; overload;
//    Function map(const aCallBack : TJSArrayMapEventArray) : JSValue; overload;
    Function map(const aCallBack : TJSArrayMapCallBack) : TJSArray; overload;
    Function map(const aCallBack : TJSArrayMapEvent; aThis : TObject) : TJSArray; overload;
    function pop : JSValue; 
    function push(aElement : JSValue) : NativeInt; varargs;
    function reduce(const aCallBack : TJSArrayReduceCallBack) : JSValue; overload;
    function reduce(const aCallBack : TJSArrayReduceCallBack; initialValue : JSValue) : JSValue; overload;
    function reduceRight(const aCallBack : TJSArrayReduceCallBack) : JSValue; overload;
    function reduceRight(const aCallBack : TJSArrayReduceCallBack; initialValue : JSValue) : JSValue; overload;
    Function reverse : TJSArray;
    Function shift : JSValue;
    Function slice : TJSArray; overload;
    function slice(aBegin : NativeInt) : TJSArray; overload;
    function slice(aBegin,aEnd : NativeInt) : TJSArray; overload;
    Function some(const aCallback : TJSArrayCallBack) : boolean; overload;
    Function some(const aCallback : TJSArrayEvent; aThis : TObject) : boolean; overload;
    Function sort(const aCallback : TJSArrayCompareCallBack) : TJSArray; overload;
    Function sort() : TJSArray; overload;
    function splice(aStart : NativeInt) : TJSArray; overload;
    function splice(aStart,aDeleteCount : NativeInt) : TJSArray; varargs; overload;
    function toLocaleString: String; overload;
    function toLocaleString(locales : string) : String; overload;
    function toLocaleString(locales : string; const Options : TLocaleCompareOptions) : String; overload;
    function toString : String;
    function unshift : NativeInt; varargs;
    function values: TJSIterator;
    Property Length : NativeInt Read FLength Write FLength;
    property Elements[Index: NativeInt]: JSValue read GetElements write SetElements; default;
  end;

  TJSAbstractArrayBuffer = Class external name 'Object' (TJSObject)
  private
    fLength : NativeInt; external name 'byteLength';
    fmaxByteLength: NativeInt; external name 'maxByteLength';
  Public
    constructor new(aByteLength : NativeInt);
    Property byteLength : NativeInt Read fLength;
    property maxByteLength : NativeInt Read fmaxByteLength;
  end;

  { TJSArrayBuffer }

  TJSArrayBuffer = Class external name 'ArrayBuffer' (TJSAbstractArrayBuffer)
  private
    fResizable: Boolean; external name 'resizable';
  public
    class function isView(aValue : JSValue) : Boolean;
    function slice(aBegin : NativeInt) : TJSArrayBuffer; overload;
    function slice(aBegin,aEnd : NativeInt) : TJSArrayBuffer; overload;
    property resizable : Boolean Read fResizable;
  end;

  TJSSharedArrayBuffer = Class external name 'SharedArrayBuffer' (TJSAbstractArrayBuffer)
  private
    fGrowable : boolean; external name 'growable';
  public
    procedure grow(aNewLength : nativeInt);
    function slice(aBegin : NativeInt) : TJSSharedArrayBuffer; overload;
    function slice(aBegin,aEnd : NativeInt) : TJSSharedArrayBuffer; overload;
    property growable : Boolean Read fGrowable;
  end;


  TJSBufferSource = class external name 'BufferSource' (TJSObject)
  end;

  { TJSTypedArray }
  TJSTypedArray = Class;

  TJSTypedArrayCallBack = reference to function (element : JSValue; index: NativeInt; anArray : TJSTypedArray) : Boolean;
  TJSTypedArrayEvent = TJSTypedArrayCallBack; // function (element : JSValue; index: NativeInt; anArray : TJSTypedArray) : Boolean of object;
  TJSTypedArrayMapCallBack = reference to function (element : JSValue; index: NativeInt; anArray : TJSTypedArray) : JSValue;
  TJSTypedArrayMapEvent = TJSTypedArrayMapCallBack; // reference to function (element : JSValue; index: NativeInt; anArray : TJSTypedArray) : JSValue of object;
  TJSTypedArrayReduceCallBack = reference to function (accumulator, currentValue : JSValue; currentIndex : NativeInt; anArray : TJSTypedArray) : JSValue;
  TJSTypedArrayCompareCallBack = reference to function (a,b : JSValue) : NativeInt;

  TJSTypedArray = class external name 'TypedArray' (TJSBufferSource)
  Private
    FBuffer: TJSArrayBuffer; external name 'buffer';
    FBufferObj: TJSAbstractArrayBuffer; external name 'buffer';
    FByteLength: NativeInt; external name 'byteLength';
    FLength: NativeInt; external name 'length';
    FByteOffset: NativeInt; external name 'byteOffset';
    FBytesPerElement : NativeInt; external name 'BYTES_PER_ELEMENT';
    function getValue(Index : NativeInt) : JSValue; external name '[]';
    procedure setValue(Index : NativeInt;AValue : JSValue); external name '[]';
  Public
    property BYTES_PER_ELEMENT : NativeInt Read FBytesPerElement;
    class var name : string;
//    class function from(aValue : jsValue) : TJSTypedArray;
//    class function from(aValue : jsValue; Map : TJSTypedArrayMapCallBack) : TJSTypedArray;
//    class function from(aValue : jsValue; aMap : TJSTypedArrayMapEvent) : TJSTypedArray;
    class function _of(aValue : jsValue) : TJSTypedArray; varargs; external name 'of';
    function copyWithin(aTarget : NativeInt) : TJSTypedArray;overload;
    function copyWithin(aTarget, aStart : NativeInt) : TJSTypedArray;overload;
    function copyWithin(aTarget, aStart, aEnd : NativeInt) : TJSTypedArray;overload;
    Function every(const aCallback : TJSTypedArrayCallBack) : boolean;overload;
    Function every(const aCallback : TJSTypedArrayEvent; aThis : TObject) : boolean;overload;
    Function fill(aValue : JSValue) : TJSTypedArray; overload;
    Function fill(aValue : JSValue; aStartIndex : NativeInt) : TJSTypedArray; overload;
    Function fill(aValue : JSValue; aStartIndex,aEndIndex : NativeInt) : TJSTypedArray; overload;
    Function filter(const aCallBack : TJSTypedArrayCallBack) : TJSTypedArray; overload;
    Function filter(const aCallBack : TJSTypedArrayEvent; aThis : TObject) : TJSTypedArray;overload;
    Function find(const aCallBack : TJSTypedArrayCallBack) : JSValue; overload;
    Function find(const aCallBack : TJSTypedArrayEvent; aThis : TObject) : JSValue; overload;
    Function findIndex(const aCallBack : TJSTypedArrayCallBack) : NativeInt; overload;
    Function findIndex(const aCallBack : TJSTypedArrayEvent; aThis : TObject) : NativeInt; overload;
    procedure forEach(const aCallBack : TJSTypedArrayCallBack); overload;
    procedure forEach(const aCallBack : TJSTypedArrayEvent; aThis : TObject); overload;
    function includes(aElement : JSValue) : Boolean; overload;
    function includes(aElement : JSValue; FromIndex : NativeInt) : Boolean; overload;
    function indexOf(aElement : JSValue) : NativeInt; overload;
    function indexOf(aElement : JSValue; FromIndex : NativeInt) : NativeInt; overload;
    function join : String; overload;
    function join (aSeparator : string) : String; overload;
    function lastIndexOf(aElement : JSValue) : NativeInt; overload;
    function lastIndexOf(aElement : JSValue; FromIndex : NativeInt) : NativeInt; overload;
    Function map(const aCallBack : TJSTypedArrayCallBack) : TJSTypedArray; overload;
    Function map(const aCallBack : TJSTypedArrayEvent; aThis : TObject) : TJSTypedArray; overload;
    function reduce(const aCallBack : TJSTypedArrayReduceCallBack) : JSValue; overload;
    function reduce(const aCallBack : TJSTypedArrayReduceCallBack; initialValue : JSValue) : JSValue; overload;
    function reduceRight(const aCallBack : TJSTypedArrayReduceCallBack) : JSValue; overload;
    function reduceRight(const aCallBack : TJSTypedArrayReduceCallBack; initialValue : JSValue) : JSValue; overload;
    Function reverse : TJSTypedArray;
    procedure _set(anArray : TJSArray); external name 'set';
    procedure _set(anArray : TJSArray; anOffset : NativeInt); external name 'set';
    procedure _set(anArray : TJSTypedArray); external name 'set';
    procedure _set(anArray : TJSTypedArray; anOffset : NativeInt); external name 'set';
    Function slice : TJSTypedArray; overload;
    function slice(aBegin : NativeInt) : TJSTypedArray; overload;
    function slice(aBegin,aEnd : NativeInt) : TJSTypedArray; overload;
    Function some(const aCallback : TJSTypedArrayCallBack) : boolean; overload;
    Function some(const aCallback : TJSTypedArrayEvent; aThis : TObject) : boolean; overload;
    Function sort(const aCallback : TJSTypedArrayCompareCallBack) : TJSTypedArray; overload;
    Function sort() : TJSTypedArray; overload;
    function splice(aStart : NativeInt) : TJSTypedArray; overload;
    function splice(aStart,aDeleteCount : NativeInt) : TJSTypedArray; varargs; overload;
    function toLocaleString: String; overload;
    function toLocaleString(locales : string) : String; overload;
    function toLocaleString(locales : string; const Options : TLocaleCompareOptions) : String; overload;
    function unshift : NativeInt; varargs;
    property buffer : TJSArrayBuffer read FBuffer;
    property bufferObj : TJSAbstractArrayBuffer read FBufferObj;
    property byteLength : NativeInt Read FByteLength;
    property byteOffset : NativeInt Read FByteOffset;
    property length : NativeInt Read FLength;
    property values[Index : NativeInt] : JSValue Read getValue Write SetValue; default;
  end;
  TJSTypedArrayClass = Class of TJSTypedArray;

  { TJSInt8Array }

  TJSInt8Array = class external name 'Int8Array' (TJSTypedArray)
  private
    function getTypedValue(Index : NativeInt): Shortint; external name '[]';
    procedure setTypedValue(Index : NativeInt; AValue: Shortint);external name '[]';
  public
{$IFDEF JAVASCRIPT2017}
    constructor new; // new in ES2017
{$ENDIF}
    constructor new (length : NativeInt);
    constructor new (atypedArray : TJSTypedArray);
    constructor new (aObject : TJSObject);
    constructor new (buffer : TJSAbstractArrayBuffer);
    constructor new (buffer : TJSAbstractArrayBuffer; aByteOffset: NativeInt);
    constructor new (buffer : TJSAbstractArrayBuffer; aByteOffset, aElementLength: NativeInt);
    class function from(aValue : jsValue) : TJSInt8Array; reintroduce;
    class function from(aValue : jsValue; Map : TJSTypedArrayMapCallBack) : TJSInt8Array; reintroduce;
//    class function from(aValue : jsValue; aMap : TJSTypedArrayMapEvent) : TJSInt8Array; reintroduce;
    class function _of(aValue : jsValue) : TJSInt8Array; varargs; external name 'of'; reintroduce;overload;
    class function _of(aValue : TJSValueDynArray) : TJSInt8Array; varargs; external name 'of'; reintroduce; overload;
    function subarray(aBegin, aEnd: Integer): TJSInt8Array;  overload;
    function subarray(aBegin: Integer): TJSInt8Array; overload;
    function toBase64: String;
    function toBase64(options: TJSObject): String;
    procedure _set(anArray : Array of ShortInt); external name 'set'; reintroduce; overload;
    procedure _set(anArray : Array of ShortInt; anOffset : NativeInt); external name 'set';
    property values[Index : NativeInt] : Shortint Read getTypedValue Write setTypedValue; default;
  end;

  TJSUint8Array  = class external name 'Uint8Array' (TJSTypedArray)
  private
    function getTypedValue(Index : NativeInt): Byte; external name '[]';
    procedure setTypedValue(Index : NativeInt; AValue: Byte);external name '[]';
  public
    constructor new (length : NativeInt);
    constructor new (atypedArray : TJSTypedArray);
    constructor new (aObject : TJSObject);
    constructor new (buffer : TJSAbstractArrayBuffer);
    constructor new (buffer : TJSAbstractArrayBuffer; aByteOffset: NativeInt);
    constructor new (buffer : TJSAbstractArrayBuffer; aByteOffset, aElementLength: NativeInt);
    class function from(aValue : jsValue) : TJSUInt8Array; reintroduce; overload;
    class function from(aValue : jsValue; Map : TJSTypedArrayMapCallBack) : TJSUInt8Array; reintroduce;overload;
    // class function from(aValue : jsValue; aMap : TJSTypedArrayMapEvent) : TJSUInt8Array; reintroduce;overload;
    class function _of(aValue : jsValue) : TJSUInt8Array; varargs; external name 'of'; reintroduce; overload;
    function subarray(aBegin, aEnd: Integer): TJSUInt8Array;  overload;
    function subarray(aBegin: Integer): TJSUInt8Array; overload;
    procedure _set(anArray : Array of Byte); external name 'set'; reintroduce; overload;
    procedure _set(anArray : Array of Byte; anOffset : NativeInt); external name 'set'; overload;
    Property values[Index : NativeInt] : Byte Read getTypedValue Write setTypedValue; default;
  end;

  TJSUint8ClampedArray  = class external name 'Uint8ClampedArray' (TJSTypedArray)
  private
    function getTypedValue(Index : NativeInt): Byte; external name '[]';
    procedure setTypedValue(Index : NativeInt; AValue: Byte);external name '[]';
  public
    constructor new (length : NativeInt);
    constructor new (atypedArray : TJSTypedArray);
    constructor new (aObject : TJSObject);
    constructor new (buffer : TJSAbstractArrayBuffer);
    constructor new (buffer : TJSAbstractArrayBuffer; aByteOffset: NativeInt);
    constructor new (buffer : TJSAbstractArrayBuffer; aByteOffset, aElementLength: NativeInt);
    class function from(aValue : jsValue) : TJSUInt8ClampedArray; reintroduce;
    class function from(aValue : jsValue; Map : TJSTypedArrayMapCallBack) : TJSUInt8ClampedArray; reintroduce;overload;
//    class function from(aValue : jsValue; aMap : TJSTypedArrayMapEvent) : TJSUInt8ClampedArray; reintroduce;overload;
    class function _of(aValue : jsValue) : TJSUInt8ClampedArray; varargs; external name 'of'; reintroduce;
    procedure _set(anArray : Array of Byte); external name 'set'; reintroduce;overload;
    procedure _set(anArray : Array of Byte; anOffset : NativeInt); external name 'set';overload;
    function subarray(aBegin, aEnd: Integer): TJSUInt8ClampedArray;  overload;
    function subarray(aBegin: Integer): TJSUInt8ClampedArray; overload;
    Property values[Index : NativeInt] : Byte Read getTypedValue Write setTypedValue; default;
  end;

  TJSInt16Array = class external name 'Int16Array' (TJSTypedArray)
  private
    function getTypedValue(Index : NativeInt): smallint; external name '[]';
    procedure setTypedValue(Index : NativeInt; AValue: Smallint);external name '[]';
  public
    constructor new (length : NativeInt);
    constructor new (atypedArray : TJSTypedArray);
    constructor new (aObject : TJSObject);
    constructor new (buffer : TJSAbstractArrayBuffer);
    constructor new (buffer : TJSAbstractArrayBuffer; aByteOffset: NativeInt);
    constructor new (buffer : TJSAbstractArrayBuffer; aByteOffset, aElementLength: NativeInt);
    class function from(aValue : jsValue) : TJSInt16Array; reintroduce;
    class function from(aValue : jsValue; Map : TJSTypedArrayMapCallBack) : TJSInt16Array; reintroduce;overload;
//    class function from(aValue : jsValue; aMap : TJSTypedArrayMapEvent) : TJSInt16Array; reintroduce;overload;
    class function _of(aValue : jsValue) : TJSInt16Array; varargs; external name 'of'; reintroduce;overload;
    procedure _set(anArray : Array of SmallInt); external name 'set'; reintroduce;overload;
    procedure _set(anArray : Array of SmallInt; anOffset : NativeInt); external name 'set';overload;
    function subarray(aBegin, aEnd: Integer): TJSInt16Array;  overload;
    function subarray(aBegin: Integer): TJSInt16Array; overload;
    Property values[Index : NativeInt] : SmallInt Read getTypedValue Write setTypedValue; default;
  end;

  TJSUint16Array = class external name 'Uint16Array' (TJSTypedArray)
  private
    function getTypedValue(Index : NativeInt): Word; external name '[]';
    procedure setTypedValue(Index : NativeInt; AValue: Word);external name '[]';
  public
    constructor new (length : NativeInt);
    constructor new (atypedArray : TJSTypedArray);
    constructor new (aObject : TJSObject);
    constructor new (buffer : TJSAbstractArrayBuffer);
    constructor new (buffer : TJSAbstractArrayBuffer; aByteOffset: NativeInt);
    constructor new (buffer : TJSAbstractArrayBuffer; aByteOffset, aElementLength: NativeInt);
    class function from(aValue : jsValue) : TJSUInt16Array; reintroduce;
    class function from(aValue : jsValue; Map : TJSTypedArrayMapCallBack) : TJSUInt16Array; reintroduce;
//    class function from(aValue : jsValue; aMap : TJSTypedArrayMapEvent) : TJSUInt16Array; reintroduce;
    class function _of(aValue : jsValue) : TJSUInt16Array; varargs; external name 'of'; reintroduce;
    procedure _set(anArray : Array of Word); external name 'set'; reintroduce; overload;
    procedure _set(anArray : Array of Word; anOffset : NativeInt); external name 'set'; overload;
    function subarray(aBegin, aEnd: Integer): TJSUInt16Array;  overload;
    function subarray(aBegin: Integer): TJSUInt16Array; overload;
    Property values[Index : NativeInt] : Word Read getTypedValue Write setTypedValue; default;
  end;

  TJSInt32Array = class external name 'Int32Array' (TJSTypedArray)
  private
    function getTypedValue(Index : NativeInt): longint; external name '[]';
    procedure setTypedValue(Index : NativeInt; AValue: longint);external name '[]';
  public
    constructor new (length : NativeInt);
    constructor new (atypedArray : TJSTypedArray);
    constructor new (aObject : TJSObject);
    constructor new (buffer : TJSAbstractArrayBuffer);
    constructor new (buffer : TJSAbstractArrayBuffer; aByteOffset: NativeInt);
    constructor new (buffer : TJSAbstractArrayBuffer; aByteOffset, aElementLength: NativeInt);
    class function from(aValue : jsValue) : TJSInt32Array; reintroduce;
    class function from(aValue : jsValue; Map : TJSTypedArrayMapCallBack) : TJSInt32Array; reintroduce;
//    class function from(aValue : jsValue; aMap : TJSTypedArrayMapEvent) : TJSInt32Array; reintroduce;
    class function _of(aValue : jsValue) : TJSInt32Array; varargs;external name 'of'; reintroduce;
    procedure _set(anArray : Array of LongInt); external name 'set'; reintroduce; overload;
    procedure _set(anArray : Array of LongInt; anOffset : NativeInt); external name 'set'; overload;
    function subarray(aBegin, aEnd: Integer): TJSInt32Array;  overload;
    function subarray(aBegin: Integer): TJSInt32Array; overload;
    Property values[Index : NativeInt] : longint Read getTypedValue Write setTypedValue; default;
  end;

  TJSUint32Array = class external name 'Uint32Array' (TJSTypedArray)
  private
    function getTypedValue(Index : NativeInt): LongWord; external name '[]';
    procedure setTypedValue(Index : NativeInt; AValue: LongWord);external name '[]';
  public
    constructor new (length : NativeInt);
    constructor new (atypedArray : TJSTypedArray);
    constructor new (aObject : TJSObject);
    constructor new (buffer : TJSAbstractArrayBuffer);
    constructor new (buffer : TJSAbstractArrayBuffer; aByteOffset: NativeInt);
    constructor new (buffer : TJSAbstractArrayBuffer; aByteOffset, aElementLength: NativeInt);
    class function from(aValue : jsValue) : TJSUInt32Array; reintroduce;
    class function from(aValue : jsValue; Map : TJSTypedArrayMapCallBack) : TJSUInt32Array; reintroduce;
//    class function from(aValue : jsValue; aMap : TJSTypedArrayMapEvent) : TJSUInt32Array; reintroduce;
    class function _of(aValue : jsValue) : TJSUInt32Array; varargs; external name 'of'; reintroduce;
    procedure _set(anArray : Array of Cardinal); external name 'set'; reintroduce; overload;
    procedure _set(anArray : Array of Cardinal; anOffset : NativeInt); external name 'set'; overload;
    function subarray(aBegin, aEnd: Integer): TJSUInt32Array;  overload;
    function subarray(aBegin: Integer): TJSUInt32Array; overload;
    Property values[Index : NativeInt] : LongWord Read getTypedValue Write setTypedValue; default;
  end;

  TJSFloat32Array = class external name 'Float32Array' (TJSTypedArray)
  private
    function getTypedValue(Index : NativeInt): Float32; external name '[]';
    procedure setTypedValue(Index : NativeInt; AValue: Float32);external name '[]';
  public
    constructor new (length : NativeInt);
    constructor new (atypedArray : TJSTypedArray);
    constructor new (aObject : TJSObject);
    constructor new (buffer : TJSAbstractArrayBuffer);
    constructor new (buffer : TJSAbstractArrayBuffer; aByteOffset: NativeInt);
    constructor new (buffer : TJSAbstractArrayBuffer; aByteOffset, aElementLength: NativeInt);
    class function from(aValue : jsValue) : TJSFloat32Array; reintroduce;
    class function from(aValue : jsValue; Map : TJSTypedArrayMapCallBack) : TJSFloat32Array; reintroduce;
//    class function from(aValue : jsValue; aMap : TJSTypedArrayMapEvent) : TJSFloat32Array; reintroduce;
    class function _of(aValue : jsValue) : TJSFloat32Array; varargs; reintroduce;
    procedure _set(anArray : Array of Double); external name 'set'; reintroduce; overload;
    procedure _set(anArray : Array of Double; anOffset : NativeInt); external name 'set'; reintroduce; overload;
    function subarray(aBegin, aEnd: Integer): TJSFloat32Array;  overload;
    function subarray(aBegin: Integer): TJSFloat32Array; overload;
    Property values[Index : NativeInt] : Float32 Read getTypedValue Write setTypedValue; default;
  end;

  TJSFloat64Array = class external name 'Float64Array' (TJSTypedArray)
  private
    function getTypedValue(Index : NativeInt): Float64; external name '[]';
    procedure setTypedValue(Index : NativeInt; AValue: Float64);external name '[]';
  public
    constructor new (length : NativeInt);
    constructor new (atypedArray : TJSTypedArray);
    constructor new (aObject : TJSObject);
    constructor new (buffer : TJSAbstractArrayBuffer);
    constructor new (buffer : TJSAbstractArrayBuffer; aByteOffset: NativeInt);
    constructor new (buffer : TJSAbstractArrayBuffer; aByteOffset, aElementLength: NativeInt);
    class function from(aValue : jsValue) : TJSFloat64Array; reintroduce;
    class function from(aValue : jsValue; Map : TJSTypedArrayMapCallBack) : TJSFloat64Array; reintroduce;
//    class function from(aValue : jsValue; aMap : TJSTypedArrayMapEvent) : TJSFloat64Array; reintroduce;
    class function _of(aValue : jsValue) : TJSFloat64Array; varargs; reintroduce;
    procedure _set(anArray : Array of Double); external name 'set'; reintroduce; overload;
    procedure _set(anArray : Array of Double; anOffset : NativeInt); external name 'set'; reintroduce; overload;
    function subarray(aBegin, aEnd: Integer): TJSFloat64Array;  overload;
    function subarray(aBegin: Integer): TJSFloat64Array; overload;
    Property values[Index : NativeInt] : Float64 Read getTypedValue Write setTypedValue; default;
  end;

  { TJSDataView }

  TJSDataView = Class external name 'DataView' (TJSBufferSource)
  private
    fBuffer : TJSArrayBuffer; external name 'buffer';
    fBufferObj: TJSAbstractArrayBuffer; external name 'buffer';
    fLength : NativeInt; external name 'byteLength';
    fOffset : NativeInt; external name 'byteOffset';

  public
    constructor new(aBuffer : TJSAbstractArrayBuffer); overload;
    constructor new(aBuffer : TJSAbstractArrayBuffer; aOffset : NativeInt); overload;
    constructor new(aBuffer : TJSAbstractArrayBuffer; aOffset,aByteLength : NativeInt); overload;
    function getFloat32(aByteOffset : NativeInt) : double; overload;
    function getFloat32(aByteOffset : NativeInt; aLittleEndian: Boolean) : double; overload;
    function getFloat64(aByteOffset : NativeInt) : double; overload;
    function getFloat64(aByteOffset : NativeInt; aLittleEndian: Boolean) : double; overload;
    function getInt8(aByteOffset : NativeInt) : ShortInt; 
    function getInt16(aByteOffset : NativeInt) : SmallInt; overload;
    function getInt16(aByteOffset : NativeInt; aLittleEndian : Boolean) : SmallInt; overload;
    function getInt32(aByteOffset : NativeInt) : Longint; overload;
    function getInt32(aByteOffset : NativeInt; aLittleEndian : Boolean) : Longint; overload;
    function getUint8(aByteOffset : NativeInt) : Byte; overload;
    function getUint16(aByteOffset : NativeInt) : Word; overload;
    function getUint16(aByteOffset : NativeInt; aLittleEndian : Boolean) : Word; overload;
    function getUint32(aByteOffset : NativeInt) : LongWord; overload;
    function getUint32(aByteOffset : NativeInt; aLittleEndian : Boolean) : LongWord; overload;
    function getBigInt64(aByteOffset : NativeInt) : TJSBigInt; overload;
    function getBigInt64(aByteOffset : NativeInt; aLittleEndian : Boolean) : TJSBigInt; overload;
    function getBigUInt64(aByteOffset : NativeInt) : TJSBigInt; overload;
    function getBigUInt64(aByteOffset : NativeInt; aLittleEndian : Boolean) : TJSBigInt; overload;

    procedure setFloat32(aByteOffset : NativeInt; aValue : double); overload;
    procedure setFloat32(aByteOffset : NativeInt; aValue : double; aLittleEndian: Boolean); overload;
    procedure setFloat64(aByteOffset : NativeInt; aValue : double); overload;
    procedure setFloat64(aByteOffset : NativeInt; aValue : double; aLittleEndian: Boolean); overload;
    procedure setInt8(aByteOffset : NativeInt; aValue : ShortInt); 
    procedure setInt16(aByteOffset : NativeInt; aValue : SmallInt); overload;
    procedure setInt16(aByteOffset : NativeInt; aValue : SmallInt; aLittleEndian : Boolean); overload;
    procedure setInt32(aByteOffset : NativeInt; aValue : Longint); overload;
    procedure setInt32(aByteOffset : NativeInt; aValue : Longint; aLittleEndian : Boolean); overload;
    procedure setUint8(aByteOffset : NativeInt; aValue : Byte); overload;
    procedure setUint16(aByteOffset : NativeInt; aValue : Word); overload;
    procedure setUint16(aByteOffset : NativeInt; aValue : Word; aLittleEndian : Boolean); overload;
    procedure setUint32(aByteOffset : NativeInt; aValue : LongWord); overload;
    procedure setUint32(aByteOffset : NativeInt; aValue: LongWord; aLittleEndian : Boolean); overload;
    procedure setBigInt64(aByteOffset : NativeInt; aValue : TJSBigInt); overload;
    procedure setBigInt64(aByteOffset : NativeInt; aValue: TJSBigInt;aLittleEndian : Boolean)  overload;
    procedure setBigUInt64(aByteOffset : NativeInt; aValue : TJSBigInt); overload;
    procedure setBigUInt64(aByteOffset : NativeInt; aValue : TJSBigInt; aLittleEndian : Boolean) ; overload;
    Property byteLength : NativeInt Read fLength;
    Property byteOffset : NativeInt read fOffset;
    property buffer : TJSArrayBuffer Read fBuffer;
    property bufferObj : TJSAbstractArrayBuffer Read fBufferObj;
  end;

  TJSJSON = class external name 'JSON' (TJSObject)
  Public
    class function parse(aJSON : String) : JSValue;
    // Use this only when you are sure you will get an object, no checking is done.
    class function parseObject(aJSON : String) : TJSObject; external name 'parse';
    class function stringify(aValue : JSValue) : string;
    class function stringify(aValue,aReplacer : JSValue) : string;
    class function stringify(aValue,aReplacer : JSValue; space:  NativeInt) : string;
    class function stringify(aValue,aReplacer : JSValue; space:  String) : string;
  end;

  { TJSError }

  TJSError = Class external name 'Error'   (TJSObject)
  private
    FMessage: String; external name 'message';
    FStack: JSValue; external name 'stack';
  Public
    Constructor new;
    Constructor new(Const aMessage : string);
    Constructor new(Const aMessage,aFileName : string);
    Constructor new(Const aMessage,aFileName : string; aLineNumber : NativeInt);
    Property Message : String Read FMessage;
    Property Stack: JSValue read FStack;
  end;

  TJSPromise = class;

  TJSPromiseResolvers = class external name 'Object'
  private
    FPromise: TJSPromise; external name 'promise';
  public
    procedure Resolve; overload; external name 'resolve';
    procedure Resolve(const Value: JSValue); overload; external name 'resolve';
    procedure Reject; overload; external name 'reject';
    procedure Reject(const Value: JSValue); overload; external name 'reject';

    property Promise: TJSPromise read FPromise;
  end;

  TJSPromiseResolver = reference to function (aValue : JSValue) : JSValue;
  TJSPromiseExecutor = reference to procedure (resolve,reject : TJSPromiseResolver);
  TJSPromiseFinallyHandler = reference to procedure;
  TJSPromiseArray = array of TJSPromise;

  TJSPromise = class external name 'Promise'
  public
    constructor new(Executor : TJSPromiseExecutor);

    class function all(arg : Array of JSValue) : TJSPromise; overload;
    class function all(arg : JSValue) : TJSPromise; overload;
    class function all(arg : TJSPromiseArray) : TJSPromise; overload;
    class function allSettled(arg : Array of JSValue) : TJSPromise; overload;
    class function allSettled(arg : JSValue) : TJSPromise; overload;
    class function allSettled(arg : TJSPromiseArray) : TJSPromise; overload;
    class function race(arg : Array of JSValue) : TJSPromise; overload;
    class function race(arg : JSValue) : TJSPromise; overload;
    class function race(arg : TJSPromiseArray) : TJSPromise; overload;
    class function reject(reason : JSValue) : TJSPromise;
    class function resolve(value : JSValue): TJSPromise; overload;
    class function resolve : TJSPromise; overload;
    class function withResolvers: TJSPromiseResolvers;
    function _then (onAccepted : TJSPromiseResolver) : TJSPromise; external name 'then';
    function _then (onAccepted,OnRejected: TJSPromiseResolver) : TJSPromise; external name 'then';
    function catch (onRejected : TJSPromiseResolver) : TJSPromise;
    function _finally(value : TJSPromiseFinallyHandler): TJSPromise; external name 'finally';
  end;

  generic TGPromise<T> = class external name 'Promise'
  Type
    TResolve = reference to function (aValue : T) : JSValue;
    TReject = reference to function (aValue : JSValue) : JSValue;
    TExecute = reference to procedure (resolve: TResolve; reject : TReject);
    TFinallyHandler = reference to procedure;
  Public
    constructor new(Executor : TExecute);
    function then_ (onAccepted : TResolve) : TJSPromise; external name 'then';
    function then_ (onAccepted : TResolve; onRejected : TReject) : TJSPromise; external name 'then';
    function finally_(value : TFinallyHandler): TJSPromise; external name 'finally';
    function catch (onRejected : TReject) : TJSPromise;
  end;

  generic TGPromiseEx<T,E> = class external name 'Promise'
  Type
    TResolve = reference to function (aValue : T) : JSValue;
    TReject = reference to function (aValue : E) : JSValue;
    TExecute = reference to procedure (resolve: TResolve; reject : TReject);
    TFinallyHandler = reference to procedure;
  Public
    constructor new(Executor : TExecute);
    function then_ (onAccepted : TResolve) : TJSPromise; external name 'then';
    function then_ (onAccepted : TResolve; onRejected : TReject) : TJSPromise; external name 'then';
    function catch (onRejected : TReject) : TJSPromise;
    function finally_(value : TFinallyHandler): TJSPromise; external name 'finally';
  end;

  TJSFunctionArguments = class external name 'arguments'
  private
    FLength: NativeInt; external name 'length';
    function GetElements(Index: NativeInt): JSValue; external name '[]';
    procedure SetElements(Index: NativeInt; const AValue: JSValue); external name '[]';
  public
    property Length: NativeInt read FLength;
    property Elements[Index: NativeInt]: JSValue read GetElements write SetElements; default;
  end;

  TJSIteratorResult = Class external name 'IteratorResult' (TJSObject)
  Private
    fDone : Boolean; external name 'done';
    fValue : JSValue; external name 'value';
  Public
    property done : boolean Read FDone;
    property value : JSValue read FValue;
  end;

  TJSAsyncIterator = Class external name 'AsyncIterator' (TJSObject)
    function next: TJSIteratorResult;
  end;

  TJSSyntaxError = class external name 'SyntaxError' (TJSError);

  TJSTextDecoderOptions = class external name 'Object' (TJSObject)
    fatal : Boolean;
    ignoreBOM : Boolean;
  end;

  TJSTextDecodeOptions = class external name 'Object' (TJSObject)
    stream : Boolean;
  end;

  TJSTextDecoder = class external name 'TextDecoder' (TJSObject)
  Private
    FEncoding : String; external name 'encoding';
    FFatal : Boolean; external name 'fatal';
    FIgnoreBOM : Boolean; external name 'ignoreBOM';
  Public
    Constructor New(utfLabel : String); overload;
    Constructor New(utfLabel : String; Options : TJSTextDecoderOptions); overload;
    Function decode(arr : TJSTypedArray) : String; overload;
    Function decode(arr : TJSArrayBuffer) : String; overload;
    Function decode(arr : TJSTypedArray; opts : TJSTextDecodeOptions) : String; overload;
    Function decode(arr : TJSArrayBuffer; opts : TJSTextDecodeOptions) : String; overload;
    property Encoding : string Read FEncoding;
    Property Fatal : Boolean Read FFatal;
    Property IgnoreBOM : Boolean Read FIgnoreBOM;
  end;

  TJSTextEncoderEncodeIntoResult = class external name 'Object' (TJSObject)
    read : Nativeint;
    written : NativeInt;
  end;

  TJSTextEncoder = class external name 'TextEncoder' (TJSObject)
  Private
    FEncoding : String; external name 'encoding';
  Public
    Constructor New;
    function encode(aString : String) : TJSUInt8Array;
    Function encodeInto(aString : String; aArray : TJSUInt8Array) : TJSTextEncoderEncodeIntoResult;
    Property Encoding : string Read FEncoding;
  end;

  generic TGGenerator<T> = class external name 'Generator' (TJSObject)
  public type
    TGGeneratorValue = class external name 'Generator' (TJSObject)
    public
      done: Boolean;
      value: T;
    end;
  public
    function next: TGGeneratorValue; overload;
    function next(Value: T): TGGeneratorValue; overload;
    function return: TGGeneratorValue; overload;
    function return(Value: T): TGGeneratorValue; overload;
    function throw(Error: TJSError): TGGeneratorValue;
  end;
  
  TJSGenerator = specialize TGGenerator<JSValue>;

  TJSProxy = class external name 'Proxy' (TJSObject)
  public
    constructor New(Target, Handler: TJSObject);
  end;

  TJSNumber = class external name 'Number' (TJSFunction)
  private
    class var FEPSILON: Double; external name 'EPSILON';
    class var {%H-}FMAX_SAFE_INTEGER: NativeInt; external name 'MAX_SAFE_INTEGER';
    class var FMAX_VALUE: Double; external name 'MAX_VALUE';
    class var {%H-}FMIN_SAFE_INTEGER: NativeInt; external name 'MIN_SAFE_INTEGER';
    class var FMIN_VALUE: Double; external name 'MIN_VALUE';
    class var FNaN: Double; external name 'NaN';
    class var FNEGATIVE_INFINITY: TJSNumber; external name 'NEGATIVE_INFINITY';
    class var FPOSITIVE_INFINITY: TJSNumber; external name 'POSITIVE_INFINITY';
  public
    constructor New(const value: Double);

    class function isFinite(const value: Double): Boolean; overload;
    class function isFinite(const value: Integer): Boolean; overload;
    class function isFinite(const value: TJSNumber): Boolean; overload;
    class function isInteger(const value: Double): Boolean; overload;
    class function isInteger(const value: Integer): Boolean; overload;
    class function isInteger(const value: TJSNumber): Boolean; overload;
    class function isNaN(const value: Double): Boolean; overload;
    class function isNaN(const value: Integer): Boolean; overload;
    class function isNaN(const value: TJSNumber): Boolean; overload;
    class function isSafeInteger(const value: Double): Boolean; overload;
    class function isSafeInteger(const value: Integer): Boolean; overload;
    class function isSafeInteger(const value: TJSNumber): Boolean; overload;
    class function parseFloat(const value: String): TJSNumber; overload;
    class function parseInt(const value: String): TJSNumber; overload;

    function toExponential: TJSString; overload;
    function toExponential(const fractionDigits: Integer): TJSString; overload;
    function toFixed: TJSString; overload;
    function toFixed(const digits: Integer): TJSString; overload;
    function toLocaleString: TJSString; overload;
    function toLocaleString(const locale: String): TJSString; overload;
    function toPrecision: TJSString; overload;
    function toPrecision(const precision: Integer): TJSString; overload;
    function toString: TJSString; overload;
    function toString(const radix: Integer): TJSString; overload;
    function valueOf: Double; reintroduce;

    class property EPSILON: Double read FEPSILON;
    class property MAX_SAFE_INTEGER{%H-}: NativeInt read FMAX_SAFE_INTEGER;
    class property MAX_VALUE: Double read FMAX_VALUE;
    class property MIN_SAFE_INTEGER{%H-}: NativeInt read FMIN_SAFE_INTEGER;
    class property MIN_VALUE: Double read FMIN_VALUE;
    class property NaN: Double read FNaN;
    class property NEGATIVE_INFINITY: TJSNumber read FNEGATIVE_INFINITY;
    class property POSITIVE_INFINITY: TJSNumber read FPOSITIVE_INFINITY;
  end;

  TJSBigInt = class external name 'BigInt' (TJSObject)
     class function asIntN(Size : Integer;aValue : TJSBigInt) : NativeInt;
     class function asUIntN(Size : Integer;aValue : TJSBigInt) : NativeInt;
  end;

  { TJSBigIntHelper }

  TJSBigIntHelper = type helper for TJSBigint
    class function new(aValue : JSValue) : TJSBigInt; overload; static;
  end;

  { TJSAtomicWaitResult }

  TJSAtomicWaitResult = class external name 'Object' (TJSObject)
  private
    FAsync: boolean; external name 'async';
    FValue: JSValue; external name 'value';
    FValueAsPromise: TJSPromise; external name 'value';
    FValueAsString: String; external name 'value';
  Public
    property async : boolean Read FAsync;
    property value : JSValue Read FValue;
    property valueAsPromise : TJSPromise Read FValueAsPromise;
    property valueAsString : String Read FValueAsString;
  end;

  TJSAtomics = class external name 'Atomics' (TJSObject)
    class function add(aTypedArray : TJSTypedArray; index: integer; value : Integer) : integer;
    class function and_(aTypedArray : TJSTypedArray; index: integer; value : Integer) : integer; external name 'and';
    class function compareExchange(aTypedArray : TJSTypedArray; index: integer; ExpectedValue, ReplacementValue : Integer) : integer;
    class function exchange(aTypedArray : TJSTypedArray; index: integer; ReplacementValue : Integer) : integer;
    class function isLockFree(size : integer) : integer;
    class function load(aTypedArray : TJSTypedArray; Index : integer) : integer;
    class function notify(aTypedArray : TJSTypedArray; Index : integer; count : integer) : integer;
    class function notify(aTypedArray : TJSTypedArray; Index : integer) : integer;
    class function or_(aTypedArray : TJSTypedArray; index: integer; value : Integer) : integer; external name 'or';
    class function store(aTypedArray : TJSTypedArray; index: integer; value : Integer) : integer;
    class function sub(aTypedArray : TJSTypedArray; index: integer; value : Integer) : integer;
    class function wait(aTypedArray : TJSTypedArray; index: integer; value : Integer) : string;
    class function wait(aTypedArray : TJSTypedArray; index: integer; value : Integer; TimeOut : integer) : string;
    class function waitAsync(aTypedArray : TJSTypedArray; index: integer; value : Integer) : TJSAtomicWaitResult;
    class function waitAsync(aTypedArray : TJSTypedArray; index: integer; value : Integer; TimeOut : integer) : TJSAtomicWaitResult;

    class function xor_(aTypedArray : TJSTypedArray; index: integer; value : Integer) : integer; external name 'xor';
  end;

  TJSLocalesOfOptions = class external name 'Object' (TJSObject)
  public
    localeMatcher : string;
  end;

  TJSFormatRangePart = class external name 'Object' (TJSObject)
  private
    FType : string; external name 'string';
    FValue : string; external name 'value';
    FSource : string; external name 'source';
  Public
   property type_ : string read FType;
   property value : string read FValue;
   property source : string read FSource;
  end;
  TJSFormatRangePartArray = array of TJSFormatRangePart;

  TJSFormatDatePart = class external name 'Object' (TJSObject)
  private
    FType : string; external name 'string';
    FValue : string; external name 'value';
  Public
   property type_ : string read FType;
   property value : string read FValue;
  end;
  TJSFormatDatePartArray = array of TJSFormatDatePart;

  { TJSDateTimeResolvedOptions }

  TJSDateTimeResolvedOptions = class external name 'Object' (TJSObject)
  private
    FCalendar: string; external name 'calendar';
    FDateStyle: String; external name 'dateStyle';
    FDay: string; external name 'day';
    FDayPeriod: string; external name 'dayPeriod';
    FEra: string; external name 'era';
    FfractionalSecondDigits: Integer; external name 'fractionalSecondDigits';
    FHour: string; external name 'hour';
    FHour12: string; external name 'hour12';
    FHourCycle: string; external name 'hourCycle';
    FLocale: string; external name 'locale';
    FMinute: string; external name 'minute';
    FMonth: string; external name 'month';
    FNumberingSystem: string; external name 'numberingSystem';
    FSecond: string; external name 'second';
    FTimeStyle: string; external name 'timeStyle';
    FTimeZone: string; external name 'timeZone';
    FtimeZoneName: string; external name 'timeZoneName';
    FWeekday: string; external name 'weekday';
    FYear: string; external name 'year';
  Public
    property locale : string read FLocale;
    property calendar : string read FCalendar;
    property numberingSystem : string read FNumberingSystem;
    property timeZone : string read FTimeZone;
    property hourCycle : string read FHourCycle;
    property hour12 : string read FHour12;
    property weekday : string read FWeekday;
    property era : string read FEra;
    property year : string read FYear;
    property month : string read FMonth;
    property day : string read FDay;
    property hour : string read FHour;
    property dayPeriod : string read FDayPeriod;
    property minute :  string Read FMinute;
    property second : string read FSecond;
    property fractionalSecondDigits : Integer read FfractionalSecondDigits;
    property timeZoneName : string read FtimeZoneName;
    property dateStyle : String Read FDateStyle;
    property timeStyle : string read FTimeStyle;
  end;

  TJSDateLocaleOptions = class external name 'Object' (TJSObject)
  Public
    localeMatcher : string;
    locale : string;
    calendar : string;
    numberingSystem : string;
    timeZone : string;
    hourCycle : string;
    hour12 : string;
    weekday : string;
    era : string;
    year : string;
    month : string;
    day : string;
    hour : string;
    dayPeriod : string;
    minute :  string;
    second : string;
    fractionalSecondDigits : Integer;
    timeZoneName : string;
    dateStyle : String;
    timeStyle : string;
  end;

  TJSIntlDateTimeFormat = class external name 'Intl.DateTimeFormat' (TJSObject)
  Public
    constructor new ();
    constructor new (locales : string);
    constructor new (locales : string; Options : TJSDateLocaleOptions);
    constructor new (locales : Array of string);
    constructor new (locales : array of string; Options : TJSDateLocaleOptions);
    class function supportedLocalesOf(locales : string) : TJSStringDynArray;
    class function supportedLocalesOf(locales : string; Options: TJSLocalesOfOptions) : TJSStringDynArray;
    function format(aDate : TJSDate) : string;
    function formatRange(aStartDate, aEndDate : TJSDate) : string;
    function formatRangeToParts(aStartDate, aEndDate : TJSDate) : TJSFormatRangePartArray;
    function formatToParts(aStartDate, aEndDate : TJSDate) : TJSFormatDatePartArray;
    function resolvedOptions : TJSDateTimeResolvedOptions;
  end;

  { TJSDisplayNamesOptions }

  TJSDisplayNamesOptions = class external name 'Object' (TJSObject)
  Public
    locale : string ;
    style : string ;
    type_ : string ; external name 'type';
    fallback : string ;
    languageDisplay : string ;
  end;

  TJSIntlDisplayNamesResolvedOptions = class external name 'Object' (TJSObject)
  private
    FFallback: string; external name 'fallback';
    FLanguageDisplay: string; external name 'languageDisplay';
    FLocale: string; external name 'locale';
    FStyle: string; external name 'style';
    FType: string; external name 'type';
  Public
    property locale : string read FLocale;
    property style : string read FStyle;
    property type_ : string read FType;
    property fallback : string read FFallback;
    property languageDisplay : string read FLanguageDisplay;
  end;

  TJSIntlDisplayNames = class external name 'Intl.DisplayNames' (TJSObject)
  Public
    constructor new (locales : string; Options : TJSDisplayNamesOptions);
    class function supportedLocalesOf(locales : string) : TStringDynArray;
    class function supportedLocalesOf(locales : string; Options: TJSLocalesOfOptions) : TStringDynArray;
    function of_ : string; external name 'of';
    function resolvedOptions : TJSIntlDisplayNamesResolvedOptions;
  end;

  TJSDurationLocaleOptions = class external name 'Object' (TJSObject)
  Public
    localeMatcher : string;
    style : string;
    numberingSystem : string;
    timeZone : string;
    years : string;
    yearsDisplay : string;
    months : string;
    monthsDisplay : string;
    weeks : string;
    weeksDisplay : string;
    days : string;
    daysDisplay : string;
    hours : string;
    hoursDisplay : string;
    minutes : string;
    minutesDisplay : string;
    seconds : string;
    secondsDisplay : string;
    milliseconds : string;
    millisecondsDisplay : string;
    microseconds : string;
    microsecondsDisplay : string;
    nanoseconds : string;
    nanosecondsDisplay : string;
    fractionalDigits : byte;
  end;

  TJSFormatDurationPart = class external name 'Object' (TJSObject)
  private
    FType : string; external name 'string';
    FValue : string; external name 'value';
    FUnits : string; external name 'units';
  Public
   property type_ : string read FType;
   property value : string read FValue;
   property units : string read FUnits;
  end;
  TJSFormatDurationPartArray = array of TJSFormatDurationPart;

  { TJSDurationResolvedOptions }

  TJSDurationResolvedOptions = class external name 'Object' (TJSObject)
  private
    Fdays : string; external name 'days';
    FdaysDisplay : string; external name 'daysDisplay';
    FfractionalDigits : byte; external name 'fractionalDigits';
    Fhours : string; external name 'hours';
    FhoursDisplay : string; external name 'hoursDisplay';
    FlocaleMatcher : string; external name 'localeMatcher';
    Fmicroseconds : string; external name 'microseconds';
    FmicrosecondsDisplay : string; external name 'microsecondsDisplay';
    Fmilliseconds : string; external name 'milliseconds';
    FmillisecondsDisplay : string; external name 'millisecondsDisplay';
    Fminutes : string; external name 'minutes';
    FminutesDisplay : string; external name 'minutesDisplay';
    Fmonths : string; external name 'months';
    FmonthsDisplay : string; external name 'monthsDisplay';
    Fnanoseconds : string; external name 'nanoseconds';
    FnanosecondsDisplay : string; external name 'nanosecondsDisplay';
    FnumberingSystem : string; external name 'numberingSystem';
    Fseconds : string; external name 'seconds';
    FsecondsDisplay : string; external name 'secondsDisplay';
    Fstyle : string; external name 'style';
    FtimeZone : string; external name 'timeZone';
    Fweeks : string; external name 'weeks';
    FweeksDisplay : string; external name 'weeksDisplay';
    Fyears : string; external name 'years';
    FyearsDisplay : string; external name 'yearsDisplay';
  Public
    property localeMatcher : string read FlocaleMatcher;
    property style : string read Fstyle;
    property numberingSystem : string read FnumberingSystem;
    property timeZone : string read FtimeZone;
    property years : string read Fyears;
    property yearsDisplay : string read FyearsDisplay;
    property months : string read Fmonths;
    property monthsDisplay : string read FmonthsDisplay;
    property weeks : string read Fweeks;
    property weeksDisplay : string read FweeksDisplay;
    property days : string read Fdays;
    property daysDisplay : string read FdaysDisplay;
    property hours : string read Fhours;
    property hoursDisplay : string read FhoursDisplay;
    property minutes : string read Fminutes;
    property minutesDisplay : string read FminutesDisplay;
    property seconds : string read Fseconds;
    property secondsDisplay : string read FsecondsDisplay;
    property milliseconds : string read Fmilliseconds;
    property millisecondsDisplay : string read FmillisecondsDisplay;
    property microseconds : string read Fmicroseconds;
    property microsecondsDisplay : string read FmicrosecondsDisplay;
    property nanoseconds : string read Fnanoseconds;
    property nanosecondsDisplay : string read FnanosecondsDisplay;
    property fractionalDigits : byte read FfractionalDigits;
  end;

  TJSDuration = class external name 'Object' (TJSObject)
  Public
    years : integer;
    months : integer;
    weeks : integer;
    days : integer;
    hours : integer;
    minutes : integer;
    seconds : integer;
    milliseconds : integer;
    microseconds : integer;
    nanoseconds : integer;
  end;

  TJSIntlDurationFormat = class external name 'Intl.DurationFormat' (TJSObject)
  Public
    constructor new ();
    constructor new (locales : string);
    constructor new (locales : string; Options : TJSDurationLocaleOptions);
    class function supportedLocalesOf(locales : string) : TJSStringDynArray;
    class function supportedLocalesOf(locales : string; Options: TJSLocalesOfOptions) : TJSStringDynArray;
    function format(duration : TJSDuration) : String;
    function formatToParts(duration : TJSDuration) : TJSFormatDurationPartArray;
    function resolvedOptions  : TJSDurationResolvedOptions;
  end;

  TJSListFormatOptions = class external name 'Object' (TJSObject)
    localeMatcher : string;
    type_ : string; external name 'type';
    style : string; external name 'style';
  end;

  TJSListFormatResolvedOptions = class external name 'Object' (TJSObject)
  Private
    FlocaleMatcher : string; external name 'localeMatched';
    Ftype : string; external name 'type';
    Fstyle : string; external name 'style';
  Public
    property localeMatcher : string read FlocaleMatcher;
    property type_ : string read FType;
    property style : string read FStyle;
  end;

  TJSFormatListPart = class external name 'Object' (TJSObject)
  Public
    type_ : string; external name 'type';
    value : string;
  end;
  TJSFormatListPartArray = Array of TJSFormatListPart;

  TJSIntlListFormat = class external name 'Intl.ListFormat' (TJSObject)
  Public
    constructor new ();
    constructor new (locales : string);
    constructor new (locales : string; Options : TJSListFormatOptions);
    class function supportedLocalesOf(locales : string) : TJSStringDynArray;
    class function supportedLocalesOf(locales : string; Options: TJSLocalesOfOptions) : TJSStringDynArray;
    function format(aList : Array of string) : String;
    function formatToParts(aList : array of string) : TJSFormatListPartArray;
    function resolvedOptions  : TJSListFormatResolvedOptions;
  end;

  TJSIntlLocaleOptions = class external name 'Object' (TJSObject)
  public
    language : string;
    script : string;
    region : string;
    calendar : string;
    collation : string;
    numberingSystem : string;
    caseFirst : string;
    hourCycle : string;
    numeric : boolean;
  end;

  { TJSIntlTextInfo }

  TJSIntlTextInfo = class external name 'Object' (TJSObject)
  private
    FDirection: string; external name 'direction';
  Public
    property direction : string read FDirection;
  end;

  { TJSIntlWeekInfo }

  TJSIntlWeekInfo = class external name 'Object' (TJSObject)
  private
    FFirstDay: integer; external name 'firstDay';
    FMInimalDays: Integer; external name 'minimalDays';
    FWeekend: TIntegerDynArray; external name 'weekend';
  Public
    property firstDay : integer read FFirstDay;
    property weekend : TIntegerDynArray read FWeekend;
    property minimalDays : Integer Read FMInimalDays;
  end;

  { TJSIntlLocale }

  TJSIntlLocale = class external name 'Intl.Locale' (TJSObject)
  private
    FBaseName: string; external name 'baseName';
    FCalendar: string; external name 'calendar';
    FCaseFirst: string; external name 'caseFirst';
    FCollation: string; external name 'collation';
    FHourCycle: string; external name 'hourCycle';
    FLanguage: string; external name 'language';
    FNumberingSystem: string; external name 'numberingSystem';
    FNumeric: boolean; external name 'numeric';
    FRegion: string; external name 'region';
    FScript: string; external name 'script';
  public
    constructor new(aLocale : string);
    constructor new(aLocale : string; Options : TJSIntlLocaleOptions);
    function getCalendars : TStringDynArray;
    function getCollations : TStringDynArray;
    function getHourCycles : TStringDynArray;
    function getNumberingSystems : TStringDynArray;
    function getTextInfo : TJSIntlTextInfo;
    function getTimeZones : TStringDynArray;
    function getWeekInfo : TJSIntlWeekInfo;
    function maximize : TJSIntlLocale;
    function minimize : TJSIntlLocale;
    property baseName : string read FBaseName;
    property calendar : string read FCalendar;
    property caseFirst : string read FCaseFirst;
    property collation : string read FCollation;
    property hourCycle : string read FHourCycle;
    property language : string read FLanguage;
    property numberingSystem : string read FNumberingSystem;
    property numeric : boolean Read FNumeric;
    property region : string read FRegion;
    property script : string read FScript;
  end;

  TJSNumberFormatOptions = class external name 'Object' (TJSObject)
    localeMatcher : string;
    numberingSystem : string;
    style : string;
    currency_ : string; external name 'currency';
    currencyDisplay : string;
    currencySign : string;
    unit_ : string; external name 'unit';
    unitDisplay : string;
    minimumIntegerDigits : Byte;
    minimumFractionDigits : Byte;
    maximumFractionDigits : Byte;
    minimumSignificantDigits : Byte;
    maximumSignificantDigits : Byte;
    roundingpriority : string;
    roundingIncrement : word;
    roundingMode : string;
    trailingZeroDisplay : string;
    notation : string;
    compactDisplay : string;
    useGrouping : string;
    signDisplay : string;
  end;

  TJSNumberFormatResolvedOptions = class external name 'Object' (TJSObject)
  Private
    FlocaleMatcher : string; external name 'localeMatcher';
    FnumberingSystem : string; external name 'numberingSystem';
    Fstyle : string; external name 'style';
    Fcurrency_ : string; external name 'currency';
    FcurrencyDisplay : string; external name 'currencyDisplay';
    FcurrencySign : string; external name 'currencySign';
    Funit_ : string; external name 'unit';
    FunitDisplay : string; external name 'unitDisplay';
    FminimumIntegerDigits : Byte; external name 'minimumIntegerDigits';
    FminimumFractionDigits : Byte; external name 'minimumFractionDigits';
    FmaximumFractionDigits : Byte; external name 'maximumFractionDigits';
    FminimumSignificantDigits : Byte; external name 'minimumSignificantDigits';
    FmaximumSignificantDigits : Byte; external name 'maximumSignificantDigits';
    Froundingpriority : string; external name 'roundingpriority';
    FroundingIncrement : word; external name 'roundingIncrement';
    FroundingMode : string; external name 'roundingMode';
    FtrailingZeroDisplay : string; external name 'trailingZeroDisplay';
    Fnotation : string; external name 'notation';
    FcompactDisplay : string; external name 'compactDisplay';
    FuseGrouping : string; external name 'useGrouping';
    FsignDisplay : string; external name 'signDisplay';
  Public
    property localeMatcher : string read FlocaleMatcher;
    property numberingSystem : string read FnumberingSystem;
    property style : string read Fstyle;
    property currency_ : string read Fcurrency_;
    property currencyDisplay : string read FcurrencyDisplay;
    property currencySign : string read FcurrencySign;
    property unit_ : string read Funit_;
    property unitDisplay : string read FunitDisplay;
    property minimumIntegerDigits : Byte read FminimumIntegerDigits;
    property minimumFractionDigits : Byte read FminimumFractionDigits;
    property maximumFractionDigits : Byte read FmaximumFractionDigits;
    property minimumSignificantDigits : Byte read FminimumSignificantDigits;
    property maximumSignificantDigits : Byte read FmaximumSignificantDigits;
    property roundingpriority : string read Froundingpriority;
    property roundingIncrement : word read FroundingIncrement;
    property roundingMode : string read FroundingMode;
    property trailingZeroDisplay : string read FtrailingZeroDisplay;
    property notation : string read Fnotation;
    property compactDisplay : string read FcompactDisplay;
    property useGrouping : string read FuseGrouping;
    property signDisplay : string read FsignDisplay;
  end;

  { TJSNumberPart }

  TJSIntlNumberPart = class external name 'Object' (TJSObject)
  private
    FType: String; external name 'type';
    FValue: string; external name 'value';
  Public
    Property Type_ : String read FType;
    property Value : string read FValue;
  end;
  TJSIntlNumberPartArray = array of TJSIntlNumberPart;

  TJSIntlNumberFormat = class external name 'Intl.NumberFormat' (TJSObject)
  Public
    constructor new ();
    constructor new (locales : string);
    constructor new (locales : string; Options : TJSNumberFormatOptions);
    class function supportedLocalesOf(locales : string) : TJSStringDynArray;
    class function supportedLocalesOf(locales : string; Options: TJSLocalesOfOptions) : TJSStringDynArray;
    function format(aDate : TJSDate) : string;
    function formatRange(aStart, aEnd: Double) : string;
    function formatRange(aStart, aEnd: TJSBigint) : string;
    function formatRange(aStart, aEnd: String) : string;
    function formatRange(aStart: TJSBigint; aEnd : Double) : string;
    function formatRange(aStart: Double; aEnd : TJSBigint) : string;
    function formatRange(aStart: string; aEnd : Double) : string;
    function formatRange(aStart: Double; aEnd : string) : string;
    function formatRange(aStart: TJSBigint; aEnd : string) : string;
    function formatRange(aStart: string; aEnd : TJSBigint) : TJSIntlNumberPartArray;
    function formatRangeToParts(aStart, aEnd: Double) : TJSIntlNumberPartArray;
    function formatRangeToParts(aStart, aEnd: TJSBigint) : TJSIntlNumberPartArray;
    function formatRangeToParts(aStart, aEnd: String) : TJSIntlNumberPartArray;
    function formatRangeToParts(aStart: TJSBigint; aEnd : Double) : TJSIntlNumberPartArray;
    function formatRangeToParts(aStart: Double; aEnd : TJSBigint) : TJSIntlNumberPartArray;
    function formatRangeToParts(aStart: string; aEnd : Double) : TJSIntlNumberPartArray;
    function formatRangeToParts(aStart: Double; aEnd : string) : TJSIntlNumberPartArray;
    function formatRangeToParts(aStart: TJSBigint; aEnd : string) : TJSIntlNumberPartArray;
    function formatRangeToParts(aStart: string; aEnd : TJSBigint) : TJSIntlNumberPartArray;
    function formatToParts(aValue : Double) : TJSIntlNumberPartArray;
    function formatToParts(aValue : TJSBigint) : TJSIntlNumberPartArray;
    function formatToParts(aValue : String) : TJSIntlNumberPartArray;
    function resolvedOptions : TJSNumberFormatResolvedOptions;
  end;

  TJSIntlCollatorOptions = class external name 'Object' (TJSObject)
  Public
    usage : string;
    localeMatcher : string;
    collation : string;
    numeric : boolean;
    caseFirst : string;
    sensitivity : string;
    ignorePunctuation : boolean;
  end;

  { TJSIntlCollatorResolvedOptions }

  TJSIntlCollatorResolvedOptions = class external name 'Object' (TJSObject)
  private
    FCaseFirst: string; external name 'caseFirst';
    FCollation: string; external name 'collation';
    FIgnorePunctuation: boolean; external name 'ignorePunctuation';
    FLocale: string; external name 'locale';
    FNumeric: boolean; external name 'numeric';
    FSensitivity: string; external name 'sensitivity';
    FUsage: string; external name 'usage';
  Public
    Property usage : string read FUsage;
    Property locale : string read FLocale;
    Property collation : string read FCollation;
    Property numeric : boolean read FNumeric;
    Property caseFirst : string read FCaseFirst;
    Property sensitivity : string read FSensitivity;
    Property ignorePunctuation : boolean read FIgnorePunctuation;
  end;

  TJSIntlCollator = class external name 'Intl.Collator' (TJSObject)
    constructor new ();
    constructor new (locales : string);
    constructor new (locales : string; Options : TJSIntlCollatorOptions);
    class function supportedLocalesOf(locales : string) : TJSStringDynArray;
    class function supportedLocalesOf(locales : string; Options: TJSLocalesOfOptions) : TJSStringDynArray;
    function compare (aString1, aString2 : string) : Integer;
    function resolvedOptions : TJSIntlCollatorResolvedOptions;
  end;

  TJSIntlPluralRuleOptions = class external name 'Object' (TJSObject)
  Public
    localeMatcher : string;
    type_ : string; external name 'type';
    minimumIntegerDigits : Byte;
    minimumFractionDigits : Byte;
    maximumFractionDigits : Byte;
    minimumSignificantDigits : Byte;
    maximumSignificantDigits : Byte;
    roundingpriority : string;
    roundingIncrement : word;
    roundingMode : string;
  end;

  { TJSIntlPluralRuleResolvedOptions }

  TJSIntlPluralRuleResolvedOptions = class external name 'Object' (TJSObject)
  private
    FLocale: string; external name 'locale';
    FmaximumFractionDigits: Byte; external name 'maximumFractionDigits';
    FmaximumSignificantDigits: Byte; external name 'maximumSignificantDigits';
    FminimumFractionDigits: Byte; external name 'minimumFractionDigits';
    FminimumIntegerDigits: Byte; external name 'minimumIntegerDigits';
    FminimumSignificantDigits: Byte; external name 'minimumSignificantDigits';
    FroundingIncrement: word; external name 'roundingIncrement';
    FroundingMode: string; external name 'roundingMode';
    Froundingpriority: string; external name 'roundingPriority';
    FType: string; external name 'type';
  Public
    property locale : string read FLocale;
    property type_ : string read FType;
    property minimumIntegerDigits : Byte read FminimumIntegerDigits;
    property minimumFractionDigits : Byte read FminimumFractionDigits;
    property maximumFractionDigits : Byte read FmaximumFractionDigits;
    property minimumSignificantDigits : Byte read FminimumSignificantDigits;
    property maximumSignificantDigits : Byte read FmaximumSignificantDigits;
    property roundingpriority : string read Froundingpriority;
    property roundingIncrement : word read FroundingIncrement;
    property roundingMode : string read FroundingMode;
  end;

  TJSIntlPluralRules = class external name 'Intl.PluralRules' (TJSObject)
    constructor new ();
    constructor new (locales : string);
    constructor new (locales : string; Options : TJSIntlPluralRuleOptions);
    class function supportedLocalesOf(locales : string) : TJSStringDynArray;
    class function supportedLocalesOf(locales : string; Options: TJSLocalesOfOptions) : TJSStringDynArray;
    function select (aValue : Double) : string;
    function selectRange (aValue1, aValue2: Double) : string;
    function resolvedOptions : TJSIntlPluralRuleResolvedOptions;
  end;

  { TJSRelativeTimeParts }

  TJSRelativeTimeParts = class external name 'Object' (TJSObject)
  private
    FType: string; external name 'type';
    FUnits: string; external name 'units';
    Fvalue: string; external name 'value';
  Public
    Property type_ : string read FType;
    Property value : string read Fvalue;
    Property units : string read FUnits;
  end;
  TJSRelativeTimePartsArray = array of TJSRelativeTimeParts;

  TJSIntlRelativeTimeFormatOptions = class external name 'Object' (TJSObject)
    localeMatcher : string;
    numberingSystem :string;
    style : string;
    numeric : string;
  end;

  TJSIntlRelativeTimeFormatResolvedOptions = class external name 'Object' (TJSObject)
  Private
    Flocale : string; external name 'locale';
    FnumberingSystem : string; external name 'numberingSystem';
    Fstyle : string; external name 'style';
    Fnumeric : string; external name 'numeric';
  Public
    property locale : string read Flocale;
    property numberingSystem : string read FnumberingSystem;
    property style : string read Fstyle;
    property numeric : string read Fnumeric;
  end;

  TJSIntlRelativeTimeFormat = class external name 'Intl.RelativeTimeFormat' (TJSObject)
    constructor new ();
    constructor new (locales : string);
    constructor new (locales : string; Options : TJSIntlRelativeTimeFormatOptions);
    class function supportedLocalesOf(locales : string) : TJSStringDynArray;
    class function supportedLocalesOf(locales : string; Options: TJSLocalesOfOptions) : TJSStringDynArray;
    function format (aValue : Double; aUnits: string) : string;
    function formatToParts (aValue : Double; aUnits: string) : TJSRelativeTimePartsArray;
    function resolvedOptions : TJSIntlRelativeTimeFormatResolvedOptions;
  end;

  TJSIntl = class external name 'Intl' (TJSObject)
  Public
    class function DateTimeFormat() : TJSIntlDateTimeFormat;
    class function DateTimeFormat(locales : string) : TJSIntlDateTimeFormat;
    class function DateTimeFormat(locales : string; Options : TJSDateLocaleOptions) : TJSIntlDateTimeFormat;
    class function DisplayNames(locales : string; Options : TJSDisplayNamesOptions) : TJSIntlDisplayNames;
    class function NumberFormat() : TJSIntlNumberFormat;
    class function NumberFormat(locales : string) : TJSIntlNumberFormat;
    class function NumberFormat(locales : string; Options : TJSNumberFormatOptions) : TJSIntlNumberFormat;
    class function Collator() : TJSIntlCollator;
    class function Collator(locales : string) : TJSIntlCollator;
    class function Collator(locales : string; Options : TJSIntlCollatorOptions) : TJSIntlCollator;
  end;

var
  // JSArguments can be used in procedures/functions to provide access to the 'arguments' array.
  JSArguments: TJSFunctionArguments; external name 'arguments';
  // JSThis can be used in all code to access the javascript 'this' object.
  JSThis: TJSObject; external name 'this';
  // JSExceptValue can be used in catch blocks to access the JS throw value
  JSExceptValue: JSValue; external name '$e';

function Symbol : TJSSymbol;
function Symbol(Description : String) : TJSSymbol;
function AsNumber(v : JSValue) : Double; assembler;
function AsIntNumber(v : JSValue) : NativeInt; assembler;
Function JSValueArrayOf(Args : Array of const) : TJSValueDynArray;
function new(aElements: TJSValueDynArray) : TJSObject; overload;
function JSDelete(const Obj: JSValue; const PropName: string): boolean; assembler; overload;

function decodeURIComponent(encodedURI : String) : String; external name 'decodeURIComponent';
function encodeURIComponent(str : String) : String; external name 'encodeURIComponent';

function parseInt(s: String; Radix: NativeInt): NativeInt; overload; external name 'parseInt'; // may result NaN
function parseInt(s: String): NativeInt; overload; external name 'parseInt'; // may result NaN
function parseFloat(s: String): double; overload; external name 'parseFloat'; // may result NaN

function hasString(const v: JSValue): boolean; external name 'rtl.hasString';// isString(v) and v<>''
function hasValue(const v: JSValue): boolean; assembler; // returns the JS definition of if(v): v is not false, undefined, null, 0, NaN, or the empty string. Note: JS if(new Boolean(false)) returns true.
function jsIn(const keyName: String; const &object: TJSObject): Boolean; assembler;
function isArray(const v: JSValue): boolean; external name 'rtl.isArray';
function isBoolean(const v: JSValue): boolean; assembler;
function isDate(const v: JSValue): boolean; assembler;
function isCallback(const v: JSValue): boolean; assembler;
function isChar(const v: JSValue): boolean; assembler;
function isClass(const v: JSValue): boolean; assembler; // is a Pascal class, e.g. a TClass
function isClassInstance(const v: JSValue): boolean; assembler;// is a Pascal class instance, e.g. a TObject
function isFunction(const v: JSValue): boolean; external name 'rtl.isFunction';
function isInteger(const v: JSValue): boolean; assembler;
function isModule(const v: JSValue): boolean; external name 'rtl.isModule';
function isNull(const v: JSValue): boolean; assembler;
function isNumber(const v: JSValue): boolean; external name 'rtl.isNumber';
function isObject(const v: JSValue): boolean; external name 'rtl.isObject'; // true if not null and a JS Object
function isRecord(const v: JSValue): boolean; assembler;
function isBigint(const v: JSValue): boolean; assembler;
function isString(const v: JSValue): boolean; external name 'rtl.isString';
function isUndefined(const v: JSValue): boolean; assembler;
function isDefined(const v: JSValue): boolean; assembler;
function isUTF16Char(const v: JSValue): boolean; assembler;
function isExt(const InstanceOrClass, aClass: JSValue): boolean; external name 'rtl.isExt'; // aClass can be a JS object or function
function jsInstanceOf(const aFunction, aFunctionWithPrototype: JSValue): Boolean; assembler;
function jsTypeOf(const v: JSValue): String; external name 'typeof';
function jsIsNaN(const v: JSValue): boolean; external name 'isNaN';// true if value cannot be converted to a number. e.g. True on NaN, undefined, {}, '123'. False on true, null, '', ' ', '1A'
function jsIsFinite(const v: JSValue): boolean; external name 'isFinite';// true if value is a Finite number
function toNumber(const v: JSValue): double; assembler; // if not possible, returns NaN
function toInteger(const v: JSValue): NativeInt; // if v is not an integer, returns 0
function toObject(Value: JSValue): TJSObject; // If Value is not a Javascript object, returns Nil
function toArray(Value: JSValue): TJSArray; // If Value is not a Javascript array, returns Nil
function toBoolean(Value: JSValue): Boolean; // If Value is not a Boolean, returns False
function toString(Value: JSValue): String; // If Value is not a string, returns ''
function JSClassName(aObj : TJSObject) : string;

Type
  TJSValueType = (jvtNull,jvtBoolean,jvtInteger,jvtFloat,jvtString,jvtObject,jvtArray);

Function GetValueType(JS : JSValue) : TJSValueType;

Function HaveSharedArrayBuffer : Boolean;
Function SharedToNonShared(aBuffer : TJSAbstractArrayBuffer) : TJSArrayBuffer;
Function SharedToNonShared(aArray : TJSTypedArray; aWordSized : Boolean = False) : TJSTypedArray;
Function JSBigInt(aValue : JSValue) : TJSBigInt external name 'BigInt';

Const
  Null : JSValue; external name 'null';
  Undefined : JSValue; external name 'undefined';

implementation

function JSClassName(aObj : TJSObject) : string;

begin
  Result:='';
  if aObj=Nil then exit;
  asm
    return aObj.constructor.name;
  end;
end;

function AsNumber(v: JSValue): Double; assembler;
asm
  return Number(v);
end;

function AsIntNumber(v: JSValue): NativeInt;
asm
  return Number(v);
end;

function JSValueArrayOf(Args: array of const): TJSValueDynArray;

var
  I : Integer;

begin
  SetLength(Result,Length(Args));
  for I:=0 to Length(Args)-1 do
    Result[i]:=Args[i].VJSValue
end;


function new(aElements: TJSValueDynArray): TJSObject;

  function toString(I : Integer): string; external name 'String';

Var
  L,I : integer;
  S : String;

begin
  L:=length(aElements);
  if (L mod 2)=1 then
    raise EJS.Create('Number of arguments must be even');
  I:=0;
  // Check all arguments;
  While (i<L) do
    begin
    if Not isString(aElements[i]) then
      begin
      S:=ToString(I);
      raise EJS.Create('Argument '+S+' must be a string.');
      end;
    inc(I,2);
    end;
  I:=0;
  Result:=TJSObject.New;
  While (i<L) do
    begin
    S:=String(aElements[i]);
    Result.Properties[S]:=aElements[i+1];
    inc(I,2);
    end;
end;

function JSDelete(const Obj: JSValue; const PropName: string): boolean; assembler;
asm
  return delete Obj[PropName];
end;

function hasValue(const v: JSValue): boolean; assembler;
asm
  if(v){ return true; } else { return false; };
end;

function jsIn(const keyName: String; const &object: TJSObject): Boolean; assembler;
asm
  return keyName in object;
end;

function isBoolean(const v: JSValue): boolean; assembler;
asm
  return typeof(v) == 'boolean';
end;

function isDate(const v: JSValue): boolean; assembler;
asm
  return (v instanceof Date);
end;

function isCallback(const v: JSValue): boolean; assembler;
asm
  return rtl.isObject(v) && rtl.isObject(v.scope) && (rtl.isString(v.fn) || rtl.isFunction(v.fn));
end;

function isChar(const v: JSValue): boolean; assembler;
asm
  return (typeof(v)!="string") && (v.length==1);
end;

function isClass(const v: JSValue): boolean; assembler;
asm
  return (typeof(v)=="object") && (v!=null) && (v.$class == v);
end;

function isClassInstance(const v: JSValue): boolean; assembler;
asm
  return (typeof(v)=="object") && (v!=null) && (v.$class == Object.getPrototypeOf(v));
end;

function isInteger(const v: JSValue): boolean; assembler;
asm
  return Math.floor(v)===v;
end;

function isNull(const v: JSValue): boolean; assembler;
// Note: use identity, "==" would fit undefined
asm
  return v === null;
end;

function isRecord(const v: JSValue): boolean; assembler;
asm
  return (typeof(v)==="object")
      && (typeof(v.$new)==="function")
      && (typeof(v.$clone)==="function")
      && (typeof(v.$eq)==="function")
      && (typeof(v.$assign)==="function");
end;

function isBigint(const v: JSValue): boolean; assembler;
asm
  return typeof(v) === 'bigint';
end;

function isUndefined(const v: JSValue): boolean; assembler;
asm
  return v == undefined;
end;

function isDefined(const v: JSValue): boolean; assembler;
asm
  return !(v == undefined);
end;

function isUTF16Char(const v: JSValue): boolean; assembler;
asm
  if (typeof(v)!="string") return false;
  if ((v.length==0) || (v.length>2)) return false;
  var code = v.charCodeAt(0);
  if (code < 0xD800){
    if (v.length == 1) return true;
  } else if (code <= 0xDBFF){
    if (v.length==2){
      code = v.charCodeAt(1);
      if (code >= 0xDC00 && code <= 0xDFFF) return true;
    };
  };
  return false;
end;

function jsInstanceOf(const aFunction, aFunctionWithPrototype: JSValue
  ): Boolean; assembler;
asm
  return aFunction instanceof aFunctionWithPrototype;
end;

function toNumber(const v: JSValue): double; assembler;
asm
  return v-0;
end;

function toInteger(const v: JSValue): NativeInt;
begin
  if IsInteger(v) then
    Result:=NativeInt(v)
  else
    Result:=0;
end;

function toObject(Value: JSValue): TJSObject;

begin
  if IsObject(Value) then
    Result:=TJSObject(Value)
  else
    Result:=Nil;
end;

function toArray(Value: JSValue): TJSArray; // If not possible, returns Nil

begin
  if IsArray(Value) then
    Result:=TJSArray(Value)
  else
    Result:=Nil;
end;

function toBoolean(Value: JSValue): Boolean; // If not possible, returns False

begin
  if isBoolean(Value) then
    Result:=Boolean(Value)
  else
    Result:=False;
end;

function toString(Value: JSValue): String; // If not possible, returns ''

begin
  if IsString(Value) then
    Result:=String(Value)
  else
    Result:='';
end;

{ EJS }

constructor EJS.Create(const Msg: String);
begin
  FMessage:=Msg;
end;

{ TJSBigIntHelper }

class function TJSBigIntHelper.new(aValue: JSValue): TJSBigInt;
begin
  Result:=JSBigint(aValue);
end;


function GetValueType(JS: JSValue): TJSValueType;

Var
  t : string;

begin
  if isNull(js) then   // null reported as object
    result:=jvtNull
  else
    begin
    t:=jsTypeOf(js);
    if (t='string') then
      Result:=jvtString
    else if (t='boolean') then
      Result:=jvtBoolean
    else if (t='object') then
      begin
      if IsArray(JS) then
        Result:=jvtArray
      else
        Result:=jvtObject;
      end
    else if (t='number') then
      if isInteger(JS) then
        result:=jvtInteger
      else
        result:=jvtFloat
    end;
end;

Function HaveSharedArrayBuffer : Boolean; assembler;

asm
  return (typeof SharedArrayBuffer !== 'undefined');
end;


function SharedToNonShared(aBuffer: TJSAbstractArrayBuffer): TJSArrayBuffer;
var
  Src,Dest : TJSUint8Array;
begin
  if HaveSharedArrayBuffer and (aBuffer is TJSSharedArrayBuffer) then
    begin
    Result:=TJSArrayBuffer.new(aBuffer.byteLength);
    Src:=TJSUint8Array.New(aBuffer);
    Dest:=TJSUint8Array.New(Result);
    Dest._set(Src);
    end
  else
    Result:=TJSArrayBuffer(aBuffer);
end;

function SharedToNonShared(aArray : TJSTypedArray; aWordSized : Boolean = False): TJSTypedArray;
var
  Buf : TJSSharedArrayBuffer;

begin
  if HaveSharedArrayBuffer and (aArray.bufferObj is TJSSharedArrayBuffer) then
    begin
    Buf:=TJSSharedArrayBuffer(aArray.bufferObj).slice(aArray.byteOffset,aArray.byteOffset+aArray.ByteLength);
    if aWordSized then
      Result:=TJSUInt16Array.New(SharedToNonShared(Buf))
    else
      Result:=TJSUInt8Array.New(SharedToNonShared(Buf))
    end
  else
    Result:=aArray;
end;

function Symbol : TJSSymbol; assembler;
asm
  return Symbol();
end;

function Symbol(Description : String) : TJSSymbol; assembler;

asm
  return Symbol(Description);
end;


end.

