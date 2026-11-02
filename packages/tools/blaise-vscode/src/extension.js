const vscode = require('vscode');
const fs = require('fs');
const path = require('path');

/**
 * Directives & Events documentation database for Hover and Autocomplete.
 */
const DIRECTIVES_DOCS = {
  'b-model': {
    label: 'b-model',
    detail: 'BlaiseVue Two-Way Reactive Binding',
    snippet: 'b-model="${1:fieldName}"',
    documentation: new vscode.MarkdownString(
      '**`b-model="fieldName"`**\n\n' +
      'Creates a two-way reactive data binding between a form control (`<input>`, `<select>`, `<textarea>`) ' +
      'and a property declared in the component\'s `data:` section.\n\n' +
      '```html\n' +
      '<input type="text" b-model="username" />\n' +
      '```'
    )
  },
  'b-validate': {
    label: 'b-validate',
    detail: 'BlaiseVue Form Validation Engine (v2.5+)',
    snippet: 'b-validate="${1:required|min:3}"',
    documentation: new vscode.MarkdownString(
      '**`b-validate="rules"`**\n\n' +
      'Declarative form validation engine. Automatically registers validation rules on the field ' +
      'and maintains `$v` and `$errors` reactive states.\n\n' +
      '**Supported Rules:**\n' +
      '- `required`: Field must not be empty\n' +
      '- `email`: Must be a valid email address\n' +
      '- `min:N`: Minimum character length\n' +
      '- `max:N`: Maximum character length\n' +
      '- `numeric`: Digits only\n' +
      '- `alpha`: Letters only\n\n' +
      '```html\n' +
      '<input b-model="email" b-validate="required|email" :class="{ \'is-invalid\': $errors.email }" />\n' +
      '```'
    )
  },
  'b-for': {
    label: 'b-for',
    detail: 'BlaiseVue List Iteration Directive',
    snippet: 'b-for="${1:item} in ${2:collection}"',
    documentation: new vscode.MarkdownString(
      '**`b-for="item in collection"`** or **`b-for="(item, index) in collection"`**\n\n' +
      'Renders the element repeatedly based on an array from `data:` or `computed:`.\n\n' +
      '```html\n' +
      '<li b-for="(user, idx) in userList">{{ idx + 1 }}. {{ user.name }}</li>\n' +
      '```'
    )
  },
  'b-if': {
    label: 'b-if',
    detail: 'BlaiseVue Conditional Rendering',
    snippet: 'b-if="${1:condition}"',
    documentation: new vscode.MarkdownString(
      '**`b-if="condition"`**\n\n' +
      'Conditionally adds or removes the DOM element based on the truthiness of the expression.\n\n' +
      '```html\n' +
      '<div b-if="isLoggedIn">Welcome back, {{ user.name }}!</div>\n' +
      '```'
    )
  },
  'b-else-if': {
    label: 'b-else-if',
    detail: 'BlaiseVue Conditional Branch',
    snippet: 'b-else-if="${1:condition}"',
    documentation: new vscode.MarkdownString(
      '**`b-else-if="condition"`**\n\n' +
      'Must immediately follow a `b-if` or another `b-else-if` element.'
    )
  },
  'b-else': {
    label: 'b-else',
    detail: 'BlaiseVue Conditional Fallback',
    snippet: 'b-else',
    documentation: new vscode.MarkdownString(
      '**`b-else`**\n\n' +
      'Fallback branch that renders when the preceding `b-if` or `b-else-if` expression evaluates to false.'
    )
  },
  'b-show': {
    label: 'b-show',
    detail: 'BlaiseVue Conditional Display Toggle',
    snippet: 'b-show="${1:condition}"',
    documentation: new vscode.MarkdownString(
      '**`b-show="condition"`**\n\n' +
      'Toggles the element\'s CSS `display: none` property without unmounting it from the DOM.'
    )
  },
  'b-bind': {
    label: 'b-bind',
    detail: 'BlaiseVue Attribute Binding',
    snippet: 'b-bind:${1:attr}="${2:value}"',
    documentation: new vscode.MarkdownString('Dynamically binds an HTML attribute or prop to an expression.')
  },
  'b-on': {
    label: 'b-on',
    detail: 'BlaiseVue Event Listener',
    snippet: 'b-on:${1:event}="${2:method}"',
    documentation: new vscode.MarkdownString('Attaches an event listener to the element.')
  },
  '@click': {
    label: '@click',
    detail: 'Click Event Handler',
    snippet: '@click="${1:handleClick}"',
    documentation: new vscode.MarkdownString('Shorthand for `b-on:click`. Invokes the specified method when clicked.')
  },
  '@input': {
    label: '@input',
    detail: 'Input Event Handler',
    snippet: '@input="${1:handleInput}"',
    documentation: new vscode.MarkdownString('Triggers on each keystroke or value change in an input field.')
  },
  '@change': {
    label: '@change',
    detail: 'Change Event Handler',
    snippet: '@change="${1:handleChange}"',
    documentation: new vscode.MarkdownString('Triggers when an input loses focus after its value has changed.')
  },
  '@submit': {
    label: '@submit',
    detail: 'Form Submit Event Handler',
    snippet: '@submit.prevent="${1:handleSubmit}"',
    documentation: new vscode.MarkdownString('Intercepts form submission, typically with `.prevent` to avoid page reload.')
  },
  '@keydown': {
    label: '@keydown',
    detail: 'Keydown Event Handler',
    snippet: '@keydown="${1:handleKeydown}"',
    documentation: new vscode.MarkdownString('Triggers when a keyboard key is pressed down.')
  },
  '@keyup': {
    label: '@keyup',
    detail: 'Keyup Event Handler',
    snippet: '@keyup.enter="${1:handleEnter}"',
    documentation: new vscode.MarkdownString('Triggers when a keyboard key is released.')
  },
  ':class': {
    label: ':class',
    detail: 'Dynamic Class Binding',
    snippet: ':class="{ \'${1:active}\': ${2:isActive} }"',
    documentation: new vscode.MarkdownString('Dynamically toggles CSS class names based on truthy object properties.')
  },
  ':style': {
    label: ':style',
    detail: 'Dynamic Style Binding',
    snippet: ':style="{ ${1:color}: ${2:textColor} }"',
    documentation: new vscode.MarkdownString('Dynamically applies inline CSS styles from data properties.')
  },
  ':key': {
    label: ':key',
    detail: 'List Virtual DOM Key',
    snippet: ':key="${1:item.id}"',
    documentation: new vscode.MarkdownString('Provides a unique identifier for list items in `b-for` loops.')
  },
  ':disabled': {
    label: ':disabled',
    detail: 'Disabled State Binding',
    snippet: ':disabled="${1:isLoading}"',
    documentation: new vscode.MarkdownString('Binds the disabled HTML attribute to a boolean expression.')
  }
};

