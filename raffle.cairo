// raffle.cairo

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_nn, split_felt
from starkware.cairo.common.math_cmp import is_le
from starkware.starknet.common.syscalls import get_block_timestamp, get_caller_address
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import assert_le, assert_lt, assert_nn_le, unsigned_div_rem
from openzeppelin.token.erc20.IERC20 import IERC20
from organization import OrganizationContract

// Define constants
const WAFFLE_TOKEN_ADDRESS = 0x123456789abcdef;
const MAX_FEE_PERCENTAGE = 30;

// Define the Raffle struct
struct Raffle {
    item: felt,  // The item being raffled
    total_entries: felt,  // Total number of entries in the raffle
    total_amount: felt,  // Total amount of $WAFFLE tokens collected
    target_amount: felt,  // Target amount of $WAFFLE tokens required for the raffle to be successful
    end_timestamp: felt,  // Timestamp when the raffle ends
    is_active: felt,  // Indicates if the raffle is active (1) or closed (0)
    fee_percentage: felt,  // Percentage fee set by the deployer (0-30%)
}

// Define storage variables
@storage_var
func raffles(raffle_id: felt) -> (raffle: Raffle) {
    // Stores the raffle details for each raffle ID
}

@storage_var
func user_entries(user_address: felt, raffle_id: felt) -> (entries: felt) {
    // Stores the number of entries for each user in a specific raffle
}

@storage_var
func raffle_count() -> (count: felt) {
    // Stores the total count of raffles
}

// Define events
@event
func RaffleCreated(raffle_id: felt, item: felt, target_amount: felt, end_timestamp: felt, fee_percentage: felt) {
    // Emitted when a new raffle is created
}

@event
func RaffleEntered(user_address: felt, raffle_id: felt, entries: felt) {
    // Emitted when a user enters a raffle
}

@event
func RaffleEnded(raffle_id: felt, winner: felt, fee_amount: felt) {
    // Emitted when a raffle ends and a winner is selected
}

// External functions

@external
func create_raffle{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    item: felt, target_amount: felt, duration: felt, fee_percentage: felt
) {
    // Creates a new raffle
    // Only admin can create a raffle
    let (caller) = get_caller_address();
    OrganizationContract.assert_only_admin(caller);

    assert_nn_le(fee_percentage, MAX_FEE_PERCENTAGE);  // Ensure fee percentage is within the allowed range

    let (raffle_id) = raffle_count.read();
    let end_timestamp = get_block_timestamp() + duration;

    raffles.write(raffle_id, Raffle(item, 0, 0, target_amount, end_timestamp, 1, fee_percentage));
    raffle_count.write(raffle_id + 1);
    RaffleCreated.emit(raffle_id, item, target_amount, end_timestamp, fee_percentage);
    return ();
}

@external
func enter_raffle{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    raffle_id: felt, entries: felt
) {
    // Allows users to enter a raffle by purchasing entries with $WAFFLE tokens
    let (raffle) = raffles.read(raffle_id);
    assert raffle.is_active = 1;  // Ensure the raffle is active
    assert_le(get_block_timestamp(), raffle.end_timestamp);  // Ensure the raffle hasn't ended

    let entry_cost = entries;  // Each entry costs 1 $WAFFLE token
    let (caller) = get_caller_address();

    // Transfer $WAFFLE tokens from the caller to the contract
    let (success) = IERC20.transferFrom(
        contract_address=WAFFLE_TOKEN_ADDRESS,
        sender=caller,
        recipient=self.address,
        amount=entry_cost
    );
    with_attr error_message("ERC20: transfer failed") {
        assert success = 1;
    }

    let (user_entry_count) = user_entries.read(caller, raffle_id);
    user_entries.write(caller, raffle_id, user_entry_count + entries);

    raffles.write(
        raffle_id,
        Raffle(
            raffle.item,
            raffle.total_entries + entries,
            raffle.total_amount + entry_cost,
            raffle.target_amount,
            raffle.end_timestamp,
            raffle.is_active,
            raffle.fee_percentage
        )
    );
    RaffleEntered.emit(caller, raffle_id, entries);
    return ();
}

