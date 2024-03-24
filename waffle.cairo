%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_nn, split_felt
from starkware.cairo.common.math_cmp import is_le
from starkware.starknet.common.syscalls import get_block_timestamp, get_caller_address
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import (
    assert_le,
    assert_lt,
    assert_nn_le,
    unsigned_div_rem,
)
from openzeppelin.token.erc20.IERC20 import IERC20

// Define constants
const WAFFLE_TOKEN_ADDRESS = 0x123456789abcdef;

// Define the Raffle struct
struct Raffle {
    item: felt,
    total_entries: felt,
    entry_fee: felt,
    end_timestamp: felt,
    is_active: felt,
}

// Define storage variables
@storage_var
func raffles(raffle_id: felt) -> (raffle: Raffle) {
}

@storage_var
func user_entries(user_address: felt, raffle_id: felt) -> (entries: felt) {
}

@storage_var
func raffle_count() -> (count: felt) {
}

// Define events
@event
func RaffleCreated(raffle_id: felt, item: felt, entry_fee: felt, end_timestamp: felt) {
}

@event
func RaffleEntered(user_address: felt, raffle_id: felt, entries: felt) {
}

@event
func RaffleEnded(raffle_id: felt, winner: felt) {
}

// External functions

@external
func create_raffle{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    item: felt, entry_fee: felt, duration: felt
) {
    let (caller) = get_caller_address();
    assert_only_admin(caller);

    let (raffle_id) = raffle_count.read();
    let end_timestamp = get_block_timestamp() + duration;

    raffles.write(raffle_id, Raffle(item, 0, entry_fee, end_timestamp, 1));
    raffle_count.write(raffle_id + 1);
    RaffleCreated.emit(raffle_id, item, entry_fee, end_timestamp);
}

@external
func enter_raffle{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    raffle_id: felt, entries: felt
) {
    let (raffle) = raffles.read(raffle_id);
    assert raffle.is_active = 1;
    assert_le(get_block_timestamp(), raffle.end_timestamp);

    let entry_cost = raffle.entry_fee * entries;
    let (caller) = get_caller_address();

    // Transfer $WAFFLE tokens from the caller to the contract
    let (success) = IERC20.transferFrom(
        contract_address=WAFFLE_TOKEN_ADDRESS,
        sender=caller,
        recipient=self_address,
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
            raffle.entry_fee,
            raffle.end_timestamp,
            raffle.is_active
        )
    );
    RaffleEntered.emit(caller, raffle_id, entries);
}

@external
func end_raffle{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(raffle_id: felt) {
    let (caller) = get_caller_address();
    assert_only_admin(caller);

    let (raffle) = raffles.read(raffle_id);
    assert raffle.is_active = 1;
    assert_le(raffle.end_timestamp, get_block_timestamp());

    let winner = select_winner(raffle_id);
    // Transfer the raffle item to the winner
    // Implement the logic to transfer the item to the winner

    raffles.write(
        raffle_id,
        Raffle(raffle.item, raffle.total_entries, raffle.entry_fee, raffle.end_timestamp, 0)
    );
    RaffleEnded.emit(raffle_id, winner);
}

// Internal functions

func select_winner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    raffle_id: felt
) -> (winner: felt) {
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
    // Implement a random number generation algorithm based on the raffle_id and block information
    // You can use the pedersen hash function or other techniques for randomness
    // This is a placeholder implementation
    let (random_number) = pedersen_hash(raffle_id, get_block_timestamp());
    return (random_number,);
}

func get_winner_by_index{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    raffle_id: felt, index: felt
) -> (winner: felt) {
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

func assert_only_admin{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    user: felt
) {
    // Implement the logic to check if the given user is an admin
    // You can maintain a list of admin addresses or use other access control mechanisms
    // This is a placeholder implementation
    assert user = 0x123456789abcdef;
    return ();
}
