```solidity
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";

/// @title A contract for swapping tokens on Uniswap V3
/// @notice This contract uses Uniswap V3 to swap a token for another token
contract SwapContract {
    /// @notice The Uniswap V3 SwapRouter
    ISwapRouter public immutable swapRouter;

    /// @notice The Uniswap V3 Factory
    IUniswapV3Factory public immutable poolFactory;

    /// @notice The address of the wrapped ETH token
    address public immutable wETHAddress;

    /// @notice The fee tier to be used in swaps
    uint24 public constant feeTier = 3000;

    /// @notice Initializes the contract with Uniswap V3 router, factory, and WETH address
    /// @param _swapRouter The address of the Uniswap V3 SwapRouter
    /// @param poolFactory_ The address of the Uniswap V3 Factory
    /// @param wETHAddress_ The address of the wrapped ETH token
    constructor(
        ISwapRouter _swapRouter,
        IUniswapV3Factory poolFactory_,
        address wETHAddress_
    ) {
        swapRouter = _swapRouter;
        wETHAddress = wETHAddress_;
        poolFactory = poolFactory_;
    }

    /// @notice Emitted after a successful token swap
    /// @param user The address of the user who executed the swap
    /// @param tokenIn The address of the input token
    /// @param tokenOut The address of the output token
    /// @param amountIn The amount of the input token
    /// @param amountOut The amount of the output token received
    event SwapExecuted(
        address indexed user,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    /// @notice Swaps an exact amount of one token for as much as possible of another token
    /// @dev The caller must have approved this contract to spend at least `amountIn` of `tokenIn` before calling
    /// @param amountIn The amount of the input token to swap
    /// @param tokenIn The address of the input token
    /// @param tokenOut The address of the output token
    /// @param minAmountOut The minimum amount of the output token that must be received for the transaction not to revert
    /// @param priceLimit The limit for the price the swap will push the pool to, encoded as a sqrtPriceLimitX96 value
    /// @return amountOut The amount of the output token received from the swap
    function swapTokenForToken(
        uint256 amountIn,
        address tokenIn,
        address tokenOut,
        uint256 minAmountOut,
        uint256 priceLimit
    ) external returns (uint256 amountOut) {
        require(
            poolFactory.getPool(tokenIn, tokenOut, feeTier) != address(0),
            "Pair not supported"
        );

        TransferHelper.safeTransferFrom(
            tokenIn,
            msg.sender,
            address(this),
            amountIn
        );

        TransferHelper.safeApprove(tokenIn, address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: feeTier,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: minAmountOut,
                sqrtPriceLimitX96: uint160(priceLimit)
            });

        amountOut = swapRouter.exactInputSingle(params);
    }
}
```