/**
 * BlaiseUI Components documentation and snippet database.
 */
const COMPONENTS_DOCS = {
  'bv-btn': {
    label: '<bv-btn>',
    detail: 'BlaiseUI Button Component',
    snippet: '<bv-btn variant="${1|primary,secondary,success,danger,warning,info,dark,outline-primary|}" @click="${2:handleClick}">\n  ${3:Button Text}\n</bv-btn>',
    documentation: new vscode.MarkdownString('Renders a styled action button with theme variants, sizes, and icon support.')
  },
  'bv-card': {
    label: '<bv-card>',
    detail: 'BlaiseUI Container Card',
    snippet: '<bv-card title="${1:Card Title}" subtitle="${2:Subtitle}">\n  <p>${3:Card Content}</p>\n</bv-card>',
    documentation: new vscode.MarkdownString('Card container component with header, body, subtitle, and footer slots.')
  },
  'bv-modal': {
    label: '<bv-modal>',
    detail: 'BlaiseUI Modal Dialog',
    snippet: '<bv-modal v-model="${1:showModal}" title="${2:Modal Title}">\n  <p>${3:Modal Body}</p>\n  <template #footer>\n    <bv-btn variant="secondary" @click="${1:showModal} = false">Fechar</bv-btn>\n  </template>\n</bv-modal>',
    documentation: new vscode.MarkdownString('Accessible overlay dialog with animations, backdrop, and reactive toggle.')
  },
  'bv-input': {
    label: '<bv-input>',
    detail: 'BlaiseUI Input Field',
    snippet: '<bv-input label="${1:Label}" b-model="${2:value}" placeholder="${3:Placeholder}" />',
    documentation: new vscode.MarkdownString('Input field with floating label, validation errors, and reactive two-way binding.')
  },
  'bv-checkbox': {
    label: '<bv-checkbox>',
    detail: 'BlaiseUI Checkbox',
    snippet: '<bv-checkbox b-model="${1:checked}" label="${2:Check me}" />',
    documentation: new vscode.MarkdownString('Reactive checkbox control with custom theme styling.')
  },
  'bv-switch': {
    label: '<bv-switch>',
    detail: 'BlaiseUI Toggle Switch',
    snippet: '<bv-switch b-model="${1:isEnabled}" label="${2:Enable Feature}" />',
    documentation: new vscode.MarkdownString('Smooth iOS/Bootstrap style toggle switch for boolean settings.')
  },
  'bv-select': {
    label: '<bv-select>',
    detail: 'BlaiseUI Select Dropdown',
    snippet: '<bv-select label="${1:Choose}" b-model="${2:selected}">\n  <option value="${3:val1}">${4:Option 1}</option>\n</bv-select>',
    documentation: new vscode.MarkdownString('Form select dropdown with reactive binding and validation support.')
  },
  'bv-badge': {
    label: '<bv-badge>',
    detail: 'BlaiseUI Badge / Pill',
    snippet: '<bv-badge variant="${1|primary,secondary,success,danger,warning,info|}">${2:Badge}</bv-badge>',
    documentation: new vscode.MarkdownString('Small status badge or count pill.')
  },
  'bv-alert': {
    label: '<bv-alert>',
    detail: 'BlaiseUI Contextual Alert',
    snippet: '<bv-alert variant="${1|info,success,warning,danger|}" dismissible>\n  ${2:Alert Message}\n</bv-alert>',
    documentation: new vscode.MarkdownString('Contextual feedback banner with optional dismiss button.')
  },
  'bv-toast': {
    label: '<bv-toast>',
    detail: 'BlaiseUI Toast Notification',
    snippet: '<bv-toast title="${1:Notification}">\n  ${2:Message}\n</bv-toast>',
    documentation: new vscode.MarkdownString('Corner toast notification with auto-dismiss timer.')
  },
  'bv-container': {
    label: '<bv-container>',
    detail: 'BlaiseUI Responsive Container',
    snippet: '<bv-container>\n  <bv-row>\n    <bv-col col="12" md="6">\n      ${1}\n    </bv-col>\n  </bv-row>\n</bv-container>',
    documentation: new vscode.MarkdownString('Grid system container with responsive breakpoints.')
  },
  'bv-row': {
    label: '<bv-row>',
    detail: 'BlaiseUI Grid Row',
    snippet: '<bv-row>\n  ${1}\n</bv-row>',
    documentation: new vscode.MarkdownString('Grid flexbox row container for columns.')
  },
  'bv-col': {
    label: '<bv-col>',
    detail: 'BlaiseUI Grid Column',
    snippet: '<bv-col col="${1:12}" md="${2:6}">\n  ${3}\n</bv-col>',
    documentation: new vscode.MarkdownString('Responsive column inside a grid row.')
  },
  'bv-datagrid': {
    label: '<bv-datagrid>',
    detail: 'BlaiseUI High-Performance DataGrid',
    snippet: '<bv-datagrid :items="${1:dataList}" :columns="${2:gridCols}" :paginate="true" />',
    documentation: new vscode.MarkdownString('Sortable, paginated, searchable grid for tabular datasets.')
  },
  'bv-spinner': {
    label: '<bv-spinner>',
    detail: 'BlaiseUI Loading Spinner',
    snippet: '<bv-spinner variant="${1|primary,secondary,light,dark|}" size="${2|sm,md,lg|}" />',
    documentation: new vscode.MarkdownString('Animated loading spinner indicator.')
  },
  'bv-chart': {
    label: '<bv-chart>',
    detail: 'BlaiseCharts Chart Component',
    snippet: '<bv-chart type="${1|line,bar,pie,doughnut,radar|}" :data="${2:chartData}" :options="${3:chartOptions}" height="${4:300px}" />',
    documentation: new vscode.MarkdownString('Reactive Chart.js data visualization component.')
  }
};

