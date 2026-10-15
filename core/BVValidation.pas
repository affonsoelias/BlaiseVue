unit BVValidation;

{
  BVValidation - Typed Form Validation Engine (BlaiseVue 2.5)
  -----------------------------------------------------------
  Provides declarative, reactive validation rules, error tracking ($errors),
  and form validation state management ($v) for BlaiseVue components.
}

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVReactivity;

type
  { TBVValidation: Static validation helper and registry }
  TBVValidation = class
  public
    class procedure RegisterRule(const Name: string; RuleFn: JSValue; const DefaultMsg: string = '');
    class function ValidateValue(const RuleName: string; Value: JSValue; const Param: string = ''; const FieldName: string = ''): string;
    class function ValidateField(const RulesStr: string; Value: JSValue; const FieldName: string = ''; DataContext: JSValue = nil): string;
    class procedure SetupValidation(Data: TBlaiseData; const FieldName: string; const RulesStr: string);
    class function ValidateAll(Data: TBlaiseData): Boolean;
    class procedure Reset(Data: TBlaiseData);
  end;

implementation

class procedure TBVValidation.RegisterRule(const Name: string; RuleFn: JSValue; const DefaultMsg: string);
begin
  asm
    let v = window.__BV_CORE__.validation;
    if (!v) return;
    v.rules[Name] = RuleFn;
    if (DefaultMsg) v.messages[Name] = DefaultMsg;
  end;
end;

class function TBVValidation.ValidateValue(const RuleName: string; Value: JSValue; const Param: string; const FieldName: string): string;
var
  ResStr: JSValue;
begin
  asm
    let v = window.__BV_CORE__.validation;
    ResStr = v ? v.validateRule(RuleName, Value, Param, FieldName) : '';
  end;
  Result := String(ResStr);
end;

class function TBVValidation.ValidateField(const RulesStr: string; Value: JSValue; const FieldName: string; DataContext: JSValue): string;
var
  ResStr: JSValue;
begin
  asm
    let v = window.__BV_CORE__.validation;
    ResStr = v ? v.validateField(RulesStr, Value, FieldName, DataContext) : '';
  end;
  Result := String(ResStr);
end;

class procedure TBVValidation.SetupValidation(Data: TBlaiseData; const FieldName: string; const RulesStr: string);
begin
  asm
    let v = window.__BV_CORE__.validation;
    if (v && Data && Data.FData) {
      v.setupField(Data.FData, FieldName, RulesStr);
    }
  end;
end;

class function TBVValidation.ValidateAll(Data: TBlaiseData): Boolean;
var
  ResVal: Boolean;
begin
  asm
    let v = window.__BV_CORE__.validation;
    if (v && Data && Data.FData && Data.FData.$v) {
      ResVal = Data.FData.$v.$validate();
    } else {
      ResVal = true;
    }
  end;
  Result := ResVal;
end;

class procedure TBVValidation.Reset(Data: TBlaiseData);
begin
  asm
    let v = window.__BV_CORE__.validation;
    if (v && Data && Data.FData && Data.FData.$v) {
      Data.FData.$v.$reset();
    }
  end;
end;

