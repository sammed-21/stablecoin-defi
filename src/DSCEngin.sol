// SPDX-License-Identifier: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volitility coin

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.18;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title DSCEngine
 * @author Sammed S B
 * This system maintain 1token == 1$ peg.
 * this stablecoin has the properties;
 * -Exogenous Collateral
 * -Dollar pegged
 * -Algoritmically Stable
 *
 * It is similary to dia if dia had not govenance and no fees , and was only backed by WETH and WBTC.
 *
 * Our DSC system should always be "overCollateralized" , At no point, should the value of all collateral <= the $ backed value of all the DSC
 *
 * @notice This conract is the core of the DSC System. It handles all thel ogic for mining and redeeming DSC, as well as depositing and withdrawing collateral.
 * @notice This contract is Very loosely based on the MakerDAO DSS (DAI) system.
 */

contract DSCEngine is ReentrancyGuard {
    //////////////////
    // Errors       //
    //////////////////
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine_TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error DSCEngine_NotAllowedToken();
    error DSCEngine__TransferFailed();
    error DSCEngine__BreaksHealthFactor(uint256 healthFactor);
    error DSCEngine_MintFailed();

    /////////////////////
    // State Varialbes //
    /////////////////////
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50;
    uint256 private constant LIQUIDATION_PRECISION = 100;

    uint256 private constant MIN_HEALTHFACTOR = 1;

    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount))
        private s_collateralDeposited;
    mapping(address user => uint256 amountDscMinted) private s_DSCMinted;
    address[] private s_collaterTokens;

    DecentralizedStableCoin private immutable i_dsc;

    /////////////
    // Events //
    ///////////
    event CollateralDeposited(
        address indexed user,
        address indexed token,
        uint256 indexed amount
    );
    //////////////////
    // Modifiers    //
    //////////////////

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert DSCEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert DSCEngine_NotAllowedToken();
        }
        _;
    }

    //////////////////
    // Functions    //
    //////////////////

    constructor(
        address[] memory tokenAddresses,
        address[] memory priceFeedAddress,
        address dscAddress
    ) {
        //USD Price Feeeds
        if (tokenAddresses.length != priceFeedAddress.length) {
            revert DSCEngine_TokenAddressesAndPriceFeedAddressesMustBeSameLength();
            // for example ETH/USD, BTC/USD, MKR/USD etc

            for (uint256 i = 0; i < tokenAddresses.length; i++) {
                s_priceFeeds[tokenAddresses[i] = priceFeedAddress[i]];
                s_collaterTokens.push(tokenAddresses[i]);
            }
            i_dsc = DecentralizedStableCoin(dscAddress);
        }
    }

    ///////////////////////////
    // External Functions    //
    //////////////////////////

    function depositeCollateralAndMintDsc() external {}

    /**
     *@notice follows Check Effect Interaction (CEI)
     * @param tokenCollateralAddress the address of token to deposit as collateral
     * @param amountCollateral the amount of collateral to deposite
     */
    function depositeCollateral(
        address tokenCollateralAddress,
        uint256 amountCollateral
    )
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][
            tokenCollateralAddress
        ] += amountCollateral;
        emit CollateralDeposited(
            msg.sender,
            tokenCollateralAddress,
            amountCollateral
        );
        bool success = IERC20(tokenCollateralAddress).transferFrom(
            msg.sender,
            address(this),
            amountCollateral
        );
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    /*
     * @notice fellows CEI
     * @param amountDscToMint the amount of decentralized stablecoin to mint
     * @notice they must collateral value then the minimum threshold
     */

    function mintDsc(
        uint256 amountDscToMint
    ) external moreThanZero(amountDscToMint) nonReentrant {
        s_DSCMinted[msg.sender] += amountDscToMint;
        // if they mined too much ($150 DSC, $100ETH)

        _revertIfHealthFactorIsBroken(msg.sender);
        bool minted = i_dsc.mint(msg.sender, amountDscToMint);
        if (!minted) {
            revert DSCEngine_MintFailed();
        }
    }

    function burnDsc() external {}

    function liquidate() external {}

    // function getHealthFactor() external view {}
    ////////////////////////////////////////
    // Private and Internal  Functions    //
    ///////////////////////////////////////
    function _getAccountInformation(
        address user
    )
        private
        view
        returns (uint256 totalDscMinted, uint256 collateralValueInUsd)
    {
        totalDscMinted = s_DSCMinted[user];
        collateralValueInUsd = getAccountCollateralValue(user);
    }

    /*
     *Returns how close to liquidation a user is
     * if a user goes below !, then can get liquidated
     */
    function _healthFactor(address user) private view returns (uint256) {
        //total DSC minted
        // total collateral value
        (
            uint256 totlaDscMinted,
            uint256 collaterValueInUsd
        ) = _getAccountInformation(user);
        uint256 collateralAdjustedForThreshold = (collaterValueInUsd *
            LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
        return (collateralAdjustedForThreshold * PRECISION) / totlaDscMinted;
    }

    function _revertIfHealthFactorIsBroken(address user) internal view {
        uint256 userHealthFactor = _healthFactor(user);
        if (userHealthFactor < MIN_HEALTHFACTOR) {
            revert DSCEngine__BreaksHealthFactor(userHealthFactor);
        }
    }

    function getHealthFactor() external view {}

    ////////////////////////////////////////
    // Public  and External  Functions    //
    ///////////////////////////////////////

    function getAccountCollateralValue(
        address user
    ) public view returns (uint256 toalCollateralValueInUsd) {
        //loop throug each collateral token, get the amount
        for (uint256 i = 0; i < s_collaterTokens.length; i++) {
            address token = s_collaterTokens[i];
            uint256 amount = s_collateralDeposited[user][token];
            toalCollateralValueInUsd += getUsdValue(token, amount);
        }
        return toalCollateralValueInUsd;
    }

    function getUsdValue(
        address token,
        uint256 amount
    ) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            s_priceFeeds[token]
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return
            ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
    }
}
