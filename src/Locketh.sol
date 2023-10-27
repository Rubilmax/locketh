// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

import {ERC20PermitUpgradeable} from
    "../lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20PermitUpgradeable.sol";

contract Locketh is ERC20PermitUpgradeable {
    using Strings for uint256;

    uint256 public RELEASE_TIMESTAMP;

    constructor() initializer {}

    function initialize(uint256 releaseTimestamp) external initializer {
        RELEASE_TIMESTAMP = releaseTimestamp;

        __ERC20_init(
            string.concat("Locked ETH (", releaseTimestamp.toString(), ")"),
            string.concat("lockETH-", releaseTimestamp.toString())
        );
        __ERC20Permit_init("Locketh");
    }

    /* EXTERNAL */

    function mint(address to) external payable {
        require(block.timestamp <= RELEASE_TIMESTAMP, ErrorsLib.LOCKED);

        _mint(to, msg.value);
    }

    function redeem(address from, uint256 value) external {
        require(block.timestamp > RELEASE_TIMESTAMP, ErrorsLib.LOCKED);

        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _burn(from, value);

        payable(spender).transfer(value);
    }
}
