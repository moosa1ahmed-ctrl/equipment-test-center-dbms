# Smart Parking: Optimization vs. Reinforcement Learning

CP468 – Artificial Intelligence | Fall 2025 | AI Term Project, Group Project

## Table of Contents
- [Project Overview](#project-overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Team Members](#team-members)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Running the Notebooks](#running-the-notebooks)
- [Problem Setup](#problem-setup)
- [Algorithm Reference](#algorithm-reference)
- [Test Scenarios](#test-scenarios)
- [Testing](#testing)
- [Results](#results)
- [Known Issues / Limitations](#known-issues--limitations)
- [Project Management](#project-management)
- [License](#license)

## Project Overview
A driver navigating toward a destination must pick a parking lot from several nearby options, but travel time, lot availability, and cost all shift while they're still en route. This project models that as a graph search / sequential decision problem and compares two solution strategies for choosing — and updating — that decision on the fly: a direct graph-search optimization, and a reinforcement learning agent that learns the same behaviour through trial and error.

**In Scope:**
- Graph-based road network and parking-lot model
- Dijkstra + hill-climbing optimization solver
- Q-learning reinforcement learning solver
- Comparison across 3 constraint scenarios (baseline, distance-constrained, availability-constrained)
- IEEE-format written report

**Out of Scope:**
- Real-world map/traffic data integration
- Live/production deployment
- More than 2 candidate parking lots
- UI or visualization beyond notebook output

## Features

**Must Have**
- Working Dijkstra + hill-climbing solver ([`Optimization.ipynb`](notebooks/Optimization.ipynb))
- Working Q-learning solver ([`Reinforcement_Learning.ipynb`](notebooks/Reinforcement_Learning.ipynb))
- Shared objective function (travel time + cost + walking distance, subject to availability/max-walk constraints)
- Comparison across 3 test scenarios, logged to [`results/Results.xlsx`](results/Results.xlsx)
- Full IEEE-format writeup

**Should Have**
- Hyperparameter documentation for the RL agent (learning rate, discount factor, exploration rate)

**Could Have (Stretch Goals)**
- Additional parking lots / more complex graph
- Dynamic re-routing mid-trip in response to changing conditions
- Live traffic or pricing data instead of static in-notebook scenarios

## Technology Stack
| Layer | Technology |
|---|---|
| Language | Python 3 |
| Environment | Jupyter Notebook |
| Algorithms | Dijkstra's algorithm, hill climbing, Q-learning |
| Data / Results | pandas, Excel (`Results.xlsx`) |
| Version Control | Git, GitHub |

## Team Members
| Name |
|---|
| Moosa Ahmed |
| Lucas Matheson |
| Bhavnoor Dhillon |
| Reilly MacDonald |

## Repository Structure
```
smart-parking-optimization-rl/
├── README.md
├── requirements.txt
├── notebooks/
│   ├── Optimization.ipynb
│   └── Reinforcement_Learning.ipynb
├── results/
│   └── Results.xlsx
└── docs/
    └── CP468-TP-35-writeup.pdf   ← full IEEE-format writeup
```

## Getting Started

### Prerequisites
- Python 3
- Jupyter Notebook or JupyterLab

### Running the Notebooks
```bash
git clone https://github.com/moosa1ahmed-ctrl/smart-parking-optimization-r1.git
cd smart-parking-optimization-r1
pip install -r requirements.txt
jupyter notebook notebooks/
```
Each notebook runs independently — no external data files needed, the road network and parking-lot scenarios are defined in-notebook.

## Problem Setup
A small directed road graph (`S → A/B → C → P1/P2 → D`) where edge weights are travel times, and two candidate parking lots (`P1`, `P2`) each have a cost, a walking distance from the lot to the destination, an availability flag, and a maximum-walk constraint.

**Shared objective, both approaches solve this:**
```
minimize:  travel_time + α · parking_cost + β · walking_distance
subject to: lot must be available, and walking_distance ≤ max_walk
```

## Algorithm Reference

### Optimization ([`Optimization.ipynb`](notebooks/Optimization.ipynb))
1. Run Dijkstra from the start node `S` to get shortest travel time to every node.
2. For each parking lot, check feasibility (`available == True` and `walk_dist ≤ max_walk`).
3. Hill-climb over the feasible lots using the weighted objective above (`α = 1.0` for cost, `β = 0.01` for walking distance) to pick the single best lot.
4. Deterministic and instant — recomputed from scratch whenever conditions change.

### Reinforcement Learning ([`Reinforcement_Learning.ipynb`](notebooks/Reinforcement_Learning.ipynb))
Formulated as a Markov Decision Process:

| Element | Definition |
|---|---|
| States | Current node — `{S, A, B, C, P1, P2, TERMINAL}` |
| Actions | Move to an adjacent node, or `park` (only valid at P1/P2) |
| Reward | `-travel_time` per move; on `park`, `-(cost + β · walk_dist)` if the lot is available and within `max_walk`, otherwise a large penalty (`-1000`) for an invalid choice |
| Policy | ε-greedy during training (explore vs. exploit), greedy at evaluation |

**Hyperparameters**

| Hyperparameter | Value |
|---|---|
| Learning rate (α) | 0.1 |
| Discount factor (γ) | 0.9 |
| Exploration rate (ε) | 0.2 |
| Episodes | 5,000 |
| Walking-distance weight (β) | 0.01 |

## Test Scenarios
Run identically in both notebooks so results are directly comparable:

| # | Scenario | Expected behaviour |
|---|---|---|
| 1 | Baseline | Both lots feasible — agent should pick the better cost/distance trade-off |
| 2 | P2 too far | P2's walking distance exceeds `max_walk`, forcing P1 |
| 3 | P1 unavailable | P1 is marked unavailable, forcing P2 |

## Testing
Both notebooks were run end-to-end and manually verified: every code cell executes without errors, and every cell expected to produce output (test-case results, comparison tables) does so. There is no separate automated test suite — correctness is verified by inspecting notebook output against the expected behaviour in the table above.

## Results
Comparison metrics — cost, adaptability, and convergence across the three scenarios — are in [`results/Results.xlsx`](results/Results.xlsx). Full analysis is in the writeup (see below).

## Known Issues / Limitations
- Fixed to a 2-lot, 7-node graph — does not generalize to arbitrary graph sizes without code changes.
- RL agent is retrained from scratch per scenario rather than adapting online to a changing environment.

## Project Management
GitHub Kanban Board: *not yet set up*
Wiki: *not yet set up*

Full writeup: [`docs/CP468-TP-35-writeup.pdf`](docs/CP468-TP-35-writeup.pdf) — literature review, system model, methodology, and full results analysis.

## License
This project was developed as part of the CP468 – Artificial Intelligence course at Wilfrid Laurier University (WLU), Fall 2025. It is intended solely for academic evaluation purposes.
