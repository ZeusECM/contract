pragma solidity ^0.4.13;

import './OraclizeLib.sol';
import './ZeusPhases.sol';

contract ZeusPriceTicker is ZeusPhases {

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
        oraclizeLib.oraclize_setProof(oraclizeLib.proofType_TLSNotary() | oraclizeLib.proofStorage_IPFS());
        update();
    }

    function __callback(bytes32 myid, string result, bytes proof) {
        require(msg.sender == oraclizeLib.oraclize_cbAddress());

        uint256 price = 10 ** 18 / oraclizeLib.parseInt(result, 5);

        setSellPrice(price);

        newZeusPriceTicker(result);
        update();
    }

    function update() payable {
        if (oraclizeLib.oraclize_getPrice("URL") > this.balance) {
            newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclizeLib.oraclize_query(1, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHEUR).result.XETHZEUR.c.0");
//            oraclizeLib.oraclize_query(3600, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHEUR).result.XETHZEUR.c.0");
        }
    }

}

