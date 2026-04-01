# 🔄 Ciclo de Vida Avançado (Pro Lifecycle)

O BlaiseVue Pro adiciona novos hooks de ciclo de vida para os componentes, oferecendo controle total sobre o que acontece com o componente, do nascimento à morte.

## Hooks Disponíveis (Ciclo Completo)

| Hook | Quando Ocorre? | Uso Típico |
| :--- | :--- | :--- |
| **`created`** | Antes do componente virar DOM. | Inicializar dados na store global ou configurar reatividade base. |
| **`mounted`** | Quando o componente já está no HTML. | Configurar plugins JS externos (como um mapa ou gráfico) que precisam do elemento pronto. |
| **`updated`** | **(Novo)** Quando qualquer dado reativo muda. | Execute lógica quando algo na tela for atualizado (ex: logs de auditoria). |
| **`unmounted`** | **(Novo)** Quando o componente é destruído. | Limpar timers (setInterval), remover ouvintes de eventos globais (window.addEventListener) ou parar vídeos. |

## Exemplo de Uso dos Novos Hooks

### Hook Updated (Buscando o Pulso)
Mantenha monitoramento constante sobre atualizações de dados:

```pascal
// ContadorLog.bv
updated:
  begin
    asm console.log("[Lifecycle] Pulso detectado! Dados atualizados."); end;
  end;
```

### Hook Unmounted (Limpeza Total)
Evite vazamentos de memória (memory leaks) e interações fantasmas:

```pascal
// VideoPlayer.bv
methods:
  procedure stopVideo;
  begin
     asm this.$refs.player.pause(); end;
  end;

unmounted:
  begin
    // Limpar o vídeo quando o componente sumir via b-if ou router
    stopVideo;
    asm console.log("[Lifecycle] Componente destruído. Memória liberada."); end;
  end;
```

## Benefícios
- **Gerenciamento de Recursos**: Garante que processos pesados só rodem enquanto o componente estiver visível.
- **Auditoria de Estado**: Monitore mudanças na tela de forma simplificada com `updated`.
- **Limpeza Profunda (v2.0)**: O BlaiseVue Pro limpa automaticamente todos os observadores de reatividade (`bv.effect`) quando o componente é desmontado, evitando Lentidão a longo prazo.
