// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;
import "./erc1155currencyminter.sol";

contract rewards {
    address private currencyMinterAddress;
    mapping(uint => uint) PoolBalance;
    uint poolID;

    constructor(address _currencyAddress) {
        currencyMinterAddress = _currencyAddress;
    }

    function mintRewards(uint tokenID, uint _amount) external {
        erc1155CurrencyMinter minter = erc1155CurrencyMinter(
            currencyMinterAddress
        );

        minter.mintRewards(tokenID, _amount);
        PoolBalance[poolID] += _amount;
    }
}
