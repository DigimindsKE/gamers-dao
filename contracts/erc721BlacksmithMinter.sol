//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./multisig.sol";
import "./RNG.sol";
import "./spntoken.sol";

contract erc721BlacksmithMinter is ERC721, Ownable, Consumer {
    error NotAuthorized();
    error GameNotFound();
    error InvalidPrice();
    error NotApprovedCurrency();
    error InsufficientAmount();
    error ZeroAddress();
    error NotApprovedOperator();

    struct WeaponType {
        string[] typeWeapon; //axe, sword, gun, etc
        string[] weaponImage;
    }
    struct MintedWeapon {
        string weaponType;
        string imageUri;
    }
    
    
    address private feeCollector;
    address private admin;
    address private multisigAddress;
    multisig private dao;
    //  RNG private rng;
    IERC20 private token;

    uint private tokenCounter;
    //uint private buyingCurrency;
    uint private buyingPrice;
    uint private requestID;

    mapping(uint256 => WeaponType) private weaponType;
    mapping(uint256 => MintedWeapon) public mintedDetails;
   

    constructor(
        address _DAO,
        address _buyToken,
        uint64 subscriptionId
    ) ERC721("Weapons", "WPN") Consumer(subscriptionId) {
        if (_DAO == address(0) || _buyToken == address(0)) revert ZeroAddress();
        dao = multisig(_DAO);
        multisigAddress = _DAO;
        // rng = RNG(_rng);
        token = IERC20(_buyToken);
        admin = dao.admin();
        tokenCounter = 0;
    }

    modifier onlyAdmin() {
        if (msg.sender != admin) revert NotAuthorized();
        _;
    }

    function feeTo(address _address) external onlyAdmin {
        if (_address == address(0)) revert ZeroAddress();
        feeCollector = _address;
    }

    function checkBalance(address _address) public view returns (uint) {
        return token.balanceOf(_address);
    }

    function setWeaponPrice(uint price) external onlyAdmin {
        //if (!dao.currencyApproved(tokenId)) revert NotApprovedCurrency();
        if (price == 0) revert InvalidPrice();
        buyingPrice = price;
    }

    function addWeapon(
        uint id,
        string calldata _weapon,
        string calldata _imgUri
    ) external onlyAdmin {
        //if(!dao.gameApproved(_address)) revert GameNotFound();
        //if (_address== address(0)) revert ZeroAddress();

        WeaponType storage weapon = weaponType[id];
        weapon.typeWeapon.push(_weapon);
        weapon.weaponImage.push(_imgUri);
    }

    function mintWeapon() external {
        //check if there is enough tokens in sender wallet
        if (token.balanceOf(_msgSender()) <= buyingPrice)
            revert InsufficientAmount();

        //send buying price to burn address
        token.transferFrom(_msgSender(), feeCollector, buyingPrice);
        ++tokenCounter;
        _mint(_msgSender(), tokenCounter);
        requestRandomWords();
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal virtual override {
        //uint _requestId = requestId;
        //Retrieve details for mint using request ID
        s_requests[requestId].fulfilled = true;
        s_requests[requestId].randomWords = randomWords;
        WeaponType storage weapon = weaponType[tokenCounter];
        uint index = randomWords[0] % weapon.typeWeapon.length;

        MintedWeapon storage tokens = mintedDetails[tokenCounter];
        tokens.weaponType = weapon.typeWeapon[index];
        tokens.imageUri = weapon.weaponImage[index];
    }

    function removeWeapon(
        uint id,
        string memory _weaponType
    ) external onlyAdmin {
        WeaponType storage item = weaponType[id];

        string[] memory toBeDeleted = item.typeWeapon;

        for (uint i = 0; i < toBeDeleted.length; ) {
            if (
                keccak256(abi.encodePacked(_weaponType)) ==
                keccak256(abi.encodePacked(toBeDeleted[i]))
            ) {
                //item.typeWeapon.pop();
                //item.weaponImage.pop();
                item.typeWeapon[i] = item.typeWeapon[
                    item.typeWeapon.length - 1
                ];
                item.typeWeapon.pop();
                item.weaponImage[i] = item.weaponImage[
                    item.weaponImage.length - 1
                ];
                item.weaponImage.pop();
            }
            unchecked {
                i++;
            }
        }
    }
}
