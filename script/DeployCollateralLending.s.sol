//SPDX-License-Identifier:Unlicensed
pragma solidity ^0.8.20;
import {Script} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";
import {CollateralLending} from "../src/CollateralLending.sol";
import {OurToken} from "../src/OurToken.sol";
contract DeployCollateralLending is Script{
    OurToken public token;
    function run() external returns(OurToken,CollateralLending){
        vm.startBroadcast();
        OurToken public token;
        token = new OurToken(1000e18);
        CollateralLending lending = new CollateralLending(address(token));
        vm.stopBroadcast();
        return token , lending;

    }
}

