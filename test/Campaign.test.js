const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3')
const web3 = new Web3(ganache.provider());

const compileFactory = require('../ethereum/build/:CampaignFactory.json');
const compileCampaign = require('../ethereum/build/:Campaign.json');

let accounts;
let factory;
let campaign;
let campaignAddress;

beforeEach(async () => {
    accounts = await web3.eth.getAccounts();
    factory = await new web3.eth.Contract(JSON.parse(compileFactory.interface))
        .deploy({ data: compileFactory.bytecode })
        .send({ from: accounts[0], gas: '1000000' });
    await factory.methods.createCampaign('100').send({
        from: accounts[1],
        gas: "1000000",
    });

    [campaignAddress] = await factory.methods.getCampaigns().call();
    campaign = await new web3.eth.Contract(JSON.parse(compileCampaign.interface), campaignAddress);
});

describe('Kickstart test', async () => {
    it('deploy campaign and factory', async () => {
        const manager = await campaign.methods.manager().call();
        assert.ok(campaign.options.address);
        assert.equal(manager, accounts[1]);
    });

    it('process request', async () => {
        await campaign.methods.contribute().send({
            from: accounts[2],
            value: web3.utils.toWei('10', 'ether')
        });

        await campaign.methods.createRequest('Buy', web3.utils.toWei('5', 'ether'), accounts[3])
            .send({
                from: accounts[1],
                gas: '1000000'
            });

        await campaign.methods.approveRequest(0).send({
            from: accounts[2],
            gas: '1000000'
        });

        await campaign.methods.finalizeRequest(0).send({
            from: accounts[1],
            gas: '1000000'
        });

        let newBalance = await web3.eth.getBalance(accounts[3]);

        let balance = parseFloat(web3.utils.fromWei(
            newBalance,
            'ether'
        ));
        assert(balance > 104.9);
    });
})