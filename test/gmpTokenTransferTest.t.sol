// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeploySenderReceiver} from "../script/DeploySenderReceiver.s.sol";
import {SenderReceiver} from "../src/gmpTokenTransfer.sol";

contract GmpTokenTransferTest is Test {
    DeploySenderReceiver deployer;
    SenderReceiver deployedContract;

    function setUp() external {
        deployer = new DeploySenderReceiver();
        deployedContract = deployer.deployContract();
    }

    function testIfWethTokenAddressIsCorrect() external view {
        address expectedContractAddress = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14;
        assertEq(deployedContract.getTokenAddress("WETH"), expectedContractAddress);
    }

    // function testFunctionIsBeingCalledUsingLowLevelCall() external {
    //     address recipient = 0x147397C3d483bbE8f3544DF4C5d0486fC0bB8432;
    //     string memory fnSig = "store(uint256)";
    //     bytes memory encodedParams = hex"000000000000000000000000000000000000000000000000000000000000000a";

    //     bytes memory functionCallData = deployedContract.buildFunctionCallData(fnSig, encodedParams);
    //     bytes memory payload3 = abi.encode(uint8(1), recipient, functionCallData);
    //     deployedContract.triggerInternalExecuteFunc("", "abc", "0xA4540BF98Af7022633588f825111E2bCee4A329d", payload3);
    // }
}
