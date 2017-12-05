pragma solidity ^0.4.13;

import './ERC20.sol'; 
import './Ownable.sol';

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20, Ownable { 
    ///user balances storage
    mapping(address => uint256) balances; 

    /**
    * @dev Throws if the msg.data has the uncorrect length
    */
    modifier onlyPayloadSize(uint size) { 
        require(msg.data.length >= size + 4);
        _;
    } 
    
    /**
    * @dev _transfer method allows to send tokend beetwen two accounts, use for send ICO tokens.
    * @param _from The address to transfer from.
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function _transfer (address _from, address _to, uint _value) internal {
        require(_to != address(0));    
        require(balances[_from] >= _value);
        require(balances[_to] + _value >= balances[_to]);
		
		uint prevBalances = balances[_from] + balances[_to];
        balances[_from] -= _value;
        balances[_to] += _value;
         
		assert(balances[_from] + balances[_to] == prevBalances);
        Transfer(_from, _to, _value);
    }

    /**
    * @dev transfer token for a specified address.
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) onlyPayloadSize(2*32) public returns (bool) { 
        require(msg.sender == owner);// on preICO stage only owner can transfer tokens
        _transfer(msg.sender, _to, _value);  
        return true;
    }  

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of. 
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }  
}