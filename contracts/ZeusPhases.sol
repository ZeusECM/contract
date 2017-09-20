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
            return false;
        }
        uint256 amount = 0;
        for (uint i = 0; i < phases.length; i++) {
            Phase storage phase = phases[i];
            if (phase.since > time) {
                continue;
            }
            if (phase.till < time) {
                continue;
            }

            amount += value * (uint256(10) ** decimals) / phase.price;

            if (phase.maxAmount > amount + soldTokens) {
                return 0;
            }
        }

        return amount;
    }

    function getBonusAmount(uint256 time, uint256 amount) returns (uint256) {

        Phase storage icoPhase = phases[1];

        if (time < icoPhase.since) {
            return 0;
        }
        if (time - icoSince < 691200) {// 8d since ico => reward 30%;
            return amount * 30 / 100;
        }
        else if (time - icoSince < 1296000) {// 15d since ico => reward 20%
            return amount * 20 / 100;
        }
        else if (time - icoSince < 1987200) {// 23d since ico => reward 15%
            return amount * 15 / 100;
        }
        else if (time - icoSince < 2592000) {// 30d since ico => reward 10%
            return amount * 10 / 100;
        }

        return 0;
    }

}