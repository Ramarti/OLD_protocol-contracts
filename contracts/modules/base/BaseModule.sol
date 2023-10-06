// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import { IModule } from "contracts/interfaces/modules/base/IModule.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { ZeroAddress } from "contracts/errors/General.sol";

abstract contract BaseStoryProtocolModule is IModule {

    struct ModuleConstruction {
        IERC721 ipaRegistry;
        IERC721 franchiseRegistry;
        address moduleRegistry;
    }

    IERC721 public immutable IPA_REGISTRY;
    IERC721 public immutable FRANCHISE_REGISTRY;
    address public immutable MODULE_REGISTRY;

    constructor(ModuleConstruction memory params) {
        IPA_REGISTRY = params.ipaRegistry;
        FRANCHISE_REGISTRY = params.franchiseRegistry;
        MODULE_REGISTRY = params.moduleRegistry;
    }

    function execute(bytes calldata selfParams, bytes calldata preHookParams, bytes calldata postHookParams) external {
        _authCaller(msg.sender);
        if (!_executePreHook(preHookParams)) {
            emit RequestPending(msg.sender);
            return;
        }
        _performAction(selfParams);
        _executePostHook(postHookParams);
        emit RequestCompleted(msg.sender);
    }

    function _authCaller(address caller) virtual internal {}
    function _executePreHook(bytes calldata params) virtual internal returns (bool) {}
    function _performAction(bytes calldata params) virtual internal {}
    function _executePostHook(bytes calldata params) virtual internal {}

}