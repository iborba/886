// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WineSupplyChain {
  struct Wine {
    uint id;
    string name;
    string vineyard;
    string region;
    string grape;
    address owner;
    address producer;
    string status; // "created", "produced", "bottled", "sold", "shipped", "received"
  }

  mapping(uint => Wine) public wines;
  uint public wineCount;

  event WineCreated(uint id, string name, string vineyard, string region, string grape, address owner, address producer, string status);

  function createWine(string memory _name, string memory _vineyard, string memory _region, string memory _grape) public {
    wineCount++;
    wines[wineCount] = Wine(wineCount, _name, _vineyard, _region, _grape, msg.sender, address(0), "created");
    emit WineCreated(wineCount, _name, _vineyard, _region, _grape, msg.sender, address(0), "created");
  }

  function getWine(uint _id) public view returns (uint, string memory, string memory, string memory, string memory, address, address, string memory) {
    Wine memory wine = wines[_id];
    return (wine.id, wine.name, wine.vineyard, wine.region, wine.grape, wine.owner, wine.producer, wine.status);
  }
}