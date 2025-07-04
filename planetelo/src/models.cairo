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
pub struct Player {
    #[key]
    pub player: ContractAddress,
    pub games_played: u32,
    pub queues_joined: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct PlayerStatus {
    #[key]
    pub player: ContractAddress,
    #[key]
    pub game: felt252,
    #[key]
    pub playlist: u128,
    pub status: QueueStatus,
    pub index: u128
}

#[derive(Clone, Drop, Serde)]
#[dojo::model]
pub struct Queue {
    #[key]
    pub game: felt252,
    #[key]
    pub playlist: u128,
    pub length: u128
}

#[derive(Clone, Drop, Serde, Introspect)]
#[dojo::model]
pub struct QueueMember {
    #[key]
    pub game: felt252,
    #[key]
    pub playlist: u128,
    #[key]
    pub index: u128,
    pub player: ContractAddress,
    pub timestamp: u64,
    pub elo: u64
}

#[derive(Clone, Drop, Serde)]
#[dojo::model]
pub struct Game {
    #[key]
    pub game: felt252,
    #[key]
    pub id: u128,
    pub playlist: u128,
    pub player1: ContractAddress,
    pub player2: ContractAddress,
    pub timestamp: u64
}

#[derive(Copy, Drop, Serde, Introspect, PartialEq)]
pub enum QueueStatus {
    None,
    Queued,
    InGame: u128
}      

#[derive(Clone, Drop, Serde)]
#[dojo::model]
pub struct Global {
    #[key]
    pub key: u32,
    pub nonce: u128
}

#[generate_trait]
impl GlobalImpl of GlobalTrait {
    fn uuid(ref self: Global) -> u128 {
        let id = self.nonce;
        self.nonce += 1;
        id
    }
}