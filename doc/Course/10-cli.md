# ⚔️ Módulo 10: O Maestro do Terminal (CLI bv)
**Domine os comandos simples que constroem, testam e turbinam suas aplicações.**

Se você nunca usou o terminal antes (aquela tela preta com letras brancas), pode parecer um pouco assustador no começo. Mas não se preocupe: o terminal é apenas uma forma de conversar diretamente com o computador usando comandos de texto!

Para facilitar a sua vida, o BlaiseVue vem com uma ferramenta de linha de comando chamada **`bv`** (ou `bv.exe` no Windows). Ela é o seu copiloto: cuida da compilação, dos testes e das configurações chatas com comandos simples de uma única linha.

---

## 💻 1. Como Abrir o Terminal?

- **Dentro do seu editor (VS Code / Antigravity IDE):**  
  Pressione o atalho **`Ctrl + '`** (ou vá no menu superior: *Terminal $\rightarrow$ Novo Terminal*). Um terminal já se abrirá na pasta exata do seu projeto!
- **No Windows:** Abra o *PowerShell* ou *Prompt de Comando*.
- **No Linux ou macOS:** Abra o *Terminal* do sistema.

> [!TIP]
> **Duas Dicas de Ouro no Terminal:**
> 1. **Repetir o último comando:** Pressione a **tecla de seta para cima ($\uparrow$)** no teclado. O terminal digita o último comando para você!
> 2. **Interromper um processo:** Se você quiser parar o servidor de desenvolvimento, pressione **`Ctrl + C`**.

---

## 🧰 2. O Guia Definitivo dos Comandos Essenciais

Aqui estão os comandos que você mais usará no seu dia a dia:

### 1. Iniciar o Servidor de Desenvolvimento
Inicia o servidor local com recarregamento em tempo real (Hot Module Replacement) na porta `8080`:
```bash
bv run dev
# (ou de forma abreviada:)
bv dev
```
Abra o navegador em `http://localhost:8080` e divirta-se programando!

### 2. O Médico da Sua Máquina (`bv doctor`)
Faz um check-up completo no seu ambiente e confirma se tudo o que você precisa está instalado e pronto com `[v]`:
```bash
bv doctor
```
Ele confere:
- **Git**: Para atualizações automáticas.
- **Free Pascal (FPC) e InstantFPC**: Os compiladores e motores de script em Pascal.
- **Python 3**: Recomendado para rodar os scripts de ferramentas e extensões.
- **Pas2JS e mORMot 2**: Os compiladores embutidos de Web e Backend.
- **Node.js**: Para o servidor de testes e recarregamento rápido.

### 3. Executar Testes Automatizados
Compila e valida todos os seus arquivos de teste `.test.pas`:
```bash
bv test
```

### 4. Gerar a Versão Final para a Internet (`bv build`)
Quando o seu site estiver pronto para ir para o ar, este comando cria uma pasta chamada `dist/`:
```bash
bv build
```
A pasta `dist/` contém apenas arquivos estáticos HTML, CSS e JavaScript otimizados e minificados. Você pode hospedar essa pasta em qualquer servidor web gratuito (como GitHub Pages, Vercel, Netlify) ou servidor próprio!

### 5. Limpar Arquivos Temporários
Se você quiser limpar caches e compilações antigas:
```bash
bv clean
```

---

## 🎨 3. Gerenciando Extensões e Temas Visuais

O CLI `bv` também gerencia as extensões de desenvolvimento e a aparência do seu sistema:

### Extensões de Desenvolvimento (`bv extension`)
```bash
# Ver as ferramentas disponíveis e se já estão instaladas:
bv extension list

# Instalar a extensão oficial para o seu VS Code / Antigravity IDE:
bv extension install blaise-vscode

# Ver as instruções para instalar o DevTools no navegador Chrome/Firefox:
bv extension install blaise-devtools
```

### Temas Visuais Prontos (Bootswatch)
Cansado de criar estilos CSS do zero? O BlaiseVue já vem com suítes de temas profissionais pré-configuradas:
```bash
# Listar todos os temas disponíveis (darkly, flatly, cosmo, pulse, etc.):
bv theme list

# Aplicar um tema escuro moderno no seu projeto com 1 comando:
bv theme use darkly

# Voltar para um tema claro limpo e profissional:
bv theme use flatly
```

---

## 🎯 4. Exercício Prático do Módulo 10

1. Abra o seu terminal.
2. Digite `bv doctor` e confirme se todos os itens estão verdes com `[v]`.
3. Digite `bv extension list` e veja as ferramentas dinâmicas instaladas no seu computador.
4. Experimente digitar `bv theme use darkly`, salve e olhe no navegador para ver o seu projeto ganhar um visual dark mode sofisticado na mesma hora!

---

## 🏆 Resumo do Que Você Aprendeu
- O terminal não é um bicho de sete cabeças: é uma ferramenta prática de produtividade.
- Como usar `bv dev` para programar com recarregamento em tempo real.
- Como o `bv doctor` garante a saúde do seu ambiente.
- Como gerar o build de produção final com `bv build`.
- Como alternar temas visuais inteiros com `bv theme use`.

**Preparado para descobrir os recursos que os programadores seniores utilizam? Avance para o [Módulo 11: Recursos Pro (Master Architecture)](11-pro-features.md)!** ⚔️🛡️✨
