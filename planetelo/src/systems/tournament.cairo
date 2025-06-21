use starknet::ContractAddress;
#[starknet::interface]
trait ITournamentActionsDispatcher<T> {
    fn create_tournament(ref self: T, game: felt252, playlist: u128, config: TournamentConfig) -> u128;
    fn join_tournament(ref self: T, tournament_id: u128);
    fn start_tournament(ref self: T, tournament_id: u128);
    fn advance_tournament(ref self: T, tournament_id: u128);
}


#[derive(Copy, Drop, Serde, Introspect)]
pub struct TournamentConfig {
    swiss_rounds: u8,
    top_cut: u8, //as a power of 2 (top 8 = 3, top 16 = 4, etc.)
    entry_time: u64
}

#[derive(Copy, Drop, Serde, Introspect, PartialEq)]
pub enum TournamentStatus {
    Joining,
    InRound,
    RoundSettled,
    Finished
}   

pub const GLOBAL_TOURNAMENT_ID: u128 = 0;

#[derive(Drop, Serde)]
#[dojo::model]
pub struct GlobalTournament {
    #[key]
    id: u128,
    tournament_count: u128,
}   

#[generate_trait]
impl GlobalTournamentImpl of GlobalTournamentTrait {
    fn get_id(ref self: GlobalTournament) -> u128 {
        self.tournament_count += 1;
        self.tournament_count
    }
}

#[derive(Drop, Serde)]
#[dojo::model]
pub struct Tournament {
    #[key]
    id: u128,
    game: felt252,
    playlist: u128,
    round: u8,
    round_start_time: u64,
    config: TournamentConfig,
    pairings: Array<Pairing>,
    status: TournamentStatus
}

#[derive(Copy, Drop, Serde, Introspect)]
pub struct Pairing {
    player_1: ContractAddress,
    player_2: ContractAddress,
    game_id: u128,
    status: u8, //0 = waiting, 1 = in_game, 2 = finished
}


#[derive(Drop, Serde)]
#[dojo::model]
pub struct Pool {
    #[key]
    tournament_id: u128,
    #[key]
    wins: u8,
    players: Array<ContractAddress>,
}


#[dojo::contract]
mod tournament {

    use super::{ITournamentActionsDispatcher, 
                Tournament,
                TournamentConfig, 
                TournamentStatus,
                Pool, 
                GlobalTournament,
                GlobalTournamentTrait, 
                GLOBAL_TOURNAMENT_ID,
                Pairing
        };
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp, contract_address_const};
    use planetelo_interface::interfaces::planetary::{
        PlanetaryInterface, PlanetaryInterfaceTrait,
        IPlanetaryActionsDispatcher, IPlanetaryActionsDispatcherTrait,
    };
    use dojo::model::{ModelStorage, ModelValueStorage, Model};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};


    use planetelo_interface::interfaces::planetelo::{
        IOneOnOneDispatcher, IOneOnOneDispatcherTrait, Status
    };    

    #[abi(embed_v0)]
    impl TournamentImpl of ITournamentActionsDispatcher<ContractState> {
        fn create_tournament(ref self: ContractState, game: felt252, playlist: u128, config: TournamentConfig) -> u128 {
            let mut world = self.world(@"planetelo");

            let mut global_tournament: GlobalTournament = world.read_model(GLOBAL_TOURNAMENT_ID);   

            let tournament_id = global_tournament.get_id();
            let tournament = Tournament { 
                id: tournament_id, 
                game, 
                playlist,
                round:1, 
                config, 
                round_start_time: get_block_timestamp(), 
                pairings: ArrayTrait::new(),
                status: TournamentStatus::Joining
            };
            world.write_model(@tournament);
            world.write_model(@global_tournament);
            tournament_id
        }   

        fn join_tournament(ref self: ContractState, tournament_id: u128) {
            let mut world = self.world(@"planetelo");

            let tournament: Tournament = world.read_model(tournament_id);

            assert!(tournament.round == 1, "Tournament not joinable");
            let mut pool: Pool = world.read_model((tournament_id, 0));

            let player = get_caller_address();
            pool.players.append(player);

            world.write_model(@pool);
            
        }

        fn start_tournament(ref self: ContractState, tournament_id: u128) {
            let mut world = self.world(@"planetelo");

            let mut tournament: Tournament = world.read_model(tournament_id);

            assert!(tournament.round_start_time + tournament.config.entry_time < get_block_timestamp(), "Tournament not started");

            tournament.round_start_time = get_block_timestamp();

            let mut pool: Pool = world.read_model((tournament_id, 0));
            let mut i = 0;


            while i+1 < pool.players.len() {
                let p1 = *pool.players[i];
                let p2 = *pool.players[i+1];

           //     let game_id = dispatcher.create_match(  p1, p2, tournament.playlist);    

                let pairing = Pairing {
                    player_1: p1,
                    player_2: p2,
                    game_id: 0,
                    status: 0,
                };
                tournament.pairings.append(pairing);
                i+=2;

            };


            world.write_model(@tournament);
        }

        fn advance_tournament(ref self: ContractState, tournament_id: u128) {
            let mut world = self.world(@"planetelo");
            let mut tournament: Tournament = world.read_model(tournament_id);

            assert!(tournament.status == TournamentStatus::InRound, "Tournament not in round");


            tournament.round += 1;

            world.write_model(@tournament);

        }



    }
}   