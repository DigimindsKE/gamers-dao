// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
/* 
Contract to create new currencies
Can only be called by the multi-sig contract.

minting tokens as rewards can be called by enemies/reward contracts
burnable
*/


contract erc1155Minter is ERC1155, Ownable, ERC1155Burnable {
    constructor() ERC1155("") {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(address account, uint256 id, uint256 amount, bytes calldata data)
        public
        onlyOwner
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes calldata data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }
}