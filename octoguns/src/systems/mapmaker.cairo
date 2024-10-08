use octoguns::types::MapObjects;

#[dojo::interface]
trait IMapmaker {
    fn create(ref world: IWorldDispatcher, objects: MapObjects);
    fn default_map(ref world: IWorldDispatcher);
}

#[dojo::contract]
mod mapmaker {
    use super::IMapmaker;
    use octoguns::models::map::{Map, MapTrait};
    use octoguns::models::global::{Global, GlobalTrait};
    use octoguns::consts::{GLOBAL_KEY};
    use octoguns::types::MapObjects;
    #[abi(embed_v0)]
    impl MapmakerImpl of IMapmaker<ContractState> {

        fn default_map(ref world: IWorldDispatcher) {
            let mut global = get!(world, GLOBAL_KEY, (Global));
            assert!(global.map_count == 0, "Map already exists");
            let map_id = 0;
            let row = 12 * 25;
            // some objects in the middle of the map with some gaps
            let objects: Array<u16> = array![row + 1, row+2, row+3, row+5, row+6, row+7, row+9, row+10, row+ 11, row + 13, row+14, row+15, row+17, row+18, row+19, row+21, row+22, row+ 23];
            let map = MapTrait::new(map_id, MapObjects { objects });
            global.map_count += 1;
            set!(world, (map, global));
        }

        fn create(ref world: IWorldDispatcher, objects: MapObjects) {
            let mut global = get!(world, GLOBAL_KEY, (Global));
            assert!(global.map_count != 0, "Must spawn default map first");
            let map_id = global.map_count;
            let map = MapTrait::new(map_id, objects);
            global.map_count += 1;
            set!(world, (map, global));
        }
    }
}