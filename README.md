# MyCitadel Wallet

Mobile & desktop wallet for Apple Darwin platforms (iOS, iPadOS, macOS) supporting:
- Bitcoin descriptor-based wallets with private keys stored in Apple hardware secure enclave
- [RGB](https://rgbfaq.com): bitcoin & lightning client-validated smart contracts
- Multisignature & miniscript-based spending policies (WIP)
- Taproot & Schnorr signatures (WIP)
- Lightning network, including RGB-over-lightning payments (WIP)

The wallet is using [MyCitadel Node](https://github.com/mycitadel/mycitadel-node) backend, either as an embedded
library & runtime, or as an externally hosted service (personal or enterprise server).

MyCitadel is a consumer-facing apps & products based on [LNP/BP Association](https://github.com/LNP-BP) open-source 
libraries for:
- [client-side-validation](https://github.com/LNP-BP/rust-lnpbp), RGB(https://github.com/rgb-org),
- LNP ([lightning network protocol](https://github.com/LNP-BP/lnp-core) and [rust node](https://github.com/LNP-BP/lnp-node)),
- [descriptor wallets](https://github.com/LNP-BP/descriptor-wallet)
- [Internet2](https://github.com/internet2-org/rust-internet2) focusing on end-to-end-encrypted peer-to-peer 
  microservice architectures
  
It is also heavily uses [rust-bitcoin](https://github.com/rust-bitcoin/) community libraries:
- [rust-bitcoin](https://github.com/rust-bitcoin/rust-bitcoin)
- [rust-miniscript](https://github.com/rust-bitcoin/rust-miniscript)

## Screenshots

### General

![](Docs/Assets/ipad01.png)
![](Docs/Assets/ipad02.png)
![](Docs/Assets/ipad03.png)
![](Docs/Assets/ipad04.png)
![](Docs/Assets/ipad05.png)
![](Docs/Assets/ipad06.png)

### Invoicing

![](Docs/Assets/invoice01.png)
![](Docs/Assets/invoice02.png)
![](Docs/Assets/invoice03.png)

### Payments

![](Docs/Assets/payment01.png)
![](Docs/Assets/payment02.png)
![](Docs/Assets/payment03.png)

### Payment acceptance

![](Docs/Assets/accept01.png)
![](Docs/Assets/accept02.png)

### Tool for bitcoin hackers

![](Docs/Assets/internals01.png)
![](Docs/Assets/internals02.png)
![](Docs/Assets/internals03.png)
![](Docs/Assets/internals04.png)
![](Docs/Assets/internals05.png)
![](Docs/Assets/internals06.png)
![](Docs/Assets/internals07.png)
