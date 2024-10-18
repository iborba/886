import hre from "hardhat";
import { expect } from "chai";
import { ethers } from "hardhat";

interface Transaction {
  id: number;
  wineId: number;
  owner: string;
  receiver: string;
  transporter: string;
  status: string;
}


describe("WineSupplyChain", function () {
  describe("Wine Management", function () {
    let wineSupplyChain: any;
    let owner: any;
    let otherAccount: any;
    let transporterAccount: any;
    const targetWineId = 1;

    before(async function () {
      const WineSupplyChain = await ethers.getContractFactory("WineSupplyChain");
      wineSupplyChain = await WineSupplyChain.deploy();

      await wineSupplyChain.waitForDeployment(); 
      [owner, otherAccount, transporterAccount] = await hre.ethers.getSigners();
    });

    // this.afterEach(async function () {
    //   const wines = await wineSupplyChain.getWine(1);
    //   for (let i = 0; i < wines.length; i++) {
    //     await wineSupplyChain.connect(owner).deleteWine(1);
    //   }
    // });

    it("should create and return a new wine", async function () {
      const tx = await wineSupplyChain.connect(owner).createWine("WineName", "Vineyard", "Region", "Grape");

      await tx.wait();

      const wine = await wineSupplyChain.getWine(targetWineId);

      expect(wine.name).to.equal("WineName");
      expect(wine.vineyard).to.equal("Vineyard");
      expect(wine.region).to.equal("Region");
      expect(wine.grape).to.equal("Grape");
      expect(wine.owner).to.equal(owner.address);
      expect(wine.status).to.equal("available");
    });

    it("should sell a wine to another account preserving the owner", async function () {
      const tx = await wineSupplyChain.connect(owner).createWine("WineName", "Vineyard", "Region", "Grape");
      await tx.wait();

      await wineSupplyChain.connect(owner).sellWine(targetWineId, otherAccount.address);
      const soldWine = await wineSupplyChain.getWine(targetWineId);
      
      expect(soldWine.owner).to.equal(owner.address);
      expect(soldWine.status).to.equal("sold");
    });

    it("should transport a wine to the consumer", async function () {
      const tx = await wineSupplyChain.connect(owner).createWine("WineName", "Vineyard", "Region", "Grape");
      await tx.wait();

      await wineSupplyChain.connect(owner).sellWine(targetWineId, otherAccount.address);
      await wineSupplyChain.connect(owner).shipWine(targetWineId, otherAccount.address, transporterAccount.address);
      const transportedWine = await wineSupplyChain.getWine(targetWineId);

      expect(transportedWine.owner).to.equal(transporterAccount.address);
      expect(transportedWine.status).to.equal("in transit");
    });

    it("should deliver a wine to the consumer", async function () {
      const tx = await wineSupplyChain.connect(owner).createWine("WineName", "Vineyard", "Region", "Grape");
      await tx.wait();

      await wineSupplyChain.connect(owner).sellWine(targetWineId, otherAccount.address);
      await wineSupplyChain.connect(owner).shipWine(targetWineId, otherAccount.address, transporterAccount.address);
      await wineSupplyChain.connect(transporterAccount).deliverWine(targetWineId, otherAccount.address);
      const deliveredWine = await wineSupplyChain.getWine(targetWineId);

      expect(deliveredWine.owner).to.equal(otherAccount.address);
      expect(deliveredWine.status).to.equal("delivered");
    });

    it.only('should trace wine history', async function () {
      const tx = await wineSupplyChain.connect(owner).createWine("WineName", "Vineyard", "Region", "Grape");
      await tx.wait();

      await wineSupplyChain.connect(owner).sellWine(targetWineId, otherAccount.address);
      await wineSupplyChain.connect(owner).shipWine(targetWineId, otherAccount.address, transporterAccount.address);
      await wineSupplyChain.connect(transporterAccount).deliverWine(targetWineId, otherAccount.address);

      const wineHistory: Transaction[] = await wineSupplyChain.getWineTransactionHistory(targetWineId);

      expect(wineHistory[0].owner).to.equal(owner.address);
      expect(wineHistory[0].status).to.equal("available");

      expect(wineHistory[1].owner).to.equal(owner.address);
      expect(wineHistory[1].status).to.equal("sold");

      expect(wineHistory[2].owner).to.equal(transporterAccount.address);
      expect(wineHistory[2].status).to.equal("in transit");

      expect(wineHistory[3].owner).to.equal(otherAccount.address);
      expect(wineHistory[3].status).to.equal("delivered");
    });
  });
});