// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";

contract SwapContract {
    ISwapRouter public immutable swapRouter;
    IUniswapV3Factory public immutable poolFactory;
    address public immutable wETHAddress;
    uint24 public constant feeTier = 3000;

    constructor(
        ISwapRouter _swapRouter,
        IUniswapV3Factory poolFactory_,
        address wETHAddress_
    ) {
        swapRouter = _swapRouter;
        wETHAddress = wETHAddress_;
        poolFactory = poolFactory_;
    }

    //******************
    //*     EVENTS     *
    //******************
    event SwapExecuted(
        address indexed user,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    /// @notice A function that swaps one token for other using UniswapV3
    /// @dev caller should allow amountIn of tokenIn to this contract before calling this function
    /// @param amountIn Amount to be spent for the swap
    /// @param tokenIn Address of the token to be exchanged
    /// @param tokenOut Address of the token to be received
    /// @param minAmountOut Minimum amount of the received token
    /// @param priceLimit This value can be used to set the limit for the price the swap will push the pool to.
    /// @dev Setting minAmountOut = 0 is a significant risk in production.
    ///        For a real deployment, this value should be calculated using our SDK or an onchain price oracle -
    ///        this helps protect against getting an unusually bad price for a trade
    ///        due to a front running sandwich or another type of price manipulation.
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
