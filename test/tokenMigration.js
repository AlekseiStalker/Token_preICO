var Token = artifacts.require("./Token.sol");
var GolemNetworkToken = artifacts.require("./GolemNetworkToken");
const assertJump = require('./assertJump.js');

contract ('Token', function(accounts) { 
    describe('Test_migration', function() {
        let instance;
        let agent;
        
        it('Should correctly count holders', async () => {
            instance = await Token.new(accounts[8], accounts[9]);
            await instance.setStagePreICO(true);
    
            await instance.payTokensPledgers([accounts[1]], [50000]);  
            let val = await web3.toWei('1', 'ether');
            await instance.buyTokens({from: accounts[2], value: val});//300 -> 150000
            await instance.payTokensPledgers([accounts[3]], [550000]);  
            let val2 = await web3.toWei('1', 'ether');
            await instance.buyTokens({from: accounts[4], value: val2});
            await instance.payTokensPledgers([accounts[5]], [4200000]); 
            await instance.payTokensPledgers([accounts[6]], [4200000]); 
            await instance.payTokensPledgers([accounts[7]], [4200000]);  
            
            let countHolders = await instance.countOfHolders();
            assert.equal(countHolders, 7);
        });

        it('Should correctly set migration agent address', async () => { 
            agent = await GolemNetworkToken.new();
            await instance.setMigrationAgent(agent.address);
            let addressMigrationAgent = await instance.migrationAgent();
            assert.equal(addressMigrationAgent, agent.address);
        });
    
        it('Should throw exception if set users to migrate start 0', async () => {
            try {
                await instance.setCountOfUserToMigrate(0, 9);  
                assert.fail('should have thrown before');  
            } catch (error) {
                assertJump(error); 
            }  
        });

        it('Cant migrate more users, than who holds token', async () => {
            try {
                await instance.setCountOfUserToMigrate(1, 11);  
                assert.fail('should have thrown before');  
            } catch (error) {
                assertJump(error); 
            } 
        }); 

        it('After finish preICO tokenCOunters inc+2', async () => {
            await instance.setStagePreICO(false);
            await instance.finalizePreICO(); 

            let countHolders = await instance.countOfHolders();
            assert.equal(countHolders, 9);
        });

        it('Should return correct balances team', async () => {
            let acc1Balance = await instance.balanceOf(accounts[8]);   
            assert.equal(acc1Balance.toNumber(), 2025000);
        });

        it('Should return 0 holders and correct totalMigrate tokens', async () => {  
            await instance.setCountOfUserToMigrate(1,3);
            await instance.setCountOfUserToMigrate(4,7);
            await instance.setCountOfUserToMigrate(8,8);
            await instance.setCountOfUserToMigrate(9,9);
    
            let totalMigrate = (await instance.totalMigrated()).toNumber();
            assert.equal(totalMigrate, 16200000);
    
            let countHolders = await instance.countOfHolders();
            assert.equal(countHolders, 0);
        }); 

        it ('Should be correct totalSupply & owner balances after migrate', async () => { 
             let newTokens = await agent.totalSupply(); 
             let amountTokenOwners = await agent.balanceOf(accounts[8]);

             assert.equal(newTokens, 16200000); 
             assert.equal(amountTokenOwners, 2025000);
        });
    
        it('Should return correct balance of all accounts', async () => {
            let acc1Balance = await agent.balanceOf(accounts[1]);  
            let acc2Balance = await agent.balanceOf(accounts[2]);
            let acc3Balance = await agent.balanceOf(accounts[3]);  
            let acc4Balance = await agent.balanceOf(accounts[4]);
            let acc5Balance = await agent.balanceOf(accounts[5]); 
            let acc6Balance = await agent.balanceOf(accounts[6]); 
            let acc7Balance = await agent.balanceOf(accounts[7]);  
     
            assert.equal(acc1Balance.toNumber(), 50000); 
            assert.equal(acc2Balance.toNumber(), 150000); 
            assert.equal(acc3Balance.toNumber(), 550000); 
            assert.equal(acc4Balance.toNumber(), 150000); 
            assert.equal(acc5Balance.toNumber(), 4200000); 
            assert.equal(acc6Balance.toNumber(), 4200000); 
            assert.equal(acc7Balance.toNumber(), 4200000);  
        }); 
    }); 
});