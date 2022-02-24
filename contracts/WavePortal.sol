// SPDX-License-Identifier; UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract WavePortal is VRFConsumerBase {
    uint256 totalWaves;

    bytes32 private s_keyHash;
    uint256 private s_fee;


    uint256 private seed;

    event NewWave(address indexed from, uint256 timestamp, string message);

    // Chainlink VRF Events 
    event RaffleStarted(bytes32 indexed requestId, address indexed waver);
    event RaffleEnded(bytes32 indexed requestId, uint256 indexed result);

    struct Wave {
        address waver;
        string message;
        uint256 timestamp;
    }

    Wave[] waves;


    mapping(address => uint256) public lastWavedAt;

    constructor(address vrfCoordinator, address link, bytes32 keyHash, uint256 fee) payable VRFConsumerBase(vrfCoordinator, link) {
        console.log("This is my smart contract, welcome.");
        s_keyHash = keyHash;
        s_fee = fee;
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        uint256 winnterValue = (randomness % 50) + 1;
        emit RaffleEnded(requestId, winnterValue);
    }

    function wave(string memory _message) public {
        require(
            lastWavedAt[msg.sender] + 15 minutes < block.timestamp,
            "Wait 15m"
        );

        lastWavedAt[msg.sender] = block.timestamp;
        totalWaves += 1;
        console.log("%s has waved!", msg.sender);

        waves.push(Wave(msg.sender, _message, block.timestamp));
        bytes32 requestID = requestRandomness(s_keyHash, s_fee);
        console.log("Random number returned from Oracle: ", requestID);
        // seed = (block.timestamp + block.difficulty) % 100;

        if (requestID <= 50) {
            require(LINK.balanceOf(address(this)) >= s_fee, "Not enough LINK to pay VRF Fee!");
            console.log("%s won!", msg.sender);

            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to award more money than available on contract."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from the contract");
        }
        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves.", totalWaves);
        return totalWaves;
    }
}