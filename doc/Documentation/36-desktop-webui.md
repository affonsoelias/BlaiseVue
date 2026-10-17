# 36. Multiplatform Desktop & Lazarus IDE (bv desktop) - Phase 3

A **Fase 3 da plataforma universal BlaiseVue (v3.5)** introduz a arquitetura de aplicações desktop nativas multiplataforma utilizando **Free Pascal**, **Lazarus IDE** e a biblioteca **WebUI** (com fallback transparente para o modo aplicação dos navegadores do sistema).

Essa arquitetura viabiliza binários desktop ultraleves (**< 10 MB** em disco, **< 40 MB** de uso de RAM), sem a sobrecarga de empacotar o Chromium/Electron e sem dependências legadas de GTK2 no Linux.

---

## 🖥️ Visão Geral da Arquitetura Desktop

```text
┌────────────────────────────────────────────────────────┐
│         BlaiseVue Single File Components (.bv)         │
│             Acesso nativo via helper $desktop          │
└──────────────────────────┬─────────────────────────────┘
                           │ Transpilação (bv run build)
┌──────────────────────────▼─────────────────────────────┐
│                 Bundle Web Otimizado                   │
│          dist/ (index.html, main.js, css/)             │
└──────────────────────────┬─────────────────────────────┘
                           │ Sincronização (bv desktop sync)
┌──────────────────────────▼─────────────────────────────┐
│          Projeto Lazarus / Free Pascal (desktop/)      │
│     <AppName>.lpi, <AppName>.lpr, uDesktopBridge.pas   │
└──────────────────────────┬─────────────────────────────┘
                           │ Compilação FPC / Lazarus (bv desktop build)
┌──────────────────────────▼─────────────────────────────┐
│          Binário Executável Nativo (< 10 MB)           │
│       desktop/bin/<AppName>.exe (Win/Linux/macOS)      │
│  (Runtime WebUI C ou Fallback Modo App Edge/Chrome)    │
└────────────────────────────────────────────────────────┘
```

---

## 🛠️ Comandos da CLI (`bv desktop`)

```bash
# 1. Scaffolding do projeto desktop completo (Lazarus .lpi, .lpr, bridges, assets, bin/, units/)
bv desktop init [NomeDoApp]

# 2. Sincroniza o build de produção (dist/) com a pasta desktop/assets/
bv desktop sync

# 3. Compilação em Modo DEBUG (com janela de console para diagnósticos e logs):
bv desktop build               # Compila para o SO atual (ex: Windows -> desktop/bin/windows/)
bv desktop build windows       # Compila especificamente para Windows
bv desktop build linux         # Compila especificamente para Linux
bv desktop run                 # Executa o binário do SO atual em modo depuração

# 4. Compilação em Modo RELEASE (para o Usuário Final - 100% GUI, sem janela de console):
bv desktop build --release             # Compila para o SO atual em modo Release
bv desktop build windows --release     # Compila para Windows em desktop/bin/windows/
bv desktop build linux --release       # Compila para Linux em desktop/bin/linux/
bv desktop build macos --release       # Compila para macOS em desktop/bin/macos/
bv desktop run windows --release       # Executa no Windows sem janela de console

# 5. Compilação para TODAS as Plataformas de uma só vez:
bv desktop build all                   # Compila Windows, Linux e macOS (Debug)
bv desktop build all --release         # Compila Windows, Linux e macOS (Release)
```

### ⚙️ Modos de Compilação & Plataformas

| Plataforma / Modo | Comando CLI | Modo Lazarus IDE | Comportamento da Janela | Binário Gerado |
|---|---|---|---|---|
| **Windows Debug** | `bv desktop run windows` | `Debug` | **Janela GUI + Console de Logs** | `desktop/bin/windows/<App>.exe` |
| **Windows Release** | `bv desktop run windows --release` | `Release` | **Apenas Janela GUI (Sem Console)** | `desktop/bin/windows/<App>.exe` |
| **Linux Debug** | `bv desktop build linux` | `Debug` | Executável ELF nativo + Logs | `desktop/bin/linux/<App>` |
| **Linux Release** | `bv desktop build linux --release` | `Release` | Executável ELF otimizado | `desktop/bin/linux/<App>` |
| **macOS Release** | `bv desktop build macos --release` | `Release` | Executável Mach-O / App Bundle | `desktop/bin/macos/<App>` |
| **Todas as Plataformas** | `bv desktop build all --release` | - | Gera binários para Win, Linux e macOS | `desktop/bin/<plataforma>/` |

---

## 📦 Estrutura do Diretório `desktop/`

Quando executado `bv desktop init [NomeDoApp]`, a seguinte estrutura multiplataforma é gerada automaticamente:

