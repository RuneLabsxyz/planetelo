use starknet::{ContractAddress, get_caller_address};
use octoguns::models::sessions::{
    Session, SessionTrait, SessionMeta, SessionMetaTrait, SessionPrimitives,
};
#[dojo::interface]
trait IStart {
    fn create(ref world: IWorldDispatcher, map_id: u32, session_primitives: SessionPrimitives) -> u32;
    fn create_closed(
        ref world: IWorldDispatcher,
        map_id: u32,
        player_address_1: ContractAddress,
        player_address_2: ContractAddress,
        session_primitives: SessionPrimitives
    );
    fn join(ref world: IWorldDispatcher, session_id: u32);
}

#[dojo::contract]
mod start {
    use super::IStart;
    use octoguns::models::sessions::{
        Session, SessionTrait, SessionMeta, SessionMetaTrait, SessionPrimitives,
        SessionPrimitivesTrait
    };
    use starknet::{ContractAddress, get_caller_address};
    use octoguns::models::global::{Global, GlobalTrait};
    use octoguns::consts::GLOBAL_KEY;
    use octoguns::models::player::{Player};

    #[abi(embed_v0)]
    impl StartImpl of IStart<ContractState> {
        fn create(ref world: IWorldDispatcher, map_id: u32, session_primitives: SessionPrimitives) -> u32 {
            let mut global = get!(world, GLOBAL_KEY, (Global));
            // Do shit
            let address = get_caller_address();
            let mut player = get!(world, address, (Player));
            let id = world.uuid();
            global.create_session(id);
            player.games.append(id);

            let session = SessionTrait::new(id, address, map_id);
            let session_meta = SessionMetaTrait::new(id);
            let session_primitives = SessionPrimitivesTrait::new_from(id, session_primitives);

            set!(world, (session, session_meta, global, player, session_primitives));
            id
        }

        fn create_closed(
            ref world: IWorldDispatcher,
            map_id: u32,
            player_address_1: ContractAddress,
            player_address_2: ContractAddress,
            session_primitives: SessionPrimitives
        ) {
            let mut player_1 = get!(world, player_address_1, (Player));
            let mut player_2 = get!(world, player_address_2, (Player));
            let id = world.uuid();
            player_1.games.append(id);
            player_2.games.append(id);

            let session = SessionTrait::new_closed(id, player_address_1, player_address_2, map_id);
            let session_meta = SessionMetaTrait::new(id);
            let session_primitives = SessionPrimitivesTrait::new_from(
                id,
                session_primitives
            );
            set!(world, (session, session_meta, player_1, player_2, session_primitives));
        }

        fn join(ref world: IWorldDispatcher, session_id: u32) {
            let mut global = get!(world, GLOBAL_KEY, (Global));
            let address = get_caller_address();
            let mut session = get!(world, session_id, (Session));
            let mut player = get!(world, address, (Player));

            assert!(session.state == 0, "already started session");

            assert!(session.player1 != address, "can't join own session");
            global.remove_session(session_id);
            session.join(address);
            player.games.append(session.session_id);

            set!(world, (session, player, global));
        }
    }
}
