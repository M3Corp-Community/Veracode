# Exemplos de Pipelines

## Sobre os exemplos
Os pipelines de exemplo foram feitos com base em dois projetos públicos com falhas conhecidas:</br>
[Verademo](https://github.com/M3Corp-Community/Verademo) e [NodeGoat](https://github.com/M3Corp-Community/NodeGoat-JS) </br>
Nesses repositórios mencionados vai encontra-los já configurados para uso </br>
Os pipelines foram desenhados para mostrar como implementar todas as ferramentas </br>

## Antes de começar a usar
Precisamos do Java disponivel para conseguir utilizar as ferramentas da Veracode </br>
Junto com ele, precisamos configurar 3 variáveis que obtemos no site da Veracode:</br>
[VeracodeID e VeracodeKey](https://docs.veracode.com/r/c_api_credentials3)</br>
[SRCCLR_API_TOKEN](https://docs.veracode.com/r/yWEmzLVoSzK6HlP~GSch2w/IpZwISEgarjTY59TzowKWQ)</br>
Clicando nos links acima vai conseguir verificar exatamente como gerar elas</br>
O ideal é que fiquem num cofre, conforme mostrado em alguns exemplos</br>

## Guia de empacotamento
Para conseguirmos extrair o melhor da ferramenta, precisamos segui-lo:</br>
[Ler com atenção as orientações para a linguagem do projeto](https://docs.veracode.com/r/c_comp_quickref)</br>

## Dicas de otimização
As ferramentas podem ser utilizadas em conjunto, buscando otimizar o processo</br>
Paralelizar o build com o SCA é bem interessante</br>
Só o SAST já faz de forma unificada os dois tipos de scans, mas ao usar o SCA e o Pipeline Scan</br>
Vai conseguir ter os resultados no LOG, o que pode ser bem util</br>