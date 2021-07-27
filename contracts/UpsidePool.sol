//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract UpsidePool {
    using SafeMath for uint256;

    event Deposit(address indexed depositer, uint256 competitionId, uint256 amount);

    event Withdraw(address indexed withdrawer, uint256 competitionId, uint256 amount);

    event Start(address indexed owner, address indexed token, uint256 tokenId, uint256 start, uint256 end);

    address public owner;

    struct Competition {
        address token;
        uint256 tokenId;
        address owner;
        uint256 start;
        uint256 end;
    }

    mapping(uint256 => Competition) competition;

    mapping(uint256 => mapping(address => uint256)) competitionDeposits;

    uint256 private competitionId = 0;

    function depositPrizeAndStart(
        address _token,
        uint256 _tokenId,
        uint256 _lengthInDays
    ) external {
        IERC721(_token).safeTransferFrom(msg.sender, address(this), _tokenId);

        competitionId++;

        Competition memory c;

        c.token = _token;
        c.tokenId = _tokenId;
        c.owner = msg.sender;
        c.start = block.timestamp;
        c.end = block.timestamp + _lengthInDays * 1 days;

        competition[competitionId] = c;

        emit Start(msg.sender, c.token, c.tokenId, c.start, c.end);
    }

    function deposit(uint256 _competitionId) public payable {
        require(msg.value > 0, "[UpsidePool]: deposit amount is invalid");

        competitionDeposits[_competitionId][msg.sender] = msg.value;

        emit Deposit(msg.sender, _competitionId, msg.value);
    }

    function withdraw(uint256 _competitionId, uint256 amount) public {
        require(competitionDeposits[_competitionId][msg.sender] <= amount, "[UpsidePool]: withdraw amount is invalid");

        competitionDeposits[_competitionId][msg.sender] = competitionDeposits[_competitionId][msg.sender] - amount;

        payable(msg.sender).transfer(amount);

        emit Withdraw(msg.sender, _competitionId, amount);
    }

    constructor() {
        owner = msg.sender;
    }
}
