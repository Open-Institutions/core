# Open-Institutions : empower the people

With smart-contract technology, it's the first time in history that people can verify that the rules are followed by everyone without any third-party authority. Allowing people to create our own institutions (thus the system they live in) on the cloud that are efficient and less energy consuming than traditional state-based institutions while being resistant to censorship and DDoS attacks.

It's a true opportunity for human being to recover the control of our own lifes without waiting for the politics !


## Self-sovereign identity system powered by people

Self-Sovereign identity systems allow the individuals to own they identity and to not rely on a central system (that can deny their existence) by using a decentralized system that are resistant to censorship and DDoS attacks.

Identifying people and make sure identities are unique, is a basic requirement for any institution and are the first step toward universal basic income, referendum, social insurance, voting system etc.

However most current approach are based on complex state-of-the-art algorithms that are not familiar for the average user or not enoughly eprouved. Making them less trust-able for people that are don't know/understand how they works. We decided here to keep it simple by enforcing a randomly assigned roles based system to build a participatory democracy on the block-chain where the decisions are made by people not algorithms.

#### Building trust with participatory democracy

Inspired by the Athenian democracy, Open-Institutions aim to bring true democracy to people by making them part of the process. Every citizen can be randomly picked to do some work on the behalf of the institution. Basically in the identity system the work is to validate people identity and make sure they are unique.

#### Role-based approach

- Citizens are the validated people, they control Validators
- Validators are citizens randomly picked to validate others people/citizens

#### Daily automated assignement

In this role-based system, the key component is the assignement procedure that is done every day. Each day, if the system need more validators or controllers, citizens are picked. To avoid high fee only one validator and one controller can be picked each day. We ensure the fairness of that behavior by randomly pick citizens.

#### Randomly picked citizen

The random picking is done every day by sending a query to an oracle, an oracle is a system that provide external data to blockchains. It is used here to provide true randomness in a secure way, the oracle generate random bytes that are then used to pick citizens (see used technologies for more details).

#### An ERC721 token as Identity card

By following the ERC721 standards we provide identity cards on the block-chain that benefit from functonalities like wallets, meta-data field etc.

This design choice allow also people to vote on the behalf of someone else, by transfering the token. To garanty that we can always recover our identity, the signer can get back his identity card at any time.

#### Validation flexibility

This design approach enable the community to create their own validation procedure by using external tools, to communicate or help the descision. Because the system is agnostic of the way validators verify the identity of people, the community can aggree and enhance how they include new people in the system over time. This procedure can benefit from a wide range of software, from video-based discussion to face recognition.

#### Personnal data

Personnal data are not stored on the blockchain, but are instead stored in an separate system which is accessible throught the meta-data URI of the identity card.

### Used technologies

- [Ethereum](https://www.ethereum.org/) : The blockchain used to power the smart-contracts
- [Solidity](https://solidity.readthedocs.io/en/v0.4.24/) : A Javascript inspired language to program smart-contracts
- [Oraclize](http://www.oraclize.it/) : An oracle to provide true randomness and scheduling in the future for smart-contracts
- [Open-zeppelin](https://openzeppelin.org/api/docs/open-zeppelin.html) : A framework to write secure Solidity smart-contracts
- [Truffle](https://www.truffleframework.com/) : A package manager to manage the compilation/test and deployment of smart-contracts
- [Web3](https://github.com/ethereum/web3.js/) : To interact with the Ethereum blockchain (thus the smart-contracts) with Javascript
