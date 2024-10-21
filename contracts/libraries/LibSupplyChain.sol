// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibSupplyChain {

    bytes32 constant SUPPLY_CHAIN_STORAGE_POSITION =
        keccak256("supply.chain.diamond.storage");

    enum ShippingStatus {
        InTransit,
        Delivered
    }

    struct Product {
        string name;
        uint256 productId;
        string serialNumber;
        uint256 createdTime;
        uint256 bestBefore;
        address manufacturer;
    }

    struct Shipment {
        uint256 shippingId;
        string productSerialNumber;
        string fromLocation;
        string toLocation;
        ShippingStatus status; // E.g., "In Transit", "Delivered"
        uint256 shippedAt;
        uint256 shippingFee;
        uint256 deliveredAt;
        address recipient;
    }

    struct SupplyChainStorage {
        
        uint256 productCount;
        uint256 shippingCount;

        mapping(uint256 => Product) productIdToProduct;
        mapping(address => uint256[]) manufacturerToProductIds;
        mapping(string => uint256) serialNumberToProductId;
        
        mapping(uint256 => Shipment) shipments;
        
    }


    function getSupplyChainStorage()
        internal
        pure
        returns (SupplyChainStorage storage sp)
    {
        bytes32 position = SUPPLY_CHAIN_STORAGE_POSITION;
        assembly {
            sp.slot := position
        }
    }
}
