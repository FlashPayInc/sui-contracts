module defi::escrow {
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::tx_context::{Self, TxContext};

    const INSUFFICIENT_BALANCE: u64 = 0;
    const SAME_SENDER_AND_RECIPIENT: u64 = 1;
    const NOT_PERMITTED: u64 = 2;
    const WRONG_KEY: u64 = 3;
    
    struct EscrowKey<phantom T> has key, store {
        id: UID
    }

    struct Escrow<phantom T> has key, store {
        id: UID,
        sender: address,
        recipient: address,
        escrowed: Coin<T>,
        key_id: ID
    }

    struct Receipt<phantom T> has key {
        id: UID,
        sender: address,
        recipient: address,
        amount: u64
    }

    public entry fun create_escrow<T: key + store>(escrowed: &mut Coin<T>, recipient: address, amount: u64, ctx: &mut TxContext): EscrowKey<T> {
        assert!(coin::value(escrowed) >= amount, INSUFFICIENT_BALANCE);
        assert!(tx_context::sender(ctx) != recipient, SAME_SENDER_AND_RECIPIENT);

        let escrowed_balance_mut = coin::balance_mut(escrowed);
        let taken_coin = coin::take(escrowed_balance_mut, amount, ctx);
        let id = object::new(ctx);
        let key_id = object::uid_to_inner(&id);
        transfer::public_share_object(Escrow<T> {
            id: object::new(ctx),
            sender: tx_context::sender(ctx),
            recipient: recipient,
            escrowed: taken_coin,
            key_id: key_id
        });
        EscrowKey<T> { id: key_id }
    }

}