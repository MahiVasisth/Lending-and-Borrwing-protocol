//SPDX-License-Identifier:Unlicensed
pragma solidity ^0.8.20;
import {Script} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {OurToken} from "../src/OurToken.sol";
contract DeployOurToken is Script{
   
    function run() external returns(OurToken){
        vm.startBroadcast();
        uint256 initial_supply = 1500 ether;
        OurToken token = new OurToken(initial_supply);
        vm.stopBroadcast();
        return token;

    }
}

