# veracode-ci-linux-unificado.yml

Este template executa uma esteira Veracode no Azure DevOps usando agente Linux. Ele prepara um pacote unificado para analise e, em seguida, executa scans SAST, SCA e IaC com as ferramentas da Veracode.

O objetivo do template e atender projetos com codigo fonte interpretado, frontend/backend web e tambem projetos .NET compilados, incluindo assemblies `.dll` acompanhados dos respectivos arquivos `.pdb`.

## Como funciona

O pipeline possui um stage:

- `Veracode`: prepara o pacote, envia para a plataforma Veracode e executa os scans complementares.

### `Preparar pacote Veracode unificado`

Cria o arquivo definido em `caminhoPacote`.

Se `caminhoPacote` for informado como caminho relativo, o template cria o pacote a partir da raiz do repositorio. Se for informado como caminho absoluto, usa o caminho recebido.

O empacotamento copia para uma pasta temporaria apenas arquivos relevantes para analise, como:

- `.py`
- `.html`, `.htm`, `.xhtml`
- `.js`, `.jsx`, `.ts`, `.tsx`, `.mjs`, `.cjs`
- `.java`, `.jsp`, `.jspx`
- `.php4`, `.php5`, `.php7`, `.phtml`, `.module`, `.inc`, `.profile`, `.install`, `.engine`, `.theme`
- `.json`, `.lock`, `.map`, `.css`, `.vue`, `.txt`

Tambem exclui conteudos que normalmente nao devem ir para analise:

- `node_modules`
- `.git`
- `dist`
- arquivos ou caminhos com `test` ou `teste`

Para projetos .NET, o template procura arquivos `.dll` que tenham um `.pdb` correspondente. Quando encontra mais de uma DLL com o mesmo nome, prioriza:

1. arquivos em `bin/Release`;
2. arquivos em outras pastas `bin`;
3. o arquivo mais recente.

Para cada DLL selecionada, o pacote tambem inclui:

- o `.pdb` correspondente;
- `.deps.json`, se existir;
- `.runtimeconfig.json`, se existir;
- `web.config`, se existir na mesma pasta da DLL.

O pacote final e gerado com `zip -r` no caminho definido em `caminhoPacote`.

### `Download Veracode Wrapper`

Baixa a versao mais recente do Veracode Java API Wrapper a partir do Maven Central.

Esse wrapper e usado no passo seguinte para executar `UploadAndScan` na plataforma Veracode.

### `Veracode U&S`

Executa `UploadAndScan` usando o pacote gerado em `caminhoPacote`.

Na branch `main`, o scan e enviado para o perfil principal da aplicacao:

```bash
-appname "$(Build.DefinitionName)"
-createprofile true
```

Nas demais branches, o template cria ou usa uma sandbox com o nome da branch:

```bash
-createsandbox true
-sandboxname "$(Build.SourceBranchName)"
```

Isso evita misturar scans de branches de desenvolvimento com o resultado principal da aplicacao.

O nome da aplicacao na Veracode usa `$(Build.DefinitionName)`.

O parametro `-teams "$(veracodeTeams)"` associa o perfil aos times informados, quando aplicavel.

Esse passo esta com `continueOnError: true`, entao falhas no Upload & Scan nao impedem a execucao dos passos seguintes.

### `Download Veracode CLI`

Instala a Veracode CLI usando o instalador oficial:

```bash
curl -fsS https://tools.veracode.com/veracode-cli/install | sh
```

A CLI e usada pelos passos de IaC e SAST.

### `Veracode SCA`

Executa o Veracode SCA Agent para analise de componentes open source e dependencias de terceiros:

```bash
curl -sSL https://download.srcclr.com/ci.sh | bash scan --update-advisor --allow-dirty --recursive
```

Para funcionar, o SCA Agent precisa da variavel:

- `SRCCLR_API_TOKEN`

Essa variavel e obrigatoria para autenticar o agente SCA no tenant Veracode.

Esse passo tambem esta com `continueOnError: true`.

### `Veracode IaC`

Executa analise IaC usando a Veracode CLI:

```bash
./veracode scan --type directory --source "$(pwd)" --format table
```

Antes de executar, o template renomeia temporariamente a pasta do repositorio para `$(Build.DefinitionName)`. Esse ajuste ajuda a manter o nome do projeto consistente durante a analise. No final do passo, a pasta volta ao nome original.

Esse passo esta com `continueOnError: true`.

### `Veracode SAST`

Executa o Veracode Static Analysis via Veracode CLI usando o pacote criado no inicio da esteira:

```bash
./veracode static scan "$(caminhoPacote)"
```

Esse passo esta com `continueOnError: true`, portanto publica o resultado no log sem bloquear necessariamente o restante da execucao.

## Variaveis necessarias

Crie as variaveis em uma variable group do Azure DevOps ou diretamente no pipeline.

| Variavel | Obrigatoria | Uso |
| --- | --- | --- |
| `VERACODE_API_KEY_ID` | Sim | API ID Veracode usado pelo Wrapper e pela Veracode CLI. |
| `VERACODE_API_KEY_SECRET` | Sim | API Key Veracode usada pelo Wrapper e pela Veracode CLI. |
| `SRCCLR_API_TOKEN` | Sim | Token usado pelo Veracode SCA Agent. |
| `caminhoPacote` | Sim | Nome ou caminho do pacote `.zip` gerado e enviado para analise. |
| `veracodeTeams` | Sim | Times associados ao perfil da aplicacao no Upload & Scan. |

Recomendacoes para as variaveis sensiveis:

- Marcar `VERACODE_API_KEY_ID`, `VERACODE_API_KEY_SECRET` e `SRCCLR_API_TOKEN` como secret.
- Usar variable group quando o mesmo conjunto de credenciais for compartilhado por varios pipelines.
- Nao gravar credenciais diretamente no arquivo YAML.

## Configuracao minima

O projeto precisa ter um pipeline Azure DevOps incluindo o template `veracode-ci-linux-unificado.yml`.

Exemplo:

```yaml
resources:
  repositories:
    - repository: TEMPLATES
      type: git
      name: 'DEMOs/TEMPLATES'
      ref: main
      trigger: none

trigger:
- main

pool:
  vmImage: ubuntu-latest

variables:
- group: Veracode
- name: caminhoPacote
  value: veracode-package.zip
- name: veracodeTeams
  value: "Nome do Time"

stages:
  - template: veracode-ci-linux-unificado.yml@TEMPLATES
```

Antes de executar, confirme:

- as variaveis sensiveis foram criadas no Azure DevOps;
- o agente Linux possui Java, `curl`, `zip`, `find`, `stat` e Bash disponiveis;
- o agente consegue acessar a internet para baixar o Wrapper, a Veracode CLI e o SCA Agent;
- o usuario/API credential da Veracode tem permissao para criar perfil de aplicacao, criar sandbox e executar scans;
- o valor de `caminhoPacote` termina em `.zip` e aponta para um local gravavel.

## Ajustes comuns

Para mudar o nome do pacote:

```yaml
variables:
- name: caminhoPacote
  value: veracode-package.zip
```

Para enviar o pacote para uma subpasta:

```yaml
variables:
- name: caminhoPacote
  value: artifacts/veracode-package.zip
```

Para associar o perfil da aplicacao a times especificos:

```yaml
variables:
- name: veracodeTeams
  value: "Time A,Time B"
```

Para incluir ou excluir mais extensoes, ajuste o bloco `find` do passo `Preparar pacote Veracode unificado`.

Para alterar a regra de sandbox, ajuste a condicao baseada em `$(Build.SourceBranchName)` no passo `Veracode U&S`.
