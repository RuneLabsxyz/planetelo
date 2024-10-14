// define the interface
#[dojo::interface]
trait IQueue {
    fn queue(world: @IWorldDispatcher, game: felt252, playlist: u128);
    fn dequeue(world: @IWorldDispatcher, game: felt252, playlist: u128);
    fn refresh(world: @IWorldDispatcher, game: felt252, playlist: u128);
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
        IOneOnOneDispatcher, IOneOnOneDispatcherTrait,
    };

    use planetary_interface::utils::systems::{get_world_contract_address};

    use planetelo::models::elo::{Status, QueueStatus, Elo};

    #[abi(embed_v0)]
    impl QueueImpl of IQueue<ContractState> {
        

        fn queue(world: @IWorldDispatcher, game: felt252, playlist: u128) {
            let address = get_caller_address();
            let player = get!(world, (address, game), Status);

            assert!(player.status == QueueStatus::None, error("Player is already in the queue"));

            let mut queue = get!(world, playlist, Queue);
            
            let new = QueueIndex {
                game: playlist,
                index: queue.length,
                player: address,
                timestamp: get_block_timestamp()
            };

            queue.length += 1;
            player.status = QueueStatus::Queued;

            set!(world, (player, new, queue));
            
        }


        fn dequeue(world: @IWorldDispatcher, game: felt252, playlist: u128) {
            let address = get_caller_address();
            let player = get!(world, (address, game), Status);

            assert!(player.status == QueueStatus::Queued, error("Player is not in the queue"));

            let mut queue = get!(world, (game, playlist), Queue);
            let mut index = get!(world, (game, playlist, player.index), QueueIndex);
            let mut last_index = get!(world, (game, playlist, queue.length - 1), QueueIndex);

            index.player = last_index.player;
            index.index = last_index.index;
            index.timestamp = last_index.timestamp;

            queue.length -= 1;
            player.status = QueueStatus::None;

            delete!(world, last_index);
            set!(world, (player, index, queue));
        }

        fn refresh(world: @IWorldDispatcher, game: felt252, playlist: u128) {
            let address = get_caller_address();
            let status = get!(world, (address, game, playlist), Status);
            assert!(status.status != QueueStatus::None, error("Player is not in the queue"));


            let planetary: IPlanetaryActionsDispatcher = PlanetaryInterfaceTrait::new().dispatcher();
            let contract_address = get_world_contract_address(planetary.get_world_address(status.game), selector_from_tag!("planetelo-planetelo"));
            
            let dispatcher = IOneOnOneDispatcher{ contract_address };
        }


    }
}

``