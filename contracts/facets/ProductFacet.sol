// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibSupplyChain} from "../libraries/LibSupplyChain.sol";

contract ProductFacet {
    event ProductAdded(
        string indexed serialNumber,
        address indexed manufacturer
    );
    event ProductStatusUpdated(string indexed serialNumber, string newStatus);
    event ProductUpdated(uint256 indexed productId, string productName);

    function addProduct(
        string calldata name,
        string calldata serialNumber,
        uint256 createdTime,
        uint256 bestBefore
    ) external {
        LibSupplyChain.SupplyChainStorage storage sc = LibSupplyChain.getSupplyChainStorage();
        uint256 productId = sc.productCount+1;
        require(bytes(name).length > 0, "Invalid Product Name");
        require(createdTime <= block.timestamp, "Invalid Created Time");
        require(bestBefore > block.timestamp, "Invalid Best Before Date");
        require(bestBefore > createdTime, "Invalid Best Before Date");
        require(sc.serialNumberToProductId[serialNumber] == 0, "Serial Number Exists");
        sc.productIdToProduct[productId] = LibSupplyChain.Product(
            name,
            sc.productCount++,
            serialNumber,
            createdTime,
            bestBefore,
            msg.sender
        );

        sc.manufacturerToProductIds[msg.sender].push(productId);

        emit ProductAdded(serialNumber, msg.sender);
    }

    function updateProduct(
        uint256 productId,
        string calldata _name,
        uint256 bestBefore,
        uint256 createdTime
    ) external onlyManufacturer(msg.sender) {
        LibSupplyChain.SupplyChainStorage storage sc = LibSupplyChain.getSupplyChainStorage();
        require(
            sc.productIdToProduct[productId].createdTime > 0,
            "Product Does not Exists"
        );
        require(createdTime <= block.timestamp, "Invalid Created Time");
        require(bestBefore > block.timestamp, "Invalid Best Before Date");
        require(bestBefore > createdTime, "Invalid Best Before Date");
        
        sc.productIdToProduct[productId].name = _name;
        sc.productIdToProduct[productId].bestBefore = bestBefore;
        sc.productIdToProduct[productId].createdTime = createdTime;

        

        emit ProductUpdated(productId, _name);

    }

    function getProductDetails(uint256 productId) external view returns (LibSupplyChain.Product memory) {
        LibSupplyChain.SupplyChainStorage storage sc = LibSupplyChain.getSupplyChainStorage();
        require(
            sc.productIdToProduct[productId].createdTime > 0,
            "Product Does not Exists"
        );
        return sc.productIdToProduct[productId];
    }

    modifier onlyManufacturer(address manufacturer) {
        require(manufacturer == msg.sender, "Unauthorised");
        _;
    }
}