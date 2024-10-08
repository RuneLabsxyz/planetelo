use octoguns::types::{TurnMove};

#[derive(Clone, Drop, Serde)]
#[dojo::model]
struct TurnData{
    #[key]
    session_id: u32,
    #[key]
    turn_number: u32,
    moves: TurnMove,
}