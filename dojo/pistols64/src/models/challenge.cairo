use starknet::ContractAddress;
use pistols64::types::state::ChallengeState;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Challenge {
    #[key]
    pub duel_id: u128,
    //-------------------------
    pub address_a: ContractAddress,     // Challenger wallet
    pub address_b: ContractAddress,     // Challenged wallet
    pub duelist_name_a: felt252,        // Challenger name
    pub duelist_name_b: felt252,        // Challenged name 
    pub message: felt252,               // message to challenged
    // progress and results
    pub state: ChallengeState,
    pub winner: u8,                     // 0:draw, 1:duelist_a, 2:duelist_b
}


//--------------------------
// Traits
//

trait ChallengeTrait {
    fn duelist_number(self: Challenge, duelist_name: felt252) -> u8;
}

impl ChallengeTraitImpl of ChallengeTrait {
    fn duelist_number(self: Challenge, duelist_name: felt252) -> u8 {
        (
            if (self.duelist_name_a == duelist_name) { 1 }
            else if (self.duelist_name_b == duelist_name) { 2 }
            else { 0 }
        )
    }
}