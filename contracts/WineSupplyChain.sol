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
    address owner;
    address transporter;
    address receiver;
    string status; // "pending", "completed"
  }

  mapping(uint => Wine) public wines;
  mapping(uint => Transaction) public transactions;
  
  uint public wineCount;
  uint public transactionCount;

  event WineCreated(uint256 indexed id, string name, string vineyard, string region, string grape, address owner, address producer, string status);
  event WineSold(uint256 indexed id, address from, address to);
  event WineShipped(uint256 indexed id, address from, address to, address transporter);
  event WineDelivered(uint256 indexed id, address to);
  event WineStatusChanged(uint256 indexed id, string status);

  function createWine(string memory _name, string memory _vineyard, string memory _region, string memory _grape) public {
    wineCount++;
    string memory wineStatus = "available";
    wines[wineCount] = Wine(wineCount, _name, _vineyard, _region, _grape, msg.sender, address(0), wineStatus);

    emit WineCreated(wineCount, _name, _vineyard, _region, _grape, msg.sender, address(0), wineStatus);

    transactionCount++;
    transactions[transactionCount] = Transaction(transactionCount, wineCount, msg.sender, address(0), address(0), wineStatus);
  }

  function sellWine(uint _id, address _to) public {
    Wine storage wine = wines[_id];
    require(wine.owner == msg.sender, "You are not the owner of this wine");
    require(keccak256(bytes(wines[_id].status)) == keccak256(bytes("available")), "Wine must be available for sale");

    wine.status = "sold";

    emit WineSold(_id, msg.sender, _to);
    emit WineStatusChanged(_id, wine.status);

    transactionCount++;
    transactions[transactionCount] = Transaction(transactionCount, _id, msg.sender, address(0), _to, wine.status);
  }

  function shipWine(uint _id, address _to, address _transporter) public {
    Wine storage wine = wines[_id];
    require(wine.owner == msg.sender, "You are not the owner of this wine");

    wine.owner = _transporter;
    wine.status = "in transit";

    emit WineShipped(_id, msg.sender, _to, _transporter);
    emit WineStatusChanged(_id, wine.status);

    transactionCount++;
    transactions[transactionCount] = Transaction(transactionCount, _id, _transporter, address(0), _to, wine.status);
  }

  function deliverWine(uint _id, address _to) public {
    Wine storage wine = wines[_id];
    require(wine.owner == msg.sender, "You are not the owner of this wine");

    wine.owner = _to;
    wine.status = "delivered";
    emit WineDelivered(_id, _to);
    emit WineStatusChanged(_id, wine.status);

    transactionCount++;
    transactions[transactionCount] = Transaction(transactionCount, _id, _to, msg.sender, _to, wine.status);
  }

  function getWine(uint _id) public view returns (Wine memory) {
    return wines[_id];
  }

  function getWineTransactionHistory(uint _wineId) public view returns (Transaction[] memory) {
      uint transactionCountForWine = 0;
      
      // First, count how many transactions are related to this wine
      for (uint i = 1; i <= transactionCount; i++) {
          if (transactions[i].wineId == _wineId) {
              transactionCountForWine++;
          }
      }

      // Create an array to hold the transactions
      Transaction[] memory transactionHistory = new Transaction[](transactionCountForWine);
      uint index = 0;

      // Populate the transaction history
      for (uint i = 1; i <= transactionCount; i++) {
          if (transactions[i].wineId == _wineId) {
              transactionHistory[index] = transactions[i];
              index++;
          }
      }

      return transactionHistory;
    }
}