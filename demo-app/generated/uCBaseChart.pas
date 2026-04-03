unit uCBaseChart;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uCBaseChart;

implementation

procedure Register_uCBaseChart;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.chart-wrapper {     position: relative;     margin-bottom: 20px;     background: white;     padding: 15px;     border-radius: 8px;     box-shadow: 0 2px 10px rgba(0,0,0,0.05);   }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="chart-wrapper" :style="{ width: width, height: height }">' +
    '    <canvas b-ref="chartCanvas"></canvas>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['_dummy'] := 0;
    Result := d;
  end;

  comp['props'] := TJSArray.new;
  TJSArray(comp['props']).push('type');
  TJSArray(comp['props']).push('data');
  TJSArray(comp['props']).push('options');
  TJSArray(comp['props']).push('width');
  TJSArray(comp['props']).push('height');

  m := TJSObject.new;
  m['initChart'] := procedure(_this: TJSObject)

    begin
       asm
         if (this._initPending) return;
         this._initPending = true;
         requestAnimationFrame(() => {
           const canvas = this.$refs.chartCanvas;
           if (!canvas) { this._initPending = false; return; }
           const existingChart = Chart.getChart(canvas);
           if (existingChart) {
             try { existingChart.destroy(); } catch(e) {}
           }
           this._chart = null;
           if (!this.data || !this.data.datasets) { this._initPending = false; return; }
           const ctx = canvas.getContext('2d');
           if (!ctx) { this._initPending = false; return; }
           try {
             const chartData = window.__BV_CORE__.unproxy(this.data);
             const chartOptions = this.options ? window.__BV_CORE__.unproxy(this.options) : {
               responsive: true,
               maintainAspectRatio: false
             };
             this._chart = new Chart(ctx, {
               type: this.type,
               data: chartData,
               options: chartOptions
             });
           } catch (e) {
             console.error('[CBaseChart] Failed to initialize chart:', e);
           } finally {
             this._initPending = false;
           }
         });
       end;
    end;

  comp['methods'] := m;

  comp['created'] := procedure(_this: TJSObject)
    begin
       asm this._chart = null; this._pendingData = null; this._initPending = false; this._updatePending = false; end;
    end;

    ;
  comp['mounted'] := procedure(_this: TJSObject)
    begin
      asm this.initChart(); end;
    end;

    ;
  comp['watch'] := TJSObject.new;
  TJSObject(comp['watch'])['data'] := procedure(_this: TJSObject; newVal: JSValue)

    begin
       asm
         this._pendingData = newVal;
         if (this._updatePending) return;
         this._updatePending = true;
         const delay = 50 + Math.random() * 150;
         setTimeout(() => {
           this._updatePending = false;
           const dataToUse = this._pendingData;
           if (this._chart && dataToUse && dataToUse.datasets) {
             try {
               const rawNewData = window.__BV_CORE__.unproxy(dataToUse);
               // Performance Optimization: Instead of replacing the whole .data object
               // we surgically update the dataset values. This allows Chart.js to 
               // perform highly optimized incremental updates and animations.
               if (this._chart.data && this._chart.data.datasets && this._chart.data.datasets[0] && rawNewData.datasets[0]) {
                  this._chart.data.datasets[0].data = rawNewData.datasets[0].data;
                  if (rawNewData.labels) this._chart.data.labels = rawNewData.labels;
                  this._chart.update();
               } else {
                  // Fallback for structure changes
                  this._chart.data = rawNewData;
                  this._chart.update('none');
               }
             } catch (e) {
               console.warn('[CBaseChart] Hot update failed, falling back to full re-init:', e);
               this.initChart();
             }
           } else {
             this.initChart();
           }
         }, delay);
       end;
    end;
    
;
  TJSObject(comp['watch'])['type'] := procedure(_this: TJSObject; newVal: string)

    begin
      asm this.initChart(); end;
    end;

;

  RegisterComponent('c-base-chart', comp);
end;

end.
