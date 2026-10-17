# 35. Hybrid Mobile Platform & Capacitor (bv mobile) - Phase 2

A **Fase 2 da plataforma universal BlaiseVue (v3.5)** habilita a geração e execução nativa de aplicações BlaiseVue em plataformas móveis (**Android** e **iOS**), utilizando o ecossistema moderno do **Capacitor** em conjunto com a compilação Pascal do framework.

Dessa forma, o mesmo código-fonte em Object Pascal e Single File Components (`.bv`) roda tanto na Web quanto empacotado em APKs nativos para celulares e tablets.

---

## 📱 Visão Geral da Arquitetura Móvel

```text
┌────────────────────────────────────────────────────────┐
│         BlaiseVue Single File Components (.bv)         │
│          Lógica 100% Object Pascal + Templates          │
└──────────────────────────┬─────────────────────────────┘
                           │ Transpilação (bv run build)
┌──────────────────────────▼─────────────────────────────┐
│                 Bundle Web Otimizado                   │
│          dist/ (index.html, main.js, css/)             │
└──────────────────────────┬─────────────────────────────┘
                           │ Sincronização (bv mobile sync)
┌──────────────────────────▼─────────────────────────────┐
│           Capacitor Native Platform (mobile/)          │
│   mobile/android/ (Android Studio) / mobile/ios/ (Xcode)│
└──────────────────────────┬─────────────────────────────┘
                           │ Compilação (bv mobile build [target] [--release])
┌──────────────────────────▼─────────────────────────────┐
│       Pacotes Instaláveis Nativos (mobile/bin/)        │
│   mobile/bin/android/<App>-debug.apk                   │
│   mobile/bin/android/<App>-release.apk                 │
│   mobile/bin/ios/<App>.ipa                             │
└────────────────────────────────────────────────────────┘
```

---

## 📦 Estrutura do Diretório `mobile/`

Quando executado `bv mobile init [NomeDoApp] [com.empresa.app]`, a seguinte estrutura multiplataforma é gerada na pasta `mobile/`:

```text
meu-projeto/
├── mobile/
│   ├── capacitor.config.json   # Configuração do Capacitor com caminhos para mobile/android e mobile/ios
│   ├── android/                # Projeto nativo Android Studio (Gradle Wrapper, app/src, Manifest)
│   ├── ios/                    # Projeto nativo Xcode (quando adicionado)
│   ├── bin/                    # Binários instaláveis prontos separados por plataforma
│   │   ├── android/            # MeuApp-debug.apk e MeuApp-release.apk
│   │   └── ios/                # MeuApp.ipa
│   └── README.md               # Instruções de desenvolvimento e comandos
├── desktop/                    # Projeto Lazarus / WebUI desktop (Fase 3)
├── src/                        # Componentes .bv e código Object Pascal compartilhados
└── dist/                       # Bundle web compilado
```

---

## 📋 Guia de Preparação do Ambiente Mobile (Android)

Para desenvolver e compilar aplicações móveis no BlaiseVue, o desenvolvedor precisa apenas do ecossistema padrão do **Android Studio**.

> [!IMPORTANT]
> **O BlaiseVue NÃO utiliza nem precisa do Flutter.**  
> O framework não possui nenhuma dependência do SDK do Flutter ou da linguagem Dart. Caso você tenha o Flutter instalado em sua máquina, pode removê-lo completamente com segurança sem afetar o BlaiseVue.

### Ferramentas Necessárias:
1. **Node.js (v18+ LTS) & npm**: Utilizado para gerenciar a camada de runtime do Capacitor (`@capacitor/core`, `@capacitor/cli`, `@capacitor/android`).
2. **Android Studio**:
   - **Android SDK Platform**: APIs 33, 34 ou 35 instaladas pelo *SDK Manager*.
   - **Android SDK Build-Tools & Platform-Tools**: Fornece o utilitário `adb` (Android Debug Bridge).
   - **Android Emulator**: Permite rodar e testar dispositivos virtuais sem precisar de cabo USB.
