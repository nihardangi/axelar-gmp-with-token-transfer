// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AxelarExecutableWithToken} from "@axelar-network/contracts/executable/AxelarExecutableWithToken.sol";
import {IAxelarGateway} from "@axelar-network/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/contracts/interfaces/IAxelarGasService.sol";
import {IERC20} from "@axelar-network/contracts/interfaces/IERC20.sol";

contract SenderReceiver is AxelarExecutableWithToken {
    error SenderReceiver__GasPaymentRequired();
    error SenderReceiver__UserTokenBalanceLowerThanAmount();
    error SenderReceiver__InsufficientAllowance();
    error SenderReceiver__AmountShouldBeGreaterThanZero();
    error SenderReceiver__MessageTypeNotSupported();

    enum MessageType {
        Text,
        FunctionCall
    }

    IAxelarGasService public immutable i_gasService;
    string public s_message;

    constructor(address gateway_, address gasService_) AxelarExecutableWithToken(gateway_) {
        i_gasService = IAxelarGasService(gasService_);
    }

    function sendMessage(
        string calldata destinationChain,
        string calldata destinationAddress,
        uint8 messageType,
        address recipient,
        string calldata message,
        bytes calldata encodedParams
    ) external payable {
        bytes memory payload;
        if (messageType == uint8(MessageType.Text)) {
            payload = abi.encode(messageType, message);
        } else if (messageType == uint8(MessageType.FunctionCall)) {
            bytes memory functionCallData = buildFunctionCallData(message, encodedParams);
            payload = abi.encode(messageType, recipient, functionCallData);
        } else {
            revert SenderReceiver__MessageTypeNotSupported();
        }
        i_gasService.payNativeGasForContractCall{value: msg.value}(
            address(this), destinationChain, destinationAddress, payload, msg.sender
        );

        gateway().callContract(destinationChain, destinationAddress, payload);
    }

    function sendMessageWithToken(
        string calldata destinationChain,
        string calldata destinationAddress,
        address recipient,
        string calldata message_,
        string memory symbol,
        uint256 amount
    ) external payable {
        // Check if gas is sent
        if (msg.value == 0) {
            revert SenderReceiver__GasPaymentRequired();
        }
        if (amount == 0) {
            revert SenderReceiver__AmountShouldBeGreaterThanZero();
        }
        // Check if user's token balance is greater than amount
        address tokenAddress = gatewayWithToken().tokenAddresses(symbol);
        if (IERC20(tokenAddress).balanceOf(msg.sender) < amount) {
            revert SenderReceiver__UserTokenBalanceLowerThanAmount();
        }
        // Check if this contract's allowance on user's tokens is greater than amount.
        if (IERC20(tokenAddress).allowance(msg.sender, address(this)) < amount) {
            revert SenderReceiver__InsufficientAllowance();
        }
        // Transfer token from user and set approval for gateway to transfer tokens to destination contract.
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        IERC20(tokenAddress).approve(address(gatewayWithToken()), amount);

        bytes memory payload = abi.encode(recipient, message_);
        i_gasService.payNativeGasForContractCallWithToken{value: msg.value}(
            address(this), destinationChain, destinationAddress, payload, symbol, amount, msg.sender
        );

        gatewayWithToken().callContractWithToken(destinationChain, destinationAddress, payload, symbol, amount);
    }

    // Use only for local testing, don't deploy elsewhere.
    // function triggerInternalExecuteFunc(
    //     bytes32 commandId,
    //     string calldata sourceChain,
    //     string calldata sourceAddress,
    //     bytes calldata payload_
    // ) external {
    //     _execute(commandId, sourceChain, sourceAddress, payload_);
    // }

    function _execute(
        bytes32, /*commandId*/
        string calldata, /*sourceChain*/
        string calldata, /*sourceAddress*/
        bytes calldata payload_
    ) internal override {
        uint8 messageType = abi.decode(payload_, (uint8));
        if (messageType == uint8(MessageType.Text)) {
            (, s_message) = abi.decode(payload_, (uint8, string));
        } else if (messageType == uint8(MessageType.FunctionCall)) {
            (, address recipient, bytes memory functionCallData) = abi.decode(payload_, (uint8, address, bytes));

            // Forward the call using low level call
            (bool success,) = recipient.call(functionCallData);
            // Check if the call succeeded
            if (!success) {
                revert("Something is wrong");
            }
        }
    }

    function _executeWithToken(
        bytes32, /*commandId*/
        string calldata, /*sourceChain*/
        string calldata, /*sourceAddress*/
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) internal override {
        (address recipient, string memory message) = abi.decode(payload, (address, string));
        // get ERC-20 address from gateway
        address tokenAddress = gatewayWithToken().tokenAddresses(tokenSymbol);

        // transfer received tokens to the recipient
        IERC20(tokenAddress).transfer(recipient, amount);
        s_message = message;
    }

    function getTokenAddress(string calldata tokenSymbol) external view returns (address) {
        return gatewayWithToken().tokenAddresses(tokenSymbol);
    }

    function buildFunctionCallData(string memory fnSig, bytes calldata encodedParams)
        public
        pure
        returns (bytes memory)
    {
        bytes4 selector = bytes4(keccak256(bytes(fnSig)));
        return abi.encodePacked(selector, encodedParams);
    }
}
