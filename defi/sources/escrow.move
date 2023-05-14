module defi::escrow {
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::tx_context::{Self, TxContext};

    const INSUFFICIENT_BALANCE: u64 = 0;
    const SAME_SENDER_AND_RECIPIENT: u64 = 1;
    const NOT_PERMITTED: u64 = 2;
    const WRONG_KEY: u64 = 3;
    
    
}