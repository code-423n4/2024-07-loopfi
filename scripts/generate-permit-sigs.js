const ethUtil = require('ethereumjs-util');
const sigUtil = require('eth-sig-util');
const utils = sigUtil.TypedDataUtils;

// Sender sends 2 Stablecoin to Receiver
const senderPrivKeyHex = '9e99449797b670840f53a749df174a19772bcd4c6b52e976ab139812d4646f0a'
const senderPrivKey = new Buffer.from(senderPrivKeyHex, 'hex')
const sender = ethUtil.privateToAddress(senderPrivKey);
const receiver = new Buffer.from('0D1d31abea2384b0D5add552E3a9b9F66d57e141', 'hex');
// const stablecoin = new Buffer.from('0x0bA14c5a7c7EB53793076a4722Cb0939a235Ac31', 'hex');
console.log('senders address: ' + '0x' + sender.toString('hex'));
console.log('receivers address: ' + '0x' + receiver.toString('hex'));
let typedData = {
    types: {
        EIP712Domain: [
            { name: 'name', type: 'string' },
            { name: 'version', type: 'string' },
            { name: 'chainId', type: 'uint256' },
            { name: 'verifyingContract', type: 'address' }
        ],
        Permit: [
            { name: 'owner', type: 'address' },
            { name: 'spender', type: 'address' },
            { name: 'value', type: 'uint256' },
            { name: 'nonce', type: 'uint256' },
            { name: 'deadline', type: 'uint256' }
        ],
    },
    primaryType: 'Permit',
    domain: {
        name: 'Stablecoin',
        version: '1',
        chainId: '99',
        verifyingContract: '0x0bA14c5a7c7EB53793076a4722Cb0939a235Ac31', // in hevm
    },
    message: {
        owner: '0x' + sender.toString('hex'),
        spender: '0x' + receiver.toString('hex'),
        value: '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
        nonce: 0,
        deadline: '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
        // deadline: '0x2406a350' // 604411200 + 3600
    },
};

let hash = ethUtil.bufferToHex(utils.hashStruct('EIP712Domain', typedData.domain, typedData.types))
console.log('EIP712DomainHash: ' + hash);
hash = ethUtil.bufferToHex(utils.hashType('Permit', typedData.types))
console.log('Permit Typehash: ' + hash);
hash = ethUtil.bufferToHex(utils.hashStruct('Permit', typedData.message, typedData.types))
console.log('Permit (from sender to receiver) hash: ' + hash);
const sig = sigUtil.signTypedData(senderPrivKey, { data: typedData });
console.log('signed permit: ' + sig);

let r = sig.slice(0,66);
let s = '0x'+ sig.slice(66,130);
let v = ethUtil.bufferToInt(ethUtil.toBuffer('0x'+sig.slice(130,132),'hex'));

console.log('r: ' + r)
console.log('s: ' + s)
console.log('v: ' + v)