```text
meu-projeto/
├── desktop/
│   ├── assets/                 # Frontend sincronizado (dist/ compartilhado entre todos os SOs)
│   ├── bin/                    # Binários executáveis nativos separados por plataforma
│   │   ├── windows/            # Executável Windows (MeuApp.exe e webui-2.dll)
│   │   ├── linux/              # Executável nativo Linux ELF (MeuApp e libwebui-2.so)
│   │   └── macos/              # Executável macOS / App Bundle (MeuApp e libwebui-2.dylib)
│   ├── units/                  # Caches de compilação (.ppu, .o) isolados por plataforma
│   │   ├── windows/            # Evita conflitos de checksum ao compilar no Windows
│   │   ├── linux/              # Evita conflitos de checksum ao compilar no Linux
│   │   └── macos/              # Evita conflitos de checksum ao compilar no macOS
│   ├── MeuApp.lpi              # Projeto Lazarus (abrir na IDE e pressionar F9)
│   ├── MeuApp.lpr              # Programa principal em Free Pascal
│   ├── webui.pas               # Carregador dinâmico da biblioteca WebUI C
│   ├── uDesktopBridge.pas      # Bridge RPC nativo em Pascal para $desktop
│   └── README.md               # Instruções de desenvolvimento e build
```

---

## 🔌 API de Janela e Hardware (`$desktop`)

Dentro de qualquer componente BlaiseVue (`.bv`), o helper global `$desktop` está disponível e injetado diretamente no escopo reativo (`this.$desktop`):

### 1. Detecção de Ambiente
```pascal
// Verifica se a aplicação está rodando como desktop nativo
if this.$desktop.isDesktop() then
  console.log('Ambiente Desktop Detectado!');

// Retorna 'windows', 'linux', 'macos' ou 'browser'
var plat := this.$desktop.getPlatform();
```

### 2. Controle de Janela Nativa
```pascal
// Minimiza a janela nativa
this.$desktop.window.minimize();

// Maximiza ou restaura a janela nativa
this.$desktop.window.maximize();

// Altera o título da barra superior da janela
this.$desktop.window.setTitle('Novo Título do Sistema');

// Alterna modo tela cheia (kiosk)
this.$desktop.window.setFullScreen(true);

// Fecha a aplicação
this.$desktop.window.close();
```

### 3. Notificações do Sistema e URLs Externas
```pascal
// Notificação nativa na área de trabalho
this.$desktop.notification.show('Download Concluído', 'Arquivo salvo com sucesso!');

// Abre URL no navegador padrão do usuário (fora da janela do app)
this.$desktop.shell.openURL('https://blaisevue.dev');
```

### 4. Diálogos de Arquivos
```pascal
// Diálogo nativo para abrir arquivo
this.$desktop.dialog.openFile(procedure(fileInfo: JSValue)
begin
  console.log('Arquivo selecionado:', fileInfo);
end);

// Diálogo nativo para salvar arquivo
this.$desktop.dialog.saveFile('relatorio.pdf', procedure(savedFile: JSValue)
begin
  console.log('Arquivo salvo com sucesso:', savedFile);
end);
```

### 5. Informações do Sistema & RPC Nativo com Pascal
```pascal
// Obtém dados da máquina (SO, CPU, Compilador)
this.$desktop.system.getInfo(procedure(sysInfo: JSValue)
begin
  console.log('Informações do sistema:', sysInfo);
end);

// Executa função Pascal personalizada no backend nativo
this.$desktop.rpc.call('minha_funcao_pascal', payload, procedure(res: JSValue)
begin
  console.log('Resposta do Free Pascal:', res);
end);
```

---

## 🎯 Integração com Lazarus IDE (F9 Ready)

O arquivo `.lpi` gerado pelo comando `bv desktop init` é 100% compatível com a IDE oficial do **Lazarus**:

1. Abra a IDE do Lazarus.
2. Acesse **Projeto > Abrir Projeto...** e selecione `desktop/<AppName>.lpi`.
3. Pressione a tecla **F9** (ou clique no botão verde *Executar*).
4. O Lazarus compila instantaneamente o código Object Pascal com otimizações nativas e inicializa a janela do aplicativo!

---

## 🛡️ Fallback Automático e Zero Dependência

Se a biblioteca C do WebUI (`webui-2.dll` no Windows ou `libwebui-2.so` no Linux) não estiver presente na pasta do binário, o executável nativo detecta automaticamente os navegadores modernos instalados no computador (**Microsoft Edge**, **Google Chrome**, **Brave** ou **Chromium**) e executa a aplicação em **modo janela de aplicativo** (`--app`), garantindo que o programa abra perfeitamente de forma imediata sem exigir nenhuma instalação externa do usuário.
