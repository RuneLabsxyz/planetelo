use octoguns::types::Vec2;
use starknet::ContractAddress;
use octoguns::types::MapObjects;

#[derive(Clone, Drop, Serde)]
#[dojo::model]
pub struct Map {
    #[key]
    pub map_id: u32,
    pub map_objects: Array<u16>,
}

#[generate_trait]
impl MapImpl of MapTrait {
    fn new(map_id: u32, map_objects: MapObjects) -> Map {
        Map {map_id, map_objects: map_objects.objects}
    }

    fn new_empty(map_id: u32) -> Map {
        Map {map_id, map_objects: ArrayTrait::new()}
    }

    // Returns the bounds of the object in the map.
    // (x_min, x_max, y_min, y_max)
    fn get_object_bounds(self: @Map, index: u8) -> (u32, u32, u32, u32) {
        assert!(index.into() < self.map_objects.len(), "Index out of bounds");
        let object = *self.map_objects.at(index.into());
        let x_index = object % 25;
        let y_index = object / 25;
        let x_pos: u32 = x_index.into() * 4000 + 2000;
        let y_pos: u32 = y_index.into() * 4000 + 2000;
        (x_pos - 2000, x_pos + 2000, y_pos - 2000, y_pos + 2000)
    }
}

