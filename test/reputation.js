const Reputation = artifacts.require("./Reputation.sol");
const truffleAssert = require('truffle-assertions');

var repInstance;

beforeEach(function() {
    return Reputation.new()
    .then(function(instance) {
      repInstance = instance;
    });
});

contract("Reputation", accounts => {
  it("...should create a CreditLine between two accounts.", async () => {

    await repInstance.setCreditLine(accounts[1], 10, { from: accounts[0] });
    const storedData = await repInstance.getAllCreditLines.call();

    assert.equal(storedData[0].owner, accounts[0], "the wrong owner was set");
    assert.equal(storedData[0].spender, accounts[1], "the wrong recipient was set");
    assert.equal(storedData[0].maxCredit, 10, "the wrong credit was set");
    assert.equal(storedData[0].usedCredit, 0, "the wrong credit was set");
  });

  it("...should override an existing CreditLine between two accounts.", async () => {
    await repInstance.setCreditLine(accounts[1], 10, { from: accounts[0] });
    await repInstance.setCreditLine(accounts[1], 10000, { from: accounts[0] }); 
    const storedData = await repInstance.getAllCreditLines.call();

    assert.equal(storedData[0].owner, accounts[0], "the wrong owner was set");
    assert.equal(storedData[0].spender, accounts[1], "the wrong recipient was set");
    assert.equal(storedData[0].maxCredit, 10000, "the wrong credit was set");
  });

  it("...should transfer credit through a creditLine and update the blocked credit", async () => {
    await repInstance.setCreditLine(accounts[1], 10, { from: accounts[0] });
    /** 
     * ideally this array should be provided by our pathFinder algorithm
     * in the future with a traversal through multiple CreditLines
     */
    await repInstance.transferCredits([{owner: accounts[0], spender: accounts[1], proposedDeduction: 9}], {from: accounts[1]});

    const storedData = await repInstance.getAllCreditLines.call();

    assert.equal(storedData[0].usedCredit, 9, "the wrong credit was set");
  });

  it("...should not transfer more credit than the creditLine allows.", async () => {
    await repInstance.setCreditLine(accounts[1], 10, { from: accounts[0] });

    await truffleAssert.reverts(repInstance.transferCredits([{owner: accounts[0], spender: accounts[1], proposedDeduction: 99}], {from: accounts[1]}));

    const storedData = await repInstance.getAllCreditLines.call();
    assert.equal(storedData[0].usedCredit, 0, "the wrong credit was set");
  });

  it("...should update the usedCredit when a repayment is conducted.", async () => {

    await repInstance.transfer(accounts[1], 420, {from: accounts[0]});
    await repInstance.setCreditLine(accounts[1], 10, { from: accounts[0] });
    await repInstance.transferCredits([{owner: accounts[0], spender: accounts[1], proposedDeduction: 9}], {from: accounts[1]});

    await repInstance.repayCredit(accounts[0], 9, {from: accounts[1]});

    const storedData = await repInstance.getAllCreditLines.call();
    assert.equal(storedData[0].usedCredit, 0, "the wrong credit was set");

  });

  it("...should update the trustScore when a repayment is conducted successfully.", async () => {

    await repInstance.transfer(accounts[1], 420, {from: accounts[0]});
    await repInstance.setCreditLine(accounts[1], 10, { from: accounts[0] });
    await repInstance.transferCredits([{owner: accounts[0], spender: accounts[1], proposedDeduction: 9}], {from: accounts[1]});

    await repInstance.repayCredit(accounts[0], 9, {from: accounts[1]});

    const storedData = await repInstance.getTrustScore.call(accounts[0], {from: accounts[1]});
    assert.equal(storedData, 1, "the score was not increased correctly");

  });
});
