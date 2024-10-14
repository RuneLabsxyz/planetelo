// define the interface
#[dojo::interface]
trait IQueue {
    fn queue(world: @IWorldDispatcher, game: felt252, playlist: u128);
    fn dequeue(world: @IWorldDispatcher, game: felt252, playlist: u128);
    fn matchmake(world: @IWorldDispatcher, game: felt252, playlist: u128);
    fn settle(world: @IWorldDispatcher, game: felt252, game_id: u128);
}

// dojo decorator
#[dojo::contract]
mod queue {

    use super::{IQueue};
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp, contract_address_const};
    use planetary_interface::interfaces::planetary::{
        PlanetaryInterface, PlanetaryInterfaceTrait,
        IPlanetaryActionsDispatcher, IPlanetaryActionsDispatcherTrait,
    };

    use planetary_interface::interfaces::one_on_one::{
        IOneOnOneDispatcher, IOneOnOneDispatcherTrait, Status
    };

    use planetary_interface::utils::systems::{get_world_contract_address};

    use planetelo::models::{PlayerStatus, QueueStatus, Elo, QueueIndex, Game, Queue};
    use planetelo::elo::EloTrait;

    use planetelo::consts::ELO_DIFF;

    #[abi(embed_v0)]
    impl QueueImpl of IQueue<ContractState> {
        

        fn queue(world: @IWorldDispatcher, game: felt252, playlist: u128) {
            let address = get_caller_address();
            let mut player = get!(world, (address, game), PlayerStatus);
            let mut elo = get!(world, (address, game), Elo);
            if elo.value == 0 {
                elo.value = 800;
                set!(world, (elo));
            }

            assert!(player.status == QueueStatus::None, "Player is already in the queue");

            let mut queue = get!(world, playlist, Queue);
            
            let new = QueueIndex {
                game: game,
                playlist: playlist,
                index: queue.length,
                player: address,
                timestamp: get_block_timestamp(),
                elo: elo.value
            };

            queue.length += 1;
            player.status = QueueStatus::Queued;

            set!(world, (player, new, queue));
            
        }


        fn dequeue(world: @IWorldDispatcher, game: felt252, playlist: u128) {
            let address = get_caller_address();
            let mut player = get!(world, (address, game), PlayerStatus);

            assert!(player.status == QueueStatus::Queued, "Player is not in the queue");

            let mut queue = get!(world, (game, playlist), Queue);
            let mut index = get!(world, (game, playlist, player.index), QueueIndex);
            let mut last_index = get!(world, (game, playlist, queue.length - 1), QueueIndex);

            index.player = last_index.player;
            index.index = last_index.index;
            index.timestamp = last_index.timestamp;
            index.elo = last_index.elo;

            queue.length -= 1;
            player.status = QueueStatus::None;

            delete!(world, (last_index));
            set!(world, (player, index, queue));
        }

        fn matchmake(world: @IWorldDispatcher, game: felt252, playlist: u128) {
            let address = get_caller_address();
            let mut player_status = get!(world, (address, game, playlist), PlayerStatus);

            assert!(player_status.status != QueueStatus::None, "Player is not in the queue");
            let timestamp = get_block_timestamp();

            let mut player_index = get!(world, (game, playlist, player_status.index), QueueIndex);
            let time_diff = timestamp - player_index.timestamp;
            let time_diff_secs = time_diff / 1000;
            assert!(time_diff_secs > 30, "Must be in queue for at least 30 seconds to refresh");

            let queue = get!(world, (game, playlist), Queue);
            let mut potential_index = player_index;
            let mut i = 0;
            let mut found = false;
            while i < queue.length {
                let potential_index = get!(world, (game, playlist, i), QueueIndex);
                if potential_index.elo > player_index.elo {
                    if potential_index.elo - player_index.elo > ELO_DIFF {
                        i+=1;
                        continue;
                    }
                    else {
                        found = true;
                        break;
                    }
                } 
                else {
                    if player_index.elo - potential_index.elo > ELO_DIFF {
                        i+=1;
                        continue;
                    }
                    else {
                        found = true;
                        break;
                    }
                }
            };

            assert!(found, "No match found");

            let planetary: IPlanetaryActionsDispatcher = PlanetaryInterfaceTrait::new().dispatcher();
            let contract_address = get_world_contract_address(IWorldDispatcher {contract_address: planetary.get_world_address(game)}, selector_from_tag!("planetelo-planetelo"));
            
            let dispatcher = IOneOnOneDispatcher{ contract_address };

            let game_id = dispatcher.create_match(player_index.player, potential_index.player, playlist);

            player_status.status = QueueStatus::InGame(game_id);

            let mut potential_status = get!(world, (potential_index.player, game, playlist), PlayerStatus);
            potential_status.status = QueueStatus::InGame(game_id);

            let game = Game {
                game: game,
                id: game_id,
                playlist: playlist,
                player1: player_index.player,
                player2: potential_index.player,
                timestamp: timestamp
            };

            let mut last_player = get!(world, (game, playlist, queue.length - 1), QueueIndex);
            let mut second_last_player = get!(world, (game, playlist, queue.length - 2), QueueIndex);
            let mut replacing = QueueIndex { player: contract_address_const::<0x0>(), elo: 0, timestamp: 0, index: 0, game: 0, playlist: 0 };

            //if both are not in the last two positions, move last 2 positions to their spots and delelete the last 2 positions
            if player_index.index < queue.length - 2 && potential_index.index < queue.length - 2 {

                player_index.player = last_player.player;
                player_index.elo = last_player.elo;
                player_index.timestamp = last_player.timestamp;

                last_player.player = contract_address_const::<0x0>();
                last_player.elo = 0;
                last_player.timestamp = 0;

                potential_index.player = second_last_player.player;
                potential_index.elo = second_last_player.elo;
                potential_index.timestamp = second_last_player.timestamp;

                second_last_player.player = contract_address_const::<0x0>();
                second_last_player.elo = 0;
                second_last_player.timestamp = 0;

                set!(world, (last_player, second_last_player, player_index, potential_index));
                
            }

            //if one is in the last two positions, move that player to the spot of the player who is in game and delete the last position
            else if player_index.index < queue.length - 2 {
                if potential_index.index == queue.length - 2 {
                    let mut replacing = last_player;
                }
                else if potential_index.index == queue.length - 1 {
                    let mut replacing = second_last_player;
                }

                

                player_index.player = replacing.player;
                player_index.elo = replacing.elo;
                player_index.timestamp = replacing.timestamp;
                set!(world, (player_index));
                delete!(world, (replacing, potential_index));
            }

            else if potential_index.index < queue.length - 2 {
                if player_index.index == queue.length - 2 {
                    let mut replacing = last_player;
                }
                else if player_index.index == queue.length - 1 {
                    let mut replacing = second_last_player;
                }

                potential_index.player = replacing.player;
                potential_index.elo = replacing.elo;
                potential_index.timestamp = replacing.timestamp;
                set!(world, (potential_index));
                delete!(world, (replacing, player_index));
            }

            else {
                delete!(world, (player_index, potential_index));
            }


            
            set!(world, (player_status, potential_status, game));

            

        }

        fn settle(world: @IWorldDispatcher, game: felt252, game_id: u128) {

            let mut game_model = get!(world, (game, game_id), Game);


            let planetary: IPlanetaryActionsDispatcher = PlanetaryInterfaceTrait::new().dispatcher();
            let contract_address = get_world_contract_address(IWorldDispatcher {contract_address: planetary.get_world_address(game)}, selector_from_tag!("planetelo-planetelo"));
            
            let dispatcher = IOneOnOneDispatcher{ contract_address };

            let status = dispatcher.settle_match(game_id);
            
            let mut player_one = get!(world, (game_model.player1, game_model.game, game_model.playlist), PlayerStatus);
            let mut player_two = get!(world, (game_model.player2, game_model.game, game_model.playlist), PlayerStatus);
            let mut player_one_elo = get!(world, (game_model.player1, game_model.game, game_model.playlist), Elo);
            let one_elo: u64 = player_one_elo.value;
            let mut player_two_elo = get!(world, (game_model.player2, game_model.game, game_model.playlist), Elo);
            let two_elo: u64 = player_two_elo.value;

            let (mag, sign) = EloTrait::rating_change(800_u64, 800_u64, 50_u16, 20_u8);


            match status {
                Status::None => {
                    panic!("Match has doesn't exist");
                },
                Status::Active => {
                    panic!("Match is still active");
                },
                Status::Draw => {

                    let (mag, sign) = EloTrait::rating_change(one_elo, two_elo, 50_u16, 20_u8);


                    if sign {
                        player_one_elo.value += mag;
                        player_two_elo.value -= mag;
                    }
                    else {
                        player_one_elo.value -= mag;
                        player_two_elo.value += mag;
                    }
                    

                    player_one.status = QueueStatus::None;
                    player_two.status = QueueStatus::None;

                    set!(world, (player_one, player_two, player_one_elo, player_two_elo));
                },
                Status::Winner(winner) => {

                    let mut did_win: u16 = 0;

                    if winner == game_model.player1 {
                        did_win = 100;
                    }

                    let (mag, sign) = EloTrait::rating_change(one_elo, two_elo, did_win, 20_u8);

                    if sign {
                        player_one_elo.value += mag;
                        player_two_elo.value -= mag;
                    }
                    else {
                        player_one_elo.value -= mag;
                        player_two_elo.value += mag;
                    }
                    
                    player_one.status = QueueStatus::None;
                    player_two.status = QueueStatus::None;

                    set!(world, (player_one, player_two, player_one_elo, player_two_elo));
                }
            }
            
            
        }


    }
}