/**
 * Pascal script sections and helpers documentation.
 */
const PASCAL_DOCS = {
  'props:': {
    label: 'props:',
    detail: 'Component Props Section',
    snippet: 'props:\n  ${1:title}: string = \'${2:Default}\';\n',
    documentation: new vscode.MarkdownString('Defines reactive component inputs passed down from parent elements.')
  },
  'data:': {
    label: 'data:',
    detail: 'Component Reactive State Section',
    snippet: 'data:\n  ${1:counter}: integer = 0;\n  ${2:isActive}: boolean = false;\n',
    documentation: new vscode.MarkdownString('Declares reactive variables local to this component instance.')
  },
  'computed:': {
    label: 'computed:',
    detail: 'Component Computed Properties Section',
    snippet: 'computed:\n  function ${1:doubleCounter}: integer;\n  begin\n    Result := integer(this[\'${2:counter}\']) * 2;\n  end;\n',
    documentation: new vscode.MarkdownString('Defines cached getter functions automatically updated when reactive dependencies change.')
  },
  'watch:': {
    label: 'watch:',
    detail: 'Component Watchers Section',
    snippet: 'watch:\n  procedure ${1:onStateChange}(newVal, oldVal: JSValue);\n  begin\n    console.log(\'Value changed: \', newVal);\n  end;\n',
    documentation: new vscode.MarkdownString('Defines side-effect callbacks triggered whenever a watched state variable mutates.')
  },
  'methods:': {
    label: 'methods:',
    detail: 'Component Methods Section',
    snippet: 'methods:\n  procedure ${1:handleClick}(ev: JSValue);\n  begin\n    ${2}\n  end;\n',
    documentation: new vscode.MarkdownString('Declares methods callable from template event handlers or other methods.')
  },
  'created:': {
    label: 'created:',
    detail: 'Lifecycle Hook: created',
    snippet: 'created:\n  begin\n    ${1}\n  end;\n',
    documentation: new vscode.MarkdownString('Runs immediately after component instance and reactive data have been initialized.')
  },
  'mounted:': {
    label: 'mounted:',
    detail: 'Lifecycle Hook: mounted',
    snippet: 'mounted:\n  begin\n    ${1}\n  end;\n',
    documentation: new vscode.MarkdownString('Runs once the component DOM elements have been attached to the page.')
  },
  'CallMethod': {
    label: 'CallMethod',
    detail: 'Invoke Component Method Helper',
    snippet: 'CallMethod(this, \'${1:methodName}\'${2:, [arg1]});',
    documentation: new vscode.MarkdownString('Safely dispatches a named component method with optional arguments.')
  },
  'GetFieldStr': {
    label: 'GetFieldStr',
    detail: 'Read String Field from JSValue',
    snippet: 'GetFieldStr(${1:obj}, \'${2:field}\')',
    documentation: new vscode.MarkdownString('Extracts a string property from a `JSValue` object safely.')
  },
  'GetFieldInt': {
    label: 'GetFieldInt',
    detail: 'Read Integer Field from JSValue',
    snippet: 'GetFieldInt(${1:obj}, \'${2:field}\', ${3:0})',
    documentation: new vscode.MarkdownString('Extracts an integer property from a `JSValue` object with fallback default.')
  }
};

