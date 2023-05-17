# Exemplos de Pipelines

## Sobre os exemplos
Os pipelines de exemplo foram feitos com base em dois projetos públicos com falhas conhecidas:</br>
[Verademo](https://github.com/M3Corp-Community/Verademo) e [NodeGoat](https://github.com/M3Corp-Community/NodeGoat-JS) </br>
Nesses repositórios mencionados vai encontra-los já configurados para uso </br>
Os pipelines foram desenhados para mostrar como implementar todas as ferramentas </br>

## Antes de começar a usar
Precisamos do Java disponível para conseguir utilizar as ferramentas da Veracode </br>
Junto com ele, precisamos configurar 3 variáveis que obtemos no site da Veracode:</br>
[VeracodeID e VeracodeKey](https://docs.veracode.com/r/c_api_credentials3)</br>
[SRCCLR_API_TOKEN](https://docs.veracode.com/r/yWEmzLVoSzK6HlP~GSch2w/IpZwISEgarjTY59TzowKWQ)</br>
Clicando nos links acima vai conseguir verificar exatamente como gerar elas</br>
O ideal é que fiquem num cofre, conforme mostrado em alguns exemplos</br>

## Guia de empacotamento
Para conseguirmos extrair o melhor da ferramenta, precisamos segui-lo:</br>
[Ler com atenção as orientações para a linguagem do projeto](https://docs.veracode.com/r/c_comp_quickref)</br>

## Tipos de exemplos
Basic -> Modelo de implementação mais simples, onde apenas geramos o pacote e enviamos para a analise na nuvem sem aguardar</br>
Advanced -> Modelo onde também implementamos as ferramentas que trazem os resultados para os LOGs do pipeline</br>
Expert -> Projetos utilizando o paralelismo para otimizar o processo</br>

## SandBox
Para os casos onde tem dentro de um mesmo projeto uma versão de código que quer analisar mas não é a considerada "produção"</br>
Podemos utilizar o recurso de SandBox no U&S/Wrapper, onde realizamos uma analise com as mesmas capacidades, mas armazenando o resulto em uma caixa isolada</br>
Dentro de cada ferramenta teremos ao menos um exemplo de como implementar, mas lembre-se de que pode alterar os exemplos mais complexos adicionando os parâmetros necessários: SandBoxName e CreateSandBox</br>

## Dicas de otimização
As ferramentas podem ser utilizadas em conjunto, buscando otimizar o processo</br>
Paralelizar o build com o SCA é bem interessante</br>
Só o Upload And Scan(U&S) já faz de forma unificada os dois tipos de scans, mas ao usar o SCA e o Pipeline Scan vai conseguir ter os resultados no LOG, o que pode ser bem util