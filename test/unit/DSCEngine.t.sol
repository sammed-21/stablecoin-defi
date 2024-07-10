//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";

contract DSCEngineTest is Test {
    DeployDSC deployer;

    functoin setUp() public {
        deployer = new DeployeDSC();

    }

}