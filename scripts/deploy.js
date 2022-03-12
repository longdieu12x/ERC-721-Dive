const { ethers } = require("hardhat");

async function main() {
	const NFTCollection = await ethers.getContractFactory("NFTCollection");
	const nftCollection = await NFTCollection.deploy("Minh Dang Tokens", "MDT");
	await nftCollection.deployed();
	console.log(
		"Successfully deployed smart contract to ",
		nftCollection.address
	);

	await nftCollection.mint(
		"https://ipfs.io/ipfs/QmbimuxoEPJr2pee4En5cr4JCYhZqqPFvDxippgn8mpaad"
	);

	console.log(`NFT successfully minted !`);
}
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
