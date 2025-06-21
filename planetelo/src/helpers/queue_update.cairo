use dojo::world::storage::{WorldStorage};
use planetelo::models::{QueueMember, Queue, QueueStatus};
use dojo::model::{ModelStorage, ModelValueStorage, Model};
use starknet::contract_address_const;


fn update_queue(ref world: WorldStorage, game: felt252, playlist: u128, ref p1: QueueMember, ref p2: QueueMember) {
    let mut queue: Queue = world.read_model((game, playlist));
    let last_index = queue.length - 1;
    let second_last_index = queue.length - 2;

    let p1_at_end = p1.index == last_index;
    let p1_at_second_last = p1.index == second_last_index;
    let p2_at_end = p2.index == last_index;
    let p2_at_second_last = p2.index == second_last_index;

    if (p1_at_end && p2_at_second_last) || (p2_at_end && p1_at_second_last) {
        world.erase_model(@p1);
        world.erase_model(@p2);
        queue.length -= 2;
        world.write_model(@queue);
        return;
    }

    let last_member: QueueMember = world.read_model((game, playlist, last_index));
    let second_last_member: QueueMember = world.read_model((game, playlist, second_last_index));

    if p1_at_end || p1_at_second_last {
        world.erase_model(@p1);
        if !p2_at_end && !p2_at_second_last {
            let swap_member = if p1_at_end { second_last_member } else { last_member };
            p2.player = swap_member.player;
            p2.elo = swap_member.elo;
            p2.timestamp = swap_member.timestamp;
            world.write_model(@p2);
            world.erase_model(@swap_member);
        }
    } else if p2_at_end || p2_at_second_last {
        world.erase_model(@p2);
        if !p1_at_end && !p1_at_second_last {
            let swap_member = if p2_at_end { second_last_member } else { last_member };
            p1.player = swap_member.player;
            p1.elo = swap_member.elo;
            p1.timestamp = swap_member.timestamp;
            world.write_model(@p1);
            world.erase_model(@swap_member);
        }
    } else {
        p1.player = last_member.player;
        p1.elo = last_member.elo;
        p1.timestamp = last_member.timestamp;
        
        p2.player = second_last_member.player;
        p2.elo = second_last_member.elo;
        p2.timestamp = second_last_member.timestamp;

        world.write_model(@p1);
        world.write_model(@p2);
        world.erase_model(@last_member);
        world.erase_model(@second_last_member);
    }

    queue.length -= 2;
    world.write_model(@queue);
}