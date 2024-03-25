// raffle.cairo
#[contract]
mod Raffle {
use starknet::get_block_timestamp;
use starknet::get_caller_address;
use starknet::contract_address_const;
use starknet::ContractAddress;
use starknet::ContractAddressIntoFelt;
use traits::Into;
use traits::TryInto;
use option::OptionTrait;
use array::ArrayTrait;
use serde::Serde;
use organization::OrganizationContract;


// Define constants
const WAFFLE_TOKEN_ADDRESS: ContractAddress = contract_address_const::<0x123456789abcdef>();
const MAX_FEE_PERCENTAGE: u128 = 30_u128;

// Define the Raffle struct
#[derive(Copy, Drop, Serde)]
struct Raffle {
    item: u256,
    total_entries: u256,
    total_amount: u256,
    target_amount: u256,
    end_timestamp: u64,
    is_active: bool,
    fee_percentage: u128,
}

// Define storage variables
#[storage]
struct Storage {
    raffles: LegacyMap::<u256, Raffle>,
    user_entries: LegacyMap::<(ContractAddress, u256), u256>,
    raffle_count: u256,
}

// Define events
#[event]
enum Event {
    RaffleCreated: RaffleCreatedEvent,
    RaffleEntered: RaffleEnteredEvent,
    RaffleEnded: RaffleEndedEvent,
}

#[derive(Drop, Serde)]
struct RaffleCreatedEvent {
    raffle_id: u256,
    item: u256,
    target_amount: u256,
    end_timestamp: u64,
    fee_percentage: u128,
}

#[derive(Drop, Serde)]
struct RaffleEnteredEvent {
    user_address: ContractAddress,
    raffle_id: u256,
    entries: u256,
}

#[derive(Drop, Serde)]
struct RaffleEndedEvent {
    raffle_id: u256,
    winner: ContractAddress,
    fee_amount: u256,
}

// External functions
#[external(v0)]
impl RaffleImpl {
    fn create_raffle(
        ref self: ContractState,
        item: u256,
        target_amount: u256,
        duration: u64,
        fee_percentage: u128,
    ) {
        // Creates a new raffle
        // Only admin can create a raffle
        assert(target_amount > 0.into(), 'Target amount must be greater than zero');
        assert(duration > 0_u64, 'Duration must be greater than zero');
        let caller = get_caller_address();
        OrganizationContract::assert_only_admin(caller);
        assert(fee_percentage <= MAX_FEE_PERCENTAGE, 'Invalid fee percentage');
        
        let raffle_id = self.raffle_count.read();
        let end_timestamp = get_block_timestamp() + duration;
        
        self.raffles.write(
            raffle_id,
            Raffle {
                item,
                total_entries: 0.into(),
                total_amount: 0.into(),
                target_amount,
                end_timestamp,
                is_active: true,
                fee_percentage,
            },
        );
        
        self.raffle_count.write(raffle_id + 1.into());
        
        self.emit(Event::RaffleCreated(RaffleCreatedEvent {
            raffle_id,
            item,
            target_amount,
            end_timestamp,
            fee_percentage,
        }));
    }
    
    fn enter_raffle(ref self: ContractState, raffle_id: u256, entries: u256) {
        // Allows users to enter a raffle by purchasing entries with $WAFFLE tokens
        assert(entries > 0.into(), 'Entries must be greater than zero');
        
        let raffle = self.raffles.read(raffle_id);
        assert(raffle.is_active, 'Raffle is not active');
        assert(get_block_timestamp() <= raffle.end_timestamp, 'Raffle has ended');
        
        let entry_cost = entries;
        let caller = get_caller_address();
        
        // Transfer $WAFFLE tokens from the caller to the contract
        let success = IERC20Dispatcher { contract_address: WAFFLE_TOKEN_ADDRESS }
            .transfer_from(caller, self.contract_address, entry_cost);
        assert(success, 'ERC20: transfer failed');
        
        let user_entry_count = self.user_entries.get((caller, raffle_id)).unwrap_or(0.into());
        self.user_entries.insert((caller, raffle_id), user_entry_count + entries);
        
        self.raffles.write(
            raffle_id,
            Raffle {
                item: raffle.item,
                total_entries: raffle.total_entries + entries,
                total_amount: raffle.total_amount + entry_cost,
                target_amount: raffle.target_amount,
                end_timestamp: raffle.end_timestamp,
                is_active: raffle.is_active,
                fee_percentage: raffle.fee_percentage,
            },
        );
        
        self.emit(Event::RaffleEntered(RaffleEnteredEvent {
            user_address: caller,
            raffle_id,
            entries,
        }));
    }
    
