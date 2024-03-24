%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address
from openzeppelin.token.erc20.library import ERC20

// Define the token name and symbol
const NAME = 'Waffle Token';
const SYMBOL = 'WAFFLE';
const DECIMALS = 18;

// Define the total supply and allocations
const TOTAL_SUPPLY = 1000000000 * 10 ** DECIMALS;  // 1 billion tokens
const LIQUIDITY_ALLOCATION = 200000000 * 10 ** DECIMALS;  // 20% for liquidity pool
const TEAM_ALLOCATION = 200000000 * 10 ** DECIMALS;  // 20% for team
const AIRDROP_ALLOCATION = 600000000 * 10 ** DECIMALS;  // 60% for airdrop to community

// Define the contract variables
@storage_var
func total_supply() -> Uint256 {
    return Uint256(TOTAL_SUPPLY);
}

@storage_var
func liquidity_allocation() -> Uint256 {
    return Uint256(LIQUIDITY_ALLOCATION);
}

@storage_var
func team_allocation() -> Uint256 {
    return Uint256(TEAM_ALLOCATION);
}

@storage_var
func airdrop_allocation() -> Uint256 {
    return Uint256(AIRDROP_ALLOCATION);
}

// Define the airdrop variables
@storage_var
func airdrop_merkle_root() -> (merkle_root: felt) {
}

@storage_var
func airdrop_claimed(address: felt) -> (claimed: felt) {
}

// Define the token contract
@contract
class WaffleToken {
    // Constructor function to initialize the token allocations
    constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
        ERC20.initializer(NAME, SYMBOL, DECIMALS);
        let (contract_address) = get_contract_address();
        ERC20._mint(contract_address, total_supply.read());
        return ();
    }

    // Function to set the airdrop Merkle root
    @external
    func set_airdrop_merkle_root{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        merkle_root: felt
    ) {
        let (caller) = get_caller_address();
        let (contract_address) = get_contract_address();
        with_attr error_message("Only the contract owner can set the airdrop Merkle root") {
            assert caller = contract_address;
        }

        airdrop_merkle_root.write(merkle_root);
        return ();
    }

    // Function to claim airdrop tokens
    @external
    func claim_airdrop{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        recipient: felt, amount: Uint256, proof_len: felt, proof: felt*
    ) {
        with_attr error_message("Airdrop already claimed") {
            let (claimed) = airdrop_claimed.read(recipient);
            assert claimed = 0;
        }

        let merkle_root = airdrop_merkle_root.read();
        with_attr error_message("Invalid Merkle proof") {
            verify_merkle_proof(recipient, amount, merkle_root, proof_len, proof);
        }

        ERC20.transfer(recipient, amount);
        airdrop_claimed.write(recipient, 1);
        return ();
    }

    // Function to verify Merkle proof
    func verify_merkle_proof{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        recipient: felt, amount: Uint256, merkle_root: felt, proof_len: felt, proof: felt*
    ) {
        // Implement the Merkle proof verification logic here
        // This function should verify that the provided proof is valid and corresponds to the recipient and amount
        // You can use a library or implement the Merkle proof verification algorithm yourself
    }

    // Function to add liquidity to a pool
    @external
    func add_liquidity{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        pool_address: felt
    ) {
        let (caller) = get_caller_address();
        let (contract_address) = get_contract_address();
        with_attr error_message("Only the contract owner can add liquidity") {
            assert caller = contract_address;
        }

        let liquidity_amount = liquidity_allocation.read();
        with_attr error_message("Insufficient liquidity allocation") {
            assert ERC20.balance_of(contract_address) >= liquidity_amount;
        }
        ERC20.transfer(pool_address, liquidity_amount);
        return ();
    }

    // Function to distribute team allocation
    @external
    func distribute_team_allocation{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        team_address: felt
    ) {
        let (caller) = get_caller_address();
        let (contract_address) = get_contract_address();
        with_attr error_message("Only the contract owner can distribute team allocation") {
            assert caller = contract_address;
        }

        let team_amount = team_allocation.read();
        ERC20.transfer(team_address, team_amount);
        return ();
    }
}
