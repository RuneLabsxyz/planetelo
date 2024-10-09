// define the interface
#[dojo::interface]
trait IQueue {
    fn queue(world: @IWorldDispatcher, playlist: felt252);
    fn dequeue(world: @IWorldDispatcher, playlist: felt252);
}

// dojo decorator
#[dojo::contract]
mod queue {

    use super::{IQueue};
    use starknet::{ContractAddress, get_caller_address};
    use planetary_interface::interfaces::planetary::{
        PlanetaryInterface, PlanetaryInterfaceTrait,
        IPlanetaryActionsDispatcher, IPlanetaryActionsDispatcherTrait,
    };

    use planetary_interface::interfaces::octoguns::{
        OctogunsInterface, OctogunsInterfaceTrait,
        IOctogunsStartDispatcher, IOctogunsStartDispatcherTrait,
    };

    #[abi(embed_v0)]
    impl QueueImpl of IQueue<ContractState> {
        

        fn queue(world: @IWorldDispatcher, playlist: felt252) {
            let planetary: IPlanetaryActionsDispatcher = PlanetaryInterfaceTrait::new().dispatcher();
        }


        fn dequeue(world: @IWorldDispatcher, playlist: felt252) {
            let planetary: IPlanetaryActionsDispatcher = PlanetaryInterfaceTrait::new().dispatcher();
        }
    }
}

