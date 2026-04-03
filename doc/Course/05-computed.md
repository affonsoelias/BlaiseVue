# 🧠 Módulo 05: Projeto 03 - Perfil Automático
**Faça o BlaiseVue Pensar por Você!**

Propriedades Computadas (Computed) são o cérebro da sua aplicação. Elas evitam que você escreva o mesmo código várias vezes e garantem que cálculos complexos só aconteçam quando necessário.

---

## 🛠️ O Que Vamos Construir?
Um formulário de perfil onde o "Nome Completo" e o "Status de Idade" se atualizam sozinhos enquanto você digita!

### 1. Definindo o Cérebro (Computed)
Abra o seu arquivo `.bv` e adicione este bloco no script:
```pascal
  computed:
    function nomeCompleto: string;
    begin
      // O Pascal soma as strings e o BlaiseVue cuida do resto!
      Result := string(this['nome']) + ' ' + string(this['sobrenome']);
    end;

    function statusSocial: string;
    begin
      if Integer(this['idade']) >= 18 then Result := 'Adulto 🛡️'
      else Result := 'Jovem Iniciante ⚔️';
    end;
```

### 2. Exibindo na Tela
No seu template, use as propriedades como se fossem variáveis comuns:
```html
<p>Nome Completo: <strong>{{ nomeCompleto }}</strong></p>
<p>Nível: <span class="badge">{{ statusSocial }}</span></p>
```

---

## 👁️ O Que Você Aprendeu Hoje:
- **`computed`**: Como criar variáveis que dependem de outras.
- **Cache Inteligente**: O BlaiseVue só re-calcula o nome se o nome ou sobrenome mudar!
- **Lógica Pascal**: Como usar `if/then` para mudar o que aparece na tela. 🛡️✨🏆

---

**Próximo Passo: Aprenda a criar seu exército de mini-apps com Componentes no Módulo 06!** ⚔️
