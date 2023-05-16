module defi::constant_sum_amm {
    use sui::object::{Self, UID, ID};
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance, Supply};
    use sui::tx_context::{Self, TxContext};

    // Pool Token type for pool share
    // P: Witness of the Pool
    // T0: Token0 Type
    // T1: Token1 Type
    struct PoolToken<phantom P, phantom T0, phantom T1> has drop {
    }

    struct Pool<phantom P, phantom T0, phantom T1> has key {
        id: UID,
        reserve0: Balance<T0>,
        reserve1: Balance<T1>,
        pt_supply: Supply<PoolToken<P, T0, T1>>
    }

    public entry fun create_pool<P: drop, T0, T1>(token0: Coin<T0>, token1: Coin<T1>, ctx: &mut TxContext) {
        
    }

    public entry fun swap() {

    }

    public entry fun add_liquidity() {

    }

    public entry fun remove_liquidity() {

    }

}