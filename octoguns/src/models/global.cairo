#[derive(Drop, Serde)]
#[dojo::model]
pub struct Global{
    #[key]
    id: u32,
    pending_sessions: Array<u32>,
    map_count: u32
}

#[generate_trait]
impl GlobalImpl of GlobalTrait {
    fn create_session(ref self: Global, id: u32) {
        self.pending_sessions.append(id);
    } 

    fn remove_session(ref self: Global, id: u32) {
        let mut new_sessions = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == self.pending_sessions.len() {
                break;
            }
            if *self.pending_sessions.at(i) != id {
                new_sessions.append(*self.pending_sessions.at(i));
            }
            i += 1;
        };
        self.pending_sessions = new_sessions;
    } 
}