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
│             Capacitor Android Project                  │
│       android/app/src/main/assets/public/              │
└──────────────────────────┬─────────────────────────────┘
                           │ Compilação Gradle (bv mobile build)
┌──────────────────────────▼─────────────────────────────┐
│           Pacote Nativo Instalável (.apk)              │
│       app-debug.apk / app-release.apk                  │
└────────────────────────────────────────────────────────┘
```

---

## 🛠️ Comandos da CLI (`bv mobile`)

A CLI `bv.exe` fornece suporte nativo ao ciclo de vida móvel completo:

```bash
# 1. Inicializa o projeto móvel com Capacitor e estrutura Android
bv mobile init [NomeDoApp] [com.suaempresa.app]

# 2. Sincroniza o diretório de build (dist/) com os assets nativos do Android
bv mobile sync

# 3. Abre o projeto gerado no Android Studio
bv mobile open

# 4. Compila o pacote nativo APK utilizando o Gradle Wrapper do projeto
bv mobile build
```

O comando `bv mobile build` executa o Gradle de forma transparente e gera o APK final localizado em:
`android/app/build/outputs/apk/debug/app-debug.apk`.

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
adb install -r android/app/build/outputs/apk/debug/app-debug.apk

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