initialization
  asm
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
    const bv = window.__BV_CORE__;

    const validation = {
      rules: {
        required: function(val) {
          if (val === null || val === undefined) return false;
          if (typeof val === 'string') return val.trim().length > 0;
          if (typeof val === 'boolean') return val === true;
          if (Array.isArray(val)) return val.length > 0;
          if (typeof val === 'number') return !isNaN(val);
          return true;
        },
        email: function(val) {
          if (!val && val !== 0) return true; // optional unless 'required'
          const s = String(val).trim();
          if (s.length === 0) return true;
          return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(s);
        },
        min: function(val, param) {
          if (!val && val !== 0) return true;
          const limit = parseFloat(param);
          if (isNaN(limit)) return true;
          if (typeof val === 'number') return val >= limit;
          return String(val).length >= limit;
        },
        max: function(val, param) {
          if (!val && val !== 0) return true;
          const limit = parseFloat(param);
          if (isNaN(limit)) return true;
          if (typeof val === 'number') return val <= limit;
          return String(val).length <= limit;
        },
        numeric: function(val) {
          if (!val && val !== 0) return true;
          return /^-?\d+(\.\d+)?$/.test(String(val).trim());
        },
        alpha: function(val) {
          if (!val && val !== 0) return true;
          return /^[a-zA-Z]+$/.test(String(val).trim());
        },
        alphanumeric: function(val) {
          if (!val && val !== 0) return true;
          return /^[a-zA-Z0-9]+$/.test(String(val).trim());
        },
        url: function(val) {
          if (!val && val !== 0) return true;
          return /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/.test(String(val).trim());
        },
        sameAs: function(val, param, field, ctx) {
          if (!ctx) return true;
          return val === ctx[param];
        }
      },

      messages: {
        required: '{field} is required',
        email: '{field} must be a valid email',
        min: '{field} must be at least {param} characters',
        max: '{field} must not exceed {param} characters',
        numeric: '{field} must be numeric',
        alpha: '{field} must contain only letters',
        alphanumeric: '{field} must contain only letters and numbers',
        url: '{field} must be a valid URL',
        sameAs: '{field} must match {param}'
      },

      formatMessage: function(rule, field, param) {
        let tmpl = validation.messages[rule] || ('{field} is invalid (' + rule + ')');
        return tmpl.replace('{field}', field || 'Field').replace('{param}', param || '');
      },

      validateRule: function(ruleName, val, param, field, ctx) {
        let fn = validation.rules[ruleName];
        if (!fn) return '';
        let ok = fn(val, param, field, ctx);
        if (!ok) {
          return validation.formatMessage(ruleName, field, param);
        }
        return '';
      },

      validateField: function(rulesStr, val, field, ctx) {
        if (!rulesStr) return '';
        let parts = rulesStr.split('|');
        for (let i = 0; i < parts.length; i++) {
          let part = parts[i].trim();
          if (!part) continue;
          let rParts = part.split(':');
          let rName = rParts[0].trim();
          let rParam = rParts.length > 1 ? rParts[1].trim() : '';
          let err = validation.validateRule(rName, val, rParam, field, ctx);
          if (err) return err;
        }
        return '';
      },

      initDataValidation: function(dataObj) {
        if (!dataObj) return;
        if (!dataObj.$errors) dataObj.$errors = bv.defineReactive ? bv.defineReactive({}) : {};
        if (!dataObj.$v) {
          let vState = {
            $dirty: false,
            $invalid: false,
            $fields: {},
            $touch: function() {
              this.$dirty = true;
              let anyInv = false;
              Object.keys(this.$fields).forEach(f => {
                let fObj = this.$fields[f];
                fObj.$dirty = true;
                let err = validation.validateField(fObj.$rules, dataObj[f], f, dataObj);
                fObj.$error = err;
                fObj.$invalid = !!err;
                dataObj.$errors[f] = err;
                if (fObj.$invalid) anyInv = true;
              });
              this.$invalid = anyInv;
              return !anyInv;
            },
            $reset: function() {
              this.$dirty = false;
              this.$invalid = false;
              Object.keys(this.$fields).forEach(f => {
                let fObj = this.$fields[f];
                fObj.$dirty = false;
                fObj.$error = '';
                fObj.$invalid = false;
                dataObj.$errors[f] = '';
              });
            },
            $validate: function() {
              return this.$touch();
            }
          };
          dataObj.$v = bv.defineReactive ? bv.defineReactive(vState) : vState;
        }
        if (!dataObj.$validate) {
          dataObj.$validate = function() {
            return dataObj.$v ? dataObj.$v.$validate() : true;
          };
        }
      },

      setupField: function(dataObj, fieldName, rulesStr) {
        validation.initDataValidation(dataObj);
        if (!dataObj.$v.$fields[fieldName]) {
          dataObj.$v.$fields[fieldName] = {
            $rules: rulesStr,
            $dirty: false,
            $error: '',
            $invalid: false,
            $touch: function() {
              this.$dirty = true;
              let err = validation.validateField(rulesStr, dataObj[fieldName], fieldName, dataObj);
              this.$error = err;
              this.$invalid = !!err;
              dataObj.$errors[fieldName] = err;
              validation.recomputeInvalid(dataObj);
              return !this.$invalid;
            },
            $reset: function() {
              this.$dirty = false;
              this.$error = '';
              this.$invalid = false;
              dataObj.$errors[fieldName] = '';
              validation.recomputeInvalid(dataObj);
            }
          };
          dataObj.$errors[fieldName] = '';
          dataObj.$v[fieldName] = dataObj.$v.$fields[fieldName];
        } else {
          dataObj.$v.$fields[fieldName].$rules = rulesStr;
        }
      },

      recomputeInvalid: function(dataObj) {
        if (!dataObj || !dataObj.$v || !dataObj.$v.$fields) return;
        let anyInv = false;
        Object.keys(dataObj.$v.$fields).forEach(k => {
          if (dataObj.$v.$fields[k].$invalid) anyInv = true;
        });
        dataObj.$v.$invalid = anyInv;
      }
    };

    bv.validation = validation;
  end;

end.
