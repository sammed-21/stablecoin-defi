//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DecentralizedStableCoint} from "../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../src/DSCEngine.sol";



contract DeployDSC is Script {
    function run() external returns(DecentralizedStableCoin, DSCEngine){
        vm.startBroadcast();
        DecentralizedStableCoin dsc = new DecentralizedStableCoint();
        DSCEngine  engine = new DSCEngine();
        vm.stopBroadcast();
    }
}