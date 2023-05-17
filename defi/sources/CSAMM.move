module defi::constant_sum_amm {
    use sui::object::{Self, UID, ID};
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance, Supply};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    // Pool Token type for pool share
    // P: Witness of the Pool
    // T0: Token0 Type
    // T1: Token1 Type
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
        
        
    }

    public entry fun swap() {

    }

    public entry fun add_liquidity() {

    }

    public entry fun remove_liquidity() {

    }

}