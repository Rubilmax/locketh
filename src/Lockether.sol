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

    function create(uint256 releaseTimestamp) public returns (address locket) {
        locket = Clones.cloneDeterministic(IMPLEMENTATION, bytes32(releaseTimestamp));

        Locketh(locket).initialize(releaseTimestamp);
    }

    function locketh(uint256 releaseTimestamp) public view returns (address) {
        return Clones.predictDeterministicAddress(IMPLEMENTATION, bytes32(releaseTimestamp), address(this));
    }

    function mint(uint256 releaseTimestamp, address to) external payable {
        address locket = locketh(releaseTimestamp);

        if (locket.code.length == 0) create(releaseTimestamp);

        Locketh(locket).mint{value: msg.value}(to);
    }
}
