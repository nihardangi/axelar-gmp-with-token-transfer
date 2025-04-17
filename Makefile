-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil 

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install cyfrin/foundry-devops@0.2.2 --no-commit && forge install foundry-rs/forge-std@v1.8.2 --no-commit && forge install axelarnetwork/axelar-gmp-sdk-solidity --no-commit

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --account $(ACCOUNT) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
else ifeq ($(findstring --network fuji,$(ARGS)),--network fuji)
	NETWORK_ARGS := --rpc-url $(FUJI_RPC_URL) --account $(ACCOUNT) --broadcast --verify --chain-id 43113 --verifier-url 'https://api.routescan.io/v2/network/mainnet/evm/43114/etherscan' --etherscan-api-key $(SNOWTRACE_API_KEY) -vvvv
else ifeq ($(findstring --network baseSepolia,$(ARGS)),--network baseSepolia)
	NETWORK_ARGS := --rpc-url $(BASE_SEPOLIA_RPC_URL) --account $(ACCOUNT) --broadcast --verify --chain-id 84532 --etherscan-api-key $(BASESCAN_API_KEY) -vvvv
endif

deploy:
	@forge script script/DeploySenderReceiver.s.sol:DeploySenderReceiver $(NETWORK_ARGS)

# NETWORK_ARGS := --rpc-url $(FUJI_RPC_URL) --account $(ACCOUNT) --broadcast --verify --chain-id 43113 --etherscan-api-key $(SNOWTRACE_API_KEY) -vvvv	
# NETWORK_ARGS := --rpc-url $(BASE_SEPOLIA_RPC_URL) --account $(ACCOUNT) --broadcast --verify --chain-id 84532 --etherscan-api-key $(BASESCAN_API_KEY) -vvvv

# forge script script/DeploySenderReceiver.s.sol:DeploySenderReceiver --rpc-url $BASE_SEPOLIA_RPC_URL --account $ACCOUNT --chain-id 84532 --broadcast --verify --etherscan-api-key $BASESCAN_API_KEY -vvvv


# cast call 0x254d06f33bDc5b8ee05b2ea472107E300226659A "balanceOf(address)(uint256)" 0xED2C3b451e15f57bf847c60b65606eCFB73C85d9 --rpc-url $SEPOLIA_RPC_URL

# cast send 0x254d06f33bDc5b8ee05b2ea472107E300226659A "approve(address,uint256)" 0x10e41C358DdA805f008c8b045625cC6087087b13 235000 --account $ACCOUNT --rpc-url $SEPOLIA_RPC_URL

# cast call 0x254d06f33bDc5b8ee05b2ea472107E300226659A "allowance(address,address)(uint256)" 0xED2C3b451e15f57bf847c60b65606eCFB73C85d9 0x10e41C358DdA805f008c8b045625cC6087087b13 --rpc-url $SEPOLIA_RPC_URL


# forge verify-contract 0x40CD6B621D6905dF59813f2ff6403D58EB55509c src/gmpTokenTransfer.sol:SenderReceiver --verifier-url 'https://api.routescan.io/v2/network/testnet/evm/43113/etherscan' --etherscan-api-key "verifyContract" --num-of-optimizations 200 --compiler-version 0.8.19 --constructor-args $(cast abi-encode "constructor(address gateway_, address gasService_)" 0xC249632c2D40b9001FE907806902f63038B737Ab 0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6)