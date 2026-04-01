# 🛡️ Especificação Técnica: Motor de Reatividade

O BlaiseVue implementa um sistema de reatividade **Dependency-Tracking** baseado em Proxies do ES6, eliminando a necessidade de Virtual DOM para atualizações de estado simples.

---

## 🧬 O Paradigma Track/Trigger

### 1. `bv.track(target, key)`
Invocado durante a armadilha `get` do Proxy.
- Verifica se existe um `activeEffect` no topo da pilha.
- Se sim, registra o efeito no `targetMap` associado ao par `target/key`.
- Utiliza um `WeakMap` para evitar vazamentos de memória (Memory Leaks) de objetos destruídos.

### 2. `bv.trigger(target, key)`
Invocado durante a armadilha `set` do Proxy ou mutação de array.
- Localiza todos os efeitos (Subscribers) registrados para aquele `target/key`.
- Executa os efeitos de forma síncrona (ou via Batching se habilitado).

---

## 🧪 Estrutura de Dados Interna (pseudo-JS)
```javascript
targetMap = new WeakMap<Target, Map<Key, Set<Effect>>>();
```

## 🧠 Ciclo de Vida de um Computed
As propriedades computadas em BlaiseVue são "Lazy" e "Cached":
1. No primeiro acesso, o `getter` é executado dento de um `effect` especial.
2. O `effect` marca a propriedade como `dirty = false`.
3. Qualquer mudança nas dependências do `getter` dispara o `trigger`, que apenas marca a propriedade como `dirty = true` (sem re-calcular imediatamente).
4. O próximo acesso ao `getter` percebe o estado `dirty` e realiza o re-cálculo.

---

## ⚡ Mutação de Arrays
O BlaiseVue sobrescreve os métodos mutadores nativos (`push`, `pop`, `splice`, etc.) para disparar o `trigger` na propriedade `length`, forçando a re-renderização de diretivas `b-for`. 🛡️✨🏆
