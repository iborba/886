// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract WineSupplyChain {
  struct Wine {
    uint id;
    string name;
    string vineyard;
    string region;
    string grape;
    address owner;
    address producer;
    string status; // "created", "produced", "bottled", "sold", "shipped", "in transit",, "received"
  }

  struct Transaction {
    uint id;
    uint wineId;
    address from;
    address transporter;
    address to;
    string status; // "pending", "completed"
  }

  mapping(uint => Wine) public wines;
  mapping(uint => Transaction) public transactions;
  
  uint public wineCount;
  uint public transactionCount;

  event WineCreated(uint256 indexed id, string name, string vineyard, string region, string grape, address owner, address producer, string status);
  event WineSold(uint256 indexed id, address from, address to, address transporter);
  event WineShipped(uint256 indexed id, address from, address to, address transporter);
  event WineReceived(uint256 indexed id, address from, address to, address transporter);
  event WineStatusChanged(uint256 indexed id, string status);

  function createWine(string memory _name, string memory _vineyard, string memory _region, string memory _grape) public {
    wineCount++;
    wines[wineCount] = Wine(wineCount, _name, _vineyard, _region, _grape, msg.sender, address(0), "available");
    emit WineCreated(wineCount, _name, _vineyard, _region, _grape, msg.sender, address(0), "available");
  }

  function sellWine(uint _id, address _to, address _transporter) public {
    Wine storage wine = wines[_id];
    require(wine.owner == msg.sender, "You are not the owner of this wine");
    require(keccak256(bytes(wines[_id].status)) == keccak256(bytes("available")), "Wine must be available for sale");

    wine.owner = _to;
    wine.status = "sold";
    transactionCount++;
    transactions[transactionCount] = Transaction(transactionCount, _id, msg.sender, _transporter, _to, "pending");

    emit WineSold(_id, msg.sender, _to, _transporter);
    emit WineStatusChanged(_id, "sold");
  }

  function shipWine(uint _id, address _to, address _transporter) public {
    Wine storage wine = wines[_id];
    require(wine.owner == msg.sender, "You are not the owner of this wine");
    wine.status = "in transit";
    transactionCount++;
    transactions[transactionCount] = Transaction(transactionCount, _id, msg.sender, _transporter, _to, "pending");
    emit WineShipped(_id, msg.sender, _to, _transporter);
    emit WineStatusChanged(_id, "in transit");
  }

  function receiveWine(uint _id, address _from, address _to, address _transporter) public {
    Wine storage wine = wines[_id];
    require(wine.owner == msg.sender, "You are not the owner of this wine");
    wine.status = "received";
    emit WineReceived(_id, _from, _to, _transporter);
    emit WineStatusChanged(_id, "received");
  }

  function getWine(uint _id) public view returns (Wine memory) {
    return wines[_id];
  }
}