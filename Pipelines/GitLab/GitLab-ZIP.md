# GitLab-ZIP.yml

Este template executa uma esteira Veracode no GitLab CI gerando primeiro um arquivo `.zip` com os arquivos recomendados para analise e, depois, usando esse pacote nos scans SAST da Veracode.

## Como funciona

O pipeline possui dois stages:

- `Artifact`: cria o pacote `.zip` e executa o Veracode SCA Agent.
- `SAST`: envia o pacote para a plataforma Veracode e executa o Pipeline Scan.

### `packaging`

Cria o arquivo definido em `Caminho_Arquivo`, por padrao `verademo.zip`.

O job usa a imagem `alpine:latest`, instala o utilitario `zip` e compacta apenas extensoes relevantes para analise, como `.js`, `.ts`, `.java`, `.py`, `.php`, `.json`, `.html`, `.css`, entre outras.

Tambem exclui conteudos que normalmente nao devem ir para analise:

- `node_modules`
- `.git`
- `dist`
- arquivos ou caminhos com `test`, `Test`, `TEST`, `teste`, `Teste` ou `TESTE`

O `.zip` gerado e publicado como artifact para ser consumido pelos jobs seguintes.

### `Veracode_SCA`

Executa o Veracode SCA Agent para analise de componentes open source e dependencias de terceiros.

Esse job roda no stage `Artifact` com `when: always`, portanto tenta executar mesmo se outro job do stage falhar.

Para funcionar, o SCA Agent precisa da variavel:

- `SRCCLR_API_TOKEN`

Essa variavel e obrigatoria para autenticar o agente SCA no tenant Veracode.

### `Veracode_Plataforma`

Executa apenas na branch principal do projeto:

```yaml
rules:
  - if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'
```

Esse job usa o Veracode Java API Wrapper para fazer `UploadAndScan` do arquivo definido em `Caminho_Arquivo`.

Ele cria o perfil da aplicacao se ainda nao existir, inicia o scan automaticamente e usa o nome definido em `APP_Profile` como nome da aplicacao na Veracode.

### `Veracode_Sandbox`

Executa nas branches que nao sao a branch principal:

```yaml
rules:
  - if: '$CI_COMMIT_BRANCH != $CI_DEFAULT_BRANCH'
```

Tambem faz `UploadAndScan`, mas cria/usa uma sandbox com o nome da branch:

```bash
-createsandbox true
-sandboxname "${CI_COMMIT_REF_NAME}"
```

Isso evita misturar scans de feature branches com o resultado principal da aplicacao.

### `Veracode_SAST`

Executa o Veracode Pipeline Scan usando o mesmo `.zip` gerado no job `packaging`.

Esse scan e mais rapido e retorna detalhes dos achados no log do pipeline. Ele usa `when: always`, entao tambem tenta executar independentemente do resultado dos outros jobs.

## Variaveis necessarias

Crie as variaveis em:

`Settings > CI/CD > Variables`

| Variavel | Obrigatoria | Uso |
| --- | --- | --- |
| `VERACODE_API_ID` | Sim | API ID Veracode usado pelo Wrapper e pelo Pipeline Scan. |
| `VERACODE_API_KEY` | Sim | API Key Veracode usada pelo Wrapper e pelo Pipeline Scan. |
| `SRCCLR_API_TOKEN` | Sim | Token usado pelo Veracode SCA Agent. Sem ele o job `Veracode_SCA` nao autentica. |
| `APP_Profile` | Nao | Nome da aplicacao na Veracode. Por padrao usa `${CI_PROJECT_NAME}`. |
| `Caminho_Arquivo` | Nao | Nome/caminho do pacote enviado para analise. Por padrao usa `verademo.zip`. |

Recomendacoes para as variaveis sensiveis:

- Marcar `VERACODE_API_ID`, `VERACODE_API_KEY` e `SRCCLR_API_TOKEN` como `Masked`.
- Marcar como `Protected` somente se o pipeline rodar em branches/tags protegidas.
- Nao gravar credenciais diretamente no arquivo `.gitlab-ci.yml`.

## Configuracao minima

O projeto precisa ter um `.gitlab-ci.yml` usando o conteudo do `GitLab-ZIP.yml` ou incluindo esse template conforme o modelo adotado no repositorio.

Antes de executar, confirme:

- as tres variaveis sensiveis foram criadas no GitLab;
- o usuario/API credential da Veracode tem permissao para criar perfil de aplicacao e executar scans;
- o runner GitLab consegue acessar a internet para baixar o SCA Agent e o Pipeline Scan;
- o nome em `APP_Profile` corresponde ao perfil desejado na Veracode, caso nao queira usar o nome do projeto.

## Ajustes comuns

Para mudar o nome da aplicacao na Veracode:

```yaml
variables:
  APP_Profile: "Minha Aplicacao"
```

Para mudar o nome do pacote:

```yaml
variables:
  Caminho_Arquivo: "pacote-veracode.zip"
```

Para incluir ou excluir mais extensoes, ajuste os parametros `-i` e `-x` do comando `zip` no job `packaging`.
