pragma solidity ^0.4.13;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20 {
    ///total amount of tokens
    uint256 public totalSupply; 

    /*
    * @param who The address from which the balance will be retrieved
    * @return The balance
    */
    function balanceOf(address who) public constant returns(uint256);

    /**
     * At the preICO stage is available only the owner 
     * @notice send `_value` token to `_to` from `msg.sender`  
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
    */
    function transfer(address _to, uint256 _value) public returns (bool);
 
    event Transfer(address indexed from, address indexed to, uint256 value);
}