pragma solidity ^0.4.13;

contract GolemNetworkToken {
    string public constant name = "Golem Network Token";
    string public constant symbol = "GNT";
    uint8 public constant decimals = 2;//18;  // 18 decimal places, the same as ETH.
 
    uint public rate = 280;
    uint public weiPerEUR = 10**14;
    uint coefEUR = 75 * weiPerEUR;
    uint changeWei = 0;
    // The current total token supply.
    uint256 totalTokens;

    mapping (address => uint256) balances; 

    event Transfer(address indexed _from, address indexed _to, uint256 _value); 
 

    /// @notice Transfer `_value` GNT tokens from sender's account
    /// `msg.sender` to provided account address `_to`.
    /// @notice This function is disabled during the funding.
    /// @dev Required state: Operational
    /// @param _to The address of the tokens recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool) {  

        var senderBalance = balances[msg.sender];
        if (senderBalance >= _value && _value > 0) {
            senderBalance -= _value;
            balances[msg.sender] = senderBalance;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }
    
    function DeleteContract() {
        selfdestruct(msg.sender);
    }
    
    
    function totalSupply() external constant returns (uint256) {
        return totalTokens;
    }

    function balanceOf(address _owner) external constant returns (uint256) {
        return balances[_owner];
    }
    
    // Crowdfunding:
    function () payable {
        create();
    }
    /// @notice Create tokens when funding is active.
    /// @dev Required state: Funding Active
    /// @dev State transition: -> Funding Success (only if cap reached)
    function create() payable { 
         
        // Do not allow creating 0 or more than the cap tokens.
        require(msg.value != 0); 

        var numTokens = getAmountTokens(msg.value);
        totalTokens += numTokens;

        // Assign new tokens to the sender
        balances[msg.sender] += numTokens;

        // Log token creation event
        Transfer(0, msg.sender, numTokens);
    } 

    function getAmountTokens(uint _eth) internal returns(uint256) {
        var curAmountToSale = balances[this];
        var tempAmount = _eth / (coefEUR / rate);

        if (tempAmount > curAmountToSale) {
            changeWei = curAmountToSale * (coefEUR / rate); 
            return curAmountToSale;
        }
        return tempAmount;
    }

    function migrateFrom(address _owner, uint _val) {
        //if (msg.sender == 0xe7d6b81eA7a0322A34720eEe41f68Fb979a1A063) {//вставить мой контракт
            balances[_owner] += _val;
            totalTokens += _val;
        //} 
    }

    function ContractBalance() constant returns(uint) {
        return this.balance;
    } 
}