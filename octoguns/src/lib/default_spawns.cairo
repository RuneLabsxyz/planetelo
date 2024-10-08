use array::ArrayTrait;
use core::debug::PrintTrait;
use octoguns::types::{Vec2};


fn generate_character_positions(player_id: u8) -> Array<Vec2> {
    assert(player_id == 1 || player_id == 2, 'Invalid player ID');

    let mut positions = ArrayTrait::new();
    let is_player_one = player_id == 1;

    // Define the x-coordinate for each player
    let x = if is_player_one {
        20000 // Player one spawns at x = 20000
    } else {
        80000 // Player two spawns at x = 80000
    };

    let num_characters = 8;
    let mut count = 0;
    while count < num_characters {
        // Calculate y position, distributing characters from 200 to 10000
        let y = 20000 + (count * 14000); // (10000 - 200) / 7 ≈ 1400
        
        positions.append(Vec2 { x, y });
        count += 1;
    };

    positions
}