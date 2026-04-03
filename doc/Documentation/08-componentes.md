# 8. Componentes
 
 Componentes são blocos reutilizáveis de interface com estado isolado. No BlaiseVue, todos os componentes são **registrados globalmente** de forma automática.
 
 ## Criando um Componente
 
 ### Via CLI
 ```bash
 bv new c MeuComponente
 ```
 Cria `src/components/MeuComponente.bv`.
 
 ### Manualmente
 Basta criar um arquivo `.bv` em `src/components/`. O compilador irá detectá-lo e torná-lo disponível em todo o projeto.
 
 ```html
 <!-- src/components/Counter.bv -->
 <template>
   <div class="counter">
     <span>{{ valor }}</span>
     <button @click="mais">+</button>
     <button @click="menos">-</button>
   </div>
 </template>
 
 <script>
   data:
     valor: integer = 0;
 
   methods:
     procedure mais;
     begin
       this['valor'] := Integer(this['valor']) + 1;
     end;
 
     procedure menos;
     begin
       this['valor'] := Integer(this['valor']) - 1;
     end;
 </script>
 ```
 
 ## Usando um Componente
 
 Use a tag HTML correspondente dentro de qualquer template:
 
 ```html
 <template>
   <div>
     <h1>Minha Pagina</h1>
     <counter></counter>
     <counter></counter>
   </div>
 </template>
 ```
 
 Cada `<counter>` tem seu **estado próprio**. Clicar no "+" de um não afeta os outros.
 
 ## Registro Global Automático
 
 Diferente de outros frameworks onde você precisa importar (`import`) e registrar (`components: { ... }`), no BlaiseVue todo arquivo dentro de `src/components/` ou `src/views/` é registrado globalmente pelo CLI no momento do build. 
 
 Isso significa que um componente pode usar outro sem nenhuma declaração extra.
 
 ## Sub-componentes (Nidificação)
 
 Você pode usar componentes dentro de outros componentes para criar interfaces complexas:
 
 ```html
 <!-- src/components/NavBar.bv -->
 <template>
   <nav>
     <logo-icon></logo-icon> <!-- Sub-componente -->
     <div class="links">
       <a href="#/">Home</a>
     </div>
   </nav>
 </template>
 ```
 
 ## Convenção de Nomes
 
 | Arquivo | Tag HTML |
 |---------|----------|
 | `Counter.bv` | `<counter>` |
 | `InfoCard.bv` | `<info-card>` |
 | `NavBar.bv` | `<nav-bar>` |
 | `FormHeader.bv` | `<form-header>` |
 
 A conversão é **PascalCase → kebab-case**.
 
 ## Estado Isolado
 
 Cada instância de componente tem seus próprios dados. Isso acontece porque o `data:` gera uma **função** que retorna um novo objeto a cada chamada no runtime Pascal:
 
 ```pascal
 // Gerado automaticamente:
 comp['data'] := function(): TJSObject
 var d: TJSObject;
 begin
   d := TJSObject.new;
   d['valor'] := 0;      
   Result := d;
 end;
 ```