/**
 * Injected globals documentation database for Hover and Autocomplete.
 */
const GLOBALS_DOCS = {
  '$store': {
    label: '$store',
    detail: 'BlaiseVue Global Reactive Store',
    documentation: new vscode.MarkdownString(
      '**`$store`**\n\n' +
      'Global reactive state shared across all components and pages in the application.\n\n' +
      '```pascal\n' +
      'user := string(this[\'$store\'][\'user\']);\n' +
      'this[\'$store\'][\'theme\'] := \'dark\';\n' +
      '```'
    )
  },
  '$router': {
    label: '$router',
    detail: 'BlaiseVue Router Instance',
    documentation: new vscode.MarkdownString(
      '**`$router`**\n\n' +
      'Client-side SPA router providing programmatic navigation methods.\n\n' +
      '```pascal\n' +
      'this[\'$router\'].push(\'/about\');\n' +
      'this[\'$router\'].back();\n' +
      '```'
    )
  },
  '$route': {
    label: '$route',
    detail: 'BlaiseVue Active Route Object',
    documentation: new vscode.MarkdownString(
      '**`$route`**\n\n' +
      'Contains information about the currently active route, including parameters and query strings.\n\n' +
      '```pascal\n' +
      'userId := string(this[\'$route\'][\'params\'][\'id\']);\n' +
      '```'
    )
  },
  '$i18n': {
    label: '$i18n',
    detail: 'BlaiseVue Multilingual Internationalization Engine (v2.5+)',
    documentation: new vscode.MarkdownString(
      '**`$i18n`**\n\n' +
      'Global localization manager for multi-language apps.\n\n' +
      '```pascal\n' +
      'window[\'$i18n\'].setLocale(\'pt\');\n' +
      '```'
    )
  },
  '$t': {
    label: '$t',
    detail: 'BlaiseVue Translation String Helper',
    documentation: new vscode.MarkdownString(
      '**`$t(\'key\')`**\n\n' +
      'Translates a message key according to the currently active `$i18n.locale`.\n\n' +
      '```html\n' +
      '<h2>{{ $t(\'nav.home\') }}</h2>\n' +
      '```'
    )
  },
  '$theme': {
    label: '$theme',
    detail: 'BlaiseThemes Bootswatch Theme Manager (v2.6+)',
    documentation: new vscode.MarkdownString(
      '**`$theme`**\n\n' +
      'Global theme manager supporting 9+ Bootswatch themes, dark/light toggle, and `localStorage` persistence.\n\n' +
      '```pascal\n' +
      'window[\'$theme\'].setTheme(\'darkly\');\n' +
      'window[\'$theme\'].toggle();\n' +
      '```'
    )
  },
  '$errors': {
    label: '$errors',
    detail: 'BlaiseVue Form Validation Error Messages',
    documentation: new vscode.MarkdownString(
      '**`$errors`**\n\n' +
      'Reactive map containing current validation error messages for each field validated via `b-validate`.\n\n' +
      '```html\n' +
      '<span class="error" v-if="$errors.email">{{ $errors.email }}</span>\n' +
      '```'
    )
  },
  '$v': {
    label: '$v',
    detail: 'BlaiseVue Form Validation State Model',
    documentation: new vscode.MarkdownString(
      '**`$v`**\n\n' +
      'Exposes global form validation state:\n' +
      '- `$v.$invalid`: Boolean (true if any field has errors)\n' +
      '- `$v.$dirty`: Boolean (true if user touched any input)\n' +
      '- `$v.$touch()`: Marks all fields as touched\n' +
      '- `$v.$reset()`: Clears validation errors\n'
    )
  },
  '$wasm': {
    label: '$wasm',
    detail: 'BlaiseVue WebAssembly Accelerator Engine (v3.0+)',
    documentation: new vscode.MarkdownString(
      '**`$wasm`**\n\n' +
      'WebAssembly runtime helper compiled from Free Pascal (`fpc -Twasi`).\n\n' +
      '```pascal\n' +
      'if Boolean(window[\'$wasm\'] && window[\'$wasm\'][\'isReady\']) then\n' +
      '  res := window[\'$wasm\'].call(\'calculate\', [1000]);\n' +
      '```'
    )
  },
  '$mobile': {
    label: '$mobile',
    detail: 'BlaiseVue Mobile & Capacitor Hardware Engine (v3.5+)',
    documentation: new vscode.MarkdownString(
      '**`$mobile`**\n\n' +
      'Unified Object Pascal access to native mobile hardware via Capacitor:\n' +
      '- `$mobile.camera.takePhoto(onSuccess, onError)`\n' +
      '- `$mobile.geolocation.getCurrentPosition(onSuccess, onError)`\n' +
      '- `$mobile.haptics.vibrate(durationMs)` / `.impact(\'heavy\')`\n' +
      '- `$mobile.device.getInfo(onSuccess)`\n' +
      '- `$mobile.statusBar.setBackgroundColor(\'#1a252f\')`\n' +
      '- `$mobile.isNative()`: Boolean\n' +
      '- `$mobile.getPlatform()`: \'android\' | \'ios\' | \'web\'\n'
    )
  }
};

