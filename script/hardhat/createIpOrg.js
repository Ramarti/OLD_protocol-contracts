const loadDeployment = require('./loadDeployment.js');

function parseEvent(events, interface, eventName) {
    const topic = interface.getEventTopic(eventName);

    const log = events.find((e) => e.topics[0] === topic);
    const event = interface.parseLog(log);
    return event.args;
}

async function main(args, hre) {
    const { ethers } = hre;
    const { chainId, contracts } = await loadDeployment(hre);
    const { name, symbol, events } = args;
    console.log("Creating IpOrg: ", name, symbol);
    const sender = await ethers.getSigner();
    const tx = await contracts.storyProtocol.registerIpOrg(
        sender.address,
        name,
        symbol,
        []
    );
    console.log("IpOrg created in tx: ", tx.hash);
    console.log("Waiting for tx to be mined...");
    const receipt = await tx.wait();
    if (events) {
        console.log("Events: ");
        console.log(receipt.events);
    }
    const result = parseEvent(
        receipt.events,
        contracts.IPOrgController.interface,
        "IPOrgRegistered"
    );
    console.log("IpOrg created", result.ipAssetOrg_);
    return result;
}

module.exports = main;
