use octoguns::types::{TurnMove};
use octoguns::models::bullet::{Bullet, BulletTrait};

#[dojo::interface]
trait IActions {
    fn move(ref world: IWorldDispatcher, session_id: u32, moves: TurnMove);
}

#[dojo::contract]
mod actions {
    use super::IActions;
    use octoguns::types::{Vec2, IVec2, Shot, TurnMove};
    use octoguns::models::sessions::{Session, SessionMeta, SessionMetaTrait, SessionPrimitives};
    use octoguns::models::characters::{CharacterModel, CharacterPosition, CharacterPositionTrait};
    use octoguns::models::bullet::{Bullet, BulletTrait};
    use octoguns::models::map::{Map, MapTrait};
    use octoguns::models::turndata::{TurnData};
    use octoguns::lib::helpers::{get_all_bullets, filter_out_dead_characters, check_is_valid_move};
    use octoguns::lib::simulate::{simulate_bullets};
    use starknet::{ContractAddress, get_caller_address};
    use core::cmp::{max, min};


    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn move(ref world: IWorldDispatcher, session_id: u32, mut moves: TurnMove) {
            let session_primitives = get!(world, session_id, (SessionPrimitives));
            let max_steps = session_primitives.sub_moves_per_turn;

            assert!(moves.shots.len() <= session_primitives.bullets_per_turn, "Invalid number of shots");
            let player = get_caller_address();
            let mut session = get!(world, session_id, (Session));
            assert!(session.state != 1, "Game doesn't exist");
            assert!(session.state != 3, "Game over");
            assert!(session.state == 2, "Game not active");


            let mut session_meta = get!(world, session_id, (SessionMeta));
            let map = get!(world, session.map_id, (Map));

            let mut updated_bullet_ids = ArrayTrait::new();

            let session_primitives = get!(world, session_id, (SessionPrimitives));

            let mut player_character_id = 0;
            let mut opp_character_id = 0;

            match session_meta.turn_count % 2 {
                0 => {
                    assert!(player == session.player1, "not turn player, 1s turn");
                    player_character_id = session_meta.p1_character;
                    opp_character_id = session_meta.p2_character;
                },
                1 => {
                    assert!(player == session.player2, "not turn player, 2s turn");
                    player_character_id = session_meta.p2_character;
                    opp_character_id = session_meta.p1_character;
                },
                _ => { panic!("???"); }
            }

            let mut player_position = get!(world, player_character_id, (CharacterPosition));
            let mut opp_position = get!(world, opp_character_id, (CharacterPosition));
            let mut positions = array![player_position, opp_position];

            let mut bullets = get_all_bullets(world, session_id);

            //start out of bounds so never reached in loop if no shots

            let mut next_shot = max_steps + 1;
            if moves.shots.len() > 0 {
                next_shot = (*moves.shots.at(0)).step;
            }

            let mut sub_move_index = 0;

            while sub_move_index < max_steps {
                let step = sub_move_index + max_steps * session_meta.turn_count;

                if sub_move_index == next_shot.into() {
                    let shot = moves.shots.pop_front();
                    match shot {
                        Option::Some(s) => {
                            let bullet = BulletTrait::new(
                                world.uuid(),
                                Vec2 { x: player_position.coords.x, y: player_position.coords.y },
                                s.angle,
                                player_character_id,
                                step.try_into().unwrap(),
                                bullet_speed: session_primitives.bullet_speed,
                                bullet_sub_steps: session_primitives.bullet_sub_steps,
                            );
                            bullets.append(bullet);
                            println!("new bullet at index {}", sub_move_index);
                            set!(world, (bullet));

                            if moves.shots.len() > 0 {
                                next_shot = *moves.shots.at(0).step;
                            }
                        },
                        Option::None => { //shouldn't reach
                        }
                    }
                }

                //advance bullets + check collisions
                let (new_bullets, new_bullet_ids, dead_characters) = simulate_bullets(
                    ref bullets, ref positions, @map, step, session_primitives.bullet_sub_steps
                );
                bullets = new_bullets;
                updated_bullet_ids = new_bullet_ids;

                let (new_positions, mut filtered_character_ids) = filter_out_dead_characters(
                    ref positions, dead_characters
                );

                positions = new_positions;

                //get next sub_move
                if filtered_character_ids.len() < 2 {
                    match filtered_character_ids.len() {
                        0 => {
                            //draw
                            break;
                        },
                        1 => {
                            let winner = filtered_character_ids.pop_front().unwrap();
                            if session_meta.p1_character == winner {
                                //p1 wins
                                session.state = 3;
                                session_meta.p2_character = 0;
                            }
                            if session_meta.p2_character == winner {
                                //p2 wins
                                session.state = 3;
                                session_meta.p1_character = 0;
                            }
                            break;
                        },
                        _ => {}
                    }
                }

                match moves.sub_moves.pop_front() {
                    Option::Some(mut vec) => {
                        //check move valid
                        if !check_is_valid_move(vec, session_primitives.max_distance_per_sub_move) {
                            vec = IVec2 { x: 0, y: 0, xdir: true, ydir: true };
                        }
                        //apply move

                        if vec.xdir {
                            player_position
                                .coords
                                .x =
                                    min(
                                        100_000,
                                        player_position.coords.x + vec.x.try_into().unwrap()
                                    );
                        } else {
                            vec.x = min(vec.x, player_position.coords.x.into());
                            player_position.coords.x -= vec.x.try_into().unwrap();
                        }
                        if vec.ydir {
                            player_position
                                .coords
                                .y =
                                    min(
                                        100_000,
                                        player_position.coords.y + vec.y.try_into().unwrap()
                                    );
                        } else {
                            vec.y = min(vec.y, player_position.coords.y.into());
                            player_position.coords.y -= vec.y.try_into().unwrap();
                        }
                    },
                    Option::None => {}
                }
                positions = array![player_position, opp_position];

                sub_move_index += 1;
                //END MOVE LOOP
            };
            //set new positions
            loop {
                let next_position = positions.pop_front();
                match next_position {
                    Option::Some(pos) => {
                        println!("setting new positions: x: {} y: {}", pos.coords.x, pos.coords.y);
                        set!(world, (pos));
                    },
                    Option::None => { break; }
                }
            };

            println!("positions set");

            session_meta.turn_count += 1;
            session_meta.bullets = updated_bullet_ids;
            set!(world, (session, session_meta));
        }
    }
}
