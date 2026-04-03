# 🧬 Módulo 02: O Motor Reativo
**Dados que Têm Vida Própria.**

O BlaiseVue utiliza **Proxies (vanguardas) de JavaScript** que funcionam como sentinelas em volta do seu estado Pascal. Sempre que uma variável é tocada, o sistema "atira" uma notificação para o compilador atualizar o que for preciso.

---

## 📝 Declarando Dados Reativos
No seu componente `.bv` (o arquivo SFC), você define seus dados assim:
```pascal
  data:
    nome: string = 'Blaise';
    ativo: boolean = true;
    itens: TJSArray = TJSArray.new;
```

## 👁️ Rastreamento de Mudanças
Ao fazer:
```pascal
this['nome'] := 'Pascal';
```
O Proxy percebe a mudança e dispara o **"Gatilho Reativo"**. O BlaiseVue sabe exatamente qual elemento HTML depende da variável `nome` e o atualiza em milissegundos. ✨🛡️✨

---

**Cuidado!** Nunca use variáveis globais em Pascal para o estado da tela; sempre defina-as na seção `data:` do componente para que o motor reativo consiga "abraçá-las".

**Próximo Passo: Como controlar o que o usuário vê (Módulo 03)!** ⚔️
