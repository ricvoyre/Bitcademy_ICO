const HDWalletProvider = require("truffle-hdwallet-provider-privkey");
const privKey = "ebe843a1ce37c22cd2a022fcdc76738ad41d2d6b9c519ff670aa1c8f6e5fd26d";

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!

    networks: {
      ropsten: {
        provider: () => { return new HDWalletProvider(privKey, "https://ropsten.infura.io/PGeaCCgYpthSugPncips")},
        network_id: '3'
      },
      rinkeby: {
        provider: () => { return new HDWalletProvider(privKey, "https://rinkeby.infura.io/PGeaCCgYpthSugPncips")},
        network_id: '4'
      },
      development: {
          host: "127.0.0.1",
          port: 8545,
          network_id: "*" // Match any network id
      }
  }
};
