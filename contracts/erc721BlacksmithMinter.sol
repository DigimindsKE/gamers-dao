//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./multisig.sol";
import "./RNG.sol";

contract erc721BlacksmithMinter is ERC721, Ownable, RNG {
    error NotAuthorized();
    error GameNotFound();
    error InvalidPrice();
    error NotApprovedCurrency();
    error InsufficientAmount();
    error ZeroAddress();

    struct WeaponType {
        string[] typeWeapon; //axe, sword, gun, etc
        string[] weaponImage;
    }
    struct MintedWeapon {
        string weaponType;
        string imageUri;
    }

    address private admin;
    address private multisigAddress;
    multisig private dao;
    RNG private rng;
    ICurrency private token;
    uint private wTypeCounter;
    uint private tokenCounter;
    uint private buyingCurrency;
    uint private buyingPrice;
    uint private requestID;

    mapping(uint256 => WeaponType) private weaponType;
    mapping(uint256 => MintedWeapon) private mintedDetails;

    constructor(
        address _DAO,
        address _rng,
        address _buyToken
    ) ERC721("Weapons", "WPN") RNG(subscriptionId,vrfCoordinator,keyHash) {
        if(_DAO==address(0)||_rng==address(0)|| _buyToken==address(0)) revert ZeroAddress();
        dao = multisig(_DAO);
        multisigAddress = _DAO;
        rng = RNG(_rng);
        token = ICurrency(_buyToken);
        // admin = multisig.admin();
        tokenCounter = 0;
    }

    function setWeaponPrice(uint tokenId, uint price) external {
        if (!dao.currencyApproved(tokenId)) revert NotApprovedCurrency();
        if (price == 0) revert InvalidPrice();
        buyingCurrency = tokenId;
        buyingPrice = price;
    }

    function addWeapon(
        uint id,
        string calldata _weapon,
        string calldata _imgUri
    ) external payable {
        if (msg.sender != multisigAddress) revert NotAuthorized();
        //if(!dao.gameApproved(_address)) revert GameNotFound();
        //if (_address== address(0)) revert ZeroAddress();

        WeaponType storage weapon = weaponType[id];
        weapon.typeWeapon.push(_weapon);
        weapon.weaponImage.push(_imgUri);
    }

    function mintWeapon() external {
        //check if there is enough tokens in sender wallet
        if (token.balanceOf(_msgSender(), buyingCurrency) <= buyingPrice)
            revert InsufficientAmount();

//send buying price to burn address
        token.safeTransferFrom(
            _msgSender(),
            address(0),
            buyingCurrency,
            buyingPrice,
            ""
        );
        uint tokenID = ++tokenCounter;
        _safeMint(_msgSender(), tokenID);
        uint requestId = rng.requestRandomWords(1, 200000);
        requestID = requestId;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        virtual
        override
    {
        uint _requestId = requestId;
        //Retrieve details for mint using request ID
        WeaponType storage weapon = weaponType[_requestId];
        uint index = randomWords[0] % weapon.typeWeapon.length;

        MintedWeapon storage tokens = mintedDetails[tokenCounter];
        tokens.weaponType = weapon.typeWeapon[index];
        tokens.imageUri = weapon.weaponImage[index];
    }

    function removeWeapon(uint id, string memory _weaponType) external {
        if (msg.sender != admin) revert NotAuthorized();
        WeaponType storage item = weaponType[id];

        string[] memory toBeDeleted = item.typeWeapon;
    
        for (uint i = 0; i < toBeDeleted.length; ) {
            if (keccak256(abi.encodePacked(_weaponType)) == keccak256(abi.encodePacked(toBeDeleted[i]))) {
                 delete toBeDeleted[i];
               delete item.weaponImage[i];
            }
            unchecked {
                i++;
            }
        }
    }
}
