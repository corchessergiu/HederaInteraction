console.clear();
require("dotenv").config();
const {
    AccountId,
    PrivateKey,
    Client,
    FileCreateTransaction,
    ContractCreateTransaction,
    ContractFunctionParameters,
    ContractExecuteTransaction,
    ContractCallQuery,
    Hbar,
    ContractCreateFlow,
} = require("@hashgraph/sdk");
const fs = require("fs");

// Configure accounts and client
const operatorId = AccountId.fromString(process.env.OPERATOR_ID);
const operatorKey = PrivateKey.fromString(process.env.OPERATOR_PVKEY);

const client = Client.forTestnet().setOperator(operatorId, operatorKey);

async function main() {
    //BlackPass deploy

    // Import the compiled contract bytecode
    const contractBytecodeBlackPass = fs.readFileSync("BlackPass_sol_BlackPass.bin");

    // Instantiate the smart contract
    const contractInstantiateTxBlackPass = new ContractCreateFlow()
        .setBytecode(contractBytecodeBlackPass)
        .setGas(10000000)
        .setConstructorParameters(
            new ContractFunctionParameters().addString("BlackPassURI")
        );
    const contractInstantiateSubmitBlackPass = await contractInstantiateTxBlackPass.execute(client);
    const contractInstantiateRxBlackPass = await contractInstantiateSubmitBlackPass.getReceipt(client);
    const contractIdBlackPass = contractInstantiateRxBlackPass.contractId;
    const contractAddressBlackPass = contractIdBlackPass.toSolidityAddress();
    console.log(`- The smart contract ID for BlackPass is: ${contractIdBlackPass} \n`);
    console.log(`- The smart contract ID in Solidity format for BlackPass is: ${contractAddressBlackPass} \n`);

    //Stake Reward deploy
    //Import the compiled contract bytecode
    const contractBytecodeStakeReward = fs.readFileSync("StakeRewardNFT_sol_StakeRewardNFT.bin");

    // Instantiate the smart contract
    const contractInstantiateTxStakeReward = new ContractCreateFlow()
        .setBytecode(contractBytecodeStakeReward)
        .setGas(10000000)
        .setConstructorParameters(
            new ContractFunctionParameters().addString("StakeRewardURI")
        );
    const contractInstantiateSubmitStakeReward = await contractInstantiateTxStakeReward.execute(client);
    const contractInstantiateRxStakeReward = await contractInstantiateSubmitStakeReward.getReceipt(client);
    const contractIdStakeReward = contractInstantiateRxStakeReward.contractId;
    const contractAddressStakeReward = contractIdStakeReward.toSolidityAddress();
    console.log(`- The smart contract ID for StakeReward is: ${contractIdStakeReward} \n`);
    console.log(`- The smart contract ID in Solidity format for StakeReward is: ${contractAddressStakeReward} \n`);

    //Stake deploy
    // Import the compiled contract bytecode

    const contractBytecodeStake = fs.readFileSync("DeviantsStake_sol_DeviantsStake.bin");

    // Instantiate the smart contract
    const contractInstantiateTxStake = new ContractCreateFlow()
        .setBytecode(contractBytecodeStake)
        .setGas(10000000)
        .setConstructorParameters(
            new ContractFunctionParameters().addAddress(contractAddressBlackPass).addAddress(contractAddressStakeReward)
        );
    const contractInstantiateSubmitStake = await contractInstantiateTxStake.execute(client);
    const contractInstantiateRxStake = await contractInstantiateSubmitStake.getReceipt(client);
    const contractIdStake = contractInstantiateRxStake.contractId;
    const contractAddressStake = contractIdStake.toSolidityAddress();
    console.log(`- The smart contract ID for Stake is: ${contractIdStake} \n`);
    console.log(`- The smart contract ID in Solidity format for Stake is: ${contractAddressStake} \n`);

}
main();