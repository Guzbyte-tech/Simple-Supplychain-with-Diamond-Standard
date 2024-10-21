// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibSupplyChain} from "../libraries/LibSupplyChain.sol";

contract PaymentFacet {


 event PaymentSent(address indexed sender, address indexed receiver, uint256 amount);

    //send payments to any party in the supply chain, depending on who the receiver is:
    function sendPayment(uint256 shippingId) external payable {
        
        LibSupplyChain.SupplyChainStorage storage sc = LibSupplyChain.getSupplyChainStorage();

        require(sc.shipments[shippingId].shippingId != 0, "Invalid shipping Id");
        require(msg.value >= sc.shipments[shippingId].shippingFee, "Insufficient funds");

        require(msg.value > 0, "Payment value must be greater than zero");

        payable(sc.shipments[shippingId].recipient).transfer(msg.value);

        emit PaymentSent(msg.sender, sc.shipments[shippingId].recipient, msg.value);
    }

}