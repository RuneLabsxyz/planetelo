use octoguns::models::bullet::{Bullet, BulletTrait};
use octoguns::types::{Vec2};
use octoguns::models::characters::{CharacterPosition, CharacterPositionTrait};
use alexandria_math::trigonometry::{fast_cos, fast_sin};
use octoguns::consts::{ONE_E_8, BULLET_SPEED, BULLET_SUBSTEPS};
use octoguns::models::map::{Map, MapTrait};

// Tuple to hold bullet_ids and character_ids to drop
pub type SimulationResult = (Array<Bullet>, Array<u32>, Array<u32>);

pub fn simulate_bullets(
    ref bullets: Array<Bullet>,
    ref character_positions: Array<CharacterPosition>,
    map: @Map,
    step: u32,
    bullet_sub_steps: u32
) -> SimulationResult {
    let mut updated_bullets = ArrayTrait::new();
    let mut updated_bullet_ids = ArrayTrait::new();
    let mut dead_characters_ids = ArrayTrait::new();
    loop {
        match bullets.pop_front() {
            Option::Some(mut bullet) => {
                let (hit_character, dropped) = bullet
                    .simulate(@character_positions, map, step, bullet_sub_steps);
                match hit_character {
                    Option::Some(character_id) => { dead_characters_ids.append(character_id); },
                    Option::None => {
                        if !dropped {
                            updated_bullets.append(bullet);
                            updated_bullet_ids.append(bullet.bullet_id);
                        } else {
                            println!("bullet {} dropped", bullet.bullet_id);
                        }
                    },
                }
            },
            Option::None => { break; },
        }
    };

    println!("bullets: {}", updated_bullets.len());

    (updated_bullets, updated_bullet_ids, dead_characters_ids)
}

#[cfg(test)]
mod simulate_tests {
    use octoguns::models::characters::{CharacterPosition, CharacterPositionTrait};
    use octoguns::models::bullet::{Bullet, BulletTrait};
    use octoguns::models::map::{Map, MapTrait};
    use octoguns::types::{Vec2};
    use octoguns::lib::default_spawns::{generate_character_positions};
    use octoguns::consts::{ONE_E_8, BULLET_SPEED, BULLET_SUBSTEPS, STEP_COUNT};
    use super::{simulate_bullets, SimulationResult};

    use octoguns::tests::helpers::{get_test_character_array};

    #[test]
    fn test_4_bullets_sim() {
        let address = starknet::contract_address_const::<0x0>();

        let map = MapTrait::new_empty(1);

        let bullet_1 = BulletTrait::new(1, Vec2 { x: 300, y: 0 }, 180 * ONE_E_8, 1, 0, BULLET_SPEED, BULLET_SUBSTEPS);
        let bullet_2 = BulletTrait::new(1, Vec2 { x: 300, y: 555 }, 100 * ONE_E_8, 2, 0, BULLET_SPEED, BULLET_SUBSTEPS);
        let bullet_3 = BulletTrait::new(1, Vec2 { x: 6, y: 1 }, 4 * ONE_E_8, 3, 0, BULLET_SPEED, BULLET_SUBSTEPS);
        let bullet_4 = BulletTrait::new(1, Vec2 { x: 3, y: 0 }, 90 * ONE_E_8, 4, 0, BULLET_SPEED, BULLET_SUBSTEPS);

        let mut characters = get_test_character_array();

        let mut bullets = array![bullet_1, bullet_2, bullet_3, bullet_4];
        let (updated_bullets, updated_bullet_ids, dead_characters_ids) = simulate_bullets(
            ref bullets, ref characters, @map, 1, BULLET_SUBSTEPS
        );
    }

    #[test]
    fn test_no_collisions() {
        let address = starknet::contract_address_const::<0x0>();

        let map = MapTrait::new_empty(1);

        let bullet = BulletTrait::new(1, Vec2 { x: 0, y: 0 }, 0, 63, 0, BULLET_SPEED, BULLET_SUBSTEPS);
        let mut bullets = array![bullet];
        let mut characters = array![
            CharacterPositionTrait::new(1, Vec2 { x: 0, y: 75000 }, STEP_COUNT),
            CharacterPositionTrait::new(2, Vec2 { x: 45800, y: 23400 }, STEP_COUNT)
        ];

        let (updated_bullets, updated_bullet_ids, dead_characters_ids) = simulate_bullets(
            ref bullets, ref characters, @map, 1, BULLET_SUBSTEPS
        );

        assert!(updated_bullets.len() == 1, "Bullet should not be removed");
        assert!(dead_characters_ids.is_empty(), "No characters should be hit");
    }

    #[test]
    fn test_multiple_collisions() {
        let address = starknet::contract_address_const::<0x0>();

        let map = MapTrait::new_empty(1);
        let mut bullets = array![];
        let mut characters = array![];

        let (updated_bullets, updated_bullet_ids, dead_characters_ids) = simulate_bullets(
            ref bullets, ref characters, @map, 1, BULLET_SUBSTEPS
        );
    }

    #[test]
    fn test_bullet_out_of_bounds() {
        let address = starknet::contract_address_const::<0x0>();

        let bullet = BulletTrait::new(1, Vec2 { x: 99999, y: 9950 }, 0, 1, 0, BULLET_SPEED, BULLET_SUBSTEPS);
        let map = MapTrait::new_empty(1);
        let mut bullets = array![bullet];
        let mut characters = array![CharacterPositionTrait::new(1, Vec2 { x: 0, y: 0 }, STEP_COUNT)];

        let (updated_bullets, updated_bullet_ids, dead_characters_ids) = simulate_bullets(
            ref bullets, ref characters, @map, 1, BULLET_SUBSTEPS
        );

        assert!(updated_bullets.is_empty(), "Bullet should be removed when out of bounds");
        assert!(dead_characters_ids.is_empty(), "No characters should be hit");
    }
}
