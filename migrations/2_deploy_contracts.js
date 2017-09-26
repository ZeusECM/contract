var Zeus = artifacts.require('./Zeus.sol');
var oraclizeLib = artifacts.require('./OraclizeLib.sol');

module.exports = function(deployer) {
    deployer.deploy(oraclizeLib);
    deployer.link(oraclizeLib, Zeus);
    deployer.deploy(Zeus);
};
