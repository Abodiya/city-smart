# CityCert - Smart City Infrastructure Tracking

CityCert is a blockchain-powered smart city infrastructure tracking system. It ensures transparency, security, and accountability in managing and certifying city infrastructure components and inspections.

## Features
- **Infrastructure Component Management**: Register and track city infrastructure components.
- **Condition Monitoring**: Update and retrieve the condition history of components.
- **Inspection Management**: Allow approved agencies to add and verify inspections.
- **Security & Authorization**: Enforce role-based access control for city administrators and inspection agencies.

## Technologies Used
- **Clarity**: Smart contract programming language for the Stacks blockchain.
- **Stacks Blockchain**: Secure and decentralized infrastructure for storing infrastructure data.

## Smart Contract Overview
The CityCert smart contract provides the following functionalities:

### Traits
Defines a contract trait `city-infrastructure-trait` to standardize infrastructure tracking:
- `register-component(component-id, initial-condition)` - Registers a new infrastructure component.
- `update-component-condition(component-id, new-condition)` - Updates the condition of a component.
- `get-component-history(component-id)` - Retrieves the condition history of a component.
- `add-inspection(component-id, inspection-type)` - Records an inspection for a component.
- `verify-inspection(component-id, inspection-type)` - Verifies if an inspection has passed.

### Condition States
Infrastructure components have defined condition states:
- `CONDITION_NEW`
- `CONDITION_OPERATIONAL`
- `CONDITION_NEEDS_MAINTENANCE`
- `CONDITION_UNDER_REPAIR`

### Inspection Types
Approved inspection agencies can conduct different types of inspections:
- `INSPECTION_STRUCTURAL`
- `INSPECTION_ELECTRICAL`
- `INSPECTION_ENVIRONMENTAL`
- `INSPECTION_SAFETY`

### Key Smart Contract Functions
- **Component Management**:
  - `register-component(component-id, initial-condition)`
  - `update-component-condition(component-id, new-condition)`
  - `get-component-condition(component-id)`
  - `get-component-history(component-id)`
- **Inspection Management**:
  - `add-inspection(component-id, inspection-type)`
  - `fail-inspection(component-id, inspection-type)`
  - `verify-inspection(component-id, inspection-type)`
  - `get-inspection-details(component-id, inspection-type)`
- **Access Control & Admin Functions**:
  - `add-inspection-agency(agency, inspection-type)` - Registers an approved inspection agency.

## Installation & Deployment
### Prerequisites
- Install the [Stacks CLI](https://docs.hiro.so/get-started/stacks-cli)
- Setup a local Clarity environment

### Deploying the Contract
```bash
clarity check ./contracts/citycert.clar
clarity deploy ./contracts/citycert.clar --testnet
```

### Interacting with the Contract
Use Stacks CLI or a frontend integration to interact with CityCert.

## Contribution Guidelines
Contributions are welcome! Please follow these steps:
1. Fork the repository.
2. Create a feature branch (`feature-new-functionality`).
3. Commit your changes.
4. Open a pull request for review.

