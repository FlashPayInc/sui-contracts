module defi::constant_sum_amm {
    use sui::object::{Self, UID, ID};
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance, Supply};
    use sui::transfer;
    use sui::event;
    use sui::tx_context::{Self, TxContext};

    struct PoolToken<phantom CoinType0, phantom CoinType1> has drop {
    }

    struct Pool<phantom CoinType0, phantom CoinType1> has key {
        id: UID,
        reserve0: Balance<CoinType0>,
        reserve1: Balance<CoinType1>,
        lp_supply: Supply<PoolToken<CoinType0, CoinType1>>,
        lp_balance: Balance<PoolToken<CoinType0, CoinType1>>,
        trade_fee: u64
    }

    struct CreatePoolEvent has copy, drop {
        pool_id: ID,
        created_by: address,
        time_stamp: u64
    }

    public entry fun create_pool<CoinType0, CoinType1>(trade_fee: u64, ctx: &mut TxContext) {
        let pool = Pool<CoinType0, CoinType1> {
            id: object::new(ctx),
            reserve0: balance::zero<CoinType0>(),
            reserve1: balance::zero<CoinType1>(),
            lp_supply: balance::create_supply(PoolToken<CoinType0, CoinType1>{}),
            lp_balance: balance::zero<PoolToken<CoinType0, CoinType1>>(),
            trade_fee: trade_fee
        };
        let pool_id = object::id(&pool);
        transfer::share_object(pool);
        event::emit(CreatePoolEvent {
            pool_id: pool_id,
            created_by: tx_context::sender(ctx),
            time_stamp: tx_context::epoch_timestamp_ms(ctx)
        })
    }

    public entry fun swap() {

    }

    public entry fun add_liquidity() {

    }

    public entry fun remove_liquidity() {

    }

}