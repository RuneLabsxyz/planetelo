use starknet::ContractAddress;
use dojo::world::storage::{WorldStorage, WorldStorageTrait};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use planetelo_interface::interfaces::planetary::{
    PlanetaryInterface,
    PlanetaryInterfaceTrait,
    IPlanetaryActions, 
    IPlanetaryActionsDispatcher,
    IPlanetaryActionsDispatcherTrait
};
use dojo::model::{ModelStorage, ModelValueStorage, Model};


use starknet::contract_address_const;


use planetelo::models::{QueueStatus, Queue, Game, QueueMember};

use planetelo::consts::ELO_DIFF;

use planetelo_interface::interfaces::planetelo::{
    IOneOnOneDispatcher, IOneOnOneDispatcherTrait, Status
};

use planetelo::elo::{EloTrait, EloImpl};

fn get_planetelo_address(world_address: ContractAddress) -> ContractAddress {
    let mut world = IWorldDispatcher {contract_address: world_address};
    let mut world_storage = WorldStorageTrait::new(world, @"planetelo");
    let maybe_planetelo = world_storage.dns(@"planetelo");

    match maybe_planetelo {
        Option::Some((address, _)) => address,
        Option::None => panic!("Error Getting Planetelo Address"),
    }

}

fn get_planetelo_dispatcher(game: felt252) -> IOneOnOneDispatcher {

    let planetary: PlanetaryInterface = PlanetaryInterfaceTrait::new();

    let world_address = planetary.dispatcher().get_world_address(game);

    match world_address {
        Option::Some(address) => {
            let planetelo_address = get_planetelo_address(address);
            IOneOnOneDispatcher{ contract_address: planetelo_address }
        },
        Option::None => panic!("Error Getting World Address??"),
    }
    let address = world_address.unwrap();


    assert!(address != starknet::contract_address_const::<0x0>(), "Error Getting World Address???");

 
    let planetelo_address = get_planetelo_address(address);
    IOneOnOneDispatcher{ contract_address: planetelo_address }
}

fn find_match(ref members: Array<QueueMember>, ref player: QueueMember) -> Option<QueueMember> {
    let mut found = false;
    let mut res = Option::None;
    let mut potential_index = player.clone();



    assert!(player.elo != 0, "Player elo must be set");
    
    loop {
        match members.pop_front() {
            Option::Some(potential_index) => {
                    assert!(potential_index.elo != 0, "Potential index elo must be set");
                    let mut elo_diff = 0;
                    if potential_index.elo > player.elo {
                        elo_diff = potential_index.elo - player.elo;
                    }
                    else {
                        elo_diff = player.elo - potential_index.elo;
                    }
                    if elo_diff < ELO_DIFF {
                        res = Option::Some(potential_index);
                        break;
                    }
            },
            Option::None => {
                panic!("??");
                break;
            }
        }
    };
    res

}

fn get_queue_members(world: WorldStorage, game: felt252, playlist: u128) -> Array<QueueMember> {
    let mut members: Array<QueueMember> = ArrayTrait::new();
    let queue: Queue = world.read_model((game, playlist));
    let mut i = 0;
    while i < queue.length {
        let member: QueueMember = world.read_model((game, playlist, i));
        assert!(member.elo != 0, "Member elo must be set");
        members.append(member);
        i+=1;
    };
    members
}

fn get_queue_members_except_player(world: WorldStorage, game: felt252, playlist: u128, player: ContractAddress) -> Array<QueueMember> {
    let mut members: Array<QueueMember> = ArrayTrait::new();
    let queue: Queue = world.read_model((game, playlist));
    let mut i = 0;
    while i < queue.length {
        let member: QueueMember = world.read_model((game, playlist, i));
        assert!(member.elo != 0, "Member elo must be set");
        if member.player != player {
            members.append(member);
        }
        i+=1;
    };
    members
}

fn update_elos(status: Status, game_model: @Game, one_elo: @u64, two_elo: @u64) -> (u64, u64) {
    let mut p1_elo = *one_elo;
    let mut p2_elo = *two_elo;
    
    match status {
        Status::None => {
            panic!("Match has doesn't exist");
        },
        Status::Active => {
            panic!("Match is still active");
        },
        Status::Draw => {
            let (mag, sign) = EloTrait::rating_change(*one_elo, *two_elo, 50_u16, 20_u8);
            assert!(mag != 0, "elo should change");
            if sign {
                p1_elo += mag;
                p2_elo -= mag;
            }
            else {
                p1_elo -= mag;
                p2_elo += mag;
            }

        },
        Status::Winner(winner) => {

            let mut did_win: u16 = 0;

            if winner == *game_model.player1 {
                did_win = 100;
            }
            assert!(p1_elo != 0, "elo should not be 0");
            assert!(p2_elo != 0, "elo should not be 0");
            let (mag, sign) = EloTrait::rating_change(*one_elo, *two_elo, did_win, 20_u8);
            assert!(mag != 0, "mag shouldnt be 0 should change");
            if !sign {
                p1_elo += mag;
                p2_elo -= mag;
            }   
            else {
                p1_elo -= mag;
                p2_elo += mag;
            }

        }
    }
    (p1_elo, p2_elo)

}


#[cfg(test)]
mod tests {
    // Local imports

    use planetelo::elo::{EloTrait};

    #[test]
    fn test_elo_change_positive_01() {
        let (mag, sign) = EloTrait::rating_change(1200_u64, 1400_u64, 100_u16, 20_u8);
        assert(mag == 15, 'Elo: wrong change mag');
        assert(!sign, 'Elo: wrong change sign');
    }

    #[test]
    fn test_elo_change_positive_02() {
        let (mag, sign) = EloTrait::rating_change(1300_u64, 1200_u64, 100_u16, 20_u8);
        assert(mag == 7, 'Elo: wrong change mag');
        assert(!sign, 'Elo: wrong change sign');
    }

    #[test]
    fn test_elo_change_positive_03() {
        let (mag, sign) = EloTrait::rating_change(1900_u64, 2100_u64, 100_u16, 20_u8);
        assert(mag == 15, 'Elo: wrong change mag');
        assert(!sign, 'Elo: wrong change sign');
    }

    #[test]
    fn test_elo_change_negative_01() {
        let (mag, sign) = EloTrait::rating_change(1200_u64, 1400_u64, 0_u16, 20_u8);
        assert(mag == 5, 'Elo: wrong change mag');
        assert(sign, 'Elo: wrong change sign');
    }

    #[test]
    fn test_elo_change_negative_02() {
        let (mag, sign) = EloTrait::rating_change(1300_u64, 1200_u64, 0_u16, 20_u8);
        assert(mag == 13, 'Elo: wrong change mag');
        assert(sign, 'Elo: wrong change sign');
    }

    #[test]
    fn test_elo_change_draw() {
        let (mag, sign) = EloTrait::rating_change(1200_u64, 1400_u64, 50_u16, 20_u8);
        assert(mag == 5, 'Elo: wrong change mag');
        assert(!sign, 'Elo: wrong change sign');
    }
}