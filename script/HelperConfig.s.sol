// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address axelarGateway;
        address axelarGasService;
        address account;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 43113) {
            activeNetworkConfig = getAvalancheFujiConfig();
        } else if (block.chainid == 84532) {
            activeNetworkConfig = getBaseSepoliaConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            axelarGateway: 0xe432150cce91c13a887f7D836923d5597adD8E31,
            axelarGasService: 0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6,
            account: 0xED2C3b451e15f57bf847c60b65606eCFB73C85d9
        });
    }

    function getAvalancheFujiConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            axelarGateway: 0xC249632c2D40b9001FE907806902f63038B737Ab,
            axelarGasService: 0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6,
            account: 0xED2C3b451e15f57bf847c60b65606eCFB73C85d9
        });
    }

    function getBaseSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            axelarGateway: 0xe432150cce91c13a887f7D836923d5597adD8E31,
            axelarGasService: 0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6,
            account: 0xED2C3b451e15f57bf847c60b65606eCFB73C85d9
        });
    }

    function getOrCreateAnvilEthConfig() public view returns (NetworkConfig memory) {
        if (activeNetworkConfig.axelarGateway != address(0)) {
            return activeNetworkConfig;
        }

        return NetworkConfig({
            axelarGateway: address(1), //Change address
            axelarGasService: address(1), //Change address,
            account: 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38
        });
    }
}
