use starknet::ContractAddress;

#[starknet::interface]
pub trait IOneOnOne<TState> {
    fn create_match(ref self: TState, p1: ContractAddress, p2: ContractAddress, playlist_id: u32) -> u32;
    fn settle_match(ref self: TState, match_id: u32) -> Status;

}

#[derive(Drop, Serde)]
pub enum Status {
    None,
    Active,
    Draw,
    Winner: ContractAddress,

}