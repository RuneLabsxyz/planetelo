use octoguns::lib::default_spawns::generate_character_positions;
use octoguns::models::characters::{CharacterPosition, CharacterPositionTrait};


fn get_test_character_array() -> Array<CharacterPosition>{
    let positions = generate_character_positions(1);
    let mut index = 0;
    let mut res = ArrayTrait::new();
    while index < positions.len() {
        let position = *positions.at(index);
        res.append(CharacterPositionTrait::new(index, position));
        index +=1;
    };
    res
}



