# Exemplos em Powershell

## Sobre os exemplos
Exemplos para uso no Powershell do Windows, podendo ser necessário atualiza-lo para utilizar algumas funções

## Antes de começar a usar
Precisamos do Java disponivel para conseguir utilizar as ferramentas da Veracode </br>
Junto com ele, precisamos configurar 3 variáveis que obtemos no site da Veracode:</br>
[VeracodeID e VeracodeKey](https://docs.veracode.com/r/c_api_credentials3)</br>
[SRCCLR_API_TOKEN](https://docs.veracode.com/r/yWEmzLVoSzK6HlP~GSch2w/IpZwISEgarjTY59TzowKWQ)</br>
Clicando nos links acima vai conseguir verificar exatamente como gerar elas</br>
As duas primeiras devem ser configuradas pensando no uso do [arquivo de credenciais](https://docs.veracode.com/r/c_configure_api_cred_file)</br>
O SRCCLR precisa ser configurado como variável de ambiente</br>
Configure as ferramentas conforme o script de configuração, adicionando a pasta com elas no Path do sistema</br>
A forma como esse ultimo item foi implementado no script só serve para a seção, para usos regulares recomendo fazer diretamente no sistema</br>

## Guia de empacotamento
Para conseguirmos extrair o melhor da ferramenta, precisamos segui-lo:</br>
[Ler com atenção as orientações para a linguagem do projeto](https://docs.veracode.com/r/c_comp_quickref)</br>