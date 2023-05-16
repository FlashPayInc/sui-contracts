module defi::cheque {
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    const INSUFFICIENT_BALANCE: u64 = 0;
    const NOT_PERMITTED: u64 = 0;

    struct Cheque has key {
        id: UID,
        issuer: address,
        recipient: address,
        asset: Coin<SUI>
    }

    public entry fun create_cheque(recipient: address, asset: &mut Coin<SUI>, amount: u64, ctx: &mut TxContext){
        assert!(coin::value(asset) >= amount, INSUFFICIENT_BALANCE);
        let asset_balance_mut = coin::balance_mut(asset);
        let taken_asset = coin::take(asset_balance_mut, amount, ctx);

        transfer::transfer(Cheque {
            id: object::new(ctx),
            issuer: tx_context::sender(ctx),
            recipient: recipient,
            asset: taken_asset
        }, recipient)
    }

    public entry fun cash_cheque(cheque: Cheque, ctx: &mut TxContext) {
        let Cheque {
            id: cheque_id,
            issuer: _cheque_issuer,
            recipient: cheque_recipient,
            asset: to_cash
        } = cheque;
        assert!(tx_context::sender(ctx) == cheque_recipient, NOT_PERMITTED);
        object::delete(cheque_id);
        transfer::public_transfer(to_cash, cheque_recipient);
    }
}