pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../interfaces/SpatialAttributes.sol";

abstract contract SpatialObject is ERC721Enumerable, SpatialAttributes {
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}
}
