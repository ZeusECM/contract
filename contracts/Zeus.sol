pragma solidity ^0.4.13;


import './ZeusPriceTicker.sol';


contract Zeus is ZeusPriceTicker {

    uint256 public tokenPrice; //0.00420168 ether; 19/09/17 11:20 am

    uint256 public collectedEthers;

    uint256 public burnTimeChange;

    address distributionAddress1;

    address distributionAddress2;

    address distributionAddress3;

    address distributionAddress4;

    address distributionAddress5;

    address successFeeAcc;

    address bountyAcc;

    bool isBurned;

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
        uint256 _icoSince,
        uint256 _icoTill,
        uint256 icoMaxAmount,
        uint256 icoMinCap,
        uint256 _burnTimeChange,
        bool _locked
    ) ZeusPriceTicker(initialSupply, decimalUnits, tokenName, tokenSymbol, false, _locked) {
        standard = 'Zeus 0.1';
        tokenPrice = _tokenPrice;
        burnTimeChange = _burnTimeChange;

        phases.push(Phase(tokenPrice, preIcoMaxAmount, 0, _preIcoSince, _preIcoTill, false));
        phases.push(Phase(tokenPrice, icoMaxAmount, icoMinCap, _icoSince, _icoTill, false));

        distributionAddress1 = 0xB3927748906763F5906C83Ed105be1C1A6d03FFE;
        distributionAddress2 = 0x8e749918fC86e3F40d1C1a1457a0f98905cD456A;
        distributionAddress3 = 0x648340938fBF7b2F2A676FCCB806cd597279cA3a;
        distributionAddress4 = 0xd4564281fAE29Ca5c7345Fe9a4602E6b35857dA3;
        distributionAddress5 = 0x6Ed01383BfdCe351A616321B1A8D08De003D493A;
        successFeeAcc = 0xdA39e0Ce2adf93129D04F53176c7Bfaaae8B051a;
        bountyAcc = 0x0064952457905eBFB9c0292200A74B1d7414F081;
    }

    function setSellPrice(uint256 value) onlyOwner {
        require(value > 0);
        for (uint i = 0; i < phases.length; i++) {
            Phase storage phase = phases[i];
            phase.price = value;
        }
    }

    function buy(address _address, uint256 time, uint256 value) internal returns (bool) {
        if (locked == true) {
            return false;
        }

//        if (priceUpdateAt + 3600 > now){
            update();
//            priceUpdateAt = now;
//        }

        uint256 amount = getIcoTokensAmount(value, time);

        if (amount == 0) {
            return false;
        }

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
        icoEtherBalances[_address] += value;
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
            sendPreICOEthers();
        }
        if (phaseId == 1) {
            sendICOEthers();
        }

        return true;
    }

    function sendPreICOEthers() internal {
        if (collectedEthers > 0) {
            distributionAddress1.transfer(collectedEthers * 87 / 100);
            distributionAddress2.transfer(collectedEthers * 5 / 100);
            distributionAddress3.transfer(collectedEthers * 5 / 100);
            successFeeAcc.transfer(this.balance);
        }
    }

    function sendICOEthers() internal {
        uint256 ethers = this.balance;
        if (ethers > 0) {
            distributionAddress5.transfer(ethers * 42 / 100);
            distributionAddress4.transfer(ethers * 30 / 100);
            distributionAddress1.transfer(ethers * 15 / 100);
            distributionAddress3.transfer(ethers * 5 / 100);
            distributionAddress2.transfer(ethers * 5 / 100);
            successFeeAcc.transfer(this.balance);
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
        if (icoEtherBalances[msg.sender] == 0) {
            return false;
        }
        setBalance(msg.sender, 0);
        uint256 refundAmount = icoEtherBalances[msg.sender];
        icoEtherBalances[msg.sender] = 0;
        msg.sender.transfer(refundAmount);
    }

    function burn() onlyOwner returns (bool){

        Phase storage icoPhase = phases[1];

        if (isSucceed(1) == false) {
            return false;
        }

        if (icoPhase.till + burnTimeChange > now) {
            return false;
        }

        if (isBurned) {
            return false;
        }

        isBurned = true;

        transferInternal(this, distributionAddress1, soldTokens * 15 / 100);
        transferInternal(this, bountyAcc, soldTokens * 2 / 100);

        setBalance(this, 0);

        return true;
    }

    function issue(address _addr, uint256 _amount) onlyOwner returns (bool){
        return transferInternal(this, _addr, _amount);
    }

    function setLocked(bool _locked) onlyOwner {
        locked = _locked;
    }

}