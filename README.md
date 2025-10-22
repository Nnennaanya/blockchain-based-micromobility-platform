# Blockchain-Based Micromobility Platform

## Overview

A decentralized platform to manage scooters, bikes, and other micromobility vehicles, including rentals, usage tracking, and maintenance. This system leverages blockchain technology to provide transparent, secure, and efficient management of shared mobility resources.

## Features

### Vehicle Registry
- Register micromobility vehicles on-chain
- Track ownership and operator information
- Maintain vehicle specifications and status
- Support for multiple vehicle types (scooters, bikes, etc.)

### Rental and Usage Management
- Seamless rental transactions
- Real-time usage tracking
- Automated payment processing
- Maintenance request system
- Rental history and analytics

## Smart Contracts

### 1. Vehicle Registry Contract
Manages the registration and lifecycle of micromobility vehicles:
- Vehicle registration with unique identifiers
- Owner/operator management
- Vehicle status tracking (available, in-use, maintenance)
- Vehicle metadata storage

### 2. Rental and Usage Contract
Handles all rental operations and tracking:
- Rental initiation and completion
- Usage time tracking
- Payment calculation and processing
- Maintenance request submission
- Rental history management

## Technology Stack

- **Blockchain**: Stacks blockchain
- **Smart Contract Language**: Clarity
- **Development Framework**: Clarinet

## Getting Started

### Prerequisites
- Clarinet installed
- Stacks wallet for testing
- Node.js and npm

### Installation

```bash
# Clone the repository
git clone <repository-url>

# Navigate to project directory
cd blockchain-based-micromobility-platform

# Install dependencies
npm install

# Check contracts
clarinet check
```

### Running Tests

```bash
# Run all tests
npm test

# Run specific contract tests
clarinet test
```

## Contract Architecture

### Vehicle Registry
- **Purpose**: Central registry for all vehicles
- **Key Functions**: Register, update, query vehicles
- **Access Control**: Owner-only operations

### Rental Management
- **Purpose**: Handle rental lifecycle
- **Key Functions**: Start rental, end rental, process payment
- **Payment**: Automated based on usage time

## Use Cases

1. **Vehicle Operators**: Register and manage fleet of vehicles
2. **Riders**: Rent vehicles seamlessly with transparent pricing
3. **Maintenance Teams**: Receive and track maintenance requests
4. **Platform Administrators**: Monitor system health and usage

## Security Considerations

- Vehicle ownership verification
- Secure payment processing
- Access control for critical operations
- Immutable rental history

## Roadmap

- [ ] Multi-city support
- [ ] Integration with IoT devices
- [ ] Advanced analytics dashboard
- [ ] Mobile app integration
- [ ] Carbon credit tracking

## Contributing

Contributions are welcome! Please submit pull requests with detailed descriptions.

## License

MIT License

## Contact

For questions or support, please open an issue in the repository.
