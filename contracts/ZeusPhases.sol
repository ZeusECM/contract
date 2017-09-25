pragma solidity ^0.4.13;


import './ERC20.sol';


contract ZeusPhases is ERC20 {

    uint256 public soldTokens;

    Phase[] public phases;

    struct Phase {
        uint256 price;
        uint256 maxAmount;
        uint256 minCap;
        uint256 since;
        uint256 till;
        bool isSucceed;
    }

    function ZeusPhases(
        uint256 initialSupply,
        uint8 precision,
        string tokenName,
        string tokenSymbol,
        bool transferAllSupplyToOwner,
        bool _locked
    ) ERC20(initialSupply, tokenName, precision, tokenSymbol, transferAllSupplyToOwner, _locked) {
        standard = 'PhaseICO 0.1';
    }

    function getIcoTokensAmount(uint256 value, uint256 time) returns (uint256) {
        if (value == 0) {
            return 0;
        }

        uint256 amount = 0;
        uint256 soldAmount = 0;

        for (uint i = 0; i < phases.length; i++) {
            Phase storage phase = phases[i];
            if (phase.since > time) {
                continue;
            }

            if (phase.till < time) {
                continue;
            }

            uint256 phaseAmount = value * (uint256(10) ** decimals) / phase.price;

            soldAmount += phaseAmount;

            uint256 bonusAmount;

            if(i == 0) {
                bonusAmount = getPreICOBonusAmount(time, phaseAmount);
            }

            if(i == 1) {
                bonusAmount = getICOBonusAmount(time, phaseAmount);
            }

            amount += phaseAmount + bonusAmount;
        
            if (phase.maxAmount < amount + soldTokens) {
                return 0;
            }
        }

        //Minimum investment (Euro transfer) in issuer wallet (# of tokens) for preICO & for ICO
        if (soldAmount < 10 * uint256(10) ** decimals) {
            return 0;
        }

        return amount;
    }

    function getPreICOBonusAmount(uint256 time, uint256 amount) returns (uint256) {
        Phase storage icoPhase = phases[0];

        if (time < icoPhase.since) {
            return 0;
        }

        if (time > icoPhase.till) {
            return 0;
        }

        return amount * 50 / 100;
    }

    function getICOBonusAmount(uint256 time, uint256 amount) returns (uint256) {
        Phase storage icoPhase = phases[1];

        if (time < icoPhase.since) {
            return 0;
        }
        if (time - icoPhase.since < 691200) {// 8d since ico => reward 30%;
            return amount * 30 / 100;
        }
        else if (time - icoPhase.since < 1296000) {// 15d since ico => reward 20%
            return amount * 20 / 100;
        }
        else if (time - icoPhase.since < 1987200) {// 23d since ico => reward 15%
            return amount * 15 / 100;
        }
        else if (time - icoPhase.since < 2592000) {// 30d since ico => reward 10%
            return amount * 10 / 100;
        }

        return 0;
    }

}