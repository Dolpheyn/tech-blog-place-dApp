# WavePortal dApp 👋

This project demonstrates a basic smart contract. It allows users to send
messages to a smart contract, and display it as some kind of a log. 

## __buildspace

This project is the result from following [buildspace](https://buildspace.so/)'s
hands on [course](https://buildspace.so/solidity) "Build a Web3 App on Ethereum
with Solidty + Smart Contracts". It's a free, high quality course and I
personally recommend everyone that wants to start learning how to develop dApps
to go and try out!

## Directory Structure

```
.
|-- contracts
|  |-- WavePortal.sol
|-- scripts
|  |-- run.js
|__ test
```

The `run.js` script will compile and deploy the smart contract using `Hardhat`.

## Learning Log

**2020-08-26 12:32**

Checkpoint - [d63bd3b](https://github.com/Dolpheyn/wave-portal-dApp/commit/d63bd3bb0e8346a23fc7d91b250514bcc49f3785)

-- Created a smart contract with a local state `totalWaves` and two methods, one
to mutate the state by incrementing it and another to access and return its
value.

The mutating method(similar to `POST` HTTP method, setter methods in Java or
methods that requires `mut self` in Rust) also accesses a global state that
every contracts have access to -- `msg`. We accessed the `msg.sender` variable
which holds the address of whoever that sends the transaction.

The global variables exist because when a function in our smart contract is
called/invoked, it's actually the blockchain that does it, and the blockchain
sends along the `calldata`, which is the metadata from the external function
call.

Here's how I picture it:
```
     (1)                              (2)
user ---------------------> blockhain ---------------> contract (addr - 0xfoo)
      "pls invoke function            "pls invoke `increment`,
       `increment` on contract         and here's what you
       with address 0xfoo"             need to know about this
                                       transaction (in `msg`)"
```

Note: The process in (2) is the one that requires the famous term `mining` or
`validating` (i think so). Without any stakeholders that validate your
transaction, the transaction wouldn't be made.

Along with `sender`, there's also other accessable variables in the `msg` global
variable:

- `data` -- immutable(you cannot change them), non-persistent(it will be gone
  after this transaction is done) area where function arguments are stored and
  behave mostly like memory.
- `gas` -- Available remaining gas.
- `sig` -- First for bytes of the calldata that tells which function to be
  called.
- `value` -- How much wei(a representation of eth) are you sending me?

The local state is however not persistent. It is created when `Hardhat` create
the contract locally and destroyed after it finished deploying and invoking the
two contract methods. In order to make it persistent, we need to deploy the
contract on-chain, whether on a testnet or the mainnet.
