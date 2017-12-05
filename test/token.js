var Token = artifacts.require("./Token.sol");
const assertJump = require('./assertJump.js');

contract ('Token', function(accounts) {
    let instance;

    describe('Test_contract_with_global_instance. 1st scenarios', function() {
        it('Cant buy tokens before active preICO', async () => {
            instance = await Token.new(accounts[8], accounts[9]);

            let val = await web3.toWei('1', 'ether');
            try {
                await instance.buyTokens({from: accounts[1], value: val});
                assert.fail('should have thrown before');
            } catch (error) {
                assertJump(error); 
            }
        });

        it('Should correctly transfer peledgers tokens', async () => {
            await instance.payTokensPledgers([accounts[1], accounts[2]], [42066600, 24488066]);

            let acc1Balance = await instance.balanceOf(accounts[1]);
            let acc2Balance = await instance.balanceOf(accounts[2]);
            
            assert.equal(acc1Balance, 42066600);
            assert.equal(acc2Balance, 24488066);
        });

        it('Should set true counting Holders & balance contract after payment pledgers', async () => {
            let countHolders = await instance.countOfHolders(); 
            let contractBalance = await instance.balanceOf(accounts[9]); 
 
            assert.equal(countHolders, 2);
            assert.equal(contractBalance.toNumber(), 933445334);
        });

        it('totalSupply must be 10000000.00', async () => {
            let totalTokens = await instance.totalSupply();
            assert.equal(totalTokens, 1000000000);
        }); 

        it('Should correctly accrue tokens bougth on 1 ether', async () => {
            await instance.setStagePreICO(true); 
            let val = web3.toWei('1', 'ether'); 
            await instance.buyTokens({from: accounts[3], value: val});
            let acc3Balance = await instance.balanceOf(accounts[3]);
             
            assert.equal(acc3Balance.toNumber(), 150000);
        });  

        it('Should correctly give tokens after change etherRate', async () => { 
            await instance.setEtherExchangeRate(150);
            let val = web3.toWei('1', 'ether'); 
            await instance.buyTokens({from: accounts[4], value: val});
            let acc3Balance = await instance.balanceOf(accounts[4]);
             
            assert.equal(acc3Balance.toNumber(), 75000);
        });  
    });
 
    describe('Test_contract_with_local_instance', function() {
        let token;

        beforeEach( () => {
            return Token.new(accounts[8], accounts[9])
            .then(function(_instance) {
               token = _instance;
               token.setStagePreICO(true);
            });
         });

         it('Money for tokens gives ownerAddress (CHANGE ADDRESS TO OWNER!)', async () => {
            let val = await web3.toWei('20', 'ether');  

            await token.buyTokens({from: accounts[1], value: val}); 
            let weiBal = web3.eth.getBalance(accounts[8]);
            let etherBal = parseInt(web3.fromWei(weiBal, 'ether')); 
            
            assert.equal(etherBal, 122);
        });
 
        it('Should correctly recive change ether', async () => {
            await token.payTokensPledgers([accounts[1]], [999700000]);  

            let val = await web3.toWei('6', 'ether');
            await token.buyTokens({from: accounts[7], value: val});
        
            let acc7_Tokens = await token.balanceOf(accounts[7]);
        
            let balPerWei = web3.eth.getBalance(accounts[7]); 
            let ether = parseInt(web3.fromWei(balPerWei, 'ether'));   

            assert.equal(acc7_Tokens.toNumber(), 300000);
            assert.equal(ether, 97); 
        });

        it('Should correctly counting Holders', async () => {
            await token.payTokensPledgers([accounts[1]], [554666]);  
            let val = await web3.toWei('1', 'ether');
            await token.buyTokens({from: accounts[2], value: val});
            await token.payTokensPledgers([accounts[3]], [554666]);  
            let val2 = await web3.toWei('1', 'ether');
            await token.buyTokens({from: accounts[4], value: val2});
            await token.payTokensPledgers([accounts[5]], [554666]);  
            await token.payTokensPledgers([accounts[6]], [554666]);  
            await token.payTokensPledgers([accounts[7]], [554666]);  
            await token.payTokensPledgers([accounts[8]], [554666]);  
            await token.payTokensPledgers([accounts[9]], [554666]);  
            await token.payTokensPledgers([accounts[9]], [554666]);  
            await token.payTokensPledgers([accounts[9]], [554666]);  
            await token.payTokensPledgers([accounts[9]], [554666]);  
            
            let holders = await token.countOfHolders();
            assert.equal(holders, 9);
        }); 

        it('should throw an error when trying to transfer more than balance', async () => { 
            try {
                await token.payTokensPledgers([accounts[1]], [1200000000]);   
                assert.fail('should have thrown before');
            } catch (error) {
                assertJump(error); 
            } 
        });
 
        it('can buy tokens only on ether_value > 0', async () => { 
            let val0 = await web3.toWei('0', 'ether');
            let valmin1 = await web3.toWei('-1', 'ether');
            try {
                await token.buyTokens({from: accounts[1], value: val0});
                assert.fail('should have thrown before');
            } catch (error) {
                assertJump(error); 
            }
            try {
                await token.buyTokens({from: accounts[1], value: valmin1});
                assert.fail('should have thrown before');
            } catch (error) {
                assertJump(error); 
            } 
        });

        it('Cant buy less than 1 token', async () => {
            let etherVal = await web3.toWei('0.0001', 'ether');
            try {
                await token.buyTokens({from: accounts[1], value: etherVal});                
                assert.fail('should have thrown before');
            } catch (error) {
                assertJump(error); 
            } 
           
            let acc1_balance = await token.balanceOf(accounts[1]);
            assert.equal(acc1_balance.toNumber(), 0);
        }); 

        it('Should throw an error when trying to finalize ICO when it Go', async () => {
            try {
                await token.finalizePreICO();
                assert.fail('should have thrown before');
            } catch (error) {
                assertJump(error); 
            }
        });

        it('after ICO all left tokens are burn', async () => {
            await token.setStagePreICO(false);
            await token.finalizePreICO();
            let contractBalance = await token.balanceOf(accounts[9]);

            assert.equal(contractBalance, 0);
        });
    });

    describe('Test_onlyOwner_modifier', function() {
        let token;

        beforeEach( () => {
            return Token.new(accounts[8], accounts[9])
            .then(function(instance) {
               token = instance;
               token.setStagePreICO(true);
            });
         });

        it('Only owner can change stageICO', async () => {
            try {
                await token.setStagePreICO(true, {from: accounts[1]});
                assert.fail('should have thrown before');
            } catch (error) {
                assertJump(error); 
            } 
            await token.setStagePreICO(true, {from: accounts[0]});
            let goICO = await token.isGoICO();
            assert.equal(goICO, true);
        });

        it('Only owner can trasfer token on preICO', async () => {
            await token.payTokensPledgers([accounts[0]], [200]);
            await token.transfer(accounts[1], 200, {from: accounts[0]});
            let acc1Tokens = await token.balanceOf(accounts[1]);
            assert.equal(acc1Tokens, 200);

            try {
                await token.transfer(accounts[2], 100, {from: accounts[1]});
                assert.fail('should have thrown before');
            } catch (error) {
                assertJump(error); 
            } 
        });
 

        it('Only owner can change rate', async () => {
            try {
                await token.setEtherExchangeRate(420, {from: accounts[1]});
                assert.fail('should have thrown before');
            } catch (error) {
                assertJump(error); 
            } 
            await token.setEtherExchangeRate(420, {from: accounts[0]});
            let curRate = await token.rate();
            assert.equal(curRate, 420);
        });

        it('Only owner can pay tokens pledgers', async () => {
            try {
                await token.payTokensPledgers([accounts[3]], [554666], {from: accounts[1]});  
                assert.fail('should have thrown before');
            } catch (error) {
                assertJump(error); 
            }  
        });

        it('Only owner can set migrationAgent', async () => {
            try {
                await token.setMigrationAgent(accounts[2], {from: accounts[1]});
                assert.fail('should have thrown before');
            } catch (error) {
                assertJump(error); 
            } 
            await token.setMigrationAgent(accounts[2], {from: accounts[0]});
            let agentContractAddress = await token.migrationAgent();
            assert.equal(agentContractAddress, accounts[2]);
        });

        it('Only owner can set count of users to migrate', async () => {
            try {
                await token.setCountOfUserToMigrate(2, 3, {from: accounts[1]});  
                assert.fail('should have thrown before');
            } catch (error) {
                assertJump(error); 
            }  
        });
    }); 
}); 