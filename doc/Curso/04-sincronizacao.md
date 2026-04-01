# 🔄 Módulo 04: Sincronização e b-model
**O Diálogo entre o Input e o Pascal.**

A diretiva **`b-model`** é como um "espelho bidirecional" entre o que o usuário digita na tela e a variável que está no seu código Pascal.

## ⚔️ b-model: Sincronismo Total
Sempre que o usuário digitar em um input com `b-model`, a variável Pascal correspondente será atualizada.

```html
<label>Seu Nome:</label>
<input type="text" b-model="nomeUsuario">
<div class="alerta">
  Oi mestre, {{ nomeUsuario }}! (Mudança instantânea!)
</div>
```

---

**A Regra da Sincronia:**
O `b-model` não é mágica; é uma ponte reativa. Ele cuida tanto do valor inicial quanto da atualização contínua, permitindo que você valide dados em tempo real no Pascal! 🛡️✨🏆

---

**Próximo Passo: Economize esforço com fórmulas reativas no Módulo 05!** 🧠✨