/**
 * Counts net unclosed HTML tags in a template line.
 */
function countUnclosedTags(s) {
  let balance = 0;
  let p = 0;
  while (p < s.length) {
    if (s[p] === '<' && p < s.length - 1) {
      if (s.substr(p, 4) === '<!--') {
        const endPos = s.indexOf('-->', p);
        if (endPos === -1) break;
        p = endPos + 3;
        continue;
      }

      const tagStart = p;
      let inQuotes = false;
      let quoteChar = '';
      p++;
      while (p < s.length) {
        if (s[p] === '"' || s[p] === "'") {
          if (!inQuotes) { inQuotes = true; quoteChar = s[p]; }
          else if (s[p] === quoteChar) { inQuotes = false; }
        } else if (s[p] === '>' && !inQuotes) {
          break;
        }
        p++;
      }
      const tag = s.substring(tagStart, p + 1);
      const lowTag = tag.toLowerCase();

      if (tag.startsWith('</')) {
        balance--;
      } else if (
        tag.endsWith('/>') ||
        lowTag.startsWith('<br') ||
        lowTag.startsWith('<hr') ||
        lowTag.startsWith('<img') ||
        lowTag.startsWith('<input') ||
        (lowTag.startsWith('<slot') && !s.toLowerCase().includes('</slot>'))
      ) {
        // self-closing / void
      } else {
        balance++;
      }
    }
    p++;
  }
  return balance;
}

