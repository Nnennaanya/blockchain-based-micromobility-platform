# Blockchain-Based Micromobility Platform

## Overview

A decentralized platform to manage scooters, bikes, and other micromobility vehicles, including rentals, usage tracking, and maintenance. This system leverages blockchain technology to create a transparent, secure, and efficient ecosystem for micromobility service providers and users.

## System Architecture

The platform consists of two core smart contracts built on the Stacks blockchain using Clarity:

### 1. Vehicle Registry Contract
Manages the registration and lifecycle of micromobility vehicles on the platform.

**Key Features:**
- Vehicle registration with unique identifiers
- Owner/operator management
- Vehicle status tracking (active, maintenance, retired)
- Vehicle type classification (scooter, bike, e-bike, etc.)
- Ownership transfer capabilities

### 2. Rental and Usage Contract
Handles the rental process, usage tracking, and maintenance coordination.

**Key Features:**
- Rental initiation and completion
- Real-time usage tracking
- Automated payment processing
- Maintenance request logging
- Rental history management
- Dynamic pricing based on duration and vehicle type

## Benefits

### For Service Providers
- **Transparency**: All vehicle data and transactions recorded immutably
- **Efficiency**: Automated rental and payment processes
- **Maintenance Tracking**: Clear maintenance logs and scheduling
- **Fraud Prevention**: Blockchain verification prevents unauthorized access

### For Users
- **Trust**: Transparent pricing and vehicle history
- **Convenience**: Seamless rental experience
- **Payment Security**: Cryptographic payment verification
- **Dispute Resolution**: Immutable transaction records

## Technical Stack

- **Blockchain**: Stacks
- **Smart Contract Language**: Clarity
- **Development Framework**: Clarinet
- **Testing**: Vitest + Clarinet Testing Framework

## Smart Contract Architecture

### Vehicle Registry
```
- Register new vehicles
- Update vehicle status
- Transfer ownership
- Query vehicle information
- Deactivate vehicles
```

### Rental and Usage
```
- Start rental session
- End rental session
- Process payments
- Log maintenance requests
- Track usage statistics
- Calculate rental fees
```

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js (v16 or higher)
- Git

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd blockchain-based-micromobility-platform
```

2. Install dependencies:
```bash
npm install
```

3. Check contract syntax:
```bash
clarinet check
```

4. Run tests:
```bash
npm test
```

## Development

### Adding New Contracts
```bash
clarinet contract new <contract-name>
```

### Testing Contracts
```bash
clarinet test
```

### Console Interaction
```bash
clarinet console
```

## Contract Deployment

Deployment configurations are available for:
- **Devnet**: Local development environment
- **Testnet**: Testing on Stacks testnet
- **Mainnet**: Production deployment

Configuration files are located in the `settings/` directory.

## Use Cases

1. **Urban Mobility**: City-wide bike and scooter sharing
2. **Campus Transportation**: University or corporate campus mobility
3. **Tourist Rentals**: Short-term vehicle rentals for visitors
4. **Last-Mile Delivery**: Micro-logistics for deliveries
5. **Multi-Operator Networks**: Shared infrastructure across providers

## Security Considerations

- All vehicle registrations require owner verification
- Rental sessions use cryptographic locks
- Payment handling includes validation checks
- Maintenance requests are authenticated
- Access control for administrative functions

## Future Enhancements

- Integration with IoT device locks
- Dynamic pricing algorithms
- Multi-token payment support
- Carbon credit tracking
- Insurance integration
- Cross-chain compatibility

## Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write tests
5. Submit a pull request

## License

MIT License

## Contact

For questions or support, please open an issue in the repository.

---

**Built with Clarity on Stacks** 🔗
