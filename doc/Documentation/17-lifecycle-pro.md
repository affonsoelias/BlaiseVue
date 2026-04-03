# 🔄 Ciclo de Vida Avançado (Pro Lifecycle)

O BlaiseVue PRO oferece controle total sobre a existência de um componente, do nascimento (inicialização) à morte (destruição), através de hooks de ciclo de vida síncronos e assíncronos.

---

## 🏛️ A Batida do Motor (Hooks em Ordem)

| Hook | Quando Ocorre? | Estado do DOM | Uso Típico |
| :--- | :--- | :--- | :--- |
| **`created`** | Dados e reatividade injetados. | ❌ Inexistente | Configurar B-Store, formatar arrays iniciais. |
| **`mounted`** | Componente inserido no documento. | ✅ Pronto | Inicializar Chart.js, Mapas ou acessar `$refs`. |
| **`updated`** | Após o DOM ser alterado por um dado. | ✅ Atualizado | Registrar logs de auditoria ou sincronizar estados complexos. |
| **`unmounted`** | Componente removido via `b-if` ou Route. | ❌ Destruído | Limpar `setInterval`, remover `window` listeners. |

---

## ⚙️ Detalhamento por Hook

### 1. Hook `created`: O Primeiro Suspiro
Neste estágio, o compilador já hidratou o objeto `data:`, mas o HTML ainda não foi gerado. **Nunca tente acessar o DOM aqui!**

```pascal
created:
  begin
     { Perfeito para buscar dados iniciais ou configurar a Store }
     TJSObject(this['$store'])['lastVisit'] := Date.now();
  end;
```

### 2. Hook `mounted`: Acesso Total ao DOM
Quando este hook é chamado, o componente já está renderizado. É o momento seguro para interagir com o elemento HTML real através das referências (`$refs`).

```pascal
mounted:
  begin
     { Acesse o elemento nativo por trás do b-ref }
     asm 
       const ctx = this.$refs.canvasElement.getContext('2d');
       // Inicialize sua biblioteca JS favorita aqui!
     end;
  end;
```

### 3. Hook `updated`: Reatividade em Ação
Chamado sempre que o motor de reatividade detecta uma mudança e finaliza a atualização visual na tela.

```pascal
updated:
  begin
     asm console.log("[Lifecycle] UI Refletiu a nova mudança de estado."); end;
  end;
```

### 4. Hook `unmounted`: Limpeza e Despedida
O BlaiseVue PRO destrói automaticamente todos os observadores de reatividade (`Effects`) e remove o componente da árvore. **Use este hook para evitar vazamentos de memória.**

```pascal
unmounted:
  begin
     { Pare timers que o componente criou }
     asm clearInterval(this.myTimerId); end;
     asm console.log("[Lifecycle] Componente desmontado com sucesso."); end;
  end;
```

---

## 🛡️ Gestão Automática do BlaiseVue PRO
Diferente da versão Standard, o **Pro Engine** realiza a limpeza profunda (Deep Cleanup) ao desmontar:
- **Detecção de Leak**: Interrompe efeitos reativos órfãos.
- **Auto-Reference Wipe**: Limpa o dicionário `$refs` para liberar memória RAM no navegador.

---
_"BlaiseVue: Robustness from spawn to despawn."_ 🛡️✨🔄🏆
