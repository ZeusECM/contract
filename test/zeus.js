var Zeus = artifacts.require("./Zeus.sol");
var Utils = require("./utils");

var BigNumber = require('bignumber.js');

contract('Zeus', function(accounts) {
    it("deploy & check constructor data", function() {
        var instance;

        return Zeus.new(
            'ZEUS TOKEN',
            'ZET',
            new BigNumber(58000000 * 100),//initialSupply
            2,
            new BigNumber(4201680000000000),//_tokenPrice
            1511179200,//_preIcoSince
            1514203200,//_preIcoTill
            new BigNumber(1000000 * 100),//preIcoMaxAmount
            0,//preIcoMinCap
            1506859200,//_icoSince
            1509451200,//_icoTill
            new BigNumber(58000000 * 100),//icoMaxAmount
            new BigNumber(1000000 * 100),//icoMinCap
            false
        )
            .then((_instance) => instance = _instance)
            .then(() => Utils.balanceShouldEqualTo(instance, instance.address, new BigNumber(58000000 * 100)));
    });

});