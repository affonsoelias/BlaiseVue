unit wasm.timer.shared;

{$mode ObjFPC}{$H+}

interface

Type
  TWasmTimerID = Longint;

Const
  ETIMER_SUCCESS       = 0;
  ETIMER_NOPERFORMANCE = -1;

  TimerExportName  = 'timer';
  TimerFN_Allocate = 'allocate_timer';
  TimerFN_DeAllocate = 'deallocate_timer';

  TimerFN_Performance_Now = 'timer_performance_now';


implementation

end.

