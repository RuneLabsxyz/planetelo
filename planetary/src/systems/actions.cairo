use starknet::ContractAddress;
use dojo::world::IWorldDispatcher;
use dojo::world::WorldStorageTrait;

// Interfaces

#[starknet::interface]
trait IPlanetaryActions<TState> {
    fn register(ref self: TState, name: felt252, world_address: ContractAddress);
    fn unregister(ref self: TState, name: felt252);
    fn get_world_address(self: @TState, name: felt252) -> Option<ContractAddress>;
    fn get_contract_address(self: @TState, world_name: felt252, namespace: ByteArray, contract_name: ByteArray) -> Option<ContractAddress>;
}

// Contracts

#[dojo::contract]
mod actions {
    use super::IPlanetaryActions;
    use starknet::ContractAddress;
    use planetary::models::planet::{
        Planet, PlanetTrait,
    };
    use dojo::model::{ModelStorage, ModelValueStorage, Model};
    use dojo::world::{WorldStorageTrait, IWorldDispatcher, WorldStorage};


    mod Errors {
        const PLANET_UNAVAILABLE: felt252 = 'PLANETARY: Unavailable';
    }

    #[abi(embed_v0)]
    impl ActionsImpl of super::IPlanetaryActions<ContractState> {
        fn register(ref self: ContractState, name: felt252, world_address: ContractAddress) {
            let mut world = self.world(@"planetary");
            let planet = Planet {
                name,
                world_address,
                is_available: true,
            };
            world.write_model(@planet);
        }

        fn unregister(ref self: ContractState, name: felt252) {
            let mut world = self.world(@"planetary");
            let mut planet: Planet = world.read_model(name);
            assert(planet.is_available == true, Errors::PLANET_UNAVAILABLE);
            planet.is_available = false;
            world.write_model(@planet);
        }

        fn get_world_address(self: @ContractState, name: felt252) -> Option<ContractAddress> {
            let world = self.world(@"planetary");
            let planet: Planet = world.read_model(name);
            if planet.is_available {
                (Option::Some(planet.world_address))
            }
            else {
                (Option::None)
            }
        }

        fn get_contract_address(self: @ContractState, world_name: felt252, namespace: ByteArray, contract_name: ByteArray) -> Option<ContractAddress> {
            let world = self.world(@"planetary");
            let planet: Planet = world.read_model(world_name);
            if planet.is_available {
                let world_storage = WorldStorageTrait::new(IWorldDispatcher {contract_address: planet.world_address}, 
                    @namespace);
                let contract_address = world_storage.dns_address(@contract_name);
                match contract_address {
                    Option::Some(address) => {
                        Option::Some(address)
                    },
                    Option::None => {
                        (Option::None)
                    }
                }
            }
            else {
                (Option::None)
            }
        }
    }

}
