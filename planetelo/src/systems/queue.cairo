// define the interface
use planetelo::models::QueueStatus;
use planetelo::models::QueueMember;
use dojo::model::{ModelStorage, ModelValueStorage, Model};
use dojo::world::storage::{WorldStorage, WorldStorageTrait};

#[starknet::interface]
trait IQueue<T> {
    fn queue(ref self: T, game: felt252, playlist: u128);
    fn dequeue(ref self: T, game: felt252, playlist: u128);
    fn matchmake(ref self: T, game: felt252, playlist: u128);
    fn settle(ref self: T, game: felt252, game_id: u128);
    fn get_elo(self: @T, address: starknet::ContractAddress, game: felt252, playlist: u128) -> u64;
    fn get_queue_length(self: @T, game: felt252, playlist: u128) -> u128;
    fn get_status(self: @T, address: starknet::ContractAddress, game: felt252, playlist: u128) -> u8;
    fn get_queue_members(self: @T, game: felt252, playlist: u128) -> Array<QueueMember>;
    fn get_player_game_id(self: @T, address: starknet::ContractAddress, game: felt252, playlist: u128) -> u128;
    fn end_game(ref self: T, game: felt252, game_id: u128);
}

// dojo decorator
#[dojo::contract]
mod queue {

    use super::{IQueue};
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp, contract_address_const};
 
    use dojo::model::{ModelStorage, ModelValueStorage, Model};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use dojo::world::storage::{WorldStorage, WorldStorageTrait};


    use planetelo_interface::interfaces::planetelo::{
        IOneOnOneDispatcher, IOneOnOneDispatcherTrait, Status
    };

    use planetelo_interface::interfaces::planetary::{
        PlanetaryInterface, PlanetaryInterfaceTrait,
        IPlanetaryActions, 
        IPlanetaryActionsDispatcher, IPlanetaryActionsDispatcherTrait
    };

    use planetelo::models::{PlayerStatus, QueueStatus, Elo, QueueMember, Game, Queue, Player, Global, GlobalTrait};
    use planetelo::elo::EloTrait;
    use planetelo::consts::ELO_DIFF;
    use planetelo::helpers::helpers::{
        find_match, 
        get_planetelo_dispatcher, 
        update_elos, 
        get_queue_members, 
        get_queue_members_except_player,
        get_planetelo_address
    };
    use planetelo::helpers::queue_update::update_queue;

    #[abi(embed_v0)]
    impl QueueImpl of IQueue<ContractState> {
        

        fn queue(ref self: ContractState, game: felt252, playlist: u128) {
            let address = get_caller_address();
            let mut world = self.world(@"planetelo");
            let mut player: PlayerStatus = world.read_model((address, game, playlist));
            let mut elo: Elo = world.read_model((address, game, playlist));
            let mut player_model: Player = world.read_model((address));
            if elo.value == 0 {
                elo.value = 800;
                world.write_model(@elo);
            }

            assert!(player.status == QueueStatus::None, "Player is already in the queue");
            player_model.queues_joined += 1;

            let mut queue: Queue = world.read_model((game, playlist));
            let index = queue.length;
            assert!(elo.value != 0, "Elo must be set");
            let new = QueueMember {
                game,
                playlist,
                index,
                player: address,
                timestamp: get_block_timestamp(),
                elo: elo.value
            };
            queue.length += 1;

            player.status = QueueStatus::Queued;
            player.index = index;

            world.write_model(@player_model);
            world.write_model(@player);
            world.write_model(@new);
            world.write_model(@queue);
            
        }


        fn dequeue(ref self: ContractState, game: felt252, playlist: u128) {
            let address = get_caller_address();
            let mut world = self.world(@"planetelo");

            let mut player: PlayerStatus = world.read_model((address, game));

            assert!(player.status != QueueStatus::None, "Player is not in the queue");
            //todo reimplement this
        }

        fn matchmake(ref self: ContractState, game: felt252, playlist: u128) {
            let address = get_caller_address();
            let mut world = self.world(@"planetelo");

            let mut player_status: PlayerStatus = world.read_model((address, game, playlist));

            assert!(player_status.status != QueueStatus::None, "Player is not in the queue");
            let timestamp = get_block_timestamp();

            let mut p1: QueueMember = world.read_model((game, playlist, player_status.index));

            assert!(p1.elo != 0, "player member elo should be set");

            let time_diff = timestamp - p1.timestamp;
            let time_diff_secs = time_diff;

            let mut queue: Queue = world.read_model((game, playlist));
            assert!(queue.length > 1, "There must be at least 2 players in the queue to matchmake");

            let mut status: QueueStatus = QueueStatus::None;

            let mut p2: QueueMember = QueueMember { game, playlist, index: 0, player: contract_address_const::<0x0>(), timestamp: 0, elo: 0 };

            let mut members = get_queue_members_except_player(world, game, playlist, address);
            let maybe_match = find_match(ref members, ref p1);

            match maybe_match {
                Option::Some(match_member) => {
                    p2 = match_member;
                },
                Option::None => {
                    panic!("No match found?");
                }
            }

            let dispatcher = get_planetelo_dispatcher(game);
            let p1_address = @p1.player;
            let p2_address = @p2.player;

            let game_id = dispatcher.create_match(  *p1_address, *p2_address, playlist);

            let mut opponent_status: PlayerStatus = world.read_model((*p2_address, game, playlist));

            status = QueueStatus::InGame(game_id);
            assert!(p1.player != contract_address_const::<0x0>(), "Player 1 should be set");
            assert!(p2.player != contract_address_const::<0x0>(), "Player 2 should be set");
            
            player_status.status = status;
            opponent_status.status = status;
            player_status.index = 0;
            opponent_status.index = 0;

            update_queue(ref world, game, playlist, ref p1, ref p2);

            let game_model: Game = Game {
                game,
                playlist,
                player1: *p1_address,
                player2: *p2_address,
                id: game_id,
                timestamp: get_block_timestamp()
            };

            world.write_model(@game_model);
            world.write_model(@player_status);
            world.write_model(@opponent_status);
            
        }

        fn settle(ref self: ContractState, game: felt252, game_id: u128) {

            let mut world = self.world(@"planetelo");

            let mut game_model: Game = world.read_model((game, game_id));
            assert!(game_model.player1 != contract_address_const::<0x0>(), "Player 1 should be set");
            assert!(game_model.player2 != contract_address_const::<0x0>(), "Player 2 should be set");

            let planetary: PlanetaryInterface = PlanetaryInterfaceTrait::new();
            let planetary_actions = planetary.dispatcher();

            let planetelo_address = get_planetelo_address(planetary_actions.get_world_address(game).unwrap());
            
            let dispatcher = IOneOnOneDispatcher{ contract_address: planetelo_address };

            let status = dispatcher.settle_match(game_id);
            
            let mut player_one: PlayerStatus = world.read_model((game_model.player1, game_model.game, game_model.playlist));
            let mut player_two: PlayerStatus = world.read_model((game_model.player2, game_model.game, game_model.playlist));
            if player_one.status != QueueStatus::InGame(game_id) {
                player_one.status = QueueStatus::None;
                player_one.index = 0;
                world.write_model(@player_one);
                player_two.status = QueueStatus::None;
                player_two.index = 0;
                world.write_model(@player_two);
                return;
            }
            if player_two.status != QueueStatus::InGame(game_id) {
                player_one.status = QueueStatus::None;
                player_one.index = 0;
                world.write_model(@player_one);
                player_two.status = QueueStatus::None;
                player_two.index = 0;
                world.write_model(@player_two);
                return;
            }
            let mut player_one_elo: Elo = world.read_model((game_model.player1, game_model.game, game_model.playlist));
            let mut one_elo: u64 = player_one_elo.value;
            
            let mut player_two_elo: Elo = world.read_model((game_model.player2, game_model.game, game_model.playlist));
            let mut two_elo: u64 = player_two_elo.value;


            let (one_new, two_new) = update_elos(status, @game_model, @one_elo, @two_elo);

            player_one.status = QueueStatus::None;
            player_two.status = QueueStatus::None;
            player_one.index = 0;
            player_two.index = 0;
            player_one_elo.value = one_new;
            player_two_elo.value = two_new;

            world.write_model(@player_one_elo);
            world.write_model(@player_two_elo);
            world.write_model(@player_one);
            world.write_model(@player_two);
            
        }

        fn get_elo(self: @ContractState, address: ContractAddress, game: felt252, playlist: u128) -> u64 {
            let world = self.world(@"planetelo");
            let elo: Elo = world.read_model((address, game, playlist));
            elo.value
        }

        fn get_queue_length(self: @ContractState, game: felt252, playlist: u128) -> u128 {
            let world = self.world(@"planetelo");
            let queue: Queue = world.read_model((game, playlist));
            queue.length
        }

        fn get_status(self: @ContractState, address: ContractAddress, game: felt252, playlist: u128) -> u8 {
            let world = self.world(@"planetelo");
            let player: PlayerStatus = world.read_model((address, game, playlist));
            match player.status {
                QueueStatus::None => 0,
                
                QueueStatus::Queued => 1,
                QueueStatus::InGame(_) => 2,
            }
        }


        fn get_queue_members(self: @ContractState, game: felt252, playlist: u128) -> Array<QueueMember> {
            let world = self.world(@"planetelo");
            let queue: Queue = world.read_model((game, playlist));
            let mut members: Array<QueueMember> = get_queue_members(world, game, playlist);
            members
        }

        fn get_player_game_id(self: @ContractState, address: ContractAddress, game: felt252, playlist: u128) -> u128 {
            let world = self.world(@"planetelo");
            let player: PlayerStatus = world.read_model((address, game, playlist));
            match player.status {
                QueueStatus::InGame(id) => id,
                _ => panic!("Player is not in a game"),
            }        }

        fn end_game(ref self: ContractState, game: felt252, game_id: u128) {
            let caller = get_caller_address();
            assert!(
                caller == starknet::contract_address_const::<0x0737C189b6207e381111E316a0249e4A2bC8fAF0A0d322A85b2dEb7fc2ba427D>()
                , "Who do you think you are?");
            let mut world = self.world(@"planetelo");
            let mut game_model: Game = world.read_model((game, game_id));


            assert!(
                game_model.timestamp + 1000 < get_block_timestamp(), "Game has expired");
            let mut  player_one: PlayerStatus = world.read_model((game_model.player1, game, game_model.playlist));
            let mut player_two: PlayerStatus = world.read_model((game_model.player2, game, game_model.playlist));
            player_one.status = QueueStatus::None;
            player_two.status = QueueStatus::None;
            player_one.index = 0;
            player_two.index = 0;
            game_model.player1 = contract_address_const::<0x0>();
            game_model.player2 = contract_address_const::<0x0>();
            world.write_model(@player_one);
            world.write_model(@player_two);
            world.write_model(@game_model);
        }

    }
}