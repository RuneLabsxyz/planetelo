use starknet::ContractAddress;
#[derive(Drop, Serde)]
#[dojo::model(namespace: "planetelo", nomapping: true)]
struct Player {
    #[key]
    address: ContractAddress,
    name: felt252,
}

#[dojo::interface]
trait IPlanetelo {
    fn register_player(ref world: IWorldDispatcher, name: felt252);
}

#[dojo::contract(namespace = "planetelo")]
mod planetelo {
    use super::{Player, IPlanetelo};
    use planetary_interface::interfaces::one_on_one::{IOneOnOne, Status};
    use planetary_interface::utils::systems::{get_world_contract_address};
    use planetary_interface::interfaces::pistols64::{
        Pistols64Interface, Pistols64InterfaceTrait, IPistols64ActionsDispatcher, IPistols64ActionsDispatcherTrait};
    use starknet::{ContractAddress, get_caller_address};
    use pistols64::models::challenge::Challenge;
    #[abi(embed_v0)]
    impl PlaneteloInterfaceImpl of IPlanetelo<ContractState> {
        fn register_player(ref world: IWorldDispatcher, name: felt252) {
            let address = get_caller_address();
            let player = Player {
                address,
                name,
            };
            set!(world, (player));
        }
    }

    #[abi(embed_v0)]
    impl OneOnOneImpl of IOneOnOne<ContractState> {
        fn create_match(ref world: IWorldDispatcher, p1: ContractAddress, p2: ContractAddress, playlist_id:u128) -> u128{
            let pistols: IPistols64ActionsDispatcher = Pistols64InterfaceTrait::new().dispatcher();
            let player1 = get!(world, p1, (Player));
            let player2 = get!(world, p2, (Player));
            assert!(player1.name != '');
            assert!(player2.name != '');

            let id: u128 = pistols.create_challenge(player1.name, player2.name, 'planetelo').into();
            id
        }

        fn settle_match(ref world: IWorldDispatcher, match_id: u128) -> Status {
            let pistols: IPistols64ActionsDispatcher = Pistols64InterfaceTrait::new().dispatcher();
            let result = pistols.get_challenge_results(match_id);
            let challenge = get!(world, match_id, (Challenge));

            if result.is_finished {
                if result.winner == 1 {
                    Status::Winner(challenge.address_a)
                } else if result.winner == 2 {
                    Status::Winner(challenge.address_b)
                } else {
                    Status::Draw
                }
            } else {    
                Status::None
            }
        }
    }
}


