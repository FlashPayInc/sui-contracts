module defi::constant_sum_amm {
    use sui::object::{Self, UID, ID};
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance, Supply};
    use sui::transfer;
    use sui::event;
    use sui::tx_context::{Self, TxContext};

    const MINIMUM_LIQUIDITY: u64 = 1000;

    struct PoolToken<phantom CoinType0, phantom CoinType1> has drop {
    }

    struct Pool<phantom CoinType0, phantom CoinType1> has key {
        id: UID,
        reserve0: Balance<CoinType0>,
        reserve1: Balance<CoinType1>,
        lp_supply: Supply<PoolToken<CoinType0, CoinType1>>,
        lp_locked: Balance<PoolToken<CoinType0, CoinType1>>,
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
            lp_locked: balance::zero<PoolToken<CoinType0, CoinType1>>(),
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

    public entry fun add_liquidity<CoinType0, CoinType1>(pool: &mut Pool<CoinType0, CoinType1>, balance0: Balance<CoinType0>, balance1: Balance<CoinType1>, ctx: &mut TxContext): Coin<PoolToken<CoinType0, CoinType1>> {
        let amount_0_in = balance::value(&balance0);
        let amount_1_in = balance::value(&balance1);
        let reserve_0 = balance::value(&pool.reserve0);
        let reserve_1 = balance::value(&pool.reserve1);
        let pool_token_supply = balance::supply_value(&pool.lp_supply);

        let liquidity: u64;
        if (pool_token_supply == 0) {
            liquidity = amount_0_in + amount_1_in - MINIMUM_LIQUIDITY;
            let locked_liquidity = balance::increase_supply(&mut pool.lp_supply, MINIMUM_LIQUIDITY);
            balance::join(&mut pool.lp_locked, locked_liquidity);
        } else {
            liquidity = (pool_token_supply * (amount_0_in + amount_1_in))/(reserve0 + reserve1);
        };

        balance::join(&mut pool.reserve0, amount_0_in);
        balance::join(&mut pool.reserve1, amount_1_in);

        let lp_token_balance = balance::increase_supply(&mut pool.lp_supply, liquidity);
        coin::from_balance(lp_token_balance, ctx)
    }

    public entry fun remove_liquidity() {

    }

    public entry fun swap() {

    }
}