// define the interface
#[dojo::interface]
trait IActions {
    fn pew(world: @IWorldDispatcher) -> felt252;
    fn live_long(world: @IWorldDispatcher) -> felt252;
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions};
    use starknet::{ContractAddress, get_caller_address};
    use planetary_interface::interfaces::planetary::{
        PlanetaryInterface, PlanetaryInterfaceTrait,
        IPlanetaryActionsDispatcher, IPlanetaryActionsDispatcherTrait,
    };

    use planetary_interface::interfaces::vulcan::{
        VulcanInterface, VulcanInterfaceTrait,        
        IVulcanSaluteDispatcher, IVulcanSaluteDispatcherTrait,

    };

    use planetary_interface::interfaces::octoguns::{
        OctogunsInterface, OctogunsInterfaceTrait,
        IOctogunsStartDispatcher, IOctogunsStartDispatcherTrait,
    };

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        

        fn pew(world: @IWorldDispatcher) -> felt252 {
            let dispatcher: IOctogunsStartDispatcher = OctogunsInterfaceTrait::new().start_dispatcher();
            dispatcher.pew()
        }

        fn live_long(world: @IWorldDispatcher) -> felt252 {
            let dispatcher: IVulcanSaluteDispatcher = VulcanInterfaceTrait::new().dispatcher();
            dispatcher.live_long()
        }
    }
}