/**
 * Formats a BlaiseVue Single File Component (.bv) string cleanly.
 */
function formatBVContent(content) {
  const inLines = content.split(/\r?\n/);
  const outLines = [];
  let section = 0; // 0=none, 1=template, 2=script, 3=style
  let tmplIndent = 1;
  let inMethodBody = false;
  let styleIndent = 1;
  let lastEmpty = false;

  for (let i = 0; i < inLines.length; i++) {
    const raw = inLines[i];
    const trimmed = raw.trim();
    const lowTrim = trimmed.toLowerCase();

    if (trimmed === '') {
      if (!lastEmpty && outLines.length > 0) {
        outLines.push('');
        lastEmpty = true;
      }
      continue;
    }
    lastEmpty = false;

    if (lowTrim.startsWith('<template')) {
      section = 1;
      tmplIndent = 1;
      outLines.push(trimmed);
    } else if (lowTrim.startsWith('</template>')) {
      section = 0;
      outLines.push('</template>');
      outLines.push('');
      lastEmpty = true;
    } else if (lowTrim.startsWith('<script')) {
      section = 2;
      inMethodBody = false;
      outLines.push(trimmed);
    } else if (lowTrim.startsWith('</script>')) {
      section = 0;
      outLines.push('</script>');
      outLines.push('');
      lastEmpty = true;
    } else if (lowTrim.startsWith('<style')) {
      section = 3;
      styleIndent = 1;
      outLines.push(trimmed);
    } else if (lowTrim.startsWith('</style>')) {
      section = 0;
      outLines.push('</style>');
    } else {
      switch (section) {
        case 1: { // Template
          if (trimmed.startsWith('</')) {
            if (tmplIndent > 1) tmplIndent--;
            outLines.push('  '.repeat(tmplIndent) + trimmed);
          } else {
            outLines.push('  '.repeat(tmplIndent) + trimmed);
            tmplIndent += countUnclosedTags(trimmed);
            if (tmplIndent < 1) tmplIndent = 1;
          }
          break;
        }
        case 2: { // Script
          if (
            ['props:', 'data:', 'computed:', 'watch:', 'methods:', 'created:', 'mounted:', 'updated:', 'unmounted:', 'provide:', 'inject:', 'routes:'].includes(lowTrim)
          ) {
            inMethodBody = false;
            outLines.push('  ' + trimmed);
          } else if (lowTrim.startsWith('procedure ') || lowTrim.startsWith('function ')) {
            inMethodBody = false;
            outLines.push('    ' + trimmed);
          } else if (lowTrim === 'var' || lowTrim === 'const') {
            inMethodBody = false;
            outLines.push('    ' + trimmed);
          } else if (lowTrim === 'begin') {
            outLines.push('    begin');
            inMethodBody = true;
          } else if (lowTrim === 'end;' || lowTrim === 'end') {
            inMethodBody = false;
            outLines.push('    ' + trimmed);
          } else if (inMethodBody) {
            outLines.push('      ' + trimmed);
          } else {
            outLines.push('    ' + trimmed);
          }
          break;
        }
        case 3: { // Style
          if (trimmed.includes('{') && trimmed.includes('}')) {
            outLines.push('  ' + trimmed);
          } else if (trimmed.includes('{')) {
            outLines.push('  ' + trimmed);
            styleIndent = 2;
          } else if (trimmed.startsWith('}')) {
            outLines.push('  }');
            styleIndent = 1;
          } else {
            outLines.push('  '.repeat(styleIndent) + trimmed);
          }
          break;
        }
        default:
          outLines.push(trimmed);
      }
    }
  }

  return outLines.join('\n') + '\n';
}

