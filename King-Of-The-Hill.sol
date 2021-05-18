// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

contract KingHill {
    using Address for address payable;

    mapping(address => uint256) private _balances;
    address private _owner;
    address private _TheKing;
    uint256 private _bet;
    uint256 private _tax;
    uint256 private _finalBlock;
    uint256 private _currentBlock;
    uint256 private _gainOwner;

    constructor(uint256 tax_, uint256 finalBlock_) payable {
        _owner = msg.sender;
        _tax = tax_;
        _bet = msg.value;
        _finalBlock = finalBlock_;
        _currentBlock = block.number;
    }

    event King(address indexed King, uint256 amount);
    event Winner(address indexed Winner, uint256 amount);

    // function

    function ToBeTheKing() public payable {
        require(
            msg.value == (_bet * 2),
            "KingHill: your bet must be egual to  muliply the balance * 2."
        );
        require(msg.sender != _TheKing, "KingHill: you are alreday the king");

        // Lorsque le  final-block est atteint alors le roi ( joeur à la 1er place) à gagner

        if ((block.number - _currentBlock) > _finalBlock) {
            uint256 fee = (_bet * _tax) / 100;
            _bet -= fee;
            _gainOwner += fee;

            uint256 amountWinner = (_bet - ((_bet * 10) / 100));
            _bet -= amountWinner;
            payable(_TheKing).sendValue(amountWinner);
            emit Winner(_TheKing, amountWinner);

            uint256 extra = msg.value - (_bet * 2);
            _bet += msg.value;
            _bet -= extra;
            payable(msg.sender).sendValue(extra);
        } else {
            _bet += msg.value;
        }

        _TheKing = msg.sender;
        _currentBlock = block.number;
        emit King(msg.sender, msg.value);
    }

    ///// cette fonction permet de recuperer les fonds du contract à une addresse indiqué. elle est utile lors de test de smart contract afin de ne pas perdre les fond en cas d'echec du contract.

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
