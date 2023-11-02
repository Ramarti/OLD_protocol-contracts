// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import { Clones } from '@openzeppelin/contracts/proxy/Clones.sol';
import { IPAsset } from "contracts/lib/IPAsset.sol";
import { AccessControl } from "contracts/lib/AccessControl.sol";
import { Errors } from "contracts/lib/Errors.sol";
import { AccessControlledUpgradeable } from "./access-control/AccessControlledUpgradeable.sol";
import { LicenseRegistry } from "contracts/modules/licensing/LicenseRegistry.sol";
import { IIPOrgFactory } from "contracts/interfaces/IIPOrgFactory.sol";
import { IPOrg } from "contracts/ip-assets/IPOrg.sol";

/// @notice IP Organization Factory Contract
/// TODO(ramarti): Extend the base hooks contract utilized by SP modules.
contract IPOrgFactory is
    AccessControlled,
    IIPOrgFactory
{

    /// @notice Base template implementation contract used for new IP Asset Org creation.
    address public immutable IP_ORG_IMPL = address(new IPOrg());

    string private constant _VERSION = "0.1.0";
    
    // TODO(@leeren): Fix storage hash
    // keccak256(bytes.concat(bytes32(uint256(keccak256("story-protocol.ip-asset-org-factory.storage")) - 1)))
    bytes32 private constant _STORAGE_LOCATION = 0x1b0b8fa444ff575656111a4368b8e6a743b70cbf31ffb9ee2c7afe1983f0e378;

    /// @custom:storage-location erc7201:story-protocol.ip-asset-org-factory.storage
    // TODO: Extend IP asset org storage to support other relevant configurations
    struct IPOrgFactoryStorage {
        /// @dev Tracks mappings from ipAssetOrg to whether they were registered.
        mapping(address => bool) registered;
    }

    /// @notice Checks if an address is a valid IP Asset Organization.
    /// @param ipAssetOrg_ the address to check
    /// @return true if `ipAssetOrg_` is a valid IP Asset Organization, false otherwise
    function isIpOrg(
        address ipAssetOrg_
    ) external view returns (bool) {
        IPOrgFactoryStorage storage $ = _getIpOrgFactoryStorage();
        return $.registered[ipAssetOrg_];
    }

    /// @notice Returns the current version of the factory contract.
    function version() external pure override returns (string memory) {
        return _VERSION;
    }


    /// @notice Registers a new ipAssetOrg for IP asset collection management.
    /// @param params_ Parameters required for ipAssetOrg creation.
    /// TODO: Converge on core primitives utilized for ipAssetOrg management.
    /// TODO: Add ipAssetOrg-wide module configurations to the registration process.
    // TODO: Remove registry
    function registerIPOrg(
        IPAsset.RegisterIPOrgParams calldata params_
    ) public returns (address) {
        address ipAssetOrg = Clones.clone(IP_ASSET_ORG_IMPL);
        IPOrg(ipAssetOrg).initialize(IPAsset.InitIPOrgParams({
            registry: params_.registry,
            owner: msg.sender,
            name: params_.name,
            symbol: params_.symbol,
            description: params_.description
        }));

        // Set the registration status of the IP Asset Org to be true.
        IPOrgFactoryStorage storage $ = _getIpOrgFactoryStorage();
        $.registered[ipAssetOrg] = true;

        emit IPOrgRegistered(
            msg.sender,
            ipAssetOrg,
            params_.name,
            params_.symbol,
            params_.tokenURI
        );
        return ipAssetOrg;

    }

    /// @notice Initializes the IPOrgFactory contract.
    /// @param accessControl_ Address of the contract responsible for access control.
    function initialize(address accessControl_) public initializer {
        __UUPSUpgradeable_init();
        __AccessControlledUpgradeable_init(accessControl_);
    }

    function _authorizeUpgrade(
        address newImplementation_
    ) internal virtual override onlyRole(AccessControl.UPGRADER_ROLE) {}

    function _getIpOrgFactoryStorage()
        private
        pure
        returns (IPOrgFactoryStorage storage $)
    {
        assembly {
            $.slot := _STORAGE_LOCATION
        }
    }
}
