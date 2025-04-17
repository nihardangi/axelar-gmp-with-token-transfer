## Cross Chain Function Calls using Axelar

This repository showcases the capability of making cross chain function calls using Axelar GMP.

Along with the above functionality, the following functionalities have also been implemented:

- Cross chain message sending
- Cross chain token transfer

## Axelar Documentation

https://docs.axelar.dev/dev/general-message-passing/overview/

## Installation

1. Clone the repository

```bash
git clone git@github.com:nihardangi/axelar-gmp-with-token-transfer.git
```

2. Navigate into the project directory

```bash
cd axelar-gmp-with-token-transfer
```

3. Install the project dependencies

```bash
make install
```

4. Initialize .env file with following keys and assign proper values.

```
ACCOUNT=
RPC_URL=
SEPOLIA_RPC_URL=
FUJI_RPC_URL=
BASE_SEPOLIA_RPC_URL=
ETHERSCAN_API_KEY=
SNOWTRACE_API_KEY=
BASESCAN_API_KEY=
```

### Build

```bash
$ make build
```

### Deploy

**Sepolia:**

```bash
make deploy ARGS="--network sepolia"
```

**Avalanche Fuji:**

```bash
make deploy ARGS="--network fuji"
```

New networks can be added by adding the network specific config function in HelperConfig.s.sol file.

Axelar Gateway and Axelar Gas Service addresses can be found here:

**Mainnet**: https://docs.axelar.dev/resources/contract-addresses/testnet/

**Testnet**: https://docs.axelar.dev/resources/contract-addresses/testnet/

Example: If you want to enable base-sepolia network,

1. Add the following function in HelperConfig.s.sol file:

```solidity
    function getBaseSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            axelarGateway: 0xe432150cce91c13a887f7D836923d5597adD8E31,
            axelarGasService: 0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6,
            account: <YOUR_PUBLIC_KEY>
        });
    }
```

2. Add the following condition in HelperConfig.s.sol constructor's if-else block.

```solidity
else if (block.chainid == 84532) {
    activeNetworkConfig = getBaseSepoliaConfig();
}
```

3. And add the relevant keys to .env file, for eg:

```
BASE_SEPOLIA_RPC_URL=
BASESCAN_API_KEY=PGT7PITX87XSC9E6R7WGHR21H42K5A3XWE
```

4. Add chain specific deploy command in Makefile in the deploy recipe, for eg:

```bash
else ifeq ($(findstring --network baseSepolia,$(ARGS)),--network baseSepolia)
	NETWORK_ARGS := --rpc-url $(BASE_SEPOLIA_RPC_URL) --account $(ACCOUNT) --broadcast --verify --chain-id 84532 --etherscan-api-key $(BASESCAN_API_KEY) -vvvv
```
