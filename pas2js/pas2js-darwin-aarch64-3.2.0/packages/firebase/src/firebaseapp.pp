unit firebaseapp;
{
  Minimal interface for firebird messaging using compatibility API.
}

{$mode ObjFPC}
{$modeswitch externalclass}

interface

uses js, types, weborworker, web;

Type

  TMessagingGetTokenOptions = class external name 'Object' (TJSObject)
    serviceWorkerRegistration : TJSServiceWorkerRegistration;
    vapidKey : string;
  end;

  TFirebaseUnsubscribeFunction = reference to procedure;

  TFirebaseMessageCallBack = reference to procedure(aMessage : TJSObject);

  TFirebaseMessaging = class external name 'firebase.messaging.Messaging' (TJSObject)
    function deleteToken : boolean; async;
    function getToken : string; async;
    function getToken (options : TMessagingGetTokenOptions): string; async;
    function onBackgroundMessage(aCallback : TFirebaseMessageCallBack) : TFirebaseUnsubscribeFunction;
    function onMessage(aCallback : TFirebaseMessageCallBack) : TFirebaseUnsubscribeFunction;
    procedure useServiceWorker(registration : TJSServiceWorkerRegistration);
  end;

  TFirebaseApp = class external name 'firebase.app.App' (TJSObject)
  Private
    fname : string; external name 'name';
    FOptions : TJSObject; external name 'options';
  Public
    function messaging : TFirebaseMessaging;
    property name: string read FName;
    property options : TJSObject read FOptions;
  end;

  TFirebaseLogCallBack = procedure (args : TJSValueDynArray; level : string; Message : string; _type : string);

  TFirebase = class external name 'Firebase' (TJSObject)
  Private
    fapps : TJSObjectDynArray; external name 'apps';
  Public
    function initializeApp(Obj : TJSObject) : TFirebaseApp;
    function initializeApp(Obj : TJSObject; const aName : string) : TFirebaseApp;
    procedure onLog(callback : TFirebaseLogCallBack);
    procedure onLog(callback : TFirebaseLogCallBack; options : TJSObject);
    property apps : TJSObjectDynArray read fapps;
  end;

var
  firebase : TFirebase external name 'firebase';

implementation

end.

