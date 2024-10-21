// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {LibSupplyChain} from "../libraries/LibSupplyChain.sol";

contract LogisticsFacet {

    event ShipmentCreated(uint256 indexed shippingId, string fromLocation, string toLocation);
    event ShipmentUpdated(uint256 indexed shippingId, LibSupplyChain.ShippingStatus newStatus);

    function createShipment(string calldata productSerialNumber, string calldata fromLocation, string calldata toLocation, uint256 _shippingFee, address _recipientrecipient) external {

        LibSupplyChain.SupplyChainStorage storage sc = LibSupplyChain.getSupplyChainStorage();

        require(msg.sender != address(0), "Invalid Address.");
        require(sc.serialNumberToProductId[productSerialNumber] != 0, "Product does not exist");
        require(bytes(fromLocation).length > 0, "Invalid 'from' location");
        require(bytes(toLocation).length > 0, "Invalid 'to' location");
        require(keccak256(abi.encodePacked(fromLocation)) != keccak256(abi.encodePacked(toLocation)), 
            "Invalid from and to.");
        require(_shippingFee > 0, "Invalid Shipping Fee.");

        uint256 shippingId = sc.shippingCount + 1;

        sc.shipments[shippingId] = LibSupplyChain.Shipment({
            shippingId: shippingId,
            productSerialNumber: productSerialNumber,
            fromLocation: fromLocation,
            toLocation: toLocation,
            status: LibSupplyChain.ShippingStatus.InTransit,
            shippedAt: block.timestamp,
            deliveredAt: 0,
            shippingFee: _shippingFee,
            recipient: address(0)
        });

        emit ShipmentCreated(shippingId, fromLocation, toLocation);
    }

    function updateShipmentStatus(uint256 shippingId,  LibSupplyChain.ShippingStatus newStatus) external {
        LibSupplyChain.SupplyChainStorage storage sc = LibSupplyChain.getSupplyChainStorage();
        require(sc.shipments[shippingId].shippingId != 0, "Shipment does not exist");
        sc.shipments[shippingId].status = newStatus;
        if (newStatus == LibSupplyChain.ShippingStatus.Delivered) {
           sc.shipments[shippingId].deliveredAt = block.timestamp;
        }
        emit ShipmentUpdated(shippingId, newStatus);
    }

    function getShipmentDetails(uint256 shippingId) external view returns (LibSupplyChain.Shipment memory) {
        LibSupplyChain.SupplyChainStorage storage sc = LibSupplyChain.getSupplyChainStorage();
        require(sc.shipments[shippingId].shippingId != 0, "Shipment does not exist");
        return sc.shipments[shippingId];
    }

}