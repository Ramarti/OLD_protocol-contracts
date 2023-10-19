const { readFileSync } = require("fs");

const DEBUG = false;

async function main(hre) {
    const { ethers } = hre;
    const chainId = await ethers.provider.getNetwork().then((n) => n.chainId);
    console.log("ChainId:", `${chainId}`);
    
    const filePath = `./deployment-${chainId}.json`;
    const deployment = JSON.parse(readFileSync(filePath));
    if (DEBUG) {
        Object.keys(deployment).forEach((key) => {
            console.log(`${key}: ${deployment[key]}`);
        });
    }
    const contracts = {}
    contracts.IPOrgController = await ethers.getContractFactory("IPOrgController-Proxy");
    contracts.ipOrgController = await contracts.IPOrgController.attach(deployment.main["IPOrgController-Proxy"]);
    contracts.IPAssetsRegistry = await ethers.getContractFactory("IPAssetRegistry");
    contracts.ipAssetsRegistry = await contracts.IPAssetsRegistry.attach(deployment.main["IPAssetRegistry"]);
    contracts.RegistrationModule = await ethers.getContractFactory("RegistrationModule");
    contracts.registrationModule = await contracts.RegistrationModule.attach(deployment.main["RegistrationModule-Proxy"]);
    contracts.LicenseRegistry = await ethers.getContractFactory("LicenseRegistry");
    contracts.licenseRegistry = await contracts.LicenseRegistry.attach(deployment.main["LicenseRegistry"]);
    contracts.LicensingModule = await ethers.getContractFactory("LicensingModule");
    contracts.licensingModule = await contracts.LicensingModule.attach(deployment.main["LicensingModule"]);
    contracts.RelationshipModule = await ethers.getContractFactory("RelationshipModule");
    contracts.relationshipModule = await contracts.RelationshipModule.attach(deployment.main["RelationshipModule"]);
    contracts.StoryProtocol = await ethers.getContractFactory("StoryProtocol");
    contracts.storyProtocol = await contracts.StoryProtocol.attach(deployment.main["StoryProtocol"]);
    
    return { chainId, contracts, deployment };
}

module.exports = main;
