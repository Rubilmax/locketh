// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import {Clones} from "../lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/Clones.sol";

import {Locketh} from "./Locketh.sol";

uint256 constant SPACING = 12 hours;

contract Lockether {
    address public immutable IMPLEMENTATION;

    constructor(address implementation) {
        IMPLEMENTATION = implementation;
    }

    function create(uint256 releaseTimestamp) external returns (address locket) {
        locket = Clones.cloneDeterministic(IMPLEMENTATION, bytes32(releaseTimestamp));

        Locketh(locket).initialize(releaseTimestamp);
    }

    function locketh(uint256 releaseTimestamp) external view returns (address) {
        return Clones.predictDeterministicAddress(IMPLEMENTATION, bytes32(releaseTimestamp), address(this));
    }
}
