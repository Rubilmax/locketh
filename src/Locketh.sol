// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {Strings} from "../lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/Strings.sol";

import {ERC20PermitUpgradeable} from
    "../lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20PermitUpgradeable.sol";

contract Locketh is ERC20PermitUpgradeable {
    using Strings for uint256;

    uint256 public RELEASE_TIMESTAMP;

    constructor() initializer {}

    function initialize(uint256 releaseTimestamp) external initializer {
        RELEASE_TIMESTAMP = releaseTimestamp;

        string memory _name = string.concat("Locked ETH (", releaseTimestamp.toString(), ")");
        string memory _symbol = string.concat("lockETH-", releaseTimestamp.toString());

        __ERC20_init(_name, _symbol);
        __ERC20Permit_init(_name);
    }

    /* EXTERNAL */

    function mint(address to) external payable {
        require(block.timestamp <= RELEASE_TIMESTAMP, ErrorsLib.LOCKED);

        _mint(to, msg.value);
    }

    function redeem(address from, address payable to, uint256 value) external {
        require(block.timestamp > RELEASE_TIMESTAMP, ErrorsLib.LOCKED);

        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _burn(from, value);

        to.transfer(value);
    }
}
