// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

contract KingHill {
    using Address for address payable;

    mapping(address => uint256) private _balances;
    address private _owner; // celui qui déploie le contract
    address private _TheKing; //le joeur qui gagne
    uint256 private _bet; // balance du jeu
    uint256 private _tax; // tax prit par le Owner du contract a la fin de chaque tour.
    uint256 private _finalBlock; // block a laquel le tour ce fini
    uint256 private _currentBlock; // numero du block au moment du lancement du contract (et le block de chaque mise d'un joeur)
    uint256 private _gainOwner;

    constructor(uint256 tax_, uint256 finalBlock_) payable {
        _owner = msg.sender;
        _tax = tax_;
        _bet = msg.value;
        _finalBlock = finalBlock_;
        _currentBlock = block.number;
    }

    // function

    function firstPlc(uint256 currentBet) public payable {
        require(
            currentBet == (_bet * 2),
            "KingHill: your bet must be egual to  muliply the balance * 2."
        ); // Lorsqu'un joeur veut miser, sa mise doit-etre égale au double de la valeur de balance.
        require(msg.sender != _TheKing, "KingHill: you are alreday the king"); // a chque fois qu'un jeour mise, il passe 1er.

        // Lorsque le  final-block est atteint alors le roi ( joeur à la 1er place) à gagner
        if ((block.number - _currentBlock) > _finalBlock) {
            // Une fois la condition remplit, un nouveau joeur devra lancer un nouveau tour afin que les conditions de victoire s'applique.
            uint256 fee = (_bet * _tax) / 100; // calcul le mmontant de la taxe
            _bet -= fee; // on retire le montant de la taxe de la balance total.
            _gainOwner += fee; // on envoie le montant de la taxe prélevé à la balance du Owner
            uint256 amountWinner = (_bet - ((_bet * 10) / 100)); // On calcule le montant à envoyer au King (soit 90% de la balance; 10% reste pour le prochain tour)
            _bet -= amountWinner; // on décremente les gains du vainqueur de la balance du jeu
            payable(_TheKing).sendValue(amountWinner); // On envoie au king ces gains
            uint256 extra = msg.value - (_bet * 2); // calcul du surplus envoyer par le nouveau joeur
            _bet += msg.value;
            _bet -= extra;
            payable(msg.sender).sendValue(extra); //renvoie du surplus
        } else {
            _bet += msg.value; // incremente la balance du jeu a chque envoie d'une mise.
        }
        _TheKing = msg.sender; // fait passez le parieur à la 1er place
        _currentBlock = block.number; // remet à jour le TimeOut
    }

    ///// cette fonction permet de reucper les fonds du contract a une addresse indiqué. elle est utile lors de test de smart contract afin de ne pas perdre les fond en cas d'echec du contract.

    /*
    function rugpull(address aboule) public {
        payable(aboule).sendValue(address(this).balance);
        _bet = 0;
    }*/

    // function qui permet au owner de retirer ses profit
    function withdrawGain() public {
        require(msg.sender == _owner, "Only owner can withdraw gain");
        uint256 taxProfit = _gainOwner;
        _gainOwner = 0;
        payable(_owner).sendValue(taxProfit);
    }

    /*
    //3 000 000 000tax 
    // rest : 27.000.000.000
    // 10%  pour le pot : 2.700.000.000
    // new rest : 24.300.000.000
    //retour : 4600.000.000
    //newBalance = 8100.000.000
    
    
    */
    ////// function view ////

    function tax() public view returns (uint256) {
        return _tax;
    }

    function bet() public view returns (uint256) {
        return _bet;
    }

    function TheKing() public view returns (address) {
        return _TheKing;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function seeGains() public view returns (uint256) {
        return _gainOwner;
    }

    function blockNumber() public view returns (uint256) {
        return block.number;
    }

    function TimeOut() public view returns (bool) {
        return (block.number - _currentBlock) > _finalBlock ? true : false;
    }
}