    fn end_raffle(ref self: ContractState, raffle_id: u256) {
        // Ends a raffle and selects a winner if the target amount is reached
        // Only admin can end a raffle
        let caller = get_caller_address();
        OrganizationContract::assert_only_admin(caller);
        
        let raffle = self.raffles.read(raffle_id);
        assert(raffle.is_active, 'Raffle is not active');
        assert(get_block_timestamp() >= raffle.end_timestamp, 'Raffle has not ended');
        
        if raffle.total_amount >= raffle.target_amount {
            let winner = self.select_winner(raffle_id);
            let fee_amount = raffle.total_amount * raffle.fee_percentage / 100.into();
            let prize_amount = raffle.total_amount - fee_amount;
            
            // Transfer the fee amount to the organization account
            OrganizationContract::transfer_fees(fee_amount);
            
            // Transfer the prize amount to the winner
            let success = IERC20Dispatcher { contract_address: WAFFLE_TOKEN_ADDRESS }
                .transfer(winner, prize_amount);
            assert(success, 'ERC20: transfer failed');
            
            self.emit(Event::RaffleEnded(RaffleEndedEvent {
                raffle_id,
                winner,
                fee_amount,
            }));
        } else {
            // Refund the participants if the target amount is not reached
            self.refund_participants(raffle_id);
        }
        
        self.raffles.write(
            raffle_id,
            Raffle {
                item: raffle.item,
                total_entries: raffle.total_entries,
                total_amount: raffle.total_amount,
                target_amount: raffle.target_amount,
                end_timestamp: raffle.end_timestamp,
                is_active: false,
                fee_percentage: raffle.fee_percentage,
            },
        );
    }
}

// Internal functions
#[generate_trait]
impl InternalImpl {
    fn select_winner(self: @ContractState, raffle_id: u256) -> ContractAddress {
        // Selects a random winner from the raffle entries
        let raffle = self.raffles.read(raffle_id);
        assert(raffle.total_entries > 0.into(), 'No entries in the raffle');
        
        let random_number = self.get_random_number(raffle_id);
        let winning_index = random_number % raffle.total_entries;
        
        let winner = self.get_winner_by_index(raffle_id, winning_index);
        winner
    }
    
    fn get_random_number(self: @ContractState, raffle_id: u256) -> u256 {
        // Generates a random number based on the raffle ID and block information
        // This is a placeholder implementation using the pedersen hash function
        // Consider using a more secure and fair random number generation method
        let random_number = starknet::pedersen(raffle_id, get_block_timestamp().into());
        random_number
    }
    
    fn get_winner_by_index(self: @ContractState, raffle_id: u256, index: u256) -> ContractAddress {
        // Retrieves the winner based on the winning index
        let raffle = self.raffles.read(raffle_id);
        
        let mut cumulative_entries = 0.into();
        let users = self.user_entries.keys().into_iter().map(|(user, _)| user);
        
        for user in users {
            let entry_count = self.user_entries.get((user, raffle_id)).unwrap_or(0.into());
            cumulative_entries += entry_count;
            
            if cumulative_entries > index {
                return user;
            }
        }
        
        panic_with_felt252('No winner found');
    }
    
    fn refund_participants(self: @ContractState, raffle_id: u256) {
        // Refunds the participants if the target amount is not reached
        let users = self.user_entries.keys().into_iter().map(|(user, _)| user);
        
        for user in users {
            let entry_count = self.user_entries.get((user, raffle_id)).unwrap_or(0.into());
            
            if entry_count > 0.into() {
                let refund_amount = entry_cost;
                
                // Transfer the refund amount back to the user
                let success = IERC20Dispatcher { contract_address: WAFFLE_TOKEN_ADDRESS }
                    .transfer(user, refund_amount);
                assert(success, 'ERC20: transfer failed');
            }
        }
    }
}
}
