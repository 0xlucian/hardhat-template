```solidity
//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

/// @title A simple ERC-20 token example
/// @notice This contract is a basic demonstration of an ERC-20 token
contract Token {
    /// @notice Token name for identification
    string public name = "Example Token";
    /// @notice Token symbol for identification
    string public symbol = "EXT";
    /// @notice Total supply of tokens
    uint256 public totalSupply = 1000000;
    /// @notice Address of the token owner
    address public owner;

    /// @notice Mapping of addresses to their respective token balances
    mapping(address => uint256) balances;

    /// @notice Event emitted when tokens are transferred between addresses
    /// @param _from The address of the sender
    /// @param _to The address of the receiver
    /// @param _value The amount of tokens transferred
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /// @notice Sets the total supply and assigns it to the transaction sender, marking them as the owner
    constructor() {
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    /// @notice Transfers tokens from the caller's address to another address
    /// @param to The address to transfer tokens to
    /// @param amount The amount of tokens to transfer
    function transfer(address to, uint256 amount) external {
        require(balances[msg.sender] >= amount, "Not enough tokens");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    /// @notice Returns the token balance of a specific account
    /// @param account The address of the account to query
    /// @return The token balance of the queried account
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}
```