
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {LibSupplyChain} from "../libraries/LibSupplyChain.sol";

contract VerifyProductFacet{


    function AuthenticateProduct(string calldata serialNumber) external view returns(bool, string memory, address) {
        LibSupplyChain.SupplyChainStorage storage sc = LibSupplyChain.getSupplyChainStorage();
        require(sc.serialNumberToProductId[serialNumber] == 0, "Serial Number Exists");
        return (true, sc.productIdToProduct[sc.serialNumberToProductId[serialNumber]].name, sc.productIdToProduct[sc.serialNumberToProductId[serialNumber]].manufacturer);
    }


}