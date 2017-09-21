var Zeus = artifacts.require("./Zeus.sol");
var Utils = require("./utils");

var BigNumber = require('bignumber.js');
var precision = new BigNumber('100');

contract('Zeus', function(accounts) {
    it("deploy & check constructor data", function() {
        var instance;
            // preIcoSince = parseInt(new Date().getTime() / 1000),
            // preIcoTill = parseInt(new Date().getTime() / 1000) + 3600;

        return Zeus.new(
            'ZEUS TOKEN',
            'ZET',
            new BigNumber(58000000).mul(precision),//initialSupply
            2,
            new BigNumber(4201680000000000),//_tokenPrice
            1511179200,//_preIcoSince
            1514203200,//_preIcoTill
            new BigNumber(1000000).mul(precision),//preIcoMaxAmount
            1506859200,//_icoSince
            1509451200,//_icoTill
            new BigNumber(58000000).mul(precision),//icoMaxAmount
            new BigNumber(1000000).mul(precision),//icoMinCap
            false
        )
            .then((_instance) => instance = _instance)

            .then(() => instance.name.call())
            .then((result) => assert.equal(result.valueOf(), 'ZEUS TOKEN', 'name is not equal'))

            .then(() => instance.symbol.call())
            .then((result) => assert.equal(result.valueOf(), 'ZET', 'symbol is not equal'))

            .then(() => Utils.balanceShouldEqualTo(instance, instance.address, new BigNumber(58000000).mul(precision)))
            .then(() => Utils.balanceShouldEqualTo(instance, accounts[0], new BigNumber(0).valueOf()))

            .then(() => instance.decimals.call())
            .then((result) => assert.equal(result.valueOf(), 2, 'precision is not equal'))

            .then(() => instance.tokenPrice.call())
            .then((result) => assert.equal(result.valueOf(), new BigNumber(4201680000000000), 'token price is not equal'))

            // .then(() => Utils.getPhase(instance, 0))
            // .then((phase) => Utils.checkPhase(
            //     phase,
            //     new BigNumber(4201680000000000),
            //     new BigNumber(1000000).mul(precision),
            //     0,
            // ))

    });

});