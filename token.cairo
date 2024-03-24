%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address
from openzeppelin.token.erc20.library import ERC20

// Define the token name and symbol
const NAME = 'Waffle Token';
const SYMBOL = 'WAFFLE';
const DECIMALS = 18;

// Define the total supply and allocations
const TOTAL_SUPPLY = 1000000000 * 10 ** DECIMALS;  // 1 billion tokens
const LIQUIDITY_ALLOCATION = 200000000 * 10 ** DECIMALS;  // 20% for liquidity pool
const TEAM_ALLOCATION = 100000000 * 10 ** DECIMALS;  // 10% for team
const MARKETING_ALLOCATION = 50000000 * 10 ** DECIMALS;  // 5% for marketing
const DEV_ALLOCATION = 50000000 * 10 ** DECIMALS;  // 5% for development
const AIRDROP_ALLOCATION = 600000000 * 10 ** DECIMALS;  // 60% for airdrop to community

// Define the vesting periods for team, marketing, and dev allocations (e.g., 2 years)
const VESTING_PERIOD = 730 days;

// Define the contract variables
@storage_var
func total_supply() -> Uint256 {
    return TOTAL_SUPPLY;
}

@storage_var
func liquidity_allocation() -> Uint256 {
    return LIQUIDITY_ALLOCATION;
}

@storage_var
func team_allocation() -> Uint256 {
    return TEAM_ALLOCATION;
}

@storage_var
func marketing_allocation() -> Uint256 {
    return MARKETING_ALLOCATION;
}

@storage_var
func dev_allocation() -> Uint256 {
    return DEV_ALLOCATION;
}

@storage_var
func airdrop_allocation() -> Uint256 {
    return AIRDROP_ALLOCATION;
}

@storage_var
func vesting_start_timestamp() -> felt {
    return 0;
}

// Define the token contract
@contract
class WaffleToken {
    // Constructor function to initialize the token allocations
    constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
        let (caller) = get_caller_address();
        ERC20.mint(caller, total_supply.read());
        ERC20._approve(caller, self.address, total_supply.read());
        ERC20._transfer(caller, self.address, total_supply.read());
        vesting_start_timestamp.write(get_block_timestamp());
        return ();
    }

    // Function to perform the airdrop to the community
    func airdrop{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        recipients_len: felt, recipients: felt*, amounts: Uint256*
    ) {
        let (caller) = get_caller_address();
        assert caller = self.address;
        assert ERC20.balanceOf(self.address) >= airdrop_allocation.read();

        with_attr error_message("Amount exceeds airdrop allocation") {
            let total_amount = Uint256(0);
            loop:
            for i in range(recipients_len) {
                let recipient = recipients[i];
                let amount = amounts[i];
                total_amount += amount;
                ERC20.transfer(recipient, amount);
            }
            assert_lt_felt(total_amount, airdrop_allocation.read());
        }
        return ();
    }

    // Function to claim vested tokens for team, marketing, and dev allocations
    func claim_vested_tokens{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
        let (caller) = get_caller_address();
        assert caller = self.address;
        let current_timestamp = get_block_timestamp();
        let vesting_start = vesting_start_timestamp.read();
        let vesting_end = vesting_start + VESTING_PERIOD;

        with_attr error_message("Vesting period has not ended") {
            assert_lt_felt(current_timestamp, vesting_end);
        }

        let team_amount = team_allocation.read();
        let marketing_amount = marketing_allocation.read();
        let dev_amount = dev_allocation.read();

        ERC20.transfer(team_wallet, team_amount);
        ERC20.transfer(marketing_wallet, marketing_amount);
        ERC20.transfer(dev_wallet, dev_amount);

        return ();
    }

    // Function to add liquidity to a pool
    func add_liquidity{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        pool_address: felt
    ) {
        let (caller) = get_caller_address();
        assert caller = self.address;
        let liquidity_amount = liquidity_allocation.read();

        with_attr error_message("Insufficient liquidity allocation") {
            assert ERC20.balanceOf(self.address) >= liquidity_amount;
        }

        ERC20.transfer(pool_address, liquidity_amount);

        return ();
    }
}
