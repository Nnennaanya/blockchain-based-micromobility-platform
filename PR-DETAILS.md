## Overview

This PR introduces the core smart contracts for the blockchain-based micromobility platform, enabling decentralized vehicle management and rental operations.

## Changes

### Vehicle Registry Contract (`vehicle-registry.clar`)
- **Vehicle Registration**: Register scooters, bikes, and other micromobility vehicles with unique IDs
- **Ownership Management**: Track vehicle owners and operators with verification system
- **Status Tracking**: Monitor vehicle availability (available, in-use, maintenance, decommissioned)
- **Dynamic Pricing**: Configurable rate-per-minute for each vehicle
- **Operator Profiles**: Reputation scores and verification status for operators

**Key Functions:**
- `register-vehicle`: Add new vehicles to the registry
- `update-vehicle-status`: Change vehicle availability status
- `update-vehicle-location`: Update GPS coordinates
- `transfer-vehicle-ownership`: Transfer vehicles between operators
- `verify-operator`: Platform verification for trusted operators

### Rental and Usage Contract (`rental-and-usage-contract.clar`)
- **Rental Management**: Start, end, and cancel rental sessions
- **Usage Tracking**: Monitor rental duration and calculate costs automatically
- **Payment Processing**: Automated payment calculation with platform fees
- **Maintenance System**: Submit and track vehicle maintenance requests
- **User Analytics**: Track rental history, spending, and reputation scores

**Key Functions:**
- `start-rental`: Initiate a new rental session
- `end-rental`: Complete rental and process payment
- `cancel-rental`: Cancel active rental
- `submit-maintenance-request`: Report vehicle issues
- `resolve-maintenance-request`: Mark maintenance as complete

## Technical Details

- **Lines of Code**: 340+ lines (vehicle-registry), 398+ lines (rental-and-usage)
- **Data Maps**: 9 comprehensive data structures
- **Error Handling**: Robust validation and authorization checks
- **Platform Fee**: Configurable percentage (default 5%)
- **Block-based Timing**: Uses Stacks block height for timestamps

## Testing

Run contract validation:
```bash
clarinet check
```

All contracts pass syntax validation with no errors.

## Security

- Owner-only administrative functions
- Rental authorization checks
- Vehicle ownership verification
- Status validation for state transitions

## Future Enhancements

- Integration with IoT sensors for real-time vehicle data
- Multi-signature operator management
- Advanced analytics and reporting
- Carbon credit integration
