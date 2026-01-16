//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngin.sol";

contract DSCEngineTest is Test {
    DeployDSC deployer;
    DecentralizedStableCoin dsc;
    DSCEngine dsc;
    HelperConfig config;
    address ethUsdPriceFeed;
    address weth;

    function setUp() public {
        deployer = new DeployeDSC();
        (dsc, dsce, config) = deployer.run();
        (ethUsdPriceFeed, , weth, , ) = config.activeNetworkConfig();
    }

    /////////////////
    // Price Tests //
    /////////////////

    function testGetUsdValue() public {
        console.log(ethUsdPriceFeed, weth);
    }
}
