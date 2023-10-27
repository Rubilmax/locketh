// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import {IERC20} from
    "../lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {IERC20Metadata} from
    "../lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/interfaces/IERC20Metadata.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {Strings} from "../lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {SafeERC20} from
    "../lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

import {ERC20PermitUpgradeable} from
    "../lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20PermitUpgradeable.sol";

contract LockERC20 is ERC20PermitUpgradeable {
    using Strings for uint256;
    using SafeERC20 for IERC20;

    IERC20 public UNDERLYING;
    uint256 public RELEASE_TIMESTAMP;

    constructor() initializer {}

    function initialize(address underlying, uint256 releaseTimestamp) external initializer {
        UNDERLYING = IERC20(underlying);
        RELEASE_TIMESTAMP = releaseTimestamp;

        string memory underlyingSymbol = IERC20Metadata(underlying).symbol();

        string memory _name = string.concat("Locked ", underlyingSymbol, " (", releaseTimestamp.toString(), ")");
        string memory _symbol = string.concat("lock", underlyingSymbol, "-", releaseTimestamp.toString());

        __ERC20_init(_name, _symbol);
        __ERC20Permit_init(_name);
    }

    /* EXTERNAL */

    function mint(address to, uint256 value) external {
        require(block.timestamp <= RELEASE_TIMESTAMP, ErrorsLib.LOCKED);

        UNDERLYING.safeTransferFrom(msg.sender, address(this), value);

        _mint(to, value);
    }

    function redeem(address from, address to, uint256 value) external {
        require(block.timestamp > RELEASE_TIMESTAMP, ErrorsLib.LOCKED);

        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _burn(from, value);

        UNDERLYING.safeTransfer(to, value);
    }
}
