// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "./multisig.sol";
/* 
Contract to create new currencies
Can only be called by the multi-sig contract.

minting tokens as rewards can be called by enemies/reward contracts
burnable
*/

contract erc1155CurrencyMinter is ERC1155, Ownable, ERC1155Burnable {
    error NotAuthorised();
    error NotApprovedCurrency();
    error ZeroAddress();
    error RewardTokenNotFound();
    mapping(uint => bool) private tokenExists;

    multisig msDAO;
    //only these addresses can call specific functions from the contract
    address private admin;
    address private reward;

    uint private currentId;
    uint[] public tokenIDs;
    constructor(address _DAO) ERC1155("") {
        //DAO = _DAO;
        msDAO = multisig(_DAO);
        admin = msDAO.admin();
        currentId = 0;
    }

    function setURI(string memory newuri) external onlyOwner {
        _setURI(newuri);
    }

    function setRewardAddress(address _reward)external onlyOwner{
        if (_reward== address(0) ) revert ZeroAddress();
        reward = _reward;
    }

    function addToken(uint256 amount) external {
        uint tokenId = currentId + 1;
        bool isCurrencyApproved = msDAO.currencyApproved(tokenId);
        if (msg.sender != admin) revert NotAuthorised();
        if(!isCurrencyApproved) revert NotApprovedCurrency();
        tokenExists[tokenId] = true;
        _mint(_msgSender(), tokenId, amount, "");
        currentId = tokenId;
        tokenIDs.push(tokenId);
    }

    //function to mint reward
    function mintRewards(uint256 id, uint256 amount) external {
        if (msg.sender != reward) revert NotAuthorised();
        if (!tokenExists[id]) revert RewardTokenNotFound();
        _mint(_msgSender(), id, amount, "");
    }
}

interface ICurrency is IERC1155{
function _burn(address from,
        uint256 id,
        uint256 amount) external;
}
