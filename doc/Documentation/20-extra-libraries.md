# 20. Extra-Official Libraries & BlaiseUI Evolution

Nas versões iniciais do BlaiseVue, foram desenvolvidas duas bibliotecas auxiliares na pasta `lib/` para demonstrar o ecossistema de componentes externos: `bootstrap-bv` (wrapper do Bootstrap 5) e `chart-bv` (wrapper do Chart.js).

Com a evolução para o **BlaiseVue 2.0**, esses componentes foram consolidados e unificados sob a biblioteca oficial **[BlaiseUI](24-blaise-ui.md)**, eliminando redundâncias de prefixos e a dependência pesada de frameworks CSS externos.

---

## 🏛️ A Evolução para o BlaiseUI Unificado

| Biblioteca Antiga | Nova Estrutura Unificada | Motivo da Migração |
|---|---|---|
| `bootstrap-bv/` | **`packages/blaise-ui/`** | Eliminação do `bootstrap.css` (~230KB) em favor de CSS leve nativo com variáveis (`blaise-ui.css`). |
| `chart-bv/` | **`packages/blaise-ui/`** | Inclusão do `<bv-chart>` e wrappers diretamente no kit oficial de componentes. |
| Prefixos `b-*` e `c-*` | **Prefixo Padronizado `bv-*`** | Fim da ambiguidade entre componentes (`BBtn` vs `BVBtn`, `BToast` vs `BVToast`). |

---

## 📦 Como Criar Suas Próprias Bibliotecas em `/lib`

O ecossistema do BlaiseVue continua oferecendo suporte completo a bibliotecas externas e módulos de terceiros colocados na pasta `lib/`.

Qualquer pasta dentro de `lib/` desfruta dos seguintes recursos automáticos do CLI (`bv.exe`):
1. **Auto-Registro de Componentes**: Qualquer arquivo `.bv` dentro de `lib/<sua-lib>/` é transpilado e registrado globalmente na aplicação.
2. **Auto-Injeção de CSS**: Arquivos `.css` presentes em `lib/<sua-lib>/` são copiados para `dist/css/lib/` e injetados via `<link>` no `index.html`.
3. **Auto-Injeção de Scripts JS**: Arquivos `.js` presentes em `lib/<sua-lib>/` (como drivers de gráficos ou utilitários) são copiados para `dist/js/lib/` e incluídos via `<script>` antes da inicialização do app.
4. **Lifecycle Setup (`setup.pas`)**: Bibliotecas podem incluir um script `setup.pas` interativo executável via `bv s <nome-da-lib>`.

---

## 📊 Gráficos no BlaiseUI Unificado

Para utilizar gráficos reativos em qualquer projeto, basta utilizar os componentes unificados do BlaiseUI:

```html
<template>
  <div style="height: 350px;">
    <!-- Master component ou atalho direto -->
    <bv-bar :data="chartData" :options="chartOptions"></bv-bar>
    <bv-btn variant="primary" @click="updateData">Randomize Data ⚡</bv-btn>
  </div>
</template>

<script>
  data:
    chartData: JSValue = null;
    chartOptions: JSValue = null;

  created:
    begin
       asm
         this.chartOptions = { responsive: true, maintainAspectRatio: false };
         this.chartData = {
           labels: ['Jan', 'Fev', 'Mar'],
           datasets: [{ label: 'Vendas', data: [10, 25, 42], backgroundColor: '#42b883' }]
         };
       end;
    end;

  methods:
    procedure updateData;
    begin
       asm
         this.chartData = {
           ...this.chartData,
           datasets: [{ ...this.chartData.datasets[0], data: [35, 12, 58] }]
         };
       end;
    end;
</script>
```

---

🛡️ Para a lista completa de componentes, consulte o capítulo oficial **[24. BlaiseUI (Official Component Kit)](24-blaise-ui.md)**.
