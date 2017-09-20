pragma solidity ^0.4.13;


import './ZeusPhases.sol';


contract Zeus is ZeusPhases {

    uint256 public etherWeis = 1000000000000000000;

    uint256 public tokenPrice; //0.00420168 ether; 19/09/17 11:20 am

    uint256 public collectedEthers;

    address distributionAddress1;

    address distributionAddress2;

    address distributionAddress3;

    address distributionAddress4;

    address distributionAddress5;

    address successFeeAcc;

    address bountyAcc;

    mapping (address => uint256) public icoEtherBalances;

    event Refund(address holder, uint256 ethers, uint256 tokens);

    function Zeus(
        string tokenName,
        string tokenSymbol,
        uint256 initialSupply,
        uint8 decimalUnits,
        uint256 _tokenPrice,
        uint256 _preIcoSince,
        uint256 _preIcoTill,
        uint256 preIcoMaxAmount,
        uint256 preIcoMinCap,
        uint256 _icoSince,
        uint256 _icoTill,
        uint256 icoMaxAmount,
        uint256 icoMinCap,
        bool _locked
    ) ZeusPhases(initialSupply, decimalUnits, tokenName, tokenSymbol, false, _locked) {
        standard = 'Zeus 0.1';
        tokenPrice = _tokenPrice;

        phases.push(Phase(tokenPrice * etherWeis, preIcoMaxAmount * decimalUnits, preIcoMinCap, _preIcoSince, _preIcoTill, false));
        phases.push(Phase(tokenPrice * etherWeis, icoMaxAmount * decimalUnits, preIcoMinCap, _icoSince, _icoTill, false));

        distributionAddress1 = '0xB3927748906763F5906C83Ed105be1C1A6d03FFE';
        distributionAddress2 = '0x8e749918fC86e3F40d1C1a1457a0f98905cD456A';
        distributionAddress3 = '0x648340938fBF7b2F2A676FCCB806cd597279cA3a';
        distributionAddress4 = '0xd4564281fAE29Ca5c7345Fe9a4602E6b35857dA3';
        distributionAddress5 = '0x6Ed01383BfdCe351A616321B1A8D08De003D493A';
        successFeeAcc = '0xdA39e0Ce2adf93129D04F53176c7Bfaaae8B051a';
        bountyAcc = '0x0064952457905eBFB9c0292200A74B1d7414F081';
    }

    function setSellPrice(uint256 value) onlyOwner {
        if (value == 0) {
            return false;
        }
        for (uint i = 0; i < phases.length; i++) {
            Phase storage phase = phases[i];
            phase.price = value * etherWeis;
        }
    }

    function buy(address _address, uint256 time, uint256 value) internal returns (bool) {
        if (locked == true) {
            return false;
        }

        uint256 amount = getIcoTokensAmount(value, time);

        //Minimum investment (Euro transfer) in issuer wallet (# of tokens)
        if (amount < 10) {
            return false;
        }

        amount += getBonusAmount(time, amount);

        bool status = transferInternal(this, _address, amount);

        if (status) {
            onSuccessfulBuy(_address, value, amount, time);
        }

        return status;
    }

    function onSuccessfulBuy(address _address, uint256 value, uint256 amount, uint256 time) internal {
        collectedEthers += value;
        soldTokens += amount;

        Phase storage phase = phases[1];
        if (phase.since > time) {
            return;
        }
        if (phase.till < time) {
            return;
        }
        icoEtherBalances[_address] = value;
    }

    function() payable {
        bool status = buy(msg.sender, now, msg.value);

        require(status == true);
    }

    function isSucceed(uint8 phaseId) returns (bool) {
        if (phases.length < phaseId) {
            return false;
        }

        Phase storage phase = phases[phaseId];

        if (phase.isSucceed == true) {
            return true;
        }

        if (phase.till > now) {
            return false;
        }

        if (phase.minCap != 0 && phase.minCap > soldTokens) {
            return false;
        }

        phase.isSucceed = true;

        if (phaseId == 0) {
            sendPreIcoBonuses();
            sendBonusesToFeeAcc();
        }
        if (phaseId == 1) {
            sendIcoBonuses();
            sendBonusesToFeeAcc();
        }

        return true;
    }

    function sendPreIcoBonuses() internal {
        if (collectedEthers > 0) {
            uint256 bonusesAmount = collectedEthers / 2;

            distributionAddress1.transfer(bonusesAmount * 100 / 87);
            distributionAddress2.transfer(bonusesAmount * 100 / 5);
            distributionAddress3.transfer(bonusesAmount * 100 / 5);
            successFeeAcc.transfer(bonusesAmount * 100 / 3);
        }
    }

    function sendIcoBonuses() internal {
        if (soldTokens > 0) {
            transferInternal(this, bountyAcc, soldTokens * 100 / 2);
        }
        if (collectedEthers > 0) {
            distributionAddress5.transfer(collectedEthers * 100 / 42);
            distributionAddress4.transfer(collectedEthers * 100 / 30);
            distributionAddress1.transfer(collectedEthers * 100 / 15);
            distributionAddress3.transfer(collectedEthers * 100 / 5);
            distributionAddress2.transfer(collectedEthers * 100 / 5);
            successFeeAcc.transfer(collectedEthers * 100 / 3);
        }
    }

    function sendBonusesToFeeAcc() internal {
        if (soldTokens > 0) {
            transferInternal(this, successFeeAcc, soldTokens * 100 / 3);
        }
    }

    function refund() returns (bool) {
        Phase storage icoPhase = phases[1];
        if (icoPhase.till > now) {
            return false;
        }
        if (icoPhase.till < now && icoPhase.minCap <= soldTokens) {
            return false;
        }
        if (!icoEtherBalances[msg.sender].isValue) {
            return false;
        }

        msg.sender.transfer(icoEtherBalances[msg.sender]);

        setBalance(msg.sender, 0);
    }

    function burn() onlyOwner returns (bool){
        Phase storage icoPhase = phases[1];
        if (isSucceed(1) == false) {
            return false;
        }
        if (icoPhase.till + 432000 < now) {
            return false;
        }
        if (soldTokens < initialSupply) {
            uint256 diff = initialSupply - soldTokens;
            transferInternal(this, distributionAddress1, diff * 100 / 15);
            transferInternal(this, bountyAcc, diff * 100 / 2);
            setBalance(this, 0);

            return true;
        }

        return false;
    }

}