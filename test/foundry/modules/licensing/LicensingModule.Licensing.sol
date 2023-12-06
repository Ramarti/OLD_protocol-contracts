// SPDX-License-Identifier: BUSDL-1.1
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "test/foundry/utils/BaseTest.sol";
import { AccessControl } from "contracts/lib/AccessControl.sol";
import { Licensing } from "contracts/lib/modules/Licensing.sol";
import { IPAsset } from "contracts/lib/IPAsset.sol";
import { BaseTest } from "test/foundry/utils/BaseTest.sol";
import { Errors } from "contracts/lib/Errors.sol";
import { PIPLicensingTerms } from "contracts/lib/modules/PIPLicensingTerms.sol";

contract LicensingModuleLicensingTest is BaseTest {
    using ShortStrings for *;

    address lnftOwner = address(0x13334);
    address ipaOwner = address(0x13336);
    Licensing.ParamValue[] params;

    uint256 ipaId;

    modifier withFrameworkConfig(bool derivativesWithApproval, bool reciprocal, Licensing.LicensorConfig licensorConfig) {
        ShortString[] memory channels = new ShortString[](2);
        channels[0] = "test1".toShortString();
        channels[1] = "test2".toShortString();
        params.push(Licensing.ParamValue({
            tag: PIPLicensingTerms.CHANNELS_OF_DISTRIBUTION.toShortString(),
            value: abi.encode(channels)
        }));
        params.push(Licensing.ParamValue({
            tag: PIPLicensingTerms.ATTRIBUTION.toShortString(),
            value: abi.encode("")// unset
        }));
        params.push(Licensing.ParamValue({
            tag: PIPLicensingTerms.DERIVATIVES_WITH_ATTRIBUTION.toShortString(),
            value: abi.encode(true)
        }));
        params.push(Licensing.ParamValue({
            tag: PIPLicensingTerms.DERIVATIVES_WITH_APPROVAL.toShortString(),
            value: abi.encode(derivativesWithApproval)
        }));
        params.push(Licensing.ParamValue({
            tag: PIPLicensingTerms.DERIVATIVES_WITH_RECIPROCAL_LICENSE.toShortString(),
            value: abi.encode(reciprocal)
        }));
       
        Licensing.LicensingConfig memory config = Licensing.LicensingConfig({
            frameworkId: PIPLicensingTerms.FRAMEWORK_ID,
            params: params,
            licensor: licensorConfig
        });
        vm.prank(ipOrg.owner());
        spg.configureIpOrgLicensing(
            address(ipOrg),
            config
        );
        _;
    }

    function setUp() public override {
        super.setUp();
        (ipaId, ) = _createIpAsset(ipaOwner, 1, bytes(""));

        Licensing.ParamDefinition[] memory paramDefs = PIPLicensingTerms._getParamDefs();
        Licensing.SetFramework memory framework = Licensing.SetFramework({
            id: PIPLicensingTerms.FRAMEWORK_ID,
            textUrl: "text_url",
            paramDefs: paramDefs
        });
        vm.prank(licensingManager);
        licensingFrameworkRepo.addFramework(framework);
    }
    
    function test_LicensingModule_createLicense_noParent_ipa_userSetsParam()
    withFrameworkConfig(true, true, Licensing.LicensorConfig.IpOrgOwnerAlways)
    public {
        Licensing.ParamValue[] memory inputParams = new Licensing.ParamValue[](1);
        inputParams[0] = Licensing.ParamValue({
            tag: PIPLicensingTerms.ATTRIBUTION.toShortString(),
            value: abi.encode(true)
        });

        Licensing.LicenseCreation memory creation = Licensing.LicenseCreation({
            params: inputParams,
            parentLicenseId: 0,
            ipaId: ipaId
        });
        uint256 licenseId = spg.createLicense(
            address(ipOrg),
            creation,
            new bytes[](0),
            new bytes[](0)
        );
        Licensing.LicenseData memory license = licenseRegistry.getLicenseData(licenseId);
        assertEq(uint8(license.status), uint8(Licensing.LicenseStatus.PendingLicensorApproval));
        assertEq(license.isReciprocal, true);
        assertEq(license.derivativeNeedsApproval, true);
        assertEq(license.revoker, Licensing.ALPHA_REVOKER);
        assertEq(license.licensor, ipOrg.owner());
        assertEq(license.ipOrg, address(ipOrg));
        assertEq(license.frameworkId.toString(), PIPLicensingTerms.FRAMEWORK_ID);
        assertEq(license.ipaId, ipaId);
        assertEq(license.parentLicenseId, 0);
        _assertParams(licenseId);

    }
    

    function _assertParams(uint256 licenseId) private view {
        Licensing.ParamValue[] memory lParams = licenseRegistry.getParams(licenseId);
        for(uint256 i = 0; i < lParams.length; i++) {
            console2.log(lParams[i].tag.toString());
        }
    }

}
