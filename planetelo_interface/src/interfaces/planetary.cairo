use starknet::{ContractAddress, ClassHash, contract_address_const};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, Resource, WorldStorage, WorldStorageTrait};

#[starknet::interface]
trait IPlanetaryActions<TState> {
    fn register(ref self: TState, name: felt252, world_address: ContractAddress);
    fn unregister(ref self: TState, name: felt252);
    fn get_world_address(self: @TState, name: felt252) -> Option<ContractAddress>;
}

#[derive(Copy, Drop)]
struct PlanetaryInterface {
    world: WorldStorage
}

#[generate_trait]
impl PlanetaryInterfaceImpl of PlanetaryInterfaceTrait {

    fn WORLD_CONTRACT() -> ContractAddress {
        (starknet::contract_address_const::<0x37ef49590c2e6a1d385029c45b8ee5f1ec62bac99d43ec25985bfcf62831a1f>())
    }
    //
    // create a new interface
    fn new() -> PlanetaryInterface {
        (PlanetaryInterface{ 
            world: WorldStorageTrait::new(IWorldDispatcher{contract_address: Self::WORLD_CONTRACT()}, @"planetary")
        })
    }
    fn new_custom(world_address: ContractAddress) -> PlanetaryInterface {
        (PlanetaryInterface{ 
            world: WorldStorageTrait::new(IWorldDispatcher{contract_address: world_address}, @"planetary")
        })
    }

    //
    // dispatchers
    fn dispatcher(self: PlanetaryInterface) -> IPlanetaryActionsDispatcher {
        let planetary = Self::new();
        let actions_address = planetary.world.dns_address(@"actions");
        match actions_address {
            Option::Some(address) => {
                (IPlanetaryActionsDispatcher{
                    contract_address: address
                })
            },
            Option::None => {
                panic!("Actions contract not found");
                (IPlanetaryActionsDispatcher{
                    contract_address: starknet::contract_address_const::<0x0>()
                })
            }
        }
    }

}