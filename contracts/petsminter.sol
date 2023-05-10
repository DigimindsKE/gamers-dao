// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./spntoken.sol";

contract petsMinter is ERC721 {
    error NotAuthorised();
    error InvalidInput();
    error AllowanceInsufficient();

    event PetMinted( address ownerAddress, uint tokenID);

    uint private tknCounter;
    uint public petPrice;

    spnToken private token;

    address private feeReceiver;
    address private admin;

    constructor(address _tokenAddress ) ERC721("DAO Pets", "PETS") {
        token = spnToken(_tokenAddress);
        tknCounter = 0;
        admin = msg.sender;
    }

    modifier onlyApproved {
        if(msg.sender != admin) revert NotAuthorised();
        _;
    }
    function setFeeTo(address _receiverAddress) external onlyApproved{
        if(_receiverAddress==address(0)) revert InvalidInput();
        feeReceiver = _receiverAddress;

    }
    function setPetPrice(uint _amount) external onlyApproved {
        if(_amount==0) revert InvalidInput();
        petPrice = _amount;
    }

    function mintPet() external{
        if(token.allowance(msg.sender, address(this))<petPrice) revert AllowanceInsufficient();
        token.transferFrom(msg.sender, feeReceiver, petPrice);
        uint tokenId = ++tknCounter;
        _mint(msg.sender,tokenId);

        emit PetMinted(msg.sender, tokenId);
    }

}