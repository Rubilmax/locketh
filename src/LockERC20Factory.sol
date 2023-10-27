// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import {IERC20} from
    "../lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";

import {Clones} from "../lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/Clones.sol";
import {SafeERC20} from
    "../lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

import {LockERC20} from "./LockERC20.sol";

uint256 constant SPACING = 12 hours;
address constant ETH = address(0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

contract LockERC20Factory {
    using SafeERC20 for IERC20;

    address public immutable IMPLEMENTATION;

    constructor(address implementation) {
        IMPLEMENTATION = implementation;
    }

    function create(address underlying, uint256 releaseTimestamp) public returns (address locket) {
        locket = Clones.cloneDeterministic(IMPLEMENTATION, bytes32(releaseTimestamp));

        LockERC20(locket).initialize(underlying, releaseTimestamp);
    }

    function lockErc20(address underlying, uint256 releaseTimestamp) public view returns (address) {
        return Clones.predictDeterministicAddress(
            IMPLEMENTATION, keccak256(abi.encode(underlying, releaseTimestamp)), address(this)
        );
    }

    function lock(address underlying, uint256 releaseTimestamp, address to, uint256 value) external {
        address locket = lockErc20(underlying, releaseTimestamp);
        if (locket.code.length == 0) {
            create(underlying, releaseTimestamp);

            IERC20(underlying).forceApprove(locket, type(uint256).max);
        }

        IERC20(underlying).safeTransferFrom(msg.sender, address(this), value);

        LockERC20(locket).mint(to, value);
    }
}
