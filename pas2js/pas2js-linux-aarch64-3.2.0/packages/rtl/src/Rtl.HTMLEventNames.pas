{
    This file is part of the Pas2JS run time library.
    Copyright (c) 2017-2020 by the Pas2JS development team.

    Browser Window & DOM event name definitions
    
    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{$IFNDEF FPC_DOTTEDUNITS}
unit Rtl.HTMLEventNames;
{$ENDIF}

{$mode ObjFPC}
{$h+}

interface

Const
  sEventAbort = 'abort';
  SEventAnimationCancel = 'animationcancel';
  SEventAnimationEnd = 'animationend';
  SEventAnimationIteration = 'animationiteration';
  SEventAnimationStart = 'animationstart';
  sEventAuxClick = 'auxclick';
  sEventBlur = 'blur';
  SEventCancel = 'cancel';
  SEventCanPlay = 'canplay';
  SEventCanPlayThrough = 'canplaythrough';
  SEventChange = 'change';
  sEventClick = 'click';
  sEventCompositionEnd = 'compositionend';
  sEventCompositionStart = 'compositionstart';
  sEventCompositionUpdate = 'compositionupdate';
  sEventContextMenu = 'contextmenu';
  sEventCopy = 'copy';
  sEventCut = 'cut';
  sEventCueChange = 'cuechange';
  sEventDblClick = 'dblclick';
  sEventDurationChange = 'durationchange';
  sEventEnded  = 'ended';
  sEventError  = 'error';
  sEventFocus = 'focus';
  sEventFocusIn  = 'focusin';
  sEventFocusOut  = 'focusout';
  SEventGotPointerCapture = 'gotpointercapture';
  SEventInput = 'input';
  SEventInvalid = 'invalid';
  sEventKeyDown = 'keydown';
  sEventKeyPress = 'keypress';
  sEventKeyUp = 'keyup';
  sEventLoad = 'load';
  sEventLoadedData = 'loadeddata';
  sEventLoadedMetaData = 'loadedmetadata';
  sEventLoadend = 'loadend';
  sEventLoadStart = 'loadstart';
  SEventLostPointerCapture = 'lostpointercapture';
  sEventMouseDown = 'mousedown';
  sEventMouseEnter = 'mouseenter';
  sEventMouseLeave = 'mouseleave';
  sEventMouseMove = 'mousemove';
  sEventMouseOut = 'mouseout';
  sEventMouseUp = 'mouseup';
  sEventOverFlow = 'overflow';
  sEventPaste = 'paste';
  sEventPause = 'pause';
  sEventPlay = 'play';
  SEventPointerCancel = 'pointercancel';
  SEventPointerDown = 'pointerdown';
  SEventPointerEnter = 'pointerenter';
  SEventPointerLeave = 'pointerleave';
  SEventPointerMove = 'pointermove';
  SEventPointerOut = 'pointerout';
  SEventPointerOver = 'pointerover';
  SEventPointerUp = 'pointerup';
  sEventReset = 'reset';
  sEventResize = 'resize';
  sEventScroll = 'scroll';
  sEventSelect = 'select';
  sEventSubmit = 'submit';
  sEventTouchStart = 'touchstart';
  SEventTransitionCancel = 'transitioncancel';
  SEventTransitionEnd = 'transitionend';
  SEventTransitionRun = 'transitionrun';
  SEventTransitionStart = 'transitionstart';
  SEventWheel = 'wheel';

Type
  THTMLEvent = (
     heAbort, heAnimationCancel, heAnimationEnd,heAnimationIteration,heAnimationStart,
     heAuxClick, heBlur, heCancel, heCanPlay, heCanPlayThrough, heChange, heClick,
     heCompositionEnd, heCompositionStart, heCompositionUpdate, heContextMenu, heCopy,
     heCut, heCueChange, heDblClick, heDurationChange, heEnded, heError, heFocus,
     heFocusIn, heFocusOut, heGotPointerCapture, heInput, heInvalid, heKeyDown, heKeyPress,
     heKeyUp, heLoad, heLoadedData, heLoadedMetaData, heLoadend, heLoadStart, heLostPointerCapture,
     heMouseDown, heMouseEnter, heMouseLeave, heMouseMove, heMouseOut, heMouseUp, heOverFlow,
     hePaste, hePause, hePlay, hePointerCancel, hePointerDown, hePointerEnter, hePointerLeave,
     hePointerMove, hePointerOut, hePointerOver, hePointerUp, heReset, heResize, heScroll,
     heSelect, heSubmit, heTouchStart, heTransitionCancel, heTransitionEnd, heTransitionRun,
     heTransitionStart, heWheel);
  THTMLEvents = set of THTMLEvent;

Const
  HTMLEventNameArray : Array [THTMLEvent] of string = (
    sEventAbort,               //0
    SEventAnimationCancel,
    SEventAnimationEnd,
    SEventAnimationIteration,
    SEventAnimationStart,
    sEventAuxClick ,
    sEventBlur ,
    SEventCancel ,
    SEventCanPlay ,
    SEventCanPlayThrough ,
    SEventChange ,             // 10
    sEventClick ,
    sEventCompositionEnd ,
    sEventCompositionStart ,
    sEventCompositionUpdate ,
    sEventContextMenu ,
    sEventCopy ,
    sEventCut ,
    sEventCueChange ,
    sEventDblClick ,
    sEventDurationChange ,         // 20
    sEventEnded  ,
    sEventError  ,
    sEventFocus ,
    sEventFocusIn  ,
    sEventFocusOut  ,
    SEventGotPointerCapture ,
    SEventInput ,
    SEventInvalid ,
    sEventKeyDown ,
    sEventKeyPress ,                //  30
    sEventKeyUp ,
    sEventLoad ,
    sEventLoadedData ,
    sEventLoadedMetaData ,
    sEventLoadend ,
    sEventLoadStart ,
    SEventLostPointerCapture ,
    sEventMouseDown ,
    sEventMouseEnter ,
    sEventMouseLeave ,                  // 40
    sEventMouseMove ,
    sEventMouseOut ,
    sEventMouseUp ,
    sEventOverFlow ,
    sEventPaste ,
    sEventPause ,
    sEventPlay ,
    SEventPointerCancel ,
    SEventPointerDown ,
    SEventPointerEnter , // 50
    SEventPointerLeave ,
    SEventPointerMove ,
    SEventPointerOut ,
    SEventPointerOver ,
    SEventPointerUp ,
    sEventReset ,
    sEventResize ,
    sEventScroll ,
    sEventSelect ,
    sEventSubmit , // 60
    sEventTouchStart ,
    SEventTransitionCancel ,
    SEventTransitionEnd ,
    SEventTransitionRun ,
    SEventTransitionStart ,
    SEventWheel
  );

implementation

end.

