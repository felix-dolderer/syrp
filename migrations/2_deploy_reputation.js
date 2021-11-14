var Reputation = artifacts.require("./Reputation.sol");

module.exports = async function(deployer, network, accounts) {
  deployer.deploy(Reputation);

  let rep = await Reputation.deployed();

  await rep.setCreditLine(accounts[1], 10, {from: accounts[1]});
  await rep.setCreditLine(accounts[2], 30);
  await rep.setCreditLine(accounts[3], 100);
};
