#[cfg(test)]
mod tests {
    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use dojo::model::{Model, ModelTest, ModelIndex, ModelEntityTest};
    // import test utils
    use dojo::utils::test::{spawn_test_world, deploy_contract};
    use starknet::testing::{set_contract_address};
    use starknet::{ContractAddress, contract_address_const};
    // import test utils
    use octoguns::models::characters::{CharacterModel, CharacterPosition, CharacterPositionTrait, character_model, character_position};
    use octoguns::models::map::{Map, MapTrait, map};
    use octoguns::models::sessions::{Session, session, SessionMeta, session_meta};
    use octoguns::models::bullet::{Bullet, bullet, BulletTrait};
    use octoguns::models::global::{Global, global};
    use octoguns::types::{TurnMove, Vec2, IVec2, Shot};
    use octoguns::consts::{TEN_E_8, GLOBAL_KEY};
    use octoguns::systems::start::{start, IStartDispatcher, IStartDispatcherTrait}; 
    use octoguns::systems::actions::{actions, IActionsDispatcher, IActionsDispatcherTrait};
    use octoguns::systems::spawn::{spawn, ISpawnDispatcher, ISpawnDispatcherTrait};
    use octoguns::systems::mapmaker::{mapmaker, IMapmakerDispatcher, IMapmakerDispatcherTrait};

    fn setup() -> ( IWorldDispatcher, 
                    IStartDispatcher, 
                    IActionsDispatcher,
                    ISpawnDispatcher,
                    IMapmakerDispatcher) {

        let world = spawn_test_world!(["octoguns"]);


        // deploy systems contract
        let actions_address = world
            .deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap());
        let spawn_address = world
            .deploy_contract('m', spawn::TEST_CLASS_HASH.try_into().unwrap());
        let start_address = world
            .deploy_contract('b', start::TEST_CLASS_HASH.try_into().unwrap());
        let mapmaker_address = world
            .deploy_contract('m', mapmaker::TEST_CLASS_HASH.try_into().unwrap());

        let actions_system = IActionsDispatcher { contract_address: actions_address };
        let spawn_system = ISpawnDispatcher { contract_address: spawn_address };
        let start_system = IStartDispatcher { contract_address: start_address };
        let mapmaker_system = IMapmakerDispatcher { contract_address: mapmaker_address };

        world.grant_writer(dojo::utils::bytearray_hash(@"octoguns"), actions_address);
        world.grant_writer(dojo::utils::bytearray_hash(@"octoguns"), spawn_address);
        world.grant_writer(dojo::utils::bytearray_hash(@"octoguns"), start_address);
        world.grant_writer(dojo::utils::bytearray_hash(@"octoguns"), mapmaker_address);

        mapmaker_system.default_map();

