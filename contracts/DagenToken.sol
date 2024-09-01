// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "hardhat/console.sol";

contract DegenToken is ERC20, Ownable, ERC20Burnable {
    struct StoreItem {
        string name;
        uint256 cost;
    }

    struct StoreRewards {
        uint DegenSword;
        uint DegenNFT;
        uint DegenShield;
    }

    mapping(uint8 => StoreItem) public storeItems;
    mapping(address => StoreRewards) public redeemed;

    constructor() ERC20("Degen", "DGN") Ownable(msg.sender) {
        storeItems[1] = StoreItem("Degen Sword", 100);
        storeItems[2] = StoreItem("Degen NFT", 75);
        storeItems[3] = StoreItem("Degen Shield", 50);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function decimals() public pure override returns (uint8) {
        return 0;
    }

    function getBalance() external view returns (uint256) {
        return this.balanceOf(msg.sender);
    }

    function transferTokens(address _receiver, uint256 _value) external {
        require(
            balanceOf(msg.sender) >= _value,
            "You do not have enough Degen Tokens"
        );
        approve(msg.sender, _value);
        transferFrom(msg.sender, _receiver, _value);
    }

    function burnTokens(uint256 _value) external {
        require(
            balanceOf(msg.sender) >= _value,
            "You do not have enough Degen Tokens"
        );
        burn(_value);
    }

    function showStoreItems() external view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "The following items are available for purchase:\n",
                    "Selection 1. ",
                    storeItems[1].name,
                    " (Cost: ",
                    uint2str(storeItems[1].cost),
                    " DGN)\n",
                    "Selection 2. ",
                    storeItems[2].name,
                    " (Cost: ",
                    uint2str(storeItems[2].cost),
                    " DGN)\n",
                    "Selection 3. ",
                    storeItems[3].name,
                    " (Cost: ",
                    uint2str(storeItems[3].cost),
                    " DGN)"
                )
            );
    }

    function redeemTokens(uint8 _userChoice) external returns (bool) {
        require(_userChoice >= 1 && _userChoice <= 3, "Invalid choice");

        StoreItem memory item = storeItems[_userChoice];
        require(
            balanceOf(msg.sender) >= item.cost,
            "You do not have enough Degen Tokens"
        );

        // Burn the tokens first
        burn(item.cost);

        // Now add the item to the user's account
        StoreRewards storage redeemedItems = redeemed[msg.sender];
        if (_userChoice == 1) {
            redeemedItems.DegenSword++;
        } else if (_userChoice == 2) {
            redeemedItems.DegenNFT++;
        } else if (_userChoice == 3) {
            redeemedItems.DegenShield++;
        }

        console.log("You have redeemed for a %s!", item.name);
        return true;
    }

    function uint2str(uint _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
