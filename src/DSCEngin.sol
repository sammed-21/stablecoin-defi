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
contract DSCEngine{
    //////////////////
    // Errors       //
    //////////////////
    error DSCEngine__NeedsMoreThanZero();

     //////////////////
    // State Varialbes    //
    //////////////////
    mapping(address token=>address priceFeed) private s_priceFeeds; 

     //////////////////
    // Modifiers    //
    //////////////////
modifier moreThanZero(uint256 amount){
    if(amount==0){
        revert DSCEngine__NeedsMoreThanZero();
    }
    _;
}
    modifier isAllowedToken(address token){
        

    }
   //////////////////
    // Functions    //
    //////////////////
 constructor(){

 }
    ///////////////////////////
    // External Functions    //
    //////////////////////////
    function depositeCollateralAndMintDsc() external{}

/**
 * 
 * @param tokenCollateralAddress the address of token to deposit as collateral
 * @param amountCollateral the amount of collateral to deposite
 */
    function depositeCollateral(address tokenCollateralAddress, 
    uint256 amountCollateral) external moreThanZero {

    }


    function redeemCollateralForDsc() external{}

    function redeemCollateral() external {}

    function mintDsc() external {
        
    }


    function burnDsc() external {}
    function liquidate() external{}

    function getHealthFactor() external view {}

}