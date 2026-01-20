//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngin.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract DSCEngineTest is Test {
    DeployDSC deployer;
    DecentralizedStableCoin dsc;
    DSCEngine dsce;
    HelperConfig config;
    address ethUsdPriceFeed;
    address btcUsdPriceFeed;
    address weth;

    address public USER = makeAddr("user");
    uint256 constant AMOUNT_COLLATERAL = 10e18;
    uint256 constant STARTING_ERC20_BALANCE = 10e18;

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, dsce, config) = deployer.run();
        HelperConfig.NetworkConfig memory networkConfig = config
            .activeNetworkConfig();
        ethUsdPriceFeed = networkConfig.wethUsdPriceFeed;
        btcUsdPriceFeed = networkConfig.wbtcUsdPriceFeed;
        weth = networkConfig.weth;

        ERC20Mock(weth).mint(address(USER), STARTING_ERC20_BALANCE);
    }

    ///////////////////////
    // Constructor Tests //
    //////////////////////
    address[] public tokenAddress;
    address[] public priceFeedAddress;

    function testRevertIfTokenLengthDoesntMatch() public {
        tokenAddress.push(weth);
        priceFeedAddress.push(ethUsdPriceFeed);
        priceFeedAddress.push(btcUsdPriceFeed);
        vm.expectRevert(
            DSCEngine
                .DSCEngine_TokenAddressesAndPriceFeedAddressesMustBeSameLength
                .selector
        );
        new DSCEngine(tokenAddress, priceFeedAddress, address(dsc));
    }

    /////////////////
    // Price Tests //
    /////////////////

    function testGetUsdValue() public {
        uint256 wethPrice = 1e18;
        uint256 expectedEthUsd = 2000e18;
        uint256 actualUsd = dsce.getUsdValue(weth, wethPrice);
        console.log("actualUsd", actualUsd);
        console.log("expectedEthUsd", expectedEthUsd);
        assertEq(actualUsd, expectedEthUsd);
    }

    //////////////////////////////
    // Deposit Colleteral Tests //
    //////////////////////////////
    function testDepositCollateralRevertsIfAmountIsZero() public {
        vm.prank(USER);
        ERC20Mock(weth).approve(address(dsce), 10e18);
        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        dsce.depositeCollateral(weth, 0);
        vm.stopPrank();
    }
}
