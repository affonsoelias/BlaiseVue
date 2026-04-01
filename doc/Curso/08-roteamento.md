# 🛰️ Módulo 08: Roteamento e SPAs
**Navegando Sem Recarregar.**

A maior magia de um framework moderno é ser uma **SPA (Single Page Application)**. O BlaiseVue tem seu próprio roteador integrado que gerencia as URLs para você.

## ⚔️ O Hash-Router
Navegar no BlaiseVue é tão simples quanto mudar o hash da URL:
```html
<a href="#/home">Início</a>
<a href="#/sobre">Sobre Nós</a>
```

## 👁️ Roteamento Automático
O roteador observa a URL e, quando ela muda, ele injeta o componente correspondente no seu `#app` principal.

- **URL: `#/home`** ➔ Exibe o componente `uHome`.
- **URL: `#/sobre`** ➔ Exibe o componente `uAbout`. ✨🛡️✨

---

**O Segredo da Fluidez:**
Suas páginas carregam instantaneamente porque o BlaiseVue já as tem registradas no motor reativo quando a aplicação inicia! 🛡️✨🏆

---

**Próximo Passo: Pegue o que quiser na tela no Módulo 09!** ⚔️
