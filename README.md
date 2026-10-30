# CivicLedger

> **[Open the live demo →](https://tejaswikharade.github.io/civic-ledger/)**

A small, transparent governance primitive for neighbourhood and civic initiatives. Anyone can publish a proposal, each address can vote once, and proposals can be finalized after a fixed voting window.

## What is included

- `src/CivicLedger.sol` — lightweight Solidity governance contract
- `test/CivicLedger.t.sol` — Foundry tests for proposal, voting, and execution flows
- `web/` — Vite + React landing page in a warm paper / civic blue visual system

## Run it

```bash
forge test
cd web && npm install && npm run dev
```

> This is an educational prototype. It does not transfer funds or perform on-chain actions when a proposal is executed; execution records the final approved result.
