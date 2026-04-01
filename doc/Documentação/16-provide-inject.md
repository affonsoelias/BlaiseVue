# 🔗 Elo Sagrado (Provide/Inject)

O BlaiseVue Pro traz o suporte para **Provide/Inject**, uma ferramenta poderosa para injeção de dependências em componentes profundamente aninhados que não precisam compartilhar estado global de forma explícita.

## O Que é Provide/Inject?
Imagine que seu componente Root (App) tem informações de "Configuração de Ambiente" (ex: ID da loja, URL de API). Você quer que um componente lá no fundo da página (como um botão de Rodapé) acesse essas informações.

- O componente Pai **provê** (`provide`) o valor.
- O componente Filho longínquo **injeta** (`inject`) o valor.

## Como Usar

### 1. No Componente Pai (ex: app.bv ou views)
Use o bloco `provide` para expor dados ou funções. O retorno deve ser um objeto JS:

```pascal
// app.bv
provide:
  begin
    Result := TJSObject.new;
    Result['getAmbiente'] := function(): string
      begin
         Result := 'Produção 🛡️';
      end;
  end;
```

### 2. No Componente Filho (profundamente aninhado)
Use o bloco `inject` para listar as chaves que você quer capturar. O BlaiseVue Pro injetará essas propriedades diretamente na reatividade do componente:

```pascal
// MeuBotaoRodape.bv
inject:
  getAmbiente;
```

### 3. Acesso no Template (.bv)
Agora a variável injetada é reativa e acessível diretamente:

```html
<template>
  <button>Ambiente Atual: {{ getAmbiente() }}</button>
</template>
```

## Benefícios
- **Desacoplamento Vertical**: Filhos não precisam saber de quem estão recebendo os dados, apenas que o ID da dependência existe.
- **Injeção de Plugins**: Ótimo para injetar serviços de roteamento, tradução (i18n) ou logs.
- **Hierarquia Flexível**: Se um pai no meio do caminho também fizer "provide" da mesma chave, o filho pegará o valor do pai MAIS PRÓXIMO.
