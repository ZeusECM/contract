var Zeus = artifacts.require('./Zeus.sol');
var Utils = require('./utils');

var BigNumber = require('bignumber.js');
var precision = new BigNumber('100');

contract('Zeus', function(accounts) {
    // it('deploy & check constructor data', function() {
    //     var instance,
    //         preICOSince = 1511179200,
    //         preICOTill = 1514203200,
    //         ICOSince = 1506859200,
    //         ICOTill = 1509451200;
    //
    //     return Zeus.new(
    //         'ZEUS TOKEN',
    //         'ZET',
    //         new BigNumber(58000000).mul(precision),//initialSupply
    //         2,
    //         new BigNumber(4201680000000000),//_tokenPrice
    //         preICOSince,//_preIcoSince
    //         preICOTill,//_preIcoTill
    //         new BigNumber(1000000).mul(precision),//preIcoMaxAmount
    //         ICOSince,//_icoSince
    //         ICOTill,//_icoTill
    //         new BigNumber(58000000 -  580000 * 17).mul(precision),//icoMaxAmount
    //         new BigNumber(1000000).mul(precision),//icoMinCap
    //         false
    //     )
    //         .then((_instance) => instance = _instance)
    //
    //         .then(() => instance.name.call())
    //         .then((result) => assert.equal(result.valueOf(), 'ZEUS TOKEN', 'name is not equal'))
    //
    //         .then(() => instance.symbol.call())
    //         .then((result) => assert.equal(result.valueOf(), 'ZET', 'symbol is not equal'))
    //
    //         .then(() => Utils.balanceShouldEqualTo(instance, instance.address, new BigNumber(58000000).mul(precision)))
    //         .then(() => Utils.balanceShouldEqualTo(instance, accounts[0], new BigNumber(0).valueOf()))
    //
    //         .then(() => instance.decimals.call())
    //         .then((result) => assert.equal(result.valueOf(), 2, 'precision is not equal'))
    //
    //         .then(() => instance.tokenPrice.call())
    //         .then((result) => assert.equal(result.valueOf(), new BigNumber(4201680000000000), 'token price is not equal'))
    //
    //         .then(() => Utils.getPhase(instance, 0))
    //         .then((phase) => Utils.checkPhase(
    //             phase,
    //             new BigNumber(4201680000000000),
    //             new BigNumber(1000000).mul(precision),
    //             0,
    //             preICOSince,
    //             preICOTill,
    //             false
    //         ))
    //
    //         .then(() => Utils.getPhase(instance, 1))
    //         .then((phase) => Utils.checkPhase(
    //             phase,
    //             new BigNumber(4201680000000000),
    //             new BigNumber(58000000 -  580000 * 17).mul(precision),
    //             new BigNumber(1000000).mul(precision),
    //             ICOSince,
    //             ICOTill,
    //             false
    //         ))
    //
    //         .then(() => instance.locked.call())
    //         .then((result) => assert.equal(result.valueOf(), false, 'locked is not equal'));
    //
    // });

    it('create contract, buy tokens, get balance', function () {
        var instance,
            preICOSince = parseInt(new Date().getTime() / 1000),
            preICOTill = parseInt(new Date().getTime() / 1000) + 3600,
            ICOSince = 1506859200,
            ICOTill = 1509451200;

        return Zeus.new(
            'ZEUS TOKEN',
            'ZET',
            new BigNumber(58000000).mul(precision),//initialSupply
            2,
            new BigNumber(4201680000000000),//_tokenPrice
            preICOSince,//_preIcoSince
            preICOTill,//_preIcoTill
            new BigNumber(1000000).mul(precision),//preIcoMaxAmount
            ICOSince,//_icoSince
            ICOTill,//_icoTill
            new BigNumber(58000000 -  580000 * 17).mul(precision),//icoMaxAmount
            new BigNumber(1000000).mul(precision),//icoMinCap
            false
        )
            .then((_instance) => instance = _instance)

            .then(() => Utils.balanceShouldEqualTo(instance, instance.address, new BigNumber(58000000).mul(precision)))
            .then(() => Utils.balanceShouldEqualTo(instance, accounts[0], new BigNumber(0).valueOf()))
            .then(() => instance.sendTransaction({value: '1'}))
            // .then(() => Utils.receiptShouldSucceed)
            // .then(() => instance.collectedEthers.call())
            // .then(() => assert.equal(result.valueOf(), '1', 'collected amount is not equal'))

    });

});