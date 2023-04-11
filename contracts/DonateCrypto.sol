// SPDX-License-Identifier: MIT
// - Licença dos fontes

pragma solidity ^0.8.17;


/**
 * @tittle Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

//campanha tem várias variáveis, fazendo assim preciso criar uma struct
//ajuda a definir estruturas de dados mais complexa
//Valores default em todas variáveis não inicializadas
struct Campaign {
    //uso do tipo address tem validações adicionais, tem algumas funções para pagamento
    address author;
    string tittle;
    string decription;
    string videoUrl;
    string imageUrl;
    uint256 balance;
    bool active;

}

contract DonateCrypto {
    //o tipo uint256 para não trabalhar com números negativos e são grandes
    //uint256 = tipo  
    //public  = modificador de acesso
    //fee     = nome da variável
    // = 100  = o valor da variável (opcionalmente)  
    uint256 public fee = 100; //100 da menor fração da moeda Ether (Wei) Seriam os centavos se o Ether fosse o real
    uint256 public nextId = 0;

    //estrutura de dados do solidity que define uma chave que aponta para o valor
    
    //criando um mapeamento de campanha 
    mapping(uint256 => Campaign) public campaigns; //id => campanha
    //essas variáveis de estado possuem esse nome pq elas ficam registradas na blockchain no disco, diferente de outras
    //linguagens de programação em que as coisas ficam por padrão na memória RAM, o SOLIDY é no disco do nó da blockchain
    //que estiver processando minha requisição

    //Por padrão o contrato salva as informações na blockchain 
    //calldata serve para não ser gravada na blockchain - somente leitura
    //memory - permite mudar o valor da variável

    //criar a função que adiciona a campanha na blockchain
    //toda chamada de função 
    function addCampaign(string calldata tittle, string calldata description, string calldata videoUrl, string calldata imageUrl) public {
       //criar uma variável temporária
       Campaign memory newCampaign;
       newCampaign.tittle = tittle;
       newCampaign.decription = description;
       newCampaign.videoUrl = videoUrl;
       newCampaign.imageUrl = imageUrl;
       newCampaign.active = true;
       newCampaign.author = msg.sender;
       //é quem enviou a campanha

       nextId++;
       campaigns[nextId] = newCampaign;
    }

    //funcionalidade de doação, de enviar fundos para plataforma
    //e a plataforma receber tais.
    //payable quer dizer que junto a chamada da função a 
    //carteira que chamou essa função pode enviar uma quantia em dinheiro junto
    //função que envolve envio de fundos
    //msg.value mostra a quantidade de dinheiro
    //botões vermelhos são funções payable que envia valores juntos
    function donate(uint256 id) public payable {
        require(msg.value > 0, "You must send a donation value > 0");
        require(campaigns[id].active == true, "Cannot donate to this campaign");

        //adiciona valor na campanha
        campaigns[id].balance += msg.value;

    }

    function withdraw(uint256 id) public {
        Campaign memory campaign = campaigns[id];
        require(campaign.author == msg.sender, "You do not have permission");
        require(campaigns[id].active == true, "This campaign is closed");
        require(campaign.balance > fee, "This campaign does not have enough balance");

        address payable recipient = payable(campaign.author);
        recipient.call{value: campaign.balance - fee}("");

        campaigns[id].active = false;

    }

}