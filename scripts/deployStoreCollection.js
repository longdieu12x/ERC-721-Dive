const { ethers } = require("hardhat");

async function main() {
	const StoreCollection = await ethers.getContractFactory("StoreCollection");
	const storeCollection = await StoreCollection.deploy(
		"Store Collections Tokens",
		"SCT",
		"https://ipfs.io/ipfs/QmYwKhQmvBpwSy4guxnrV87YmqPxpyw7t8M1v4HiSi4CT7/"
	);
	await storeCollection.deployed();
	console.log(
		"Successfully deployed smart contract to ",
		storeCollection.address
	);

	for (let i = 1; i <= 5; i++) {
		await storeCollection.mint(i * 10);
	}

	console.log(`NFTs successfully minted !`);
}
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
