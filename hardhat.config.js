require("@nomiclabs/hardhat-ethers");
require("dotenv").config();
const privateKey = process.env.PRIVATE_KEY;
module.exports = {
	defaultNetwork: "matic",
	networks: {
		hardhat: {},
		matic: {
			url: "https://rpc-mumbai.maticvigil.com",
			accounts: [process.env.PRIVATE_KEY],
		},
	},
	solidity: {
		version: "0.8.4",
		settings: {
			optimizer: {
				enabled: true,
				runs: 200,
			},
		},
	},
};
