use planetary_interface::interfaces::octoguns::Settings;
use octoguns::consts::GLOBAL_KEY;

#[derive(Drop, Serde)]
#[dojo::model(namespace: "planetelo", nomapping: true)]
struct Playlist {
    #[key]
    id: u128,
    maps: Array<u32>,
    settings: Settings
}


#[derive(Copy, Drop, Serde)]
#[dojo::model(namespace: "planetelo", nomapping: true)]
struct PlaylistGlobal {
    #[key]
    global_key: u32,
    playlist_count: u32
}

#[dojo::interface]
trait IPlanetelo {
    fn create_playlist(ref world: IWorldDispatcher, maps: Array<u32>, settings: Settings) -> u32;
}

#[dojo::contract(namespace: "planetelo")]
mod planetelo {
    use octoguns::consts::GLOBAL_KEY;
    use super::{Playlist, PlaylistGlobal, IPlanetelo};
    use planetary_interface::interfaces::one_on_one::{IOneOnOne, Status};
    use planetary_interface::utils::systems::{get_world_contract_address};
    use planetary_interface::interfaces::octoguns::{
        OctogunsInterface, OctogunsInterfaceTrait, 
        IOctogunsStartDispatcher, IOctogunsStartDispatcherTrait, Settings};
    use octoguns::lib::dice::{Dice, DiceTrait};
    use octoguns::models::sessions::{Session, SessionMeta};
    use starknet::{ContractAddress, get_block_timestamp};

    #[abi(embed_v0)]
    impl PlaneteloInterfaceImpl of IPlanetelo<ContractState> {
        fn create_playlist(ref world: IWorldDispatcher, maps: Array<u32>, settings: Settings) -> u32 {
            let mut global = get!(world, GLOBAL_KEY, (PlaylistGlobal));
            let id = global.playlist_count;
            global.playlist_count += 1;

            let playlist = Playlist {
                id,
                maps,
                settings
            };
            set!(world, (global, playlist));
            id
        }
    }

    #[abi(embed_v0)]
    impl OneOnOneImpl of IOneOnOne<ContractState> {
        fn create_match(ref world: IWorldDispatcher, p1: ContractAddress, p2: ContractAddress, playlist_id: u128) -> u128{
            let octoguns_interface = OctogunsInterfaceTrait::new();
            let start_dispatcher: IOctogunsStartDispatcher = octoguns_interface.start_dispatcher();

            let global = get!(world, GLOBAL_KEY, (PlaylistGlobal));
            assert!(playlist_id < global.playlist_count.into(), "Playlist does not exist");

            let playlist = get!(world, playlist_id, (Playlist));

            let map_count = playlist.maps.len();

            let seed: felt252 = starknet::get_block_timestamp().into();
            let mut dice = DiceTrait::new(map_count, seed);
            let map_index = dice.roll() - 1;

            let map_id = playlist.maps[map_index];

            let id: u128 = start_dispatcher.create_closed(*map_id, p1, p2, playlist.settings).into();
            id
        }

        fn settle_match(ref world: IWorldDispatcher, match_id: u128) -> Status {
            let session = get!(world, match_id, (Session));
            let session_meta = get!(world, match_id, (SessionMeta));

            match session.state {
                0 => {
                    Status::None
                },
                1 => {
                    Status::Active
                },
                2 => {
                    Status::Active
                },
                3 => {
                    if session_meta.p1_character == 0 && session_meta.p2_character == 0 {
                        Status::Draw
                    } else if session_meta.p1_character == 0 {
                        Status::Winner(session.player2)
                    } else if session_meta.p2_character == 0 {
                        Status::Winner(session.player1)
                    } else {
                        Status::Draw
                    }
                },
                _ => {
                    Status::None
                }
            }
        }
    }
}


