# Smart contract creating a token and realize ICO.


A smart contract contains contracts such as Ownable.sol, ERC20.sol and BasicToken.sol, which contains the ERC20 implementation standard. You will also find the GolemNetworkToken.sol contract, which I used to test the migration.

The basic logic is contained in the contract Token.sol

## Key features of a smart contract
- This smart contract was created in order to conduct preICO and in the future migrates to a new contract.
- The total number of released tokens is 10,000,000.
- For the payment of pre-orders, created function of sending tokens manually
- All the invested ether is immediately sent from the contract to the owner's wallet.
- The exchange rate token to ether set manually (due to a strong change in the airspeed)
- After the start of preICO, tokens are bought at a fixed price of 0.2 USD.
- If the investor has paid more tokens than left for sale - contract will return remaining ether.
- The ability to send tokens will be enabled after preICO. Transfers available only for Owner.
- "The contract provides protection against a short attack."
- In the contract "Token.sol" you can switch to another contract. For this purpose, an abstract contract "MigrationAgent" was created.
- The team receives 20% of the sold tokens at the end of the pre-ISTO.
- All tests are written in JavaScript in the "test" folder.

Migration of the token is made by Ovner, he can call the method, and which will indicate the number of token holders who must switch to a new contract. So you can avoid overflow on gas, and investors will not need to call the smart contract method for the transition.

## How do I set up the development environment and run tests?

Use this link to install all you need -> http://truffleframework.com/tutorials/how-to-install-truffle-and-testrpc-on-windows-for-blockchain-development

1. Install the truffle if you do not have it.
2. Clone this repo.
3. Start "testrpc".
4. Run the "truffle test" in your local directory, which contains this repo.

I did not use truffle migration, instead I downloaded Mist (or EthereumWallet) with the full ethereum node, inserted the whole .sol contract into one file and loaded it into the block chain.
