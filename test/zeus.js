var Zeus = artifacts.require('./Zeus.sol');
var Utils = require('./utils');

var BigNumber = require('bignumber.js');
var precision = new BigNumber('100');

contract('Zeus', function(accounts) {
    it('deploy & check constructor data', function() {
        var instance,
            preICOSince = 1511179200,
            preICOTill = 1514203200,
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
            432000,
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

            .then(() => Utils.getPhase(instance, 0))
            .then((phase) => Utils.checkPhase(
                phase,
                new BigNumber(4201680000000000),
                new BigNumber(1000000).mul(precision),
                0,
                preICOSince,
                preICOTill,
                false
            ))

            .then(() => Utils.getPhase(instance, 1))
            .then((phase) => Utils.checkPhase(
                phase,
                new BigNumber(4201680000000000),
                new BigNumber(58000000 -  580000 * 17).mul(precision),
                new BigNumber(1000000).mul(precision),
                ICOSince,
                ICOTill,
                false
            ))

            .then(() => instance.locked.call())
            .then((result) => assert.equal(result.valueOf(), false, 'locked is not equal'))

            .then(() => instance.burnTimeChange.call())
            .then((result) => assert.equal(result.valueOf(), '432000', 'burnTimeChange is not equal'));

    });

    it('create contract, buy tokens, get balance PreICO', function () {
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
            432000,
            false
        )
            .then((_instance) => instance = _instance)

            .then(() => Utils.balanceShouldEqualTo(instance, instance.address, new BigNumber(58000000).mul(precision)))
            .then(() => Utils.balanceShouldEqualTo(instance, accounts[0], new BigNumber(0).valueOf()))
            .then(() => instance.sendTransaction({value: "1000000000000000000"}))
            .then(() => Utils.receiptShouldSucceed)
            .then(() => instance.collectedEthers.call())
            .then((result) => assert.equal(result.valueOf(), '1000000000000000000', 'collected amount is not equal'))
            .then(() => instance.soldTokens.call())
            //1000000000000000000 * 100 / 4201680000000000 = 23800.003808 | + 23800.003808 * 50 / 100 = 35700
            .then((result) => assert.equal(result.valueOf(), '35700', 'collected amount is not equal'))
            .then(() => Utils.balanceShouldEqualTo(instance, accounts[0], new BigNumber(35700)))
            .then(() => Utils.balanceShouldEqualTo(instance, instance.address, new BigNumber(58000000).mul(precision) - new BigNumber(35700)))

    });


    it("should  not be able to buy tokens before preICO", function () {
        var instance,
            preICOSince = parseInt(new Date().getTime() / 1000 + 3600 * 8),
            preICOTill = parseInt(new Date().getTime() / 1000 + 3600 * 10),
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
            432000,
            false
        )
            .then((_instance) => instance = _instance)

            .then(() => Utils.balanceShouldEqualTo(instance, instance.address, new BigNumber(58000000).mul(precision).valueOf()))
            .then(() => instance.sendTransaction({value: 1000000000000000000}))
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed)
            // .catch(() => instance.collectedEthers.call())
            // .then((result) => assert.equal(result.valueOf(), "0", "collected amount is not equal"))
            .then(() => Utils.balanceShouldEqualTo(instance, instance.address, new BigNumber(58000000).mul(precision).valueOf()))
    });

    it("should  not be able to buy tokens after preICO", function () {
        var instance,
            preICOSince = parseInt(new Date().getTime() / 1000 - 3600 * 8),
            preICOTill = parseInt(new Date().getTime() / 1000 - 3600 * 10),
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
            432000,
            false
        )
            .then((_instance) => instance = _instance)

            .then(() => Utils.balanceShouldEqualTo(instance, instance.address, new BigNumber(58000000).mul(precision).valueOf()))
            .then(() => instance.sendTransaction({value: 1000000000000000000}))
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed)
            // .catch(() => instance.collectedEthers.call())
            // .then((result) => assert.equal(result.valueOf(), "0", "collected amount is not equal"))
            .then(() => Utils.balanceShouldEqualTo(instance, instance.address, new BigNumber(58000000).mul(precision).valueOf()))
    });

    it("should be able to buy tokens, change token price", function () {
        var instance;
        var preIcoSince = new Date().getTime() / 1000 - 3600 * 8;
        var preIcoTill = new Date().getTime() / 1000 + 3600 * 10;

        return Contract.new(
            new BigNumber("0.0002332415916").mul(precision),
            preIcoSince,
            preIcoTill,
            new BigNumber("55250000"),
            "Uncharged TAU",
            "UTAU",
            false
        ).then(function (_instance) {
            instance = _instance;
        })
            .then(() => Utils.balanceShouldEqualTo(instance, instance.address, new BigNumber("55250000").valueOf()))
            .then(function () {
                return instance.sendTransaction({value: 1});
            })
            .then(Utils.receiptShouldSucceed)
            .then(function () {
                return instance.collectedEthers.call();
            })
            .then(function (result) {
                assert.equal(result.valueOf(), "1", "collected amount is not equal");
            })
            .then(() => Utils.balanceShouldEqualTo(instance, accounts[0], "4287"))
            .then(() => Utils.balanceShouldEqualTo(instance, instance.address, "55245713"))
            .then(function () {
                return instance.setTokenPrice(new BigNumber("0.0004").mul(precision));
            })
            .then(Utils.receiptShouldSucceed)
            .then(function () {
                return instance.sendTransaction({value: 1});
            })
            .then(Utils.receiptShouldSucceed)
            .then(() => Utils.balanceShouldEqualTo(instance, accounts[0], "6787"))
            .then(() => Utils.balanceShouldEqualTo(instance, instance.address, "55243213"))
    });

});