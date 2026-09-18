# Election Transparency — Prototype and Performance Evaluation

This repository contains the prototype and the reproducibility scripts for the paper:

> L. Kimura, G. Fumagali, Y. R. Venturini, M. A. Simplicio Jr. **Election Transparency: Improving Post-election Auditability with Transparency Logs.** . [Link to article]

Election Transparency is an ecosystem for registering, publishing and collaboratively verifying electoral data using **transparency logs** (append-only Merkle trees). Its goal is not to verify voting machines, but to make any alteration, omission or equivocation of electoral data *after* it leaves the voting machines detectable by any interested party — even when the Election Authority itself is under suspicion.

The scripts here reproduce the two experiments reported in the paper:

| Experiment | Paper | What it measures |
|---|---|---|
| Operations performance | Table II | Inclusion proof, consistency proof and tree rebuild times for local trees of 1K to 1M leaves |
| 2022 Brazilian elections | Table III, Fig. 8 | Download, verification, pre-processing and independent tally of all 472,027 poll tapes (772 MB) from the 2022 Brazilian general election |

## Repository structure

```
access/
├── logserver/                        # Log Server (TLManager, Backend, Frontend), via Docker Compose
│   ├── populate_operation_performance/   # Builds synthetic trees for Table II
│   └── populate_2022_election/           # Inserts the 2022 poll tapes for Table III
├── client/                           # Verifier / Monitor / Auditor scripts (TLverifier, TLScripts)
│   ├── test_verifications.py             # Table II measurements
│   ├── test_analysis.py                  # Table III measurements
│   └── calculate_2022_results.py         # Independent tally of the 2022 presidential election
└── setup.sh                          # Installs dependencies
```

The Log Server stores the electoral data and maintains the transparency logs (one *local tree* per data type plus a *global tree* of local roots). The client scripts play the roles of Verifier (inclusion proofs), Monitor (consistency proofs) and Auditor (tree rebuild and independent tally), as described in Sections IV and VI of the paper.

## Requirements

Two Ubuntu machines are recommended, so that network transfer between Log Server and client is accounted for as in the paper. A single machine also works for the demo.

- **Log Server** — tested on DigitalOcean Premium AMD, 2 vCPU, 8 GB RAM, Ubuntu 22.04 LTS, Docker 27.3.1, Python 3.10.12
- **Client** — tested on Intel Xeon Platinum 8168, 2 vCPU, 4 GB RAM, Ubuntu 22.04 LTS, Docker 27.3.1, Python 3.10.12

These configurations were deliberately modest: the paper's claim is that any interested party can act as Verifier or Monitor on a commodity computer.

## Setup

On each machine, clone the repository and install the dependencies:

```bash
git clone https://github.com/larc-logs-transparentes/access.git
cd access
bash ./setup.sh
```

## Quick demo

Starts all Election Transparency modules and populates them with 74 poll tapes from the 2022 Brazilian election. The web interface is served at `http://localhost:3000` and talks to the backend on port `8080`.

```bash
cd logserver
docker compose up -d
sleep 10
docker run --rm --network host --pull always ghcr.io/larc-logs-transparentes/bu-utils:gh-73
```

In the interface, search for a polling station and open a poll tape; the check mark on the top right indicates that its inclusion proof was verified client-side (Fig. 8a in the paper).

## Experiment 1 — Operations performance (Table II)

Measures inclusion verification, consistency verification and tree rebuild for local trees of 1K, 10K, 100K, 500K and 1M leaves, with the global tree sized as `m = n / 2048`.

**Log Server** — builds the five trees. Takes ~2 h on the tested environment.

```bash
cd logserver
docker compose up -d
sleep 10

cd populate_operation_performance
bash ./start.sh
```

**Client** — run on the other machine after all trees have been created. With 50 samples, takes ~50 min.

```bash
cd access/
source .venv/bin/activate

cd client
LOGSERVER_IP=<LOGSERVER-IP> python3 test_verifications.py --sample_size=50
```

Expected results (median; see paper for details):

| Local tree | Verify inclusion | Verify consistency | Rebuild tree |
|---|---|---|---|
| 1K | 0.11 ms | 14 ms | 0.02 s |
| 10K | 0.11 ms | 14 ms | 0.22 s |
| 100K | 0.12 ms | 15 ms | 2.9 s |
| 500K | 0.12 ms | 24 ms | 17 s |
| 1M | 0.12 ms | 43 ms | 36 s |

## Experiment 2 — 2022 Brazilian general election (Table III)

Inserts all poll tapes published by the Brazilian election authority for the 2022 general election, then measures the four steps of the Auditor procedure (download, verify, pre-process, tally) and recomputes the presidential result.

**Log Server** — inserts the ~472K poll tapes. Takes ~18 h on the tested environment.

```bash
# Reset docker compose state
cd logserver
docker compose down
docker compose up -d
sleep 10

cd populate_2022_election
bash ./start.sh
```

**Client** — run on the other machine after all poll tapes have been inserted. With 50 samples, takes ~5 h.

```bash
cd access/
source .venv/bin/activate

cd client
LOGSERVER_IP=<LOGSERVER-IP> python3 test_analysis.py --sample_size=50
```

Expected results (median): download 1.7 min · verify 25 s · pre-process 3.4 min · tally 31 s.

**Independent tally** — prints the recomputed results of the 2022 presidential election (Fig. 8b). Takes ~10 min.

```bash
LOGSERVER_IP=<LOGSERVER-IP> python3 calculate_2022_results.py
```

The output should match the official results published by the TSE. Note that this reproduces the *tabulation* stage from the published poll tapes; it does not, and is not meant to, attest to the correctness of the poll tapes themselves (see Section VI-B of the paper).

## Data source

Poll tapes (*Boletins de Urna*) are downloaded from the TSE open data portal: https://dadosabertos.tse.jus.br/

## Acknowledgments

This work was supported in part by Ripple's University Blockchain Research Initiative; CNPq (grant 307732/2023-1); CAPES (Finance Code 001); and FAPESP (grants 2021/00199-8 and 2024/06106-0).
