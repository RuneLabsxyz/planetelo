
#[starknet::interface]
trait IOneOnOne<TState> {
    fn create_match(ref self: TState, p1: ContractAddress, p2: ContractAddress) -> u32;
    fn settle_match(ref self: TState, match_id: u32);

}