@external
func end_raffle{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(raffle_id: felt) {
    // Ends a raffle and selects a winner if the target amount is reached
    // Only admin can end a raffle
    let (caller) = get_caller_address();
    OrganizationContract.assert_only_admin(caller);

    let (raffle) = raffles.read(raffle_id);
    assert raffle.is_active = 1;  // Ensure the raffle is active
    assert_le(raffle.end_timestamp, get_block_timestamp());  // Ensure the raffle has ended

    if (raffle.total_amount >= raffle.target_amount) {
        let winner = select_winner(raffle_id);
        let fee_amount = raffle.total_amount * raffle.fee_percentage / 100;
        let prize_amount = raffle.total_amount - fee_amount;

        // Transfer the fee amount to the organization account
        OrganizationContract.transfer_fees(fee_amount);

        // Transfer the prize amount to the winner
        // Implement the logic to transfer the prize amount to the winner

        RaffleEnded.emit(raffle_id, winner, fee_amount);
    } else {
        // Refund the participants if the target amount is not reached
        refund_participants(raffle_id);
    }

    raffles.write(
        raffle_id,
        Raffle(
            raffle.item,
            raffle.total_entries,
            raffle.total_amount,
            raffle.target_amount,
            raffle.end_timestamp,
            0,
            raffle.fee_percentage
        )
    );
    return ();
}

// Internal functions

func select_winner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    raffle_id: felt
) -> (winner: felt) {
    // Selects a random winner from the raffle entries
    alloc_locals;
    let (raffle) = raffles.read(raffle_id);
    let (random_number) = get_random_number(raffle_id);
    let (winning_index, _) = unsigned_div_rem(random_number, raffle.total_entries);
    let (winner) = get_winner_by_index(raffle_id, winning_index);
    return (winner,);
}

func get_random_number{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    raffle_id: felt
) -> (random_number: felt) {
    // Generates a random number based on the raffle ID and block information
    // This is a placeholder implementation using the pedersen hash function
    // Consider using a more secure and fair random number generation method
    let (random_number) = pedersen_hash(raffle_id, get_block_timestamp());
    return (random_number,);
}

func get_winner_by_index{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    raffle_id: felt, index: felt
) -> (winner: felt) {
    // Retrieves the winner based on the winning index
    alloc_locals;
    let (local winner) = 0;
    let (local cumulative_entries) = 0;

    let (raffle) = raffles.read(raffle_id);
    let (max_entries) = raffle.total_entries;

    let (user_count) = user_entries.keys_len();
    let (users) = user_entries.keys();

    loop:
    tempvar current_index = 0;
    tempvar entry_count = 0;
    tempvar user = users[current_index];

    let (entry_count) = user_entries.read(user, raffle_id);
    let cumulative_entries = cumulative_entries + entry_count;

    if (cumulative_entries > index) {
        winner = user;
        break;
    }

    current_index = current_index + 1;
    if (current_index < user_count) {
        jump loop;
    }

    assert winner != 0;
    return (winner,);
}

func refund_participants{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    raffle_id: felt
) {
    // Refunds the participants if the target amount is not reached
    let (user_count) = user_entries.keys_len();
    let (users) = user_entries.keys();

    loop:
    tempvar current_index = 0;
    tempvar user = users[current_index];

    let (entry_count) = user_entries.read(user, raffle_id);
    if (entry_count > 0) {
        let refund_amount = entry_count;  // Refund the $WAFFLE tokens used for entries

        // Transfer the refund amount back to the user
        IERC20.transfer(
            contract_address=WAFFLE_TOKEN_ADDRESS,
            recipient=user,
            amount=refund_amount
        );
    }

    current_index = current_index + 1;
    if (current_index < user_count) {
        jump loop;
    }

    return ();
}
