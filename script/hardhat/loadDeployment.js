const { readFileSync } = require("fs");

const DEBUG = false;

async function main(hre) {
    const { ethers } = hre;
    const chainId = await ethers.provider.getNetwork().then((n) => n.chainId);
    console.log("ChainId:", `${chainId}`);

    const filePath = `./deployment-${chainId}.json`;
    const deployment = JSON.parse(readFileSync(filePath))['main'];
    console.log(deployment);
    if (DEBUG) {
        Object.keys(deployment).forEach((key) => {
            console.log(`${key}: ${deployment[key]}`);
        });
    }
    /*
    {
        "main": {
            "AccessControlSingleton-Impl": "0xC97Bf3B002354E35B026f546802Df337471F9394",
            "AccessControlSingleton-Proxy": "0xb98C744a2b9e5DF92302Feda41437C52653bBB79",
            "IPAssetRegistry": "0x60B51a24eB4748E75E2015F83dDEF212D4529439",
            "IPOrgController-Impl": "0x54B146692C73DE6985D84A5c4a82F7187829a272",
            "IPOrgController-Proxy": "0x1498Ecc8a1cA7cCeAF1E1789F2f9Cf86Fe9CDBfB",
            "LicenseRegistry": "0x9a75984bc44924d3379344085A25c893AE8c45f2",
            "LicensingFrameworkRepo": "0xDE810424341F5a42F60D57dfd3Ae84ddad79158a",
            "LicensingModule": "0x4F63a203e4120fb0a5B877A96ba1e5499E7BA1D7",
            "MockERC721": "0x314581504F3b64aAeF805Dcae4e2A20b2AA80Db4",
            "ModuleRegistry": "0x45204F4291103be222B7c93eDE252d3f5Cbf3710",
            "PolygonTokenHook": "0x6DD16148A958054F0dC5F77444031Ff6E11E6c6F",
            "RegistrationModule": "0x8a38a8527922c34dA72A57a3ca8c3a2D99dA2547",
            "RelationshipModule": "0xf9B73593d7C525153dD2801D5bDc697DA1F2DCa2",
            "StoryProtocol": "0xcb733fD57B99212e60696Fd6605154BeEBA11bDe",
            "TokenGatedHook": "0x8bc85DC6983B72df1F0A3ccA7B1c5D8c72Cb9983"
        }
    }
    */

    const contracts = {}

    return { chainId, contracts, deployment };
}

module.exports = main;
