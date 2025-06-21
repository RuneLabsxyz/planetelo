use starknet::{ContractAddress, ClassHash, contract_address_const};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, Resource};
use dojo::world::storage::{WorldStorage, WorldStorageTrait};

use planetelo_interface::interfaces::planetary::{
    PlanetaryInterface, PlanetaryInterfaceTrait,
    IPlanetaryActionsDispatcher, IPlanetaryActionsDispatcherTrait,
};

// for planetary interface
#[derive(Drop, Serde)]
pub struct SessionMeta {
    pub session_id: u32,
    pub turn_count: u32, // mod 2 = 1 is player 2 and mod 2 = 0 is player 1
    pub p1_character: u32,
    pub p2_character: u32,
    pub bullets: Array<u32>,
}


#[derive(Copy, Drop, Serde, Introspect)]
pub struct Settings {
    pub bullet_speed: u64,
    pub bullet_steps: u32,
    pub bullets: u32,
    pub sub_moves: u32,
    pub sub_move_distance: u32,
    pub characters: u64,
    pub actions: u64
}

#[derive(Copy, Drop, Serde, Introspect)]
struct Shot {
    angle: u64, // 0 to 360
    step: u32,
}

#[derive(Clone, Drop, Serde, Introspect)]
struct Action {
    characters: Array<u32>,
    sub_moves: Array<IVec2>,
    shots: Array<Shot>,
}

#[derive(Drop, Serde, Clone, Introspect)]
struct TurnMove {
    actions: Array<Action>,
}

#[derive(Copy, Drop, Serde, Introspect)]
struct IVec2 {
    x: u64,
    y: u64,
    xdir: bool,
    ydir: bool
}

#[starknet::interface]
trait IOctogunsStart<TState> {

    fn create(ref self: TState, map_id: u32, settings: Settings) -> u32;
    fn create_closed(
        ref self: TState,
        map_id: u32,
        player_address_1: ContractAddress,
        player_address_2: ContractAddress,
        settings: Settings
    ) -> u32;
    fn join(ref self: TState, session_id: u32);
    fn pew(ref self: TState) -> felt252;
}

#[starknet::interface]
trait IOctogunsSpawn<TState> {
    fn spawn(ref self: TState, session_id: u32);
}

#[starknet::interface]
trait IOctogunsActions<TState> {
    fn move(ref self: TState, session_id: u32, moves: TurnMove);
}

struct OctogunsInterface {
    world: WorldStorage
}

#[generate_trait]
impl OctogunsImpl of OctogunsTrait {
    
    fn new(contract_address: ContractAddress) -> WorldStorage {
        WorldStorage { dispatcher: IWorldDispatcher { contract_address }, namespace_hash: 'octoguns'}
    }

    fn actions_dispatcher(self: OctogunsInterface) -> IOctogunsActionsDispatcher {
        let (contract_address, _) = self.world.dns(@"actions").unwrap();
        (IOctogunsActionsDispatcher{contract_address})
    }
    fn start_dispatcher(self: OctogunsInterface) -> IOctogunsStartDispatcher {
        let (contract_address, _) = self.world.dns(@"start").unwrap();
        (IOctogunsStartDispatcher{contract_address})
    }
    fn spawn_dispatcher(self: OctogunsInterface) -> IOctogunsSpawnDispatcher {
        let (contract_address, _) = self.world.dns(@"spawn").unwrap();
        (IOctogunsSpawnDispatcher{contract_address})
    }
}