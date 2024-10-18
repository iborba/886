import hre from "hardhat";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("WineSupplyChain", function () {
  describe("Wine Management", function () {
    let wineSupplyChain: any;
    let owner: any;
    let otherAccount: any;
    let transporterAccount: any;

    before(async function () {
      const WineSupplyChain = await ethers.getContractFactory("WineSupplyChain");
      wineSupplyChain = await WineSupplyChain.deploy();

      await wineSupplyChain.waitForDeployment(); 
      [owner, otherAccount, transporterAccount] = await hre.ethers.getSigners();
    });

    it("should create and return a new wine", async function () {
      const tx = await wineSupplyChain.connect(owner).createWine("WineName", "Vineyard", "Region", "Grape");

      await tx.wait();

      const wine = await wineSupplyChain.getWine(1);

      expect(wine.name).to.equal("WineName");
      expect(wine.vineyard).to.equal("Vineyard");
      expect(wine.region).to.equal("Region");
      expect(wine.grape).to.equal("Grape");
      expect(wine.owner).to.equal(owner.address);
      expect(wine.status).to.equal("available");
    });

    it.only("should sell a wine to another account", async function () {
      const tx = await wineSupplyChain.connect(owner).createWine("WineName", "Vineyard", "Region", "Grape");
      await tx.wait();

      const wine = await wineSupplyChain.getWine(1);

      expect(wine.owner).to.equal(owner.address);
      expect(wine.status).to.equal("available");

      await wineSupplyChain.connect(owner).sellWine(wine.id, otherAccount.address, transporterAccount.address);
      const soldWine = await wineSupplyChain.getWine(1);
      
      expect(soldWine.owner).to.equal(otherAccount.address);
      expect(soldWine.status).to.equal("sold");
    });
  });
});