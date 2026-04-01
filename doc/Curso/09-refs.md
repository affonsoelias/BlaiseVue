# 👁️ Módulo 09: $refs e Lifecycle
**Pegando Tudo na Tela.**

Em BlaiseVue, o motor cuida da maioria das mudanças de tela, mas se você precisar tocar em um elemento diretamente (como focar em um input ou falar com um componente filho), você usa o **`$refs`**.

## ⚔️ A Diretiva b-ref
Adicione a diretiva no HTML:
```html
<input type="text" b-ref="meuInput">
<main-header b-ref="oCabecalho"></main-header>
```

## 👁️ Toque de Mestre no Script
Acesse-os no seu código Pascal assim:
```pascal
procedure focar;
begin
  TJSObject(this['$refs'])['meuInput'].focus();
end;
```

---

**Os Tempos Sagrados (Lifecycle):**
- **`created`**: Os dados já existem no Pascal, mas a tela ainda é um segredo.
- **`mounted`**: A tela brilha e o seu código já pode falar com o HTML! ✨🛡️✨

---

**Próximo Passo: O Comando Final no Módulo 10!** ⚔️
