# GitLab-ZIP.yml

Este template executa uma esteira Veracode no GitLab CI gerando primeiro um arquivo `.zip` com os arquivos recomendados para analise e, depois, usando esse pacote nos scans SAST da Veracode.

## Como funciona

O pipeline possui tres stages:

- `Package`: cria o pacote `.zip` usado pelos scans SAST.
- `Deps_IaC`: executa os scans independentes de dependencias e infraestrutura.
- `SAST`: envia o pacote para a plataforma Veracode e executa o Pipeline Scan.

O template usa `needs` para otimizar a execucao:

- `Veracode_SCA` e `Veracode_IaC` usam `needs: []`, portanto podem iniciar sem aguardar o empacotamento.
- `Veracode_Plataforma`, `Veracode_Sandbox` e `Veracode_SAST` dependem apenas do job `packaging` e consomem o artifact do `.zip`.

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

Esse job roda no stage `Deps_IaC` com `needs: []` e `when: always`, portanto pode iniciar de forma independente e tenta executar mesmo se outro job falhar.

Para funcionar, o SCA Agent precisa da variavel:

- `SRCCLR_API_TOKEN`

Essa variavel e obrigatoria para autenticar o agente SCA no tenant Veracode.

### `Veracode_IaC`

Executa o Veracode IaC Scan usando o Veracode CLI para analisar arquivos de infraestrutura como codigo no repositorio.

Esse job roda no stage `Deps_IaC` com `needs: []`, portanto nao depende do pacote `.zip`. Ele usa `allow_failure: true` para nao bloquear o pipeline caso o scan IaC encontre erro ou retorne falha.

O job usa as mesmas credenciais HMAC da Veracode definidas para os scans SAST:

- `VERACODE_API_ID`
- `VERACODE_API_KEY`

Durante a execucao, essas variaveis sao exportadas como `VERACODE_API_KEY_ID` e `VERACODE_API_KEY_SECRET`, nomes esperados pelo Veracode CLI.

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
| `VERACODE_API_ID` | Sim | API ID Veracode usado pelo Wrapper, Pipeline Scan e Veracode CLI/IaC. |
| `VERACODE_API_KEY` | Sim | API Key Veracode usada pelo Wrapper, Pipeline Scan e Veracode CLI/IaC. |
| `SRCCLR_API_TOKEN` | Sim | Token usado pelo Veracode SCA Agent. Sem ele o job `Veracode_SCA` nao autentica. |
| `APP_Profile` | Nao | Nome da aplicacao na Veracode. Por padrao usa `${CI_PROJECT_NAME}`. |
| `Caminho_Arquivo` | Nao | Nome/caminho do pacote enviado para analise. Por padrao usa `verademo.zip`. |

### Como obter as credenciais Veracode

Para `VERACODE_API_ID` e `VERACODE_API_KEY`, gere credenciais HMAC na plataforma Veracode:

- Documentacao oficial: [Veracode API credentials](https://docs.veracode.com/r/c_api_credentials3)
- Referencia HMAC: [HMAC credentials](https://docs.veracode.com/r/HMAC_credentials)

Na plataforma Veracode, acesse o menu do usuario e procure por `API Credentials`. Gere credenciais HMAC e copie o `API ID` para `VERACODE_API_ID` e o `Secret Key` para `VERACODE_API_KEY`.

Para `SRCCLR_API_TOKEN`, crie um agent token para o Veracode SCA Agent:

- Integracao com CI: [Integrate SCA CI agents](https://docs.veracode.com/r/Integrate_SCA_agents)
- Configuracao do agente: [Configure SCA agents](https://docs.veracode.com/r/SCA_agent_configuration)

Na plataforma Veracode, acesse `Scans & Analysis > Software Composition Analysis > Agent-Based Scan`, selecione o workspace, crie um agent e salve o token como `SRCCLR_API_TOKEN`.

Recomendacoes para as variaveis sensiveis:

- Marcar `VERACODE_API_ID`, `VERACODE_API_KEY` e `SRCCLR_API_TOKEN` como `Masked`.
- Marcar como `Protected` somente se o pipeline rodar em branches/tags protegidas.
- Nao gravar credenciais diretamente no arquivo `.gitlab-ci.yml`.

## Configuracao minima

O projeto precisa ter um `.gitlab-ci.yml` usando o conteudo do `GitLab-ZIP.yml` ou incluindo esse template conforme o modelo adotado no repositorio.

Antes de executar, confirme:

- as tres variaveis sensiveis foram criadas no GitLab;
- o usuario/API credential da Veracode tem permissao para criar perfil de aplicacao e executar scans;
- o runner GitLab consegue acessar a internet para baixar o SCA Agent, o Veracode CLI e o Pipeline Scan;
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
