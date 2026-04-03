# 🛰️ Módulo 07: Comunicação e Eventos ($emit)
**Fazendo Seu Componente Ser Ouvido.**

Em BlaiseVue, componentes filhos falam com seus pais através de **Eventos Personalizados**.

## ⚔️ O Bloco Methods
Defina seus procedimentos Pascal que serão chamados por cliques ou inputs:
```pascal
  methods:
    procedure avisarPai;
    begin
      // O Grito do Filho
      TJSFunction(this['$emit']).apply(this, ['evento-importante', 'Oi Pai!']);
    end;
```

## 👁️ Escutando o Evento
No componente pai, você escuta o evento com @:
```html
<filho-componente @evento-importante="noFilhoAvisou"></filho-componente>
```

---

**A Regra da Voz:**
A comunicação de componentes deve ser sempre:
- **Props:** Do Pai para o Filho.
- **Eventos ($emit):** Do Filho para o Pai. ✨🛡️✨

---

**Próximo Passo: Torne-se um explorador de páginas no Módulo 08!** ⚔️
