pragma solidity ^0.4.13;

import './OraclizeAPI.sol';
import './ZeusPhases.sol';

contract ZeusPriceTicker is usingOraclize, ZeusPhases {

    uint256 public priceUpdateAt;

    event newOraclizeQuery(string description);
    event newZeusPriceTicker(string price);

    function ZeusPriceTicker(
        uint256 initialSupply,
        uint8 decimalUnits,
        string tokenName,
        string tokenSymbol,
        bool transferAllSupplyToOwner,
        bool _locked
    ) ZeusPhases(initialSupply, decimalUnits, tokenName, tokenSymbol, transferAllSupplyToOwner, _locked) {
        priceUpdateAt = now;
    }

    function __callback(bytes32 myid, string result, bytes proof) {
        require(msg.sender == oraclize_cbAddress());

        uint256 price = 10 ** 18 / parseInt(result, 5);

        setSellPrice(price);

        newZeusPriceTicker(result);
    }

    function update() internal {
        if (oraclizeLib.oraclize_getPrice("URL") > this.balance) {
            newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query("URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHEUR).result.XETHZEUR.c.0");
        }
    }

}

