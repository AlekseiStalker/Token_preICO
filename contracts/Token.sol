pragma solidity ^0.4.13;

import './BasicToken.sol';  

/// @title Migration Agent interface
contract MigrationAgent {
    function migrateFrom(address _from, uint256 _value) public;
}
 
contract Token is BasicToken {
    string public constant name = "Token";
    string public constant symbol = "TKN";
    uint8 public constant decimals = 2; 
    
    // Address where funds are collected.
    address ownerWallet = 0x0;  
    // Address where tokens are storage.
    address tokenHolder = 0x0;
    // Address developers team.
    address team = 0xEaEa019D93335137711d6C29974657Fdbd3bf420; 

    // Ether rate.(USD/Ether)
    uint public rate = 300;
 
    // Token cost on USD. (0.2 USD)
    uint coefUSD = 20 * 10**14;

    // Actually token price on wei.
    uint currentTokenPrice = coefUSD / rate;

    // Change from purchase of tokens.
    uint changeWei = 0;
 
    // Stage of preICO. active = true/not active = false
    bool public isGoICO = false;
    
    // Address contratc for migrate token.  
    address public migrationAgent = 0x0;
    // Number of migrated tokens.
    uint public totalMigrated = 0;
    
    mapping (address => bool) isTokenHolder;
    uint public lastMigratedUser; 

    // Storage of all token holders.
    address[] addressHolders; 
    // Number of all token holders.
    uint256 public countOfHolders = 0;
    
    /**
    * Stage og preICO is changed.
    */
    event ICOisGo(bool _value);

    /**
    * Rate ether is changed.
    */
    event ChangeEtherRate(uint newRate);

    /**
    * Somebody has upgraded some of his tokens.
    */
    event Migrate(address indexed from, address indexed to, uint value); 

    /**
    * Modifier to run function only if preICO is active (not Paused).
    */
    modifier whenNotPaused() {
        require(isGoICO);
        _;
    }

    /**
    * Constructor for Token.
    * @param _ownerWalletAddress all incoming eth transfered here.  
    * @param _tokensStorageAddress all tokens storage on this address.
    */
    function Token(address _ownerWalletAddress, address _tokensStorageAddress) public { 
		// require(_ownerWalletAddress != address(0));
        // require(_tokensStorageAddress != address(0)); 
		
        totalSupply = 10000000 * 10**uint(decimals);  
        ownerWallet = _ownerWalletAddress;
        tokenHolder = _tokensStorageAddress;
        balances[tokenHolder] = totalSupply;
        Transfer(this, tokenHolder, totalSupply);
    }

    /**
    * Changes the stage of preICO.
    * @param _start value specifying the stage of the current stage.
    */
    function setStagePreICO(bool _start) onlyOwner external {
        isGoICO = _start;
        ICOisGo(_start);
    } 
    /**
    * After finish preICO burn all left tokens.
    */
    function finalizePreICO() onlyOwner external {
        if (!isGoICO) { 
            uint saleTokens = totalSupply - balances[tokenHolder];
            uint team_amount = saleTokens * 5 / 100;
            uint owner_amount = saleTokens * 15 / 100;

            balances[team] += team_amount; 
            confirmHolder(team);
            Transfer(this, team, team_amount);

            balances[ownerWallet] += owner_amount;
            confirmHolder(ownerWallet);
            Transfer(this, ownerWallet, owner_amount); 
            
            balances[tokenHolder] = 0;
            Transfer(tokenHolder, 0x0, balances[tokenHolder]);
        } else {
            revert();
        }
    }
    
    /**
    * Changed ether rate.
    * @param _rateETH value representing the current rate.
    */
    function setEtherExchangeRate(uint _rateETH) onlyOwner external {
        rate = _rateETH;
        currentTokenPrice = coefUSD / rate;
        ChangeEtherRate(rate);
    } 

    /**
    * Fallback function can be used to buy tokens.
    */ 
    function () payable public {
        buyTokens();
    }
    /**
    * Main function for buying tokens.
    */
    function buyTokens() whenNotPaused payable public {    
        require(msg.value > 0); 

        uint256 weiAmount = msg.value; 
        uint256 amount = getAmountTokens(weiAmount);
        
        if (amount >= 100) {// Users can't buy less than one token at a time.
            _transfer(tokenHolder, msg.sender, amount); 
            confirmHolder(msg.sender);
        } else {
            revert();
        }
         
        if (changeWei > 0) {
            msg.sender.transfer(msg.value - changeWei);
            ownerWallet.transfer(changeWei);
            changeWei = 0;
        } else {
            ownerWallet.transfer(msg.value);
        } 
    }

    /**
    * Function counting the number of tokens on receiving ether.
    * @param _eth amount of ether.
    * @return amount of tokens.
    */
    function getAmountTokens(uint _eth) private returns(uint256) {
        var curAmountToSale = balances[tokenHolder];
        var tempAmount = _eth / currentTokenPrice;

        if (tempAmount > curAmountToSale) {
            changeWei = curAmountToSale * currentTokenPrice; 
            return curAmountToSale;
        }
        return tempAmount;
    } 

    /**
    * Function for sending tokens pledgers.
    * @param _reciver array of addresses of pre-customers.
    * @param _amountTokens array of balances for each of the pre-customers.
    */
    function payTokensPledgers(address[] _reciver, uint[] _amountTokens) onlyOwner public {
        require(_reciver.length == _amountTokens.length);
        
        for (uint i = 0; i < _reciver.length; i++) {
            _transfer(tokenHolder, _reciver[i], _amountTokens[i]);
            confirmHolder(_reciver[i]);
        }
    }

    function confirmHolder(address _buyer) private {
        if (isTokenHolder[_buyer] == false) { 
            isTokenHolder[_buyer] = true;
            addressHolders.push(_buyer);
            countOfHolders++;
        }  
    }
 
    /**
    * Function for the migration of all tokens for a new contract.
    * @param _indxStart start position in the list of token holdes.
    * @param _indxLast last position in the list of token holders.
    */
    function setCountOfUserToMigrate(uint _indxStart, uint _indxLast) onlyOwner external { 
        lastMigratedUser = _indxLast;

        uint start = _indxStart - 1;
        uint last = _indxLast - 1;

        require(start >= 0 && start <= last);
        require(_indxLast - _indxStart < countOfHolders);
        require(last <= addressHolders.length);
        
        for (uint i = start; i <= last; i++) {
            migrate(addressHolders[i]);
            countOfHolders--;
        } 
    }
    /**
    * Function for for migrating each individual user. 
    * @param _who address of user with the tokens.
    */
    function migrate(address _who) onlyOwner public { 
        require(migrationAgent != 0);
        var value = balances[_who];
        balances[_who] = 0; 
        totalMigrated += value;
        MigrationAgent(migrationAgent).migrateFrom(_who, value);
        Migrate(_who, migrationAgent, value);
    }

    /**
    * Function for setting the address of a new contract.
    * @param _agent address of new contract.
    */
    function setMigrationAgent(address _agent) onlyOwner external { 
        migrationAgent = _agent;
    } 

    /**
    * Constant function for counting the amount of the token purchased on the ether.
    * @param _eth amount of ether.
    * @return number of tokens you can buy.
    */
    function convertEtherToToken(uint256 _eth) constant public returns (uint) {
        uint weiEther = _eth * 1 ether; 
        uint amount = getAmountTokens(weiEther);   
        return amount;
    } 
}
//------------------------------------------------------------------------
//-----------Powered-by-illuminates.org-----------------------------------
//------------------------------------------------------------------------