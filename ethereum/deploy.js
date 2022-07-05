const HDWalletProvider = require('@truffle/hdwallet-provider');
const HDwallet = require('@truffle/hdwallet-provider');
const Web3 = require('web3');

const factory = require('./build/:CampaignFactory.json');

const provider = new HDWalletProvider(
    'afford cash ivory layer jeans monitor certain cargo grace cherry reopen task',
    'https://rinkeby.infura.io/v3/e6e513ed7fca42fba53cdfc24550c1a4'
);

const web3 = new Web3(provider);

const deploy = async () => {
    const accounts = await web3.eth.getAccounts();
    const result = await new web3.eth.Contract(
        JSON.parse(factory.interface)
    )
        .deploy({ data: factory.bytecode })
        .send({ from: accounts[0], gas: '1000000' });
    console.log('Deploy to: ', result.options.address);
};

deploy();