3. **Java JDK (JDK 17 ou 21)**: Geralmente já embutido no próprio Android Studio (`jbr` / JetBrains Runtime) ou instalado via OpenJDK.
4. **Variáveis de Ambiente Recomendadas (Windows)**:
   - `ANDROID_HOME`: `%LOCALAPPDATA%\Android\Sdk`
   - Adicionar ao `PATH`:
     - `%LOCALAPPDATA%\Android\Sdk\platform-tools` (para o comando `adb`)
     - `%LOCALAPPDATA%\Android\Sdk\emulator` (para o comando `emulator`)

---

## 🛠️ Comandos da CLI (`bv mobile`)

A CLI `bv.exe` fornece suporte nativo ao ciclo de vida móvel completo de forma granular:

```bash
# 1. Inicializa o projeto móvel com Capacitor e estrutura mobile/
bv mobile init [NomeDoApp] [com.suaempresa.app]

# 2. Sincroniza o diretório de build (dist/) com os assets nativos do Android/iOS
bv mobile sync [android|ios|all]

# 3. Compilação em Modo DEBUG (com logs e símbolos ativos):
bv mobile build android             # Compila APK Debug para mobile/bin/android/<App>-debug.apk
bv mobile build ios                 # Prepara/sincroniza projeto nativo iOS

# 4. Compilação em Modo RELEASE (otimização R8/ProGuard para produção e lojas):
bv mobile build android --release   # Compila APK Release para mobile/bin/android/<App>-release.apk
bv mobile build all --release       # Compila todas as plataformas móveis

# 5. Gerenciamento de Emuladores Android (AVD):
bv mobile emulator list             # Lista todos os emuladores instalados no Android Studio
bv mobile emulator start [nome]      # Inicia o emulador especificado em segundo plano
bv mobile emulator run [nome]        # Inicia o emulador, aguarda o boot e abre a aplicação

# 6. Execução direta no aparelho conectado ou emulador via ADB:
bv mobile run android               # Instala e abre no celular conectado via USB
bv mobile run android --emulator    # Inicia o emulador automaticamente e executa o app

# 7. Abertura do projeto na IDE nativa:
bv mobile open android              # Abre no Android Studio
bv mobile open ios                  # Abre no Xcode (no macOS)
```

### ⚙️ Modos de Compilação & Plataformas Móveis

| Comando Móvel | Plataforma | Modo de Build | Pacote / Ação | Finalidade |
|---|---|---|---|---|
| `bv mobile build android` | Android | Debug | `mobile/bin/android/<App>-debug.apk` | Teste rápido, desenvolvimento e depuração via Logcat |
| `bv mobile build android --release` | Android | Release (R8/ProGuard) | `mobile/bin/android/<App>-release.apk` | Versão final compacta e otimizada para distribuição |
| `bv mobile emulator list` | Android | - | Exibe lista de AVDs | Consulta os emuladores configurados na máquina |
| `bv mobile emulator start` | Android | - | Inicia AVD em background | Prepara o emulador para desenvolvimento |
| `bv mobile run android` | Android | Debug | Execução via ADB | Instalação e inicialização no dispositivo USB |
| `bv mobile run android --emulator` | Android | Debug | Boot AVD + ADB Install | Execução 100% automatizada no emulador |
| `bv mobile open android` | Android | - | Android Studio | Edição nativa Java/Kotlin, emuladores e profilers |
| `bv mobile open ios` | iOS | - | Xcode | Assinatura e compilação para iPhone/iPad (macOS) |

---

## 🎨 Componentes & Layouts Especializados para Mobile

Para assegurar uma experiência de usuário (UX) fluida e ergonômica em smartphones, o pacote **BlaiseUI** inclui componentes específicos e padrões de layout responsivo:

### 1. Sistema de Grid Responsivo (`<bv-container>`, `<bv-row>`, `<bv-col>`)
Permite criar layouts que se adaptam automaticamente entre smartphones, tablets e desktops:
- Breakpoints baseados em colunas fluidas (`cols="12" md="6" lg="4"`).
- Suporte a espaçamentos ajustáveis com `gutter="sm|md|lg"`.
- Totalmente compatível com Bootstrap e variáveis de temas.

