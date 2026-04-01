# 2. Instalação

## Pré-requisitos

1. **pas2js** (3.2.0+): Transpilador Pascal → JavaScript
   - Download: https://wiki.freepascal.org/pas2js
   - Deve estar no PATH do sistema

2. **FPC** (3.2.2+): Free Pascal Compiler (para compilar o CLI)
   - Normalmente instalado junto com Lazarus

## Instalação do BlaiseVue

### 1. Estrutura do SDK

```
BlaiseVue/
├── bin/
│   └── bv.exe       # CLI do framework
├── core/            # Módulos runtime Pascal
│   ├── BlaiseVue.pas
│   ├── BVCompiler.pas
│   ├── BVComponents.pas
│   ├── BVData.pas
│   ├── BVDirectives.pas
│   ├── BVReactivity.pas
│   └── BVRouting.pas
└── rtl.js           # Runtime JavaScript do pas2js
```

### 2. Adicionar ao PATH

Adicione a pasta `bin/` do BlaiseVue ao PATH do sistema:

**Windows (PowerShell como admin):**
```powershell
[Environment]::SetEnvironmentVariable("Path",
  [Environment]::GetEnvironmentVariable("Path", "User") +
  ";C:\caminho\para\BlaiseVue\bin", "User")
```

### 3. Verificar

Reinicie o terminal e execute:
```bash
bv
```

Saída esperada:
```
BlaiseVue CLI v1.0
==================

Uso:
  bv create <nome>       Cria um novo projeto
  bv clean               Limpa arquivos gerados (generated/ e dist/)
  bv run dev             Build de DEPURACO com timestamp (SFC -> Pas -> JS)
  bv run build           Build de PRODUCAO com hashes (SFC -> Pas -> JS)
  bv serve               Inicia servidor de desenvolvimento (logs do servidor)
  ...
```

## Recompilar o CLI (opcional)

Se você modificar o `bv.pas`, recompile com FPC:

```bash
fpc -o"bin/bv.exe" bin/bv.pas
```
