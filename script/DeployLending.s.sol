//SPDX-License-Identifier:Unlicensed
pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";
import {Lending} from "src/Lending.sol";
 
contract DeployLending is Script{
    function run() external returns(Lending){
        vm.startBroadcast();
        Lending lending = new Lending(0xF1D3120934B171A6E9E767F81ff61Bf69f92bF19);
        vm.stopBroadcast();
        return lending;

    }
}

