// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import { Errors } from "contracts/lib/Errors.sol";

/// @title Relatonship Registry
/// @notice This contract is used to register relationships in Story Protocol.
/// Relationships are directional, and they might be:
/// - Between (address, uint) and (address, uint)
/// - Between (address, uint) and (address)
/// - Between (address) and (address, uint)
/// Relationships have a type identifier, which a bytes32 value obtained from 
/// keccak256(relationshipName).
/// Every relationship created will have a unique identifier, a sequential integer
/// starting from 1, that allows it to be referenced across the protocol.
/// TODO: This contract can only be called by a relationship module registered in the
/// ModuleRegistry.
contract RelationshipRegistry {

    enum RelatedElemets {
        ADDRESS_UINT_TO_ADDRESS_UINT,
        ADDRESS_UINT_TO_ADDRESS,
        ADDRESS_TO_ADDRESS_UINT
    }

    struct Relationship {
        bytes32 typeId;
        RelatedElemets relatedElements;
        address srcAddress;
        address dstAddress;
        uint256 srcId;
        uint256 dstId;
    }

    struct CreateRelationshipParams {
        bytes32 typeId;
        RelatedElemets relatedElements;
        address srcAddress;
        address dstAddress;
        uint256 srcId;
        uint256 dstId;
    }

    event RelationshipCreated(
        uint256 indexed relationshipId,
        bytes32 indexed typeId,
        string typeName,
        RelatedElemets relatedElements,
        address srcAddress,
        address dstAddress,
        uint256 srcId,
        uint256 dstId
    );

    uint256 public totalRelationships;
    mapping(uint256 => Relationship) private _relationships;
    mapping(bytes32 => uint256) private _setRelationships;

    address public immutable MODULE_REGISTRY;

    constructor(address moduleRegistry_) {
        if (moduleRegistry_ == address(0)) {
            revert("RelationshipRegistry: Module registry cannot be zero address");
        }
        MODULE_REGISTRY = moduleRegistry_;
    }


    function createRelationship(CreateRelationshipParams calldata params_) external {
        _validateParams(params_);

    }

    function getRelationshipHash(Relationship calldata rel_) external pure returns (bytes32) {
        return keccak256(abi.encode(relationship));
    }

    function _validateParams(CreateRelationshipParams calldata params_) private pure {
        if (params_.srcAddress == address(0) || params_.dstAddress == address(0)) {
            revert Errors.RelationshipRegistry_RelationshipHaveZeroAddress();
        }
        if (
            params_.relatedElements == RelatedElemets.ADDRESS_UINT_TO_ADDRESS ||
            params_.relatedElements == RelatedElemets.ADDRESS_TO_ADDRESS_UINT
        ) {
            if (params_.srcAddress == params_.dstAddress) {
                revert Errors.RelationshipRegistry_RelatingSameAsset();
            }
        } if (params_.relatedElements == RelatedElemets.ADDRESS_UINT_TO_ADDRESS_UINT) {
            if (params_.srcAddress == params_.dstAddress && params_.srcId == params_.dstId) {
                revert Errors.RelationshipRegistry_RelatingSameAsset();
            }
        } else {
            revert Errors.RelationshipRegistry_UnsupportedRelatedElements();
        }
    }
}