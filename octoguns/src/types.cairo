
#[derive(Copy, Drop, Serde, Introspect)]
struct Vec2 {
    x: u64,
    y: u64,
} 

#[derive(Copy, Drop, Serde, Introspect)]
struct Shot {
    angle: u64, // 0 to 360
    step: u32,
}

#[derive(Clone, Drop, Serde, Introspect)]
struct TurnMove {
    sub_moves: Array<IVec2>,
    shots: Array<Shot>,
}

#[derive(Copy, Drop, Serde, Introspect)]
struct IVec2 {
    x: u64,
    y: u64,
    xdir: bool,
    ydir: bool
}

#[derive(Clone, Drop, Serde, Introspect)]
struct MapObjects {
    objects: Array<u16>,
}

#[derive(Clone, Drop, Serde, Introspect)]
pub struct Settings {
    pub bullet_speed: u64,
    pub bullet_sub_steps: u32,
    pub bullets_per_turn: u32,
    pub sub_moves_per_turn: u32,
    pub max_distance_per_sub_move: u32,
}


