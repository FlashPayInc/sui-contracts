module defi::cheque {
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    const INSUFFICIENT_BALANCE: u64 = 0;

    struct Cheque has key {
        id: UID,
        issuer: address,
        recipient: address,
        asset: Coin<SUI>,
        is_valid: bool
    }

    
}