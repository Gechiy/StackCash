# Loyalty Cashback Program Smart Contract

A Clarity smart contract for managing a loyalty cashback rewards program on the Stacks blockchain.

## Overview

This smart contract enables businesses to run a loyalty cashback program where customers can accumulate cashback rewards and redeem them during specified redemption windows. The program supports premium memberships and provides comprehensive customer management features.

## Features

- **Customer Registration**: Register and manage customer accounts
- **Premium Membership**: Track premium member status
- **Cashback Management**: Assign and track cashback balances
- **Redemption Control**: Open/close redemption windows
- **Batch Operations**: Assign cashback to multiple customers at once
- **Comprehensive Tracking**: Monitor redemption history and customer profiles

## Constants

- `program-director`: The contract deployer who has administrative privileges
- `total-cashback-reserve`: Initial reserve of 5,000,000 units

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | `err-director-only` | Action restricted to program director |
| u101 | `err-cashback-redeemed` | Cashback already redeemed |
| u102 | `err-not-member` | Customer is not a valid member |
| u103 | `err-no-balance` | Customer has no cashback balance |
| u104 | `err-redemption-closed` | Redemption window is closed |
| u105 | `err-invalid-customer` | Invalid customer principal |
| u106 | `err-invalid-balance` | Invalid balance amount |

## Public Functions

### Administrative Functions (Director Only)

#### `register-customer`
```clarity
(register-customer (customer principal))
```
Registers a new customer in the program.

#### `unregister-customer`
```clarity
(unregister-customer (customer principal))
```
Removes a customer from the program.

#### `set-premium-status`
```clarity
(set-premium-status (customer principal) (is-premium bool))
```
Sets or removes premium membership status for a customer.

#### `set-cashback-balance`
```clarity
(set-cashback-balance (customer principal) (balance uint))
```
Assigns a cashback balance to a customer. Balance must be greater than 0 and within the total reserve.

#### `batch-assign-cashback`
```clarity
(batch-assign-cashback (customers (list 200 principal)) (balances (list 200 uint)))
```
Assigns cashback balances to multiple customers at once. Lists must be equal length (max 200).

#### `toggle-redemption`
```clarity
(toggle-redemption)
```
Opens or closes the redemption window.

### Customer Functions

#### `redeem-cashback`
```clarity
(redeem-cashback)
```
Allows customers to redeem their cashback balance. Requirements:
- Redemption window must be open
- Customer must be registered and have premium status
- Customer must have a cashback balance
- Customer has not previously redeemed

## Read-Only Functions

#### `get-cashback-balance`
```clarity
(get-cashback-balance (customer principal))
```
Returns the cashback balance for a customer.

#### `has-redeemed`
```clarity
(has-redeemed (customer principal))
```
Checks if a customer has already redeemed their cashback.

#### `check-membership`
```clarity
(check-membership (customer principal))
```
Verifies if a customer is a valid member (registered and premium).

#### `is-redemption-open`
```clarity
(is-redemption-open)
```
Returns whether the redemption window is currently open.

#### `get-total-reserve`
```clarity
(get-total-reserve)
```
Returns the total cashback reserve amount.

#### `get-customer-profile`
```clarity
(get-customer-profile (customer principal))
```
Returns a comprehensive profile including:
- `cashback`: Current balance
- `redeemed`: Redemption status
- `valid-member`: Membership validity
- `registered`: Registration status
- `premium`: Premium membership status
- `can-redeem`: Whether customer can currently redeem

## Usage Example

### Setting Up a Customer

```clarity
;; 1. Register customer
(contract-call? .loyalty-program register-customer 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)

;; 2. Set premium status
(contract-call? .loyalty-program set-premium-status 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 true)

;; 3. Assign cashback
(contract-call? .loyalty-program set-cashback-balance 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 u1000)

;; 4. Open redemption window
(contract-call? .loyalty-program toggle-redemption)
```

### Customer Redemption

```clarity
;; Customer redeems cashback
(contract-call? .loyalty-program redeem-cashback)
```

### Checking Customer Status

```clarity
;; Get full customer profile
(contract-call? .loyalty-program get-customer-profile 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

## Security Considerations

- Only the program director (contract deployer) can perform administrative functions
- Customers cannot redeem cashback twice
- Redemption requires both registration and premium membership
- Balance assignments are validated against the total reserve
- Customer principals are validated to prevent invalid addresses

## Development

### Requirements
- Clarity smart contract language
- Stacks blockchain

### Testing
Test all functions thoroughly, especially:
- Access control for director-only functions
- Redemption eligibility checks
- Balance validation
- Batch operations with various list sizes