        (world, start_system, actions_system, spawn_system, mapmaker_system)
    }

    fn setup_game(start_system: IStartDispatcher, spawn_system: ISpawnDispatcher, p1: ContractAddress, p2: ContractAddress) -> u32 {
        set_contract_address(p1);
        let session_id = start_system.create(0);
        set_contract_address(p2);
        start_system.join(session_id);
        spawn_system.spawn(session_id);
        session_id
    }

    #[test]
    fn test_setup() {
        let (world, _, _, _, _) = setup();
    }

    #[test]
    fn test_game_setup() {
        let (world, start, _, spawn, _) = setup();
        let player1: ContractAddress = contract_address_const::<0x01>();
        let player2: ContractAddress = contract_address_const::<0x02>();
        let session_id = setup_game(start, spawn, player1, player2);
        let session = get!(world, session_id, (Session));
        assert_eq!(session.player1, player1, "p1 is not set");
        assert_eq!(session.player2, player2, "p2 is not set");

    }

    #[test]
    fn test_move() {
        let (world, start, actions, spawn, _) = setup();
        let player1: ContractAddress = contract_address_const::<0x01>();
        let player2: ContractAddress = contract_address_const::<0x02>();
        let session_id = setup_game(start, spawn, player1, player2);
        let session = get!(world, session_id, (Session));
        let session_meta = get!(world, session_id, (SessionMeta));
        let position = get!(world, session.player1, (CharacterPosition));
        set_contract_address(player1);
        let shots = ArrayTrait::new();
        let mut sub_moves = ArrayTrait::new();
        let mut i: u32 = 0;
        while i < 100 {
            sub_moves.append(IVec2 {x: 100, y: 0, xdir: true, ydir: true});
            i+=1;
        };
        actions.move(session_id, TurnMove {sub_moves, shots});
        let new_position = get!(world, position.id, (CharacterPosition));
        let new_coords = Vec2 {x: position.coords.x + 10000, y: position.coords.y};
        assert_eq!(new_position.coords.x, new_coords.x, "character did not move");

    }

    #[test]
    fn test_hit_self() {
        let (world, start, actions, spawn, _) = setup();
        let player1: ContractAddress = contract_address_const::<0x01>();
        let player2: ContractAddress = contract_address_const::<0x02>();

        let session_id = setup_game(start, spawn, player1, player2);

        let session = get!(world, session_id, (Session));
        let session_meta = get!(world, session_id, (SessionMeta));
    
        set_contract_address(player1);
        let mut shots = ArrayTrait::new();
        let mut sub_moves = ArrayTrait::new();
        let mut i: u32 = 0;
        while i < 100 {
            sub_moves.append(IVec2 {x: 100, y: 0, xdir: true, ydir: true});
            i+=1;
        };
        shots.append(Shot {angle: 0, step: 0});
        actions.move(session_id, TurnMove {sub_moves, shots});
        let session = get!(world, session_id, (Session));
        assert!(session.state == 2, "Game should not have ended");
    
    }

    #[test]
    fn test_collision_in_move() {
        let (world, start, actions, spawn, _) = setup();
        let player1: ContractAddress = contract_address_const::<0x01>();
        let player2: ContractAddress = contract_address_const::<0x02>();

        let session_id = setup_game(start, spawn, player1, player2);

        let session = get!(world, session_id, (Session));
        let session_meta = get!(world, session_id, (SessionMeta));

        set_contract_address(player1);
        let mut shots = ArrayTrait::new();
        let mut sub_moves = ArrayTrait::new();
        let mut i: u32 = 0;
        while i < 100 {
            sub_moves.append(IVec2 {x: 0, y: 0, xdir: true, ydir: true});
            i+=1;
        };

        shots.append(Shot {angle: 90 * TEN_E_8, step: 0});
        actions.move(session_id, TurnMove {sub_moves, shots});
        // bullet travels 25000 units per turn, so it should take 3 turns to hit 
        let session_meta = get!(world, session_id, (SessionMeta));
        let mut bullet_id = 0;
        if session_meta.bullets.len() > 0 {
            bullet_id = *session_meta.bullets.at(0);
        }
        else {
            println!("no bullet");
        }
        let bullet = get!(world, bullet_id, (Bullet));
        println!("turn: {}", session_meta.turn_count);
        println!("bullet x: {}, bullet y: {}", bullet.coords.x, bullet.coords.y);

        set_contract_address(player2);
        actions.move(session_id, TurnMove {sub_moves: ArrayTrait::new(), shots: ArrayTrait::new()});
        let bullet = get!(world, bullet_id, (Bullet));
        println!("turn: {}", session_meta.turn_count);
        println!("bullet x: {}, bullet y: {}", bullet.coords.x, bullet.coords.y);

        set_contract_address(player1);
        actions.move(session_id, TurnMove {sub_moves: ArrayTrait::new(), shots: ArrayTrait::new()});
        let bullet = get!(world, bullet_id, (Bullet));
        println!("turn: {}", session_meta.turn_count);
        println!("bullet x: {}, bullet y: {}", bullet.coords.x, bullet.coords.y);

        let session = get!(world, session_id, (Session));
        assert!(session.state == 3, "Game should have ended");

    }
}