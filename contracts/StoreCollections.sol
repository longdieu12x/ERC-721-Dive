// SPDX-License-Identifier: None

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract StoreCollection is ERC1155, Ownable {
    //VARIABLES
    string public name;
    string public symbol;
    uint256 public tokenCount;
    string public baseURI;

    //CONSTRUCTOR
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI
    ) ERC1155(_baseURI) {
        name = _name;
        symbol = _symbol;
        baseURI = _baseURI;
    }

    // FUNCTIONS
    function mint(uint256 amount) public onlyOwner {
        tokenCount++;
        _mint(msg.sender, tokenCount, amount, "");
    }

    function uri(uint256 _tokenID)
        public
        view
        override
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(baseURI, Strings.toString(_tokenID), ".json")
            );
    }
}
