module defi::constant_sum_amm {
    use sui::object::{Self, UID, ID};
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance, Supply};
    use sui::transfer;
    use sui::event;
    use sui::tx_context::{Self, TxContext};

    const MINIMUM_LIQUIDITY: u64 = 1000;
    const ADD_LIQUIDITY_EVENT: u64 = 0;
    const REMOVE_LIQUIDITY_EVENT: u64 = 1;
    const EInsufficientLiquidityMinted: u64 = 0;
    const EInvalidOperation: u64 = 1;

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

    struct LiquidityEvent has copy, drop {
        pool_id: ID,
        sender: address,
        type: u64,
        amount_0: u64,
        amount_1: u64,
        liquidity: u64
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

    fun get_pool_reserves<CoinType0, CoinType1>(pool: &mut Pool<CoinType0, CoinType1>): (u64, u64) {
        let reserve_0 = balance::value(&pool.reserve0);
        let reserve_1 = balance::value(&pool.reserve1);
        (reserve_0, reserve_1)
    }

    public entry fun add_liquidity<CoinType0, CoinType1>(pool: &mut Pool<CoinType0, CoinType1>, balance0: Balance<CoinType0>, balance1: Balance<CoinType1>, ctx: &mut TxContext): Coin<PoolToken<CoinType0, CoinType1>> {
        let amount_0_in = balance::value(&balance0);
        let amount_1_in = balance::value(&balance1);
        let (reserve_0, reserve_1) = get_pool_reserves(pool);
        let pool_token_supply = balance::supply_value(&pool.lp_supply);

        let liquidity: u64;
        if (pool_token_supply == 0) {
            liquidity = amount_0_in + amount_1_in - MINIMUM_LIQUIDITY;
            let locked_liquidity = balance::increase_supply(&mut pool.lp_supply, MINIMUM_LIQUIDITY);
            balance::join(&mut pool.lp_locked, locked_liquidity);
        } else {
            liquidity = (pool_token_supply * (amount_0_in + amount_1_in))/(reserve_0 + reserve_1);
        };
        assert!(liquidity > 0, EInsufficientLiquidityMinted);
        balance::join(&mut pool.reserve0, balance0);
        balance::join(&mut pool.reserve1, balance1);

        let lp_token_balance = balance::increase_supply(&mut pool.lp_supply, liquidity);
        event::emit(LiquidityEvent {
            pool_id: object::id(pool),
            sender: tx_context::sender(ctx),
            type: ADD_LIQUIDITY_EVENT,
            amount_0: amount_0_in,
            amount_1: amount_1_in,
            liquidity: liquidity
        });
        coin::from_balance(lp_token_balance, ctx)
    }

    fun calc_liquidity_out(to_burn: u64, reserve_0: u64, reserve_1: u64, total_liq: u64): (u64, u64) {
        let amount_0_out = (reserve_0 * to_burn)/total_liq;
        let amount_1_out = (reserve_1 * to_burn)/total_liq;

        assert!(amount_0_out > 0 && amount_1_out > 0, EInvalidOperation);
        (amount_0_out, amount_1_out)
    }

    public entry fun remove_liquidity<CoinType0, CoinType1>(pool: &mut Pool<CoinType0, CoinType1>, liquidity: Balance<PoolToken<CoinType0, CoinType1>>, ctx: &mut TxContext): (Coin<CoinType0>, Coin<CoinType1>) {
        let liquidity_to_burn = balance::value(&liquidity);
        let total_liquidity = balance::supply_value(&pool.lp_supply);
        let (reserve_0, reserve_1) = get_pool_reserves(pool);

        let (amount_0_out, amount_1_out) = calc_liquidity_out(liquidity_to_burn, reserve_0, reserve_1, total_liquidity);

        balance::decrease_supply(&mut pool.lp_supply, liquidity);

        let coin_out_0 = coin::from_balance(balance::split(&mut pool.reserve0, amount_0_out), ctx);
        let coin_out_1 = coin::from_balance(balance::split(&mut pool.reserve1, amount_1_out), ctx);
        event::emit(LiquidityEvent {
            pool_id: object::id(pool),
            sender: tx_context::sender(ctx),
            type: REMOVE_LIQUIDITY_EVENT,
            amount_0: amount_0_out,
            amount_1: amount_1_out,
            liquidity: liquidity_to_burn
        });
        (coin_out_0, coin_out_1)
    }

    public entry fun swap() {

    }
}