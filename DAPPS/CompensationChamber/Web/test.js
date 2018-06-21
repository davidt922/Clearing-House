var solc = require('solc');
var input = "contract x { function g() {} }";
var output = solc.compile(input, 1); // 1 activates the optimiser
for (var contractName in output.contracts) {
    // code and ABI that are needed by web3
    console.log(contractName + ': ' + output.contracts[contractName].bytecode);
    console.log(contractName + '; ' + JSON.parse( output.contracts[contractName].interface));
}