/**
 * Activates the BlaiseVue VS Code extension.
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {
  console.log('🚀 BlaiseVue Extension is active!');

  // 1. Hover Provider for .bv files
  const hoverProvider = vscode.languages.registerHoverProvider('blaisevue', {
    provideHover(document, position) {
      const range = document.getWordRangeAtPosition(position, /[\$@:a-zA-Z0-9_-]+/);
      if (!range) return null;

      const word = document.getText(range);

      // Check Directives & Events
      if (DIRECTIVES_DOCS[word]) {
        return new vscode.Hover(DIRECTIVES_DOCS[word].documentation, range);
      }

      // Check BlaiseUI Components
      const tagMatch = word.replace(/^[<>/]+|[>]+$/g, '');
      if (COMPONENTS_DOCS[tagMatch]) {
        return new vscode.Hover(COMPONENTS_DOCS[tagMatch].documentation, range);
      }

      // Check Pascal docs
      if (PASCAL_DOCS[word]) {
        return new vscode.Hover(PASCAL_DOCS[word].documentation, range);
      }

      // Check Injected Globals
      if (GLOBALS_DOCS[word]) {
        return new vscode.Hover(GLOBALS_DOCS[word].documentation, range);
      }

      return null;
    }
  });

  // 2. Comprehensive Completion Provider for .bv Single File Components
  const completionProvider = vscode.languages.registerCompletionItemProvider(
    'blaisevue',
    {
      provideCompletionItems(document, position) {
        const linePrefix = document.lineAt(position).text.substr(0, position.character);
        const completions = [];

        // A. BlaiseUI Components (<bv-)
        if (linePrefix.match(/<bv-?[a-zA-Z0-9_-]*$/) || linePrefix.endsWith('<')) {
          for (const [tag, item] of Object.entries(COMPONENTS_DOCS)) {
            const c = new vscode.CompletionItem(tag, vscode.CompletionItemKind.Class);
            c.detail = item.detail;
            c.documentation = item.documentation;
            c.insertText = new vscode.SnippetString(item.snippet);
            completions.push(c);
          }
        }

        // B. Directives & Events (b-, @, :, v-)
        if (
          linePrefix.match(/(<[a-zA-Z0-9_-]+\s+[^>]*?)(b-?|@|:|v-?)[a-zA-Z0-9_-]*$/) ||
          linePrefix.endsWith('b-') || linePrefix.endsWith('@') || linePrefix.endsWith(':')
        ) {
          for (const [key, item] of Object.entries(DIRECTIVES_DOCS)) {
            const c = new vscode.CompletionItem(key, vscode.CompletionItemKind.Keyword);
            c.detail = item.detail;
            c.documentation = item.documentation;
            c.insertText = new vscode.SnippetString(item.snippet);
            completions.push(c);
          }
        }

        // C. Globals ($store, $router, $v, etc.)
        if (linePrefix.match(/\$[a-zA-Z0-9_]*$/)) {
          for (const [key, item] of Object.entries(GLOBALS_DOCS)) {
            const c = new vscode.CompletionItem(key, vscode.CompletionItemKind.Variable);
            c.detail = item.detail;
            c.documentation = item.documentation;
            c.insertText = key;
            completions.push(c);
          }
        }

        // D. Pascal Script sections & helpers
        const fullDoc = document.getText();
        const cursorOffset = document.offsetAt(position);
        const scriptStart = fullDoc.indexOf('<script');
        const scriptEnd = fullDoc.indexOf('</script>');
        const isInScript = (scriptStart !== -1 && cursorOffset > scriptStart && (scriptEnd === -1 || cursorOffset < scriptEnd));

        if (isInScript) {
          for (const [key, item] of Object.entries(PASCAL_DOCS)) {
            const c = new vscode.CompletionItem(key, vscode.CompletionItemKind.Snippet);
            c.detail = item.detail;
            c.documentation = item.documentation;
            c.insertText = new vscode.SnippetString(item.snippet);
            completions.push(c);
          }
        }

        return completions;
      }
    },
    '<', 'b', '-', '@', ':', '$', 'p', 'd', 'm', 'c', 'w'
  );

  // 3. Document Formatting Provider (Shift+Alt+F & Format on Save)
  const formattingProvider = vscode.languages.registerDocumentFormattingEditProvider('blaisevue', {
    provideDocumentFormattingEdits(document) {
      const fullText = document.getText();
      const formatted = formatBVContent(fullText);
      if (formatted === fullText) return [];

      const fullRange = new vscode.Range(
        document.positionAt(0),
        document.positionAt(fullText.length)
      );
      return [vscode.TextEdit.replace(fullRange, formatted)];
    }
  });

  // 4. Command: blaisevue.format
  const cmdFormat = vscode.commands.registerCommand('blaisevue.format', async () => {
    const editor = vscode.window.activeTextEditor;
    if (!editor || !editor.document.fileName.endsWith('.bv')) {
      vscode.window.showInformationMessage('No active .bv component to format.');
      return;
    }
    await vscode.commands.executeCommand('editor.action.formatDocument');
    vscode.window.showInformationMessage('✅ BlaiseVue Component formatted successfully!');
  });

  // 5. Register Command: bv run dev
  const cmdDev = vscode.commands.registerCommand('blaisevue.dev', () => {
    runTerminalCommand('bv run dev');
  });

  // 6. Register Command: bv build
  const cmdBuild = vscode.commands.registerCommand('blaisevue.build', () => {
    runTerminalCommand('bv build');
  });

  // 7. Register Command: bv test
  const cmdTest = vscode.commands.registerCommand('blaisevue.test', () => {
    runTerminalCommand('bv test');
  });

  // 8. Register Command: bv doc
  const cmdDoc = vscode.commands.registerCommand('blaisevue.doc', () => {
    runTerminalCommand('bv doc');
  });

  // 9. Register Command: Create New Component
  const cmdNewComp = vscode.commands.registerCommand('blaisevue.newComponent', async (uri) => {
    const compName = await vscode.window.showInputBox({
      prompt: 'Enter component name (e.g. UserCard or MyWidget):',
      placeHolder: 'MyComponent'
    });

    if (!compName) return;

    let targetDir = uri ? uri.fsPath : vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
    if (!targetDir) {
      vscode.window.showErrorMessage('No workspace folder open.');
      return;
    }

    if (fs.existsSync(path.join(targetDir, 'src', 'components'))) {
      targetDir = path.join(targetDir, 'src', 'components');
    }

    const cleanName = compName.replace(/\.bv$/, '');
    const filePath = path.join(targetDir, `${cleanName}.bv`);

    if (fs.existsSync(filePath)) {
      vscode.window.showErrorMessage(`File ${cleanName}.bv already exists!`);
      return;
    }

    const templateContent = `<template>
  <div class="${cleanName.toLowerCase()}-wrapper">
    <h3>{{ title }}</h3>
    <slot></slot>
  </div>
</template>

<script>
  props:
    title: string = '${cleanName}';

  data:
    isActive: boolean = true;

  methods:
    procedure handleAction(ev: JSValue);
    begin
      console.log('Action triggered on ${cleanName}');
    end;
</script>

<style>
  .${cleanName.toLowerCase()}-wrapper {
    padding: 1rem;
    border-radius: 6px;
  }
</style>
`;

    fs.writeFileSync(filePath, templateContent, 'utf-8');
    const doc = await vscode.workspace.openTextDocument(filePath);
    await vscode.window.showTextDocument(doc);
    vscode.window.showInformationMessage(`✅ Component ${cleanName}.bv created successfully!`);
  });

  // 10. Register Command: bv mobile sync
  const cmdMobileSync = vscode.commands.registerCommand('blaisevue.mobileSync', () => {
    runTerminalCommand('bv mobile sync');
  });

  // 11. Register Command: bv mobile open
  const cmdMobileOpen = vscode.commands.registerCommand('blaisevue.mobileOpen', () => {
    runTerminalCommand('bv mobile open');
  });

  context.subscriptions.push(
    hoverProvider,
    completionProvider,
    formattingProvider,
    cmdFormat,
    cmdDev,
    cmdBuild,
    cmdTest,
    cmdDoc,
    cmdNewComp,
    cmdMobileSync,
    cmdMobileOpen
  );
}

/**
 * Runs a command in a dedicated BlaiseVue VS Code terminal.
 * @param {string} cmd
 */
function runTerminalCommand(cmd) {
  let terminal = vscode.window.terminals.find(t => t.name === 'BlaiseVue');
  if (!terminal) {
    terminal = vscode.window.createTerminal('BlaiseVue');
  }
  terminal.show();
  terminal.sendText(cmd);
}

function deactivate() {}

module.exports = {
  activate,
  deactivate,
  formatBVContent
};
