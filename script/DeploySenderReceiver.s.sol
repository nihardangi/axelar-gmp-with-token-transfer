// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {HelperConfig} from "./HelperConfig.s.sol";
import {SenderReceiver} from "../src/gmpTokenTransfer.sol";
import {Script} from "forge-std/Script.sol";

contract DeploySenderReceiver is Script {
    function run() external {
        deployContract();
    }

    function deployContract() public returns (SenderReceiver) {
        HelperConfig helperConfig = new HelperConfig();
        (address axelarGateway, address axelarGasService, address account) = helperConfig.activeNetworkConfig();

        vm.startBroadcast(account);
        SenderReceiver sr = new SenderReceiver(axelarGateway, axelarGasService);
        vm.stopBroadcast();
        return sr;
    }
}
