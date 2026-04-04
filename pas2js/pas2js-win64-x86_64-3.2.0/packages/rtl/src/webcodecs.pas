{
    This file is part of the Pas2JS run time library.
    Copyright (c) 2022 by Michael Van Canneyt

    Browser WebCodecs API definitions.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{$IFNDEF FPC_DOTTEDUNITS}
Unit webcodecs;
{$ENDIF}

{$MODE ObjFPC}
{$H+}
{$modeswitch externalclass}

interface

uses
{$IFDEF FPC_DOTTEDAPI}
  System.SysUtils, JSApi.JS, BrowserApi.WebOrWorker, System.Types;
{$ELSE}
  SysUtils, JS, weborworker, types;
{$ENDIF}

{ WebCodecs API for Pas2JS }

Type
  // Array types
  TJSArrayBufferDynArray = Array of TJSArrayBuffer;

  // Forward class definitions
  TJSAudioDecoder = Class;
  TJSAudioEncoder = Class;
  TJSEncodedAudioChunk = Class;
  TJSAudioData = Class;
  TJSImageDecoder = Class;
  TJSImageTrackList = Class;
  TJSImageTrack = Class;

  // Configuration classes
  TJSAudioDecoderConfig = Class;
  TJSAudioEncoderConfig = Class;
  TJSEncodedAudioChunkMetadata = Class;
  TJSAudioDataInit = Class;
  TJSImageDecoderInit = Class;

  // Additional initialization classes
  TJSAudioDecoderInit = Class;
  TJSAudioEncoderInit = Class;
  TJSEncodedAudioChunkInit = Class;
  TJSAudioDataCopyOptions = Class;
  TJSAudioDataAllocationOptions = Class;
  TJSImageDecodeOptions = Class;

  // Type definitions - using String directly as requested

  // Callback types
  TAudioDataOutputCallback = reference to procedure (output : TJSAudioData);
  TEncodedAudioChunkOutputCallback = reference to procedure (chunk : TJSEncodedAudioChunk; metadata : TJSEncodedAudioChunkMetadata);
  TWebCodecsErrorCallback = reference to procedure (error : TJSError);

  { --------------------------------------------------------------------
    Audio
    --------------------------------------------------------------------}

  TJSAudioDecoderConfig = class external name 'Object' (TJSObject)
    codec : String;
    sampleRate : NativeInt;
    numberOfChannels : NativeInt;
    description : TJSUint8Array;
  end;

  TJSAudioEncoderConfig = class external name 'Object' (TJSObject)
    codec : String;
    sampleRate : NativeInt;
    numberOfChannels : NativeInt;
    bitrate : NativeInt;
  end;

  TJSEncodedAudioChunkMetadata = class external name 'Object' (TJSObject)
    decoderConfig : TJSAudioDecoderConfig;
  end;

  TJSAudioDataInit = class external name 'Object' (TJSObject)
    format : String;
    sampleRate : NativeInt;
    numberOfFrames : NativeInt;
    numberOfChannels : NativeInt;
    timestamp : NativeInt;
    data : TJSArrayBuffer;
    transfer : TJSArrayBufferDynArray;
  end;

  TJSImageDecoderInit = class external name 'Object' (TJSObject)
    type_ : String; external name 'type';
    data : JSValue;
    colorSpaceConversion : String;
    desiredWidth : NativeInt;
    desiredHeight : NativeInt;
    preferAnimation : Boolean;
  end;

  TJSAudioDecoderInit = class external name 'Object' (TJSObject)
    output : TAudioDataOutputCallback;
    error : TWebCodecsErrorCallback;
  end;

  TJSAudioDecoder = class external name 'AudioDecoder' (TJSEventTarget)
  Private
    Fstate : String; external name 'state';
    FdecodeQueueSize : NativeInt; external name 'decodeQueueSize';
  Public
    constructor new(init : TJSAudioDecoderInit);
    Procedure configure(config : TJSAudioDecoderConfig);
    Procedure decode(chunk : TJSEncodedAudioChunk);
    Function flush : TJSPromise;
    Procedure reset;
    Procedure close;
    class function isConfigSupported(config : TJSAudioDecoderConfig) : TJSPromise;

    Property state : String Read Fstate;
    Property decodeQueueSize : NativeInt Read FdecodeQueueSize;
  end;

  TJSAudioEncoderInit = class external name 'Object' (TJSObject)
    output : TEncodedAudioChunkOutputCallback;
    error : TWebCodecsErrorCallback;
  end;

  TJSAudioEncoder = class external name 'AudioEncoder' (TJSEventTarget)
  Private
    Fstate : String; external name 'state';
    FencodeQueueSize : NativeInt; external name 'encodeQueueSize';
  Public
    constructor new(init : TJSAudioEncoderInit);
    Procedure configure(config : TJSAudioEncoderConfig);
    Procedure encode(data : TJSAudioData);
    Function flush : TJSPromise;
    Procedure reset;
    Procedure close;
    class function isConfigSupported(config : TJSAudioEncoderConfig) : TJSPromise;

    Property state : String Read Fstate;
    Property encodeQueueSize : NativeInt Read FencodeQueueSize;
  end;

  TJSEncodedAudioChunkInit = class external name 'Object' (TJSObject)
    type_ : String; external name 'type';
    timestamp : NativeInt;
    duration : NativeInt;
    data : TJSArrayBuffer;
    transfer : TJSArrayBufferDynArray;
  end;

  TJSEncodedAudioChunk = class external name 'EncodedAudioChunk'  (TJSObject)
  Private
    Ftype_ : String; external name 'type';
    Ftimestamp : NativeInt; external name 'timestamp';
    Fduration : NativeInt; external name 'duration';
    FbyteLength : NativeInt; external name 'byteLength';
  Public
    constructor new(init : TJSEncodedAudioChunkInit);
    procedure copyTo(destination : TJSArrayBuffer);
    procedure copyTo(destination : TJSDataView);
    procedure copyTo(destination : TJSTypedArray);

    Property type_ : String Read Ftype_;
    Property timestamp : NativeInt Read Ftimestamp;
    Property duration : NativeInt Read Fduration;
    Property byteLength : NativeInt Read FbyteLength;
  end;

  TJSAudioDataAllocationOptions = class external name 'Object' (TJSObject)
    planeIndex : NativeInt;
  end;

  TJSAudioDataCopyOptions = class external name 'Object' (TJSObject)
    planeIndex : NativeInt;
    frameOffset : NativeInt;
    frameCount : NativeInt;
  end;

  TJSAudioData = class external name 'AudioData'  (TJSObject)
  Private
    Fformat : String; external name 'format';
    FsampleRate : NativeInt; external name 'sampleRate';
    FnumberOfFrames : NativeInt; external name 'numberOfFrames';
    FnumberOfChannels : NativeInt; external name 'numberOfChannels';
    Ftimestamp : NativeInt; external name 'timestamp';
    Fduration : NativeInt; external name 'duration';
  Public
    constructor new(init : TJSAudioDataInit);
    Function allocationSize(options : TJSAudioDataAllocationOptions) : NativeInt;
    procedure copyTo(destination : TJSArrayBuffer; options : TJSAudioDataCopyOptions);
    procedure copyTo(destination : TJSDataView; options : TJSAudioDataCopyOptions);
    procedure copyTo(destination : TJSTypedArray; options : TJSAudioDataCopyOptions);
    procedure copyTo(destination : TJSArrayBuffer);
    procedure copyTo(destination : TJSDataView);
    procedure copyTo(destination : TJSTypedArray);

    Procedure close;

    Property format : String Read Fformat;
    Property sampleRate : NativeInt Read FsampleRate;
    Property numberOfFrames : NativeInt Read FnumberOfFrames;
    Property numberOfChannels : NativeInt Read FnumberOfChannels;
    Property timestamp : NativeInt Read Ftimestamp;
    Property duration : NativeInt Read Fduration;
  end;

  { --------------------------------------------------------------------
    Images
    --------------------------------------------------------------------}

  TJSImageDecodeOptions = class external name 'Object' (TJSObject)
    frameIndex : NativeInt;
    completeFramesOnly : Boolean;
  end;

  TJSImageDecoder = class external name 'ImageDecoder' (TJSEventTarget)
  Private
    Fstate : String; external name 'state';
    Fcompleted : Boolean; external name 'completed';
    Ftype_ : String; external name 'type';
    FtrackCount : NativeInt; external name 'trackCount';
    Ftracks : TJSImageTrackList; external name 'tracks';
  Public
    constructor new(init : TJSImageDecoderInit);
    Function decode(options : TJSImageDecodeOptions) : TJSPromise;
    Function decodeMetadata : TJSPromise;
    Procedure reset;
    Procedure close;
    class function isTypeSupported(type_ : String) : TJSPromise;

    Property state : String Read Fstate;
    Property completed : Boolean Read Fcompleted;
    Property type_ : String Read Ftype_;
    Property trackCount : NativeInt Read FtrackCount;
    Property tracks : TJSImageTrackList Read Ftracks;
  end;

  TJSImageTrackList = class external name 'ImageTrackList'  (TJSObject)
  Private
    Fready : Boolean; external name 'ready';
    FlocalIndex : NativeInt; external name 'localIndex';
    Fselected : TJSImageTrack; external name 'selected';
    Flength_ : NativeInt; external name 'length';
  Public
    Function item(index : NativeInt) : TJSImageTrack;

    Property ready : Boolean Read Fready;
    Property localIndex : NativeInt Read FlocalIndex;
    Property selected : TJSImageTrack Read Fselected;
    Property length_ : NativeInt Read Flength_;
  end;

  TJSImageTrack = class external name 'ImageTrack' (TJSObject)
  Private
    FanimatedIndex : NativeInt; external name 'animated';
    Ffrequency : NativeInt; external name 'repetitionCount';
    Flength_ : NativeInt; external name 'frameCount';
    Flabel_ : String; external name 'label';
  Public
      selected : Boolean;

    Property animated : NativeInt Read FanimatedIndex;
    Property repetitionCount : NativeInt Read Ffrequency;
    Property frameCount : NativeInt Read Flength_;
    Property label_ : String Read Flabel_;
  end;

  { --------------------------------------------------------------------
    Video
    --------------------------------------------------------------------}

  TJSVideoChunkDecoderConfig = class external name 'Object' (TJSObject)
    codec : string;
    description : TJSObject;
    codedWidth : NativeInt;
    codedHeight : NativeInt;
    displayAspectWidth : NativeInt;
    displayAspectHeight : NativeInt;
    colorSpace : TJSObject;
    hardwareAcceleration : string;
    optimizeForLatency : boolean;
  end;
  TJSVideoChunkMetaDataSvc = class external name 'Object' (TJSObject)
    temporalLayerId : NativeInt;
  end;

  TJSVideoChunkMetaData = class external name 'Object' (TJSObject)
  private
    FalphaSideData: TJSObject; external name 'alphaSideData';
    Fdecoderconfig: TJSVideoChunkDecoderConfig; external name 'decoderConfig';
    FSvc: TJSVideoChunkMetaDataSvc;  external name 'svc';
  Public
    property decoderConfig : TJSVideoChunkDecoderConfig read Fdecoderconfig;
    property svc : TJSVideoChunkMetaDataSvc Read FSvc;
    property alphaSideData : TJSObject Read FalphaSideData;
  end;
  TJSEncodedVideoChunkMetadata = TJSVideoChunkMetaData;


  TJSVideoColorSpaceOptions = class external name 'Object' (TJSObject)
    primaries : string;
    transfer : string;
    matrix : string;
    fullrange : boolean;
  end;
  TJSVideoColorSpaceInit = TJSVideoColorSpaceOptions;

  { TJSVideoColorSpace }

  TJSVideoColorSpace = class external name 'VideoColorSpace' (TJSObject)
  private
    FPrimaries: string; external name 'primaties';
  Public
    transfer : string;
    matrix : string;
    fullrander : boolean;
    constructor new();
    constructor new(aOptions : TJSVideoColorSpace);
    property primaries : string read FPrimaries;
  end;

  { TJSVideoFrame }
  TJSVideoFrameOptionsRect  = class external name 'Object' (TJSObject)
    x,y,width,height : integer;
  end;

  TJSVideoFrameOptions = class external name 'Object' (TJSObject)
    duration : integer;
    timestamp : integer;
    alpha : string;
    visibleRect : TJSVideoFrameOptionsRect;
    displayWidth : integer;
    displayHeight : integer;
  end;
  TJSVideoFrameInit = TJSVideoFrameOptions;

  TJSVideoFramePlaneLayout = class external name 'Object' (TJSObject)
    offset : integer;
    stride : integer;
  end;

  TJSVideoFramePlaneLayoutArray = array of TJSVideoFramePlaneLayout;

  TJSVideoFrameAllocationSizeOptions = class external name 'Object' (TJSObject)
    rect : TJSVideoFrameOptionsRect;
    layout : TJSVideoFramePlaneLayoutArray;
    format : string;
    colorspace : string;
  end;
  TJSVideoFrameAllocationOptions = TJSVideoFrameAllocationSizeOptions;
  
  TJSVideoFrameCopyOptions = class external name 'Object' (TJSObject)
    rect : TJSVideoFrameOptionsRect;
    layout : TJSVideoFramePlaneLayoutArray;
  end;

  TJSVideoFrame = class external name 'VideoFrame' (TJSObject)
  private
    FcodedHeight: NativeInt; external name 'codedHeight';
    FcodedRect: TDOMRectReadOnly; external name 'codedRect';
    FcodedWidth: NativeInt; external name 'codedWidth';
    FcolorSpace: TJSVideoColorSpace; external name 'colorSpace';
    FdisplayHeight: NativeInt; external name 'displayHeight';
    FdisplayWidth: NativeInt; external name 'displayWidth';
    Fduration: NativeInt; external name 'duration';
    Fformat: string; external name 'format';
    Ftimestamp: NativeInt; external name 'timestamp';
    FvisibleRect: TDOMRectReadOnly; external name 'visibleRect';
  Public
    constructor new(aFormat : TJSImageBitmap);
    constructor new(aFormat : TJSVideoFrame);
    constructor new(aFormat : TJSHTMLOffscreenCanvas);
    constructor new(aFormat : TJSObject);
    constructor new(aFormat : TJSImageBitmap; aOptions : TJSVideoFrameOptions);
    constructor new(aFormat : TJSVideoFrame; aOptions : TJSVideoFrameOptions);
    constructor new(aFormat : TJSHTMLOffscreenCanvas; aOptions : TJSVideoFrameOptions);
    constructor new(aFormat : TJSObject; aOptions : TJSVideoFrameOptions);
    function allocationsize() : integer;
    function allocationsize(aOptions : TJSVideoFrameAllocationSizeOptions) : integer;
    function clone : TJSVideoFrame;
    procedure close;
    procedure copyTo(aDestination : TJSArrayBuffer);
    procedure copyTo(aDestination : TJSTypedArray);
    procedure copyTo(aDestination : TJSDataView);
    procedure copyTo(aDestination : TJSArrayBuffer; aOptions : TJSVideoFrameCopyOptions);
    procedure copyTo(aDestination : TJSTypedArray; aOptions : TJSVideoFrameCopyOptions);
    procedure copyTo(aDestination : TJSDataView; aOptions : TJSVideoFrameCopyOptions);

    property format : string read FFormat;
    property codedHeight : NativeInt Read FcodedHeight;
    property codedWidth : NativeInt Read FcodedWidth;
    property codedRect : TDOMRectReadOnly read FcodedRect;
    property colorSpace : TJSVideoColorSpace read FcolorSpace;
    property displayHeight : NativeInt read FdisplayHeight;
    property displayWidth : NativeInt read FdisplayWidth;
    property duration : NativeInt read Fduration;
    property timestamp : NativeInt read Ftimestamp;
    property visibleRect : TDOMRectReadOnly read FvisibleRect;
  end;

  TJSEncodedVideoChunkOptions = class external name 'Object' (TJSObject)
    type_ : string; external name 'type';
    timestamp : NativeInt;
    duration : NativeInt;
    data : TJSObject;
    transfer : TJSObjectDynArray;
  end;
  TJSEncodedVideoChunkInit = TJSEncodedVideoChunkOptions;

  { TJSEncodedVideoChunk }

  TJSEncodedVideoChunk = class external name 'EncodedVideoChunk' (TJSObject)
  private
    FbyteLength: NativeInt;external name 'byteLength';
    FDuration: NativeInt;external name 'duration';
    Ftimestamp: NativeInt;external name 'timestamp';
    Ftype: string; external name 'type';
  Public
    constructor new(aOptions : TJSEncodedVideoChunkOptions);
    procedure copyTo(aDestination : TJSArrayBuffer);
    procedure copyTo(aDestination : TJSTypedArray);
    procedure copyTo(aDestination : TJSDataView);
    property byteLength : NativeInt Read FbyteLength;
    property timestamp : NativeInt Read Ftimestamp;
    property duration : NativeInt Read FDuration;
    property type_ : string read Ftype;
  end;

  TVideoEncoderOutputCallBack = reference to procedure (aData : TJSEncodedVideoChunk; aMetaData : TJSVideoChunkMetaData);
  TVideoEncoderErrorCallBack = reference to procedure (aError: TJSError);

  TJSNewVideoEncoderOptions = class external name 'Object' (TJSObject)
    output : TVideoEncoderOutputCallBack;
    error : TVideoEncoderErrorCallBack;
  end;

  TJSVideoEncoderConfiguration = class external name 'Object' (TJSObject)
    codec : string;
    width : NativeInt;
    height: NativeInt;
    displayWidth : NativeInt;
    displayHeight : NativeInt;
    hardwareAcceleration : string;
    bitrate : NativeInt;
    framerate: NativeInt;
    alpha : string;
    scalabilityMode : string;
    bitrateMode : string;
    latencyMode : string;
  end;
  TJSVideoEncoderConfig = TJSVideoEncoderConfiguration;
  TJSVideoEncoderInit = TJSVideoEncoderConfiguration;

  TJSVideoEncodeQuantizerOptions = class external name 'Object' (TJSObject)
    quantizer : Nativeint;
  end;

  TJSVideoEncodeOptions = class external name 'Object' (TJSObject)
    keyFrame : boolean;
    vp9 : TJSVideoEncodeQuantizerOptions;
    av1 : TJSVideoEncodeQuantizerOptions;
    avc : TJSVideoEncodeQuantizerOptions;
    hevc : TJSVideoEncodeQuantizerOptions;
  end;
  TJSVideoEncoderEncodeOptions =  TJSVideoEncodeOptions;

  { TJSVideoEncoder }

  TJSVideoEncoder = class external name 'VideoEncoder' (TJSEventTarget)
  private
    FencodeQueueSize: NativeInt; external name 'encodeQueueSize';
    FState: string; external name 'state';
  Public
    class function isConfigSupported(aOptions : TJSVideoEncoderConfiguration) : boolean;
    constructor new(aOptions : TJSNewVideoEncoderOptions);
    procedure close;
    procedure configure(aConfig :TJSVideoEncoderConfiguration);
    procedure encode(Frame : TJSVideoFrame; aOptions : TJSVideoEncodeOptions);
    function flush : TJSPromise;
    procedure reset;
    property encodeQueueSize : NativeInt Read FencodeQueueSize;
    property State : string read FState;
  end;

  TJSVideoDecoderOutputCallBack = reference to procedure (aData : TJSVideoFrame);
  TJSVideoDecoderErrorCallBack = reference to procedure (aError: TJSError);

  TJSNewVideoDecoderOptions = class external name 'Object' (TJSObject)
    output : TJSVideoDecoderOutputCallback;
    error : TJSVideoDecoderErrorCallback;
  end;
  TJSVideoDecoderInit = TJSNewVideoDecoderOptions; 

  TJSVideoDecoderConfiguration = class external name 'Object' (TJSObject)
    codec : string;
    codedWidth : NativeInt;
    codedHeight: NativeInt;
    displayAspectWidth : NativeInt;
    displayAspectHeight : NativeInt;
    colorSpace : TJSVideoColorSpace;
    hardwareAcceleration : string;
    optimizeForLatency : Boolean;
  end;
  TJSVideoDecoderConfig = TJSVideoDecoderConfiguration;
  
  { TJSVideoDecoder }

  TJSVideoDecoder = class external name 'VideoDecoder' (TJSEventTarget)
  private
    FdecodeQueueSize: NativeInt; external name 'decodeQueueSize';
    FState: string; external name 'state';
  public
    constructor new(aOptions : TJSNewVideoDecoderOptions);
    class function isConfigSupported(aOptions : TJSVideoDecoderConfiguration) : boolean;
    procedure close;
    procedure configure(aConfig :TJSVideoDecoderConfiguration);
    procedure decode(Frame : TJSEncodedVideoChunk);
    function flush : TJSPromise;
    procedure reset;
    property decodeQueueSize : NativeInt Read FdecodeQueueSize;
    property State : string read FState;
  end;


// Constants
const
  // CodecState values
  CODEC_STATE_UNCONFIGURED = 'unconfigured';
  CODEC_STATE_CONFIGURED = 'configured';
  CODEC_STATE_CLOSED = 'closed';

  // EncodedChunkType values
  ENCODED_AUDIO_CHUNK_TYPE_KEY = 'key';
  ENCODED_AUDIO_CHUNK_TYPE_DELTA = 'delta';
  ENCODED_VIDEO_CHUNK_TYPE_KEY = 'key';
  ENCODED_VIDEO_CHUNK_TYPE_DELTA = 'delta';

  // AudioSampleFormat values
  AUDIO_SAMPLE_FORMAT_U8 = 'u8';
  AUDIO_SAMPLE_FORMAT_S16 = 's16';
  AUDIO_SAMPLE_FORMAT_S32 = 's32';
  AUDIO_SAMPLE_FORMAT_F32 = 'f32';
  AUDIO_SAMPLE_FORMAT_U8_PLANAR = 'u8-planar';
  AUDIO_SAMPLE_FORMAT_S16_PLANAR = 's16-planar';
  AUDIO_SAMPLE_FORMAT_S32_PLANAR = 's32-planar';
  AUDIO_SAMPLE_FORMAT_F32_PLANAR = 'f32-planar';

  // AlphaOption values
  ALPHA_OPTION_KEEP = 'keep';
  ALPHA_OPTION_DISCARD = 'discard';

  // VideoPixelFormat values
  VIDEO_PIXEL_FORMAT_I420 = 'I420';
  VIDEO_PIXEL_FORMAT_I420A = 'I420A';
  VIDEO_PIXEL_FORMAT_I422 = 'I422';
  VIDEO_PIXEL_FORMAT_I444 = 'I444';
  VIDEO_PIXEL_FORMAT_NV12 = 'NV12';
  VIDEO_PIXEL_FORMAT_RGBA = 'RGBA';
  VIDEO_PIXEL_FORMAT_RGBX = 'RGBX';
  VIDEO_PIXEL_FORMAT_BGRA = 'BGRA';
  VIDEO_PIXEL_FORMAT_BGRX = 'BGRX';

  // HardwareAcceleration values
  HARDWARE_ACCELERATION_NO_PREFERENCE = 'no-preference';
  HARDWARE_ACCELERATION_PREFER_HARDWARE = 'prefer-hardware';
  HARDWARE_ACCELERATION_PREFER_SOFTWARE = 'prefer-software';

implementation

end.

