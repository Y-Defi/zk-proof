# Aril ZK Proof System

A zero-knowledge proof system for Aril transparency and trust, enabling cryptographic verification of exchange account control, fund traceability, risk neutrality, and return rates without revealing sensitive information.

## Project Overview

This project implements a suite of zero-knowledge proofs that solve critical trust problems in Aril:

1. **Proof of Account Control**: Prove control of a valid CEX account with non-zero balance without revealing account ID or API key
2. **Proof of Fund Traceability**: Verify that exchange account assets match on-chain vault deposits with clear traceability
3. **Proof of Risk Neutrality**: Demonstrate that the portfolio maintains market neutrality (Delta ≈ 0)
4. **Proof of Actual Return Rate**: Verify that the strategy achieves promised benchmark returns

## Current MVP Implementation

The current MVP focuses on the **Proof of Account Control** circuit, which:

- Uses HMAC-SHA256 to verify control of valid API credentials
- Proves a non-zero balance exists without revealing the actual amount
- Keeps account ID and API key private while proving their validity
- Provides a timestamp-based snapshot of account state

### Tech Stack

- **Circuit Language**: [Noir](https://noir-lang.org/) (readable, prover-friendly, with SHA256 support)
- **Proving System**: `nargo` CLI and/or `@noir-lang/noir_js` + `@noir-lang/barretenberg` for Node integration
- **Data Preparation**: Node.js script for input preparation and proof generation

## Project Structure
/
├── Nargo.toml             # Noir package configuration
├── README.md              # This documentation
├── scripts/
│   └── prove_account.ts   # Node.js script for proof generation
└── src/
├── main.nr            # Main circuit (Account Control)
├── utils.nr           # Utility functions (HMAC, byte operations)
└── lib/               # Additional proof circuits (scaffolded)
├── fund_trace.nr      # Fund traceability proof (scaffold)
├── risk_neutrality.nr # Risk neutrality proof (scaffold)
└── return_rate.nr     # Return rate proof (scaffold)


## Getting Started

### Prerequisites

- [Noir](https://noir-lang.org/) (install via noirup)
- Node.js and npm

### Installation

```bash
# Install Noir
curl -L https://raw.githubusercontent.com/noir-lang/noirup/master/noirup/install | bash
noirup

# Install Node.js dependencies
npm init -y
npm install @noir-lang/noir_js @noir-lang/barretenberg
```

### Usage

1. Compile the circuit:
```bash
nargo compile
```

2. Generate a proof:
```bash
node scripts/prove_account.ts
```

## What We've Done

- ✅ Implemented the core Proof of Account Control circuit using Noir
- ✅ Created HMAC-SHA256 implementation for signature verification
- ✅ Developed a Node.js script for proof generation and verification
- ✅ Scaffolded the architecture for all four proof types
- ✅ Designed a system that keeps sensitive information private while proving key properties

## What's Next

- 📅 **Fund Traceability**: Implement Merkle-based commitments for scalable transaction history
- 📅 **On-chain Integration**: Connect with Vault deposit/withdrawal events
- 📅 **Risk Neutrality**: Integrate with Pyth Network for decentralized price oracles
- 📅 **Return Rate Verification**: Implement time-weighted performance calculations
- 📅 **User Interface**: Create a dashboard for proof generation and verification
- 📅 **Smart Contracts**: Deploy verification contracts to mainnet
- 📅 **Automated Proofs**: Set up periodic proof generation for continuous transparency

## Technical Details

The Account Control proof works by:
1. Taking a timestamp, exchange ID, and signature as public inputs
2. Keeping API key, account ID, and balance as private inputs
3. Computing HMAC-SHA256 inside the circuit to verify signature validity
4. Asserting balance > 0 without revealing the actual value
5. Publishing only a hash commitment of the account ID

This allows third parties to verify that:
- We control valid exchange credentials
- The account has a non-zero balance
- The proof is for a specific exchange at a specific time

All without revealing any sensitive information.