use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Elo {
    #[key]
    pub player: ContractAddress,
    #[key]
    pub game: felt252,
    #[key]
    pub playlist: u128,
    pub value: u64,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Status {
    #[key]
    pub player: ContractAddress,
    #[key]
    pub game: felt252,
    #[key]
    pub playlist: u128,
    pub status: QueueStatus,
    pub index: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Queue {
    #[key]
    pub game: felt252,
    #[key]
    pub playlist: u128,
    pub length: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct QueueIndex {
    #[key]
    pub game: felt252,
    #[key]
    pub index: u32,
    pub player: ContractAddress,
    pub timestamp: u64
}

#[derive(Copy, Drop, Serde, Introspect)]
pub enum QueueStatus {
    None,
    Queued,
    InGame: u32
}      