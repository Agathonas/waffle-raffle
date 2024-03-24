// organization.cairo

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from openzeppelin.token.erc20.IERC20 import IERC20

// Define constants
const WAFFLE_TOKEN_ADDRESS = 0x123456789abcdef;
const ADMIN_ADDRESS = 0x987654321fedcba;

// Define storage variables
@storage_var
func organization_balance() -> (balance: felt) {
    // Stores the balance of the organization account
}

// External functions

@external
func transfer_fees{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(amount: felt) {
    // Transfers the fee amount to the organization account
    let (success) = IERC20.transfer(
        contract_address=WAFFLE_TOKEN_ADDRESS,
        recipient=self.address,
        amount=amount
    );
    with_attr error_message("ERC20: transfer failed") {
        assert success = 1;
    }

    let (balance) = organization_balance.read();
    organization_balance.write(balance + amount);
    return ();
}

@external
func withdraw_funds{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(amount: felt) {
    // Withdraws funds from the organization account to the admin address
    let (caller) = get_caller_address();
    assert_only_admin(caller);

    let (balance) = organization_balance.read();
    assert_nn_le(amount, balance);  // Ensure sufficient balance

    let (success) = IERC20.transfer(
        contract_address=WAFFLE_TOKEN_ADDRESS,
        recipient=ADMIN_ADDRESS,
        amount=amount
    );
    with_attr error_message("ERC20: transfer failed") {
        assert success = 1;
    }

    organization_balance.write(balance - amount);
    return ();
}

// Internal functions

func assert_only_admin{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    user: felt
) {
    // Asserts that only the admin can perform certain actions
    assert user = ADMIN_ADDRESS;
    return ();
}
