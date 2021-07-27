//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract UpsideERC721Minter is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    uint256 private _tokenIds;

    string public constant IPFS_HASH = "QmWS694ViHvkTms9UkKqocv1kWDm2MTQqYEJeYi6LsJbxK";

    uint256 public constant ETH_PRICE = 0.01 ether;
    uint256 public constant MAX_PER_TX = 20;
    uint256 public constant MAX_SUPPLY = 10000;

    bool public burningEnabled = false;
    bool public mintingEnabled = false;

    address payable public upside_vault;

    event Minted(address to, uint256 quantity);

    constructor() ERC721("PUNKS Comic", "COMIC") {
        upside_vault = payable(msg.sender);
    }

    function mint(uint256 quantity) public payable {
        require(msg.sender == upside_vault || mintingEnabled, "minting is not enabled yet");
        require(quantity <= MAX_PER_TX, "minting too many");
        require(msg.value == getPrice(quantity), "wrong amount");
        require(totalSupply() < MAX_SUPPLY, "sold out");
        require(totalSupply() + quantity <= MAX_SUPPLY, "exceeds max supply");

        for (uint256 i = 0; i < quantity; i++) {
            _tokenIds++;

            uint256 newTokenId = _tokenIds;
            _safeMint(msg.sender, newTokenId);
            _setTokenURI(newTokenId, IPFS_HASH);
        }

        emit Minted(msg.sender, quantity);
    }

    function getPrice(uint256 quantity) public pure returns (uint256) {
        return ETH_PRICE * quantity;
    }

    function withdraw() public {
        upside_vault.transfer(address(this).balance);
    }

    function toggleBurningEnabled() public onlyOwner {
        burningEnabled = !burningEnabled;
    }

    function toggleMintingEnabled() public onlyOwner {
        mintingEnabled = !mintingEnabled;
    }

    function burn(uint256 tokenId) public virtual {
        require(burningEnabled, "burning is not yet enabled");
        require(_isApprovedOrOwner(_msgSender(), tokenId), "caller is not owner nor approved");
        _burn(tokenId);
    }

    function remainingSupply() public view returns (uint256) {
        return MAX_SUPPLY - totalSupply();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://ipfs/";
    }
}
