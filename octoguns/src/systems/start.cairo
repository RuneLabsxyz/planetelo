#[dojo::interface]
trait IStart {
    fn create(ref world: IWorldDispatcher, map_id: u32) -> u32;
    fn join(ref world: IWorldDispatcher, session_id: u32);
}

#[dojo::contract]
mod start {
    use super::IStart;
    use octoguns::models::sessions::{Session, SessionTrait, SessionMeta, SessionMetaTrait};
    use starknet::{ContractAddress, get_caller_address};
    use octoguns::models::global::{Global, GlobalTrait};
    use octoguns::consts::GLOBAL_KEY;
    use octoguns::models::player::{Player};

    #[abi(embed_v0)]
    impl StartImpl of IStart<ContractState> {
        fn create(ref world: IWorldDispatcher, map_id: u32) -> u32 {
            let mut global = get!(world, GLOBAL_KEY, (Global));
            // Do shit
            let address = get_caller_address();
            let mut player = get!(world, address, (Player));
            let id = world.uuid();
            global.create_session(id);
            player.games.append(id);

            let session = SessionTrait::new(id, address, map_id);
            let session_meta = SessionMetaTrait::new(id);
            set!(world, (session, session_meta, global, player));
            id
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