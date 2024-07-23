// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title Silo
 * @notice The Silo allows to store lpETH during the stake cooldown process.
 */
contract Silo {
    using SafeERC20 for IERC20;
    error OnlyStakingVault();

    address immutable STAKING_VAULT;
    IERC20 immutable lpETH;

    constructor(address _stakingVault, address _lpEth) {
        STAKING_VAULT = _stakingVault;
        lpETH = IERC20(_lpEth);
    }

    modifier onlyStakingVault() {
        if (msg.sender != STAKING_VAULT) revert OnlyStakingVault();
        _;
    }

    function withdraw(address to, uint256 amount) external onlyStakingVault {
        lpETH.safeTransfer(to, amount);
    }
}
