const vscode = require('vscode');
const fs = require('fs');
const path = require('path');

/**
 * Directives documentation database for Hover and Autocomplete.
 */
const DIRECTIVES_DOCS = {
  'b-model': {
    label: 'b-model',
    detail: 'BlaiseVue Two-Way Reactive Binding',
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
    documentation: new vscode.MarkdownString(
      '**`b-else-if="condition"`**\n\n' +
      'Must immediately follow a `b-if` or another `b-else-if` element.'
    )
  },
  'b-else': {
    label: 'b-else',
    detail: 'BlaiseVue Conditional Fallback',
    documentation: new vscode.MarkdownString(
      '**`b-else`**\n\n' +
      'Fallback branch that renders when the preceding `b-if` or `b-else-if` expression evaluates to false.'
    )
  },
  'b-show': {
    label: 'b-show',
    detail: 'BlaiseVue Conditional Display Toggle',
    documentation: new vscode.MarkdownString(
      '**`b-show="condition"`**\n\n' +
      'Toggles the element\'s CSS `display: none` property without unmounting it from the DOM.'
    )
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
      '// Read\n' +
      'user := string(this[\'$store\'][\'user\']);\n' +
      '// Mutate\n' +
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
      '// Switch language dynamically\n' +
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
  }
};

/**
 * Activates the BlaiseVue VS Code extension.
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {
  console.log('🚀 BlaiseVue Extension is active!');

  // 1. Hover Provider for .bv files
  const hoverProvider = vscode.languages.registerHoverProvider('blaisevue', {
    provideHover(document, position) {
      const range = document.getWordRangeAtPosition(position, /[\$a-zA-Z0-9_-]+/);
      if (!range) return null;

      const word = document.getText(range);

      // Check Directives
      if (DIRECTIVES_DOCS[word]) {
        return new vscode.Hover(DIRECTIVES_DOCS[word].documentation, range);
      }

      // Check Injected Globals
      if (GLOBALS_DOCS[word]) {
        return new vscode.Hover(GLOBALS_DOCS[word].documentation, range);
      }

      return null;
    }
  });

  // 2. Completion Provider for Directives & Globals
  const completionProvider = vscode.languages.registerCompletionItemProvider(
    'blaisevue',
    {
      provideCompletionItems(document, position) {
        const linePrefix = document.lineAt(position).text.substr(0, position.character);
        const completions = [];

        // Directives completions
        if (linePrefix.match(/(<[a-zA-Z0-9_-]+\s+[^>]*?)b-?$/) || linePrefix.endsWith('b-')) {
          for (const [key, item] of Object.entries(DIRECTIVES_DOCS)) {
            const c = new vscode.CompletionItem(key, vscode.CompletionItemKind.Keyword);
            c.detail = item.detail;
            c.documentation = item.documentation;
            c.insertText = new vscode.SnippetString(`${key}="$1"`);
            completions.push(c);
          }
        }

        // Globals ($store, $wasm, etc.)
        if (linePrefix.endsWith('$')) {
          for (const [key, item] of Object.entries(GLOBALS_DOCS)) {
            const nameWithoutDollar = key.substring(1);
            const c = new vscode.CompletionItem(nameWithoutDollar, vscode.CompletionItemKind.Variable);
            c.detail = item.detail;
            c.documentation = item.documentation;
            c.insertText = nameWithoutDollar;
            completions.push(c);
          }
        }

        return completions;
      }
    },
    'b', '-', '$'
  );

  // 3. Register Command: bv run dev
  const cmdDev = vscode.commands.registerCommand('blaisevue.dev', () => {
    runTerminalCommand('bv run dev');
  });

  // 4. Register Command: bv build
  const cmdBuild = vscode.commands.registerCommand('blaisevue.build', () => {
    runTerminalCommand('bv build');
  });

  // 5. Register Command: bv test
  const cmdTest = vscode.commands.registerCommand('blaisevue.test', () => {
    runTerminalCommand('bv test');
  });

  // 6. Register Command: bv doc
  const cmdDoc = vscode.commands.registerCommand('blaisevue.doc', () => {
    runTerminalCommand('bv doc');
  });

  // 7. Register Command: Create New Component
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

  context.subscriptions.push(
    hoverProvider,
    completionProvider,
    cmdDev,
    cmdBuild,
    cmdTest,
    cmdDoc,
    cmdNewComp
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
  deactivate
};
