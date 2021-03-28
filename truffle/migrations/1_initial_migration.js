const Migrations = artifacts.require("Migrations");
const Crowdfunding = artifacts.require("Crowdfunding");
module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Crowdfunding);
};
