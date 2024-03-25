// organization.cairo
#[contract]
mod OrganizationContract {
use starknet::get_caller_address;
use starknet::contract_address_const;
use starknet::ContractAddress;
use traits::Into;
use traits::TryInto;
use option::OptionTrait;
use starknet::ContractAddressIntoFelt;


Copy code
// Define constants
const WAFFLE_TOKEN_ADDRESS: ContractAddress = contract_address_const::<0x123456789abcdef>();
const ADMIN_ADDRESS: ContractAddress = contract_address_const::<0x987654321fedcba>();

// Define storage variables
#[storage]
struct Storage {
    organization_balance: u256,
}

// External functions
#[external(v0)]
impl OrganizationImpl {
    fn transfer_fees(ref self: ContractState, amount: u256) {
        // Transfers the fee amount to the organization account
        assert(amount > 0.into(), 'Amount must be greater than zero');
        
        let success = IERC20Dispatcher { contract_address: WAFFLE_TOKEN_ADDRESS }
            .transfer(self.contract_address, amount);
        assert(success, 'ERC20: transfer failed');
        
        let balance = self.organization_balance.read();
        self.organization_balance.write(balance + amount);
    }
    
    fn withdraw_funds(ref self: ContractState, amount: u256) {
        // Withdraws funds from the organization account to the admin address
        assert(amount > 0.into(), 'Amount must be greater than zero');
        
        let caller = get_caller_address();
        self.assert_only_admin(caller);
        
        let balance = self.organization_balance.read();
        assert(amount <= balance, 'Insufficient balance');
        
        let success = IERC20Dispatcher { contract_address: WAFFLE_TOKEN_ADDRESS }
            .transfer(ADMIN_ADDRESS, amount);
        assert(success, 'ERC20: transfer failed');
        
        self.organization_balance    }
}

// Internal functions
#[generate_trait]
impl InternalImpl {
    fn assert_only_admin(self: @ContractState, user: ContractAddress) {
        // Asserts that only the admin can perform certain actions
        assert(user == ADMIN_ADDRESS, 'Only admin can perform this action');
    }
}