```html
<bv-container fluid="true">
  <bv-row gutter="md">
    <!-- Ocupa largura total no celular (12 cols) e metade no tablet/desktop (6 cols) -->
    <bv-col cols="12" md="6">
      <bv-card title="Métricas em Tempo Real">...</bv-card>
    </bv-col>
    <bv-col cols="12" md="6">
      <bv-card title="Ações Rápidas">...</bv-card>
    </bv-col>
  </bv-row>
</bv-container>
```

### 2. Barra de Navegação Inferior (`<bv-bottom-nav>`, `<bv-bottom-nav-item>`)
Fixada na base da tela para acesso ergonômico com os polegares em dispositivos móveis:
- Ícones nítidos e títulos descritivos.
- Destaque reativo do item ativo baseado na rota corrente.
- Visibilidade automática via media queries (exibida em telas estreitas e oculta em telas grandes).

```html
<bv-bottom-nav class="mobile-bottom-bar">
  <bv-bottom-nav-item href="#/" icon="🏠" label="Início"></bv-bottom-nav-item>
  <bv-bottom-nav-item href="#/pro" icon="⚡" label="Pro"></bv-bottom-nav-item>
  <bv-bottom-nav-item href="#/form" icon="📋" label="Forms"></bv-bottom-nav-item>
  <bv-bottom-nav-item href="#/bootstrap" icon="🎨" label="BlaiseUI"></bv-bottom-nav-item>
</bv-bottom-nav>
```

### 3. Menu Lateral Deslizante (*Off-Canvas Drawer* - `<bv-drawer>`)
Fornece um menu de gaveta responsivo para navegação secundária:
- Controle imperativo via referências (`this.$refs.mainDrawer.open()`, `this.$refs.mainDrawer.close()`).
- Fechamento automático ao tocar no backdrop ou nos links internos.
- Renderização limpa fora do fluxo principal com alta ordem de empilhamento (`z-index`).

```html
<bv-drawer b-ref="appDrawer" title="🧭 Menu da Aplicação">
  <div class="drawer-nav">
    <a href="#/" class="drawer-link" @click="closeDrawer">🏠 Início</a>
    <a href="#/about" class="drawer-link" @click="closeDrawer">ℹ️ Sobre</a>
    <a href="#/bootstrap" class="drawer-link" @click="closeDrawer">🎨 BlaiseUI Kit</a>
  </div>
</bv-drawer>
```

### 4. Diálogos Modais Adaptativos (`<bv-modal>`)
Projetados com suporte a `<teleport to="body">`:
- Em telas pequenas, expandem-se de maneira centralizada e com margens seguras (*safe areas*).
- Controle de visibilidade otimizado via `b-show="isVisible" style="display: none;"` para carregamento instantâneo.
- Limpeza rigorosa no ciclo de vida do roteador (`bvUnmount`), garantindo que nenhum backdrop órfão permaneça na tela.

---

## 📲 Deploy e Teste em Aparelho Físico Android via ADB

Com a ferramenta `adb` (Android Debug Bridge), você pode instalar e validar o aplicativo em seu dispositivo conectado por USB ou Wi-Fi:

```bash
# 1. Verifica os dispositivos conectados
adb devices

# 2. Instala ou atualiza o APK diretamente no dispositivo
adb install -r mobile/bin/android/BlaiseVue_Demo-debug.apk

# 3. Inicia a Activity principal no smartphone
adb shell am start -n com.blaisevue.demoapp/.MainActivity

# 4. Captura uma captura de tela para validação de layout
adb exec-out screencap -p > screen_mobile_test.png
```

---

## 🏆 Vantagens da Abordagem Híbrida BlaiseVue

1. **Reaproveitamento Total de Código**: Mais de 95% do código em Object Pascal e componentes de visualização é compartilhado entre Web, Android e Desktop.
2. **Alta Performance**: Transpilação otimizada com Pas2JS RTL enxuto e aceleração por WebAssembly para operações pesadas.
3. **Consistência Visual**: A mesma paleta de temas do Bootswatch e componentes do BlaiseUI se comporta uniformemente em qualquer resolução. 🚀📱✨
