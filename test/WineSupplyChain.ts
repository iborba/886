// import {
//   time,
//   loadFixture,
// } from "@nomicfoundation/hardhat-toolbox/network-helpers";
// import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import hre from "hardhat";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract } from "ethers";

describe("WineSupplyChain", function () {
  describe("Wine Management", function () {
    let wineSupplyChain: any;
    let owner: any;
    let otherAccount: any;

    before(async function () {
      const WineSupplyChain = await ethers.getContractFactory("WineSupplyChain");
      wineSupplyChain = await WineSupplyChain.deploy();

      await wineSupplyChain.waitForDeployment(); 
      [owner, otherAccount] = await hre.ethers.getSigners();
    });

    it("should create and return a new wine", async function () {
      const tx = await wineSupplyChain.connect(otherAccount).createWine("WineName", "Vineyard", "Region", "Grape");

      await tx.wait();

      const wine = await wineSupplyChain.getWine(1);

      expect(wine.name).to.equal("WineName");
      expect(wine.vineyard).to.equal("Vineyard");
      expect(wine.region).to.equal("Region");
      expect(wine.grape).to.equal("Grape");
      expect(wine.owner).to.equal(otherAccount.address);
      expect(wine.status).to.equal("created");
    });
  